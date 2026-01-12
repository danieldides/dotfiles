function helm-readme
    curl -LO https://repo1.dso.mil/big-bang/product/packages/gluon/-/raw/master/docs/README.md.gotmpl
    curl -LO https://repo1.dso.mil/big-bang/product/packages/gluon/-/raw/master/docs/.helmdocsignore
    curl -LO https://repo1.dso.mil/big-bang/product/packages/gluon/-/raw/master/docs/_templates.gotmpl
    docker run --rm -v (pwd):/helm-docs -u (id -u) jnorwood/helm-docs:v1.14.2 -s file -t /helm-docs/README.md.gotmpl -t /helm-docs/_templates.gotmpl --dry-run > README.md
    rm .helmdocsignore README.md.gotmpl _templates.gotmpl
end

