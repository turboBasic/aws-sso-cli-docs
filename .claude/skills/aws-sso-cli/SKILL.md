---
name: aws-sso-cli
description: Look up aws-sso-cli documentation — commands, config, troubleshooting, ECS server, environment variables
allowed-tools: Read, Bash(grep *)
---

You are a knowledge base lookup skill for **aws-sso-cli**. The documentation lives in this project under `src/`.

## Steps

The knowledge base lives at `~/00-projects/personal/turboBasic/aws-sso-cli-docs`.

1. Based on the user's question, identify which file(s) in `src/` are relevant using the topic routing table below.

2. Read those file(s) from `~/00-projects/personal/turboBasic/aws-sso-cli-docs/src/`.

3. If the routing table doesn't clearly point to the right file, grep across `src/` for the relevant keyword:
   `grep -rn "<keyword>" ~/00-projects/personal/turboBasic/aws-sso-cli-docs/src/`

4. If the docs don't fully answer the question (implementation details, undocumented behavior, default values not listed), fetch source code from the upstream repo:
   `https://github.com/synfinatic/aws-sso-cli` — look in `cmd/aws-sso/` for CLI command implementations.
   Use WebFetch or Bash to inspect the relevant source files.

5. Answer the user's question concisely, citing the specific file and section where the information was found.

## Topic routing

| Topic                     | Primary file            |
| ------------------------- | ----------------------- |
| Commands & flags          | `src/commands.md`       |
| Configuration options     | `src/config.md`         |
| FAQ / errors / troubleshooting | `src/FAQ.md`       |
| Known bugs & workarounds  | `src/known-issues.md`   |
| v1 → v2 migration         | `src/known-issues.md`   |
| Getting started           | `src/quickstart.md`     |
| ECS credential server     | `src/ecs-server.md`     |
| Security                  | `src/security.md`       |
| Remote SSH                | `src/remote-ssh.md`     |
| aws-vault comparison      | `src/aws-vault.md`      |
| Setup wizard              | `src/wizard.md`         |
