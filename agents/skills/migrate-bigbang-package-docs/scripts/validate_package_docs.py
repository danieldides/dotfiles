#!/usr/bin/env python3
"""Smoke-test one package's documentation using a read-only compiler checkout.

Run with the compiler's Poetry environment. No fetches, deployments, or writes to
the package/compiler source trees are performed. Local uncommitted doc edits in
the assigned worktree are intentionally included. This is not a full-site build
or an external-link checker.
"""

import argparse
import sys
import tempfile
from copy import deepcopy
from pathlib import Path


def arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiler-repo", type=Path, required=True)
    parser.add_argument("--compiler-ref", required=True, help="Pinned compiler commit/ref")
    parser.add_argument("--package-repo", type=Path, required=True)
    parser.add_argument("--package", required=True, help="Compiled directory name")
    parser.add_argument("--ref", required=True, help="Checked-out package branch/tag/SHA")
    parser.add_argument("--guide", type=Path, required=True, help="Package-relative .md path")
    parser.add_argument(
        "--temp-root",
        type=Path,
        default=Path("/private/var/folders/l_/s09vkld931714_nwg8np57m80000gp/T/opencode"),
        help="Existing temporary parent; all generated output is removed on exit",
    )
    return parser.parse_args()


def main():
    args = arguments()
    compiler = args.compiler_repo.expanduser().resolve()
    source = args.package_repo.expanduser().resolve()
    guide = args.guide
    if not (compiler / "docs_compiler.yaml").is_file():
        raise ValueError(f"Not a compiler checkout: {compiler}")
    if not source.is_dir():
        raise ValueError(f"Package checkout does not exist: {source}")
    if (
        not args.package
        or args.package in {".", ".."}
        or "/" in args.package
        or "\\" in args.package
    ):
        raise ValueError("--package must be a single directory name")
    if guide.is_absolute() or ".." in guide.parts or guide.suffix != ".md":
        raise ValueError("--guide must be a package-relative Markdown file without '..'")
    if not (source / guide).is_file():
        raise ValueError(f"Guide does not exist: {source / guide}")
    if not (source / guide).resolve().is_relative_to(source):
        raise ValueError("Guide resolves outside the assigned package checkout")
    temp_root = args.temp_root.expanduser().resolve()
    if not temp_root.is_dir():
        raise ValueError(f"Temporary parent does not exist: {temp_root}")
    if temp_root.is_relative_to(source) or temp_root.is_relative_to(compiler):
        raise ValueError("Temporary output must be outside the package/compiler checkouts")

    # Load the explicitly selected compiler, not one inferred from the shell CWD.
    sys.dont_write_bytecode = True
    sys.path.insert(0, str(compiler))
    from git import Repo

    compiler_git = Repo(compiler)
    if compiler_git.commit(args.compiler_ref).hexsha != compiler_git.head.commit.hexsha:
        raise ValueError("Compiler checkout HEAD differs from the pinned --compiler-ref")
    if compiler_git.is_dirty(untracked_files=True):
        raise ValueError("Compiler checkout has uncommitted changes; use a clean pinned input")

    from mkdocs.commands.build import build
    from mkdocs.config import load_config
    from ruamel.yaml import YAML

    from docs_compiler.cli import process_package_values, write_package_navigation
    from docs_compiler.repo import SubmoduleRepo

    git_repo = Repo(source)
    if git_repo.commit(args.ref).hexsha != git_repo.head.commit.hexsha:
        raise ValueError("--ref does not identify this worktree's HEAD")
    origin = git_repo.remotes.origin.url
    yaml = YAML()
    metadata = yaml.load((compiler / "docs_compiler.yaml").read_text())
    template = deepcopy(metadata["packages"]["_template"])
    overrides = metadata["packages"].get(args.package, {})
    if overrides:
        # Per-package source overrides may refer to shared submodules. Do not
        # silently validate a different input or approximate their merge behavior.
        raise ValueError(
            "Package has compiler-specific overrides; hand off an isolated "
            "publication check to the coordinator rather than use this helper"
        )

    repo = SubmoduleRepo.__new__(SubmoduleRepo)
    repo.name = args.package
    repo.path = source
    repo.repo = git_repo
    repo.ref = args.ref
    repo.upstream = origin

    with tempfile.TemporaryDirectory(prefix=f"{args.package}-docs-", dir=temp_root) as tmp:
        root = Path(tmp).resolve()
        docs = root / "docs"
        destination = docs / "packages" / args.package
        destination.mkdir(parents=True)
        repo.copy_files(source, destination, template["include"])
        if not (destination / guide).is_file():
            raise ValueError(f"Compiler include rules do not publish {guide}")
        process_package_values(args.package, source, destination, template, args.ref)
        with (destination / ".pages").open("w") as f:
            yaml.dump(template["pages"], f)
        repo.patch_external_refs("**/*.md", destination)
        (docs / "index.md").write_text("# Package publication check\n")
        target = (Path(args.package) / guide).as_posix()
        (docs / "packages" / "index.md").write_text(
            f"# Packages\n\n[Assigned package integration guide]({target})\n"
        )
        write_package_navigation(docs / "packages", [args.package])
        config_path = root / "mkdocs.yml"
        with config_path.open("w") as f:
            yaml.dump(
                {
                    "site_name": "Package documentation publication check",
                    "docs_dir": "docs",
                    "site_dir": "site",
                    "plugins": [{"awesome-pages": {"strict": True}}],
                    "markdown_extensions": [
                        "admonition", "tables", "attr_list", "md_in_html",
                        "footnotes", "pymdownx.details", "pymdownx.superfences",
                        "pymdownx.tabbed",
                    ],
                },
                f,
            )
        config = load_config(config_file=str(config_path), strict=True)
        build(config)

        if guide.name == "index.md":
            route = Path("packages") / args.package / guide.parent
        else:
            route = Path("packages") / args.package / guide.with_suffix("")
        rendered = root / "site" / route / "index.html"
        if not rendered.is_file():
            raise ValueError(f"Guide was not rendered at expected route: {route}")
        expected_href = route.relative_to("packages").as_posix() + "/"
        catalog = (root / "site" / "packages" / "index.html").read_text()
        if f'href="{expected_href}"' not in catalog:
            raise ValueError("Focused Packages link did not resolve to the rendered guide")
        print(f"PASS: {args.package}@{args.ref} -> {route.as_posix()}/")
        print(f"Package HEAD: {git_repo.head.commit.hexsha}")
        print(f"Compiler HEAD: {compiler_git.head.commit.hexsha}")
        print("Local worktree docs included; no shared generated output changed.")
        print("Focused smoke check only; full-site and remote-link checks remain separate.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
