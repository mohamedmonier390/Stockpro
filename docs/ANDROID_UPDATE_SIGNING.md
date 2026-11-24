# Android update/signing setup

Android allows an in-place update only when the new APK has the same application ID and is signed with the same signing certificate as the installed app. The previous StockPro CI workflow used runner-generated debug signing, which can change between runs; that APK may therefore require uninstalling the old app and can erase local data.

## Persistent release signing (required for upgrades)

Create or retrieve the release keystore you intend to keep permanently. **Do not commit the keystore or passwords to this repository and do not send them in chat.** Store these GitHub Actions repository secrets:

- `STOCKPRO_KEYSTORE_BASE64`: Base64-encoded keystore file
- `STOCKPRO_KEYSTORE_PASSWORD`
- `STOCKPRO_KEY_ALIAS`
- `STOCKPRO_KEY_PASSWORD`

If a previously installed APK was signed with another key, this new key will not make that installation upgradeable. The original signing key must be recovered to upgrade it. If the original key cannot be recovered, a one-time uninstall/reinstall is unavoidable; back up app data before uninstalling.

When secrets are absent, workflow deliberately produces a debug-signed test APK clearly labelled as **not for upgrading**. When all signing secrets are configured, it produces release APK and AAB with the persistent key.

## Application identity

The CI workflow generates Android project files using `--org com.stockpro --project-name stockpro`. Keep the resulting application ID stable; do not change it for future updates.
