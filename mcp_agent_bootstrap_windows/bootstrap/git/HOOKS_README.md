# Git Hooks

Use Husky to keep checks Windows-friendly without editing .git/config.

1. Run npx husky install if hooks are not already active.
2. Create the pre-commit hook: npx husky add .husky/pre-commit "pwsh -File scripts/windows/Run-Tests.ps1".
3. Ensure PowerShell is available on PATH so the hook stays non-interactive.
4. Optional: set HUSKY=0 in CI where you handle tests separately.
