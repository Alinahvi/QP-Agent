# Windows Bootstrap Guide

- Launch PowerShell as a normal user (no elevation) so the scripts run without UAC prompts.
- All automation lives under scripts\windows\. Each script uses --json and --quiet flags for non-interactive defaults.
- SF CLI output streams are returned directly; capture logs under logs\\ by redirecting or using Start-LongJob.ps1.
- Update environment variables through ENV_HINTS.ps1 before running deployments or tests.
