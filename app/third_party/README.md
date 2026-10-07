# Vendored packages

| Package | Why | Changes |
|---|---|---|
| `flutter_poolakey` 2.2.0+1.0.0 (Cafe Bazaar billing, Apache-2.0) | its Android build used `jcenter()`, which Gradle 9 removed, so the Bazaar build failed | `android/build.gradle` only (see its header) |

Check pub.dev for a fixed release before upgrading; then switch back to the hosted package.
