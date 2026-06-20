# AWS SSO CLI Documentation

Local mirror of [aws-sso-cli](https://github.com/synfinatic/aws-sso-cli) docs.

All Markdown content lives under `src/`. Synced via `./sync-docs.sh`.

---

## Lookup by topic

| Question about...                    | Read first                | Then                           |
| ------------------------------------ | ------------------------- | ------------------------------ |
| What aws-sso-cli does                | `src/index.md`            | `src/aws-vault.md` (comparison)|
| Getting started / install            | `src/quickstart.md`       | `src/wizard.md`                |
| First-time setup wizard              | `src/wizard.md`           | `src/quickstart.md`            |
| CLI commands (all)                   | `src/commands.md`         |                                |
| Configuration file                   | `src/config.md`           | `src/FAQ.md` (Profiles/Tags)  |
| Frequently asked questions           | `src/FAQ.md`              |                                |
| Known bugs / workarounds / v2 changes| `src/known-issues.md`     | `src/FAQ.md`                   |
| Security model                       | `src/security.md`         | `src/ecs-threats.md`           |
| ECS credential server                | `src/ecs-server.md`       | `src/ecs-commands.md`, `src/ecs-api.md` |
| ECS server example                   | `src/ecs-server-example.md` |                              |
| ECS threats and security             | `src/ecs-threats.md`      | `src/security.md`              |
| Remote SSH usage                     | `src/remote-ssh.md`       | `src/ecs-server.md`            |
| Comparison with aws-vault            | `src/aws-vault.md`        |                                |
| Demos / screenshots                  | `src/demos.md`            |                                |
| Release / changelog                  | `src/release.md`          |                                |

---

## CLI commands

All documented in `src/commands.md`:

| Command               | Purpose                                                      |
| --------------------- | ------------------------------------------------------------ |
| `cache`               | Force refresh cached AWS account/role/tag data               |
| `console`             | Open AWS Console in browser for a role                       |
| `credentials`         | Generate static API credentials (JSON output)                |
| `ecs`                 | Manage ECS Server credentials                                |
| `eval`                | Print shell export statements for a role's credentials       |
| `exec`                | Execute a command with role credentials in environment       |
| `process`             | Credential process for `~/.aws/config`                       |
| `list`                | List accounts/roles with tags and metadata                   |
| `login`               | Authenticate to AWS SSO (get/refresh SSO token)              |
| `logout`              | Invalidate SSO token and clear STS credentials               |
| `setup completions`   | Install shell auto-completion                                |
| `setup ecs`           | Configure ECS credential server                              |
| `setup profiles`      | Generate `~/.aws/config` named profiles                      |
| `setup wizard`        | Interactive guided configuration                             |
| `tags`                | List all tags and their values                               |
| `time`                | Show time remaining on current STS credentials               |

Shell helpers (also in `src/commands.md`):

| Helper               | Purpose                                                       |
| -------------------- | ------------------------------------------------------------- |
| `aws-sso-profile`    | Shell function to set `$AWS_PROFILE` via interactive select   |
| `aws-sso-clear`      | Shell function to unset all AWS environment variables         |

---

## Configuration options

All documented in `src/config.md`. Config file: `~/.config/aws-sso/config.yaml` (or `~/.aws-sso/config.yaml`).

### SSOConfig block

| Key              | Purpose                                            |
| ---------------- | -------------------------------------------------- |
| `StartUrl`       | AWS SSO portal URL                                 |
| `SSORegion`      | AWS region where SSO is deployed                   |
| `DefaultRegion`  | Default AWS region for roles                       |
| `AuthWorkflow`   | Auth method: `device_code` or `pkce`               |
| `Accounts`       | Per-account overrides (name, tags, roles)          |

### Common settings

| Key                          | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
| `DefaultSSO`                 | Which SSO instance to use by default                 |
| `CacheRefresh`               | Hours between auto-refresh of role cache             |
| `Threads`                    | Parallel threads for AWS API calls                   |
| `MaxRetry` / `MaxBackoff`    | Retry behavior for API throttling                    |
| `Browser` / `UrlAction`      | How to open URLs (clip, exec, print, open, etc.)     |
| `ConsoleDuration`            | Console session duration in minutes                  |
| `AutoConfigCheck`            | Auto-update `~/.aws/config` on changes              |
| `AutoLogin`                  | Auto-trigger SSO login when token expires            |
| `ProfileFormat`              | Go template for generating profile names             |
| `ConfigVariables`            | Custom variables for ProfileFormat templates          |
| `SecureStore`                | Credential backend (file, keychain, kwallet, etc.)   |
| `LogLevel` / `LogLines`      | Logging verbosity                                    |
| `ListFields`                 | Customize columns in `list` output                   |
| `HistoryLimit` / `HistoryMinutes` | Role selection history settings                |
| `PromptColors`               | Customize interactive prompt colors                  |
| `EnvVarTags`                 | Expose tags as environment variables                 |

---

## Environment variables

Documented in `src/commands.md` under "Environment Variables":

### Honored (input)

| Variable                  | Purpose                                    |
| ------------------------- | ------------------------------------------ |
| `$AWS_SSO_CONFIG`         | Override config file path                  |
| `$AWS_SSO`               | Override default SSO instance              |
| `$AWS_SSO_BROWSER`       | Override browser for SSO URL               |
| `$AWS_SSO_ROLE_ARN`      | Pre-select role by ARN                     |
| `$AWS_SSO_ACCOUNT_ID`    | Pre-select account                         |
| `$AWS_SSO_ROLE_NAME`     | Pre-select role name (with account)        |
| `$AWS_PROFILE`           | Select role via profile name               |
| `$AWS_SSO_FILE_PASSWORD` | Credential store password (file backend)   |

### Managed (output)

| Variable                    | Set by aws-sso                           |
| --------------------------- | ---------------------------------------- |
| `$AWS_ACCESS_KEY_ID`        | STS temporary access key                 |
| `$AWS_SECRET_ACCESS_KEY`    | STS temporary secret key                 |
| `$AWS_SESSION_TOKEN`        | STS session token                        |
| `$AWS_DEFAULT_REGION`       | Region for the assumed role              |
| `$AWS_SSO_PROFILE`          | Profile name of assumed role             |
| `$AWS_SSO_ACCOUNT_ID`       | Account ID of assumed role               |
| `$AWS_SSO_ROLE_NAME`        | Role name of assumed role                |

---

## FAQ — common questions

Documented in `src/FAQ.md`:

### Troubleshooting

- Credential expiry / refresh behavior
- "need to login now" errors
- New roles not appearing (cache refresh)
- `device_code` vs `pkce` auth workflow choice
- Firefox container color/icon issues
- Error: "Invalid selection: Too many roles match"
- Error: "Invalid grant provided" (expired SSO token)
- Error: "Unable to save... org.freedesktop.DBus"
- Error: "Unexpected AccessToken failure"
- Warning: "Exceeded MaxRetry/MaxBackoff"

### Advanced features

- Role chaining (`Via` config)
- Multiple AWS SSO instances
- Region management (`$AWS_DEFAULT_REGION`)
- Using aws-sso on remote hosts

### Profiles and tags

- AccountAlias vs AccountName
- Defining `$AWS_PROFILE` / `$AWS_SSO_PROFILE` names
- Configuring `ProfileFormat` templates
- Tag purposes and usage

---

## ECS credential server

Documented across `src/ecs-server.md`, `src/ecs-commands.md`, `src/ecs-api.md`:

- Local credential server compatible with AWS ECS Task IAM Role protocol
- Supports HTTPS with self-signed or custom certificates
- HTTP Bearer token authentication
- Multiple simultaneous role credentials
- Docker/container integration

---

## Searching tips

- Configuration keys: grep `src/config.md`
- Command flags: grep `src/commands.md`
- Error messages: grep `src/FAQ.md` under "Errors and their meaning"
- ECS-specific: check `src/ecs-server.md`, `src/ecs-commands.md`, `src/ecs-api.md`
- Security concerns: `src/security.md` and `src/ecs-threats.md`
