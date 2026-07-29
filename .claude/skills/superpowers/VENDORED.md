# Vendored: Superpowers

This directory is a vendored copy of the [Superpowers](https://github.com/obra/superpowers)
plugin, checked into the repo so every session — local and cloud — loads it without a
marketplace fetch or an install step.

- Upstream: https://github.com/obra/superpowers
- Version: 6.2.0
- Commit: 44c9b2d6e889982ac18c27d05a19fefe335194e1
- License: MIT (see `LICENSE`)

## How it loads

Because this folder contains `.claude-plugin/plugin.json`, Claude Code loads it as a
skills-directory plugin named `superpowers@skills-dir` — its 14 skills and its
`SessionStart` hook come along with it. No `/plugin install` needed.

Project-scope skills-directory plugins load only from the `.claude/skills/` of the
directory where Claude Code starts, so start sessions at the repo root (cloud sessions
already do). After changing directories, `/reload-plugins` picks it up.

## What was left out

Upstream files not needed to run the plugin: `tests/`, `docs/`, `scripts/`, `assets/`,
`.github/`, the non-Claude platform manifests (`.codex-plugin/`, `.cursor-plugin/`,
`.kimi-plugin/`, `.opencode/`, `.pi/`, `.agents/`), and `hooks/hooks-cursor.json`.

## Updating

```bash
git clone --depth 1 https://github.com/obra/superpowers.git /tmp/sp
DEST=.claude/skills/superpowers
rm -rf "$DEST/skills" "$DEST/hooks"
cp /tmp/sp/.claude-plugin/plugin.json "$DEST/.claude-plugin/plugin.json"
cp -r /tmp/sp/skills /tmp/sp/hooks "$DEST/"
cp /tmp/sp/LICENSE /tmp/sp/README.md "$DEST/"
rm -f "$DEST/hooks/hooks-cursor.json"
chmod +x "$DEST/hooks/session-start" "$DEST/hooks/run-hook.cmd"
```

Then update the version and commit recorded above.
