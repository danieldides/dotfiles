---
name: test-provider-talos
description: |
  A local-first workflow to functionally test provider-talos changes
metadata:
  author: Daniel Dides
  version: "1.0"
---


# Test Provider Talos Locally

Use this workflow to smoke-test provider-talos changes locally with Docker, kind, kubectl, and the provider running out-of-cluster.

## Tools

- Docker Desktop or another working Docker daemon
- `kind`
- `kubectl`
- Go toolchain

## Workflow

1. Create an isolated kind cluster.

```sh
kind create cluster --name provider-talos-smoke
kind get kubeconfig --name provider-talos-smoke > /tmp/provider-talos-smoke.kubeconfig
```

2. Install provider CRDs from the repo checkout.

```sh
kubectl --context kind-provider-talos-smoke apply -R -f package/crds
kubectl --context kind-provider-talos-smoke wait --for=condition=Established crd/configurations.machine.talos.crossplane.io --timeout=60s
kubectl --context kind-provider-talos-smoke wait --for=condition=Established crd/secrets.machine.talos.crossplane.io --timeout=60s
```

3. Make sure local port `8080` is free before running the provider. The out-of-cluster provider metrics server binds to `:8080`.

```sh
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

If the listener is another local provider test process and it is safe to stop it:

```sh
kill <pid>
```

4. Run the provider externally against the kind cluster.

```sh
KUBECONFIG=/tmp/provider-talos-smoke.kubeconfig go run cmd/provider/main.go --debug --poll=5s
```

For a non-blocking run, capture logs and PID:

```sh
nohup env KUBECONFIG=/tmp/provider-talos-smoke.kubeconfig go run cmd/provider/main.go --debug --poll=5s > /tmp/provider-talos-smoke.log 2>&1 &
printf '%s' "$!" > /tmp/provider-talos-smoke.pid
```

5. Apply minimal smoke-test resources.

```sh
kubectl --context kind-provider-talos-smoke apply -f - <<'EOF'
apiVersion: talos.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: None
---
apiVersion: machine.talos.crossplane.io/v1alpha1
kind: Secrets
metadata:
  name: smoke-machine-secrets
spec:
  forProvider: {}
  providerConfigRef:
    name: default
  writeConnectionSecretToRef:
    name: smoke-machine-secrets
    namespace: default
---
apiVersion: machine.talos.crossplane.io/v1alpha1
kind: Configuration
metadata:
  name: smoke-worker-config
spec:
  forProvider:
    node: 10.0.0.2
    clusterName: smoke-cluster
    machineType: worker
    clusterEndpoint: https://10.0.0.1:6443
    machineSecretsRef:
      name: smoke-machine-secrets
    kubernetesVersion: v1.32.1
    configPatches:
      - |
        machine:
          nodeLabels:
            environment: kind-smoke
  providerConfigRef:
    name: default
  writeConnectionSecretToRef:
    name: smoke-worker-config
    namespace: default
EOF
```

6. Wait for both managed resources to become Ready.

```sh
kubectl --context kind-provider-talos-smoke wait --for=condition=Ready secrets.machine.talos.crossplane.io/smoke-machine-secrets --timeout=90s
kubectl --context kind-provider-talos-smoke wait --for=condition=Ready configuration.machine.talos.crossplane.io/smoke-worker-config --timeout=90s
```

7. Decode and inspect the generated connection details.

```sh
kubectl --context kind-provider-talos-smoke get secret smoke-worker-config -n default -o jsonpath='{.data.machine_configuration}' | base64 -d > /tmp/smoke-machine-config.yaml
kubectl --context kind-provider-talos-smoke get secret smoke-machine-secrets -n default -o jsonpath='{.data.machine_secrets}' | base64 -d > /tmp/smoke-machine-secrets.json
wc -c /tmp/smoke-machine-config.yaml /tmp/smoke-machine-secrets.json
```

Expected machine config content should include the generated and patched values:

```sh
grep -E 'type: worker|environment: kind-smoke|endpoint: https://10\.0\.0\.1:6443|clusterName: smoke-cluster' /tmp/smoke-machine-config.yaml
```

8. Verify the authoritative output contract by comparing the connection secret bytes to status.

```sh
SECRET_HASH="$(shasum -a 256 /tmp/smoke-machine-config.yaml | cut -d' ' -f1)"
STATUS_HASH="$(kubectl --context kind-provider-talos-smoke get configuration.machine.talos.crossplane.io smoke-worker-config -o jsonpath='{.status.atProvider.machineConfigurationHash}')"
test "$SECRET_HASH" = "$STATUS_HASH" && printf 'hashes match: %s\n' "$SECRET_HASH"

STATUS_CONFIG_HASH="$(kubectl --context kind-provider-talos-smoke get configuration.machine.talos.crossplane.io smoke-worker-config -o jsonpath='{.status.atProvider.machineConfiguration}' | shasum -a 256 | cut -d' ' -f1)"
test "$STATUS_CONFIG_HASH" = "$SECRET_HASH" && printf 'status matches secret: %s\n' "$STATUS_CONFIG_HASH"
```

Useful status check:

```sh
kubectl --context kind-provider-talos-smoke get configuration.machine.talos.crossplane.io smoke-worker-config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}{"\n"}{.status.atProvider.machineConfigurationHash}{"\n"}{.status.atProvider.generatedTime}{"\n"}'
```

9. Clean up.

```sh
if [ -f /tmp/provider-talos-smoke.pid ]; then kill "$(cat /tmp/provider-talos-smoke.pid)" 2>/dev/null || true; fi
lsof -nP -iTCP:8080 -sTCP:LISTEN
kind delete cluster --name provider-talos-smoke
```

## Expected Evidence For PRs

Include a concise summary in the PR with:

- Tooling used: Docker, kind, kubectl, provider run externally with `go run`.
- The resource inputs applied.
- Controller log lines showing `Secrets` generated and `Configuration` generated.
- Ready condition output for `Secrets` and `Configuration`.
- Decoded connection secret size for `machine_configuration`.
- Grep output showing expected generated and patched fields.
- Hash comparison proving connection secret bytes match status hash and status compatibility field.
