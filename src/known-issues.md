# Known Issues and Workarounds

Distilled from closed GitHub issues. Complements [FAQ.md](FAQ.md).

---

## v2.x Breaking Changes (Migration Notes)

| Old (v1.x)               | New (v2.x)                     | Issue  |
| ------------------------ | ------------------------------ | ------ |
| `aws-sso config`         | `aws-sso setup wizard`         | #1212  |
| `aws-sso config-profiles`| `aws-sso setup profiles`       | #975   |
| `--url-action` / `-u`    | Set `UrlAction` in config      | #1217  |
| `--log-level`            | `--level`                      | #1240  |
| Auto-login on expiry     | Explicit `aws-sso login` required; or set `AutoLogin: true` | #1063 |
| `aws-sso flush`          | `aws-sso logout` + `aws-sso cache` | —  |

---

## Bugs with Active Workarounds

### `setup profiles` drops final line of `~/.aws/config` when file lacks trailing newline

Affects: v2.2.5 (bug report open)

If `~/.aws/config` does not end with a newline, `setup profiles` proposes deletion of the final
line even if it is outside the managed block.

**Workaround:** append a newline before running:

```sh
printf '\n' >> ~/.aws/config
aws-sso setup profiles
```

Source: #1419

---

### storage.lock deadlock after Ctrl-C on Linux GNOME (secret-service)

Affects: Linux with GNOME / gnome-keyring, `SecureStore` not explicitly set

`aws-sso` can hang on D-Bus during keyring interaction. Ctrl-C does not fully terminate
the process; it keeps holding `storage.lock`, causing all subsequent invocations to
silently deadlock. Zombie processes accumulate.

**Workaround:**

```sh
pkill aws-sso
```

Long-term fix — add to config:

```yaml
SecureStore: file
```

Source: #1379

---

### PKCE loopback redirect fails in WSL

Affects: WSL (Windows Subsystem for Linux) when browser is opened inside WSL

`aws-sso login` with `AuthWorkflow: pkce` opens a browser but the loopback connection
(`127.0.0.1:<port>`) fails with "Connection refused" because the browser and the CLI
are in different network namespaces.

**Workaround:**

```yaml
AuthWorkflow: device_code
UrlAction: print
```

Source: #1371

---

### `aws-sso cache` fails: InvalidRequestException (MaxResults exceeds API limit)

Affects: versions before the fix was merged (reported against v2.1.0)

The SSO portal API requires `MaxResults ∈ [1, 100]`, but older builds hardcoded 1000.
Symptom: `ERROR Unexpected error error="operation error SSO: ListAccounts … ResultSize parameter must be within the valid …"`

**Fix:** upgrade to a version after the fix. No config workaround; the bug is in the binary.

Source: #1342

---

### Manually defined (non-SSO) roles logged as deleted on `aws-sso cache`

Affects: v2.2.0

Roles defined in `config.yaml` under `Via:` that are not AWS Identity Center Permission
Sets are reported as `deleted=1` on every `cache` run.

**Status:** fixed in a release after v2.2.0.

Source: #1349

---

### AWS account IDs starting with `0` rejected

Affects: v2.2.2

`AWS_SSO_ACCOUNT_ID=012345678901` causes: `expected a valid 64 bit int but got "012345678901"`.
The ID was parsed as an integer instead of a string.

**Status:** fixed in v2.2.x shortly after report.

Source: #1366

---

### `aws-sso-clear` fails on stale sessions

Affects: v2.0.1

`aws-sso-clear` required a valid session and errored with `FATAL Must run aws-sso login
before running aws-sso eval`. Running clear when credentials had already expired was
impossible.

**Workaround:**

```sh
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN \
      AWS_DEFAULT_REGION AWS_SSO_PROFILE AWS_SSO_ACCOUNT_ID AWS_SSO_ROLE_NAME \
      AWS_SSO_DEFAULT_REGION
```

Source: #1224

---

### `aws-sso list` forces re-authentication when token is still valid

Affects: early v2.x releases

`list` should never trigger an auth flow; it can display cached data. Reported as
`ERROR AccessToken Unauthorized Error` followed by an unexpected browser prompt mid-output.

**Status:** fixed in a v2.x patch.

Source: #1219

---

### `aws-sso-profile` fails with non-default SSO instance (`-S` flag)

Affects: v2.0.3

`aws-sso-profile my-profile` fails with `FATAL Must run aws-sso login before running
aws-sso eval` when the profile belongs to a non-default SSO instance.

**Workaround:** run `eval $(aws-sso eval --profile <profile> -S <sso>)` once for the SSO
instance; subsequent `aws-sso-profile` calls will work.

Source: #1241

---

### `aws-sso exec` — pass flags to sub-command using `--`

Flags after the command name may be consumed by `aws-sso` instead of the sub-command:

```sh
# Fails — --version is parsed by aws-sso
aws-sso exec --arn arn:aws:iam::123:role/Foo aws --version

# Works — everything after -- is the sub-command
aws-sso exec --arn arn:aws:iam::123:role/Foo -- aws --version
```

Source: #722

---

### `Conflicting environment variable 'AWS_ACCESS_KEY_ID' is set`

Occurs when running `aws-sso exec` inside a shell that already has AWS credentials
loaded (e.g. from a previous role assumption or from a parent process injecting them).

**Workaround 1:** clear the environment first with `aws-sso-clear`.

**Workaround 2:** use `--overwrite-env` flag (added in v2.x) to let `aws-sso exec`
replace conflicting variables:

```sh
aws-sso exec --overwrite-env --profile my-profile -- my-command
```

Source: #455, #1095

---

### `DefaultRegion` not applied in interactive menu for Account/Role-level config

Affects: v1.17.0

When `DefaultRegion` is set at the Account or Role level in `config.yaml`, it is
correctly applied when using `--account`/`--role` flags or `aws-sso-profile`, but
**not** when selecting a role via the interactive TUI.

**Workaround:** specify the account and role directly on the command line instead of
using the interactive picker.

Source: #1075

---

### Multiple SSO instances: auto-complete always uses `DefaultSSO`

Shell completion for `-A`, `-R`, `-a` is evaluated before `--sso` / `-S` is parsed,
so completion always lists roles from `DefaultSSO`.

**Workaround:** export `AWS_SSO` before running the command:

```sh
export AWS_SSO=OtherInstance
aws-sso console ...  # completions and execution use OtherInstance
```

Setting it inline (`AWS_SSO=OtherInstance aws-sso ...`) does **not** work for completion.

Source: #1139 (documented in FAQ), #524

---

### Firefox opens search bar instead of container tab

When `UrlAction: open-url-in-container` is used, Firefox may perform a search instead
of opening the URL in a Multi-Account Container.

The URL must be passed via the `ext+container:` protocol scheme. Set:

```yaml
UrlAction: exec
UrlExecCommand:
  - /Applications/Firefox.app/Contents/MacOS/firefox
  - "ext+container:name=%s&url=%s"
```

Replace path with your Firefox binary. See [Firefox Multi-Account Containers](
https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/) docs for
the correct `ext+container:` format.

Source: #1021

---

### `aws-sso time` fails with time parse error

Affects: older v1.17.x builds

`FATAL Unable to parse … as "2006-01-02 15:04:05 -0700 MST"` — timezone offset format
mismatch.

**Fix:** upgrade to a patched build.

Source: #1008

---

### `setup profiles` does not use the cached SSO token (requires re-login)

Affects: v2.0.0

`aws-sso login` succeeded but `aws-sso setup profiles` immediately triggered a second
login flow instead of using the cached token.

**Status:** fixed in v2.0.x shortly after report.

Source: #1210

---

### `aws-sso cache` does not remove revoked/renamed roles

Affects: v1.16.1 and earlier

Roles that no longer exist in AWS Identity Center were not pruned from `cache.json`
after `aws-sso cache`. They remained visible in `aws-sso list` and could cause stale
profile entries.

**Status:** fixed in v1.17.0+.

Source: #962

---

### `AuthUrlAction` per-SSO override not respected (regression)

Affects: v2.0.2 only (regression from v2.0.1)

Setting `AuthUrlAction: print` inside an `SSOConfig` block was ignored; the global
`UrlAction` was used instead.

**Status:** fixed in v2.0.3+.

Source: #1230

---

### `InvalidScopeException` on `RegisterClient` (v2.2.0+ regression)

Symptom: `InvalidScopeException` immediately after running `aws-sso login` on first
login or after token expiry.

**Workaround:** delete the cached client registration and retry:

```sh
rm -rf ~/.config/aws-sso/cache/  # or ~/.aws-sso/cache/
aws-sso login
```

Source: #1359

---

## Platform-Specific Notes

### WSL (Windows Subsystem for Linux)

- Use `AuthWorkflow: device_code` — PKCE loopback does not work across WSL network
  boundary. (#1371)
- Set `UrlAction: print` so the auth URL is printed for manual pasting into the
  Windows browser.
- Set `SecureStore: file` — the `secret-service` D-Bus backend is not available in
  most WSL environments and causes `ERROR Object does not exist at path "/"`. (#1023)

Recommended config additions:

```yaml
AuthWorkflow: device_code
UrlAction: print
SecureStore: file
```

---

### Linux (GNOME / secret-service)

- If gnome-keyring blocks on an unsurfaceable D-Bus prompt, `aws-sso` hangs
  indefinitely and holds `storage.lock`. (#1379)
- ARM Fedora 42 (and similar): after system sleep, `secret-service` loses its session;
  restart gnome-keyring or reboot to recover. (#1255)
- Workaround for both: `SecureStore: file` avoids the D-Bus dependency entirely.

---

### GitHub Codespaces / Remote / Headless Environments

No loopback browser redirect is possible. Use:

```yaml
AuthWorkflow: device_code
UrlAction: print
```

Source: #816

---

### Windows PowerShell Core v6+

`aws-sso eval` unsets env vars by setting them to empty strings (works for PowerShell
v5 / "Desktop" edition), but PowerShell Core (v6+) treats an empty-string variable as
set, which causes subsequent `aws-sso` commands to fail with conflicting-variable errors.

**Workaround:** manually remove the variables after the session:

```pwsh
Remove-Item Env:AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
Remove-Item Env:AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
Remove-Item Env:AWS_SESSION_TOKEN -ErrorAction SilentlyContinue
```

Source: #1244

---

### macOS — gatekeeper warning after Homebrew upgrade

As of v1.9.10, Homebrew distributes a pre-built bottle that is not code-signed by
Apple. macOS will warn that the binary has changed.

To build from source and avoid the warning:

```sh
brew install -s aws-sso-cli
# or
brew upgrade -s aws-sso-cli
```

Source: FAQ / #407

---

## Known Limitations (Wontfix / By Design)

| Behavior | Reason |
| -------- | ------ |
| `aws-sso list` can prompt for login when token is expired | Fixed in recent versions; `list` should be non-auth-forcing |
| ohmyzsh `aws` plugin not supported | Conflicts with aws-sso's env var management |
| Profiles cannot contain whitespace | AWS config format restriction; use `ProfileFormat` with `nospace` or `StringReplace` |
| PKCE does not work when browser is on a different host | Requires loopback redirect; use `device_code` for remote/headless |
| `AWS_SHARED_CREDENTIALS_FILE` not honored for `console` command | Tracked, partial support; use `~/.aws/credentials` default path |
| China AWS SSO (`console` command) returns invalid JSON | AWS China endpoint returns HTML error page instead of JSON on some auth flows |

---

## Quick Diagnostic Reference

| Symptom | First thing to try |
| ------- | ------------------ |
| `Object does not exist at path "/"` | Set `SecureStore: file` in config |
| `Conflicting environment variable ... is set` | Run `aws-sso-clear` or use `--overwrite-env` |
| `Invalid grant provided` | Check `SSORegion` matches your AWS Identity Center region |
| `FATAL Must run aws-sso login` but you are logged in | `AWS_SSO` env var points to a non-default SSO instance; `export AWS_SSO=<name>` first |
| `unexpected argument config` | In v2.x, `config` was renamed to `setup wizard` |
| `unknown flag --log-level` | Use `--level` instead |
| `unknown flag -u` / `--url-action` | Removed in v2; set `UrlAction` in config |
| Roles missing after permission set change | Run `aws-sso cache` to force a refresh |
| `Too many roles match` | Use `<space>` to select, not `<enter>` |
| Rate limit errors on `aws-sso cache` | Reduce `Threads` in config; increase `MaxRetry`/`MaxBackoff` |
| `storage.lock` deadlock (Linux) | `pkill aws-sso`, then retry; consider `SecureStore: file` |
