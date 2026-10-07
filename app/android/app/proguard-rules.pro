# R8 rules for release builds.
#
# WorkManager (pulled in by Google Mobile Ads) creates its Room database by
# reflection (WorkDatabase_Impl). R8 removed that class, so every release
# build crashed at launch with "Failed to create an instance of
# androidx.work.impl.WorkDatabase" (found on the CI emulator, v0.8.1).
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Adivery (Cafe Bazaar build) ships optional mediation adapters for networks
# we do not include (MBridge); R8 stops on their missing classes otherwise.
-dontwarn com.mbridge.**
