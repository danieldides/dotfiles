# Sensitive - do not commit

Put local, work-specific skills here:

```text
sensitive - do not commit/
└── my-work-skill/
    ├── SKILL.md
    └── references/
```

Only this README and `.gitignore` are committed. Everything else underneath
this directory is ignored, including nested files and hidden files.

The existing `~/.agents/skills` symlink exposes this directory to agents that
discover nested skills. Private skills are local and will not be cloned or
backed up by Git.

Gitignore is not a security boundary: agents can read these files, and
`git add -f` bypasses the ignore rules. Do not store credentials here or replace
this tracked README with private information.
