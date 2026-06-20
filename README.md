# aws-sso-cli-docs

Local mirror of [aws-sso-cli](https://github.com/synfinatic/aws-sso-cli) documentation, structured for use as an AI Knowledge Base.

## Contents

- `src/` — Markdown source files synced from the upstream repo
- `sync-docs.sh` — script to pull the latest docs from upstream

## Usage

Loaded as context by the `aws-sso-cli` Claude Code skill. See `CLAUDE.md` for the topic-to-file lookup table and a summary of all CLI commands, config keys, and environment variables.

To refresh docs from upstream:

```sh
./sync-docs.sh
```
