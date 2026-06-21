-keepattributes Signature
-keepattributes *Annotation*

# Firebase
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# Purchases / RevenueCat
-keep class com.revenuecat.** { *; }
-keep class com.android.billingclient.** { *; }

# Health Connect
-keep class com.google.android.hcandroid.** { *; }
-dontwarn com.google.android.hcandroid.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.Metadata { *; }

# WorkManager
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# SQLCipher / database
-keep class net.sqlcipher.** { *; }
-dontwarn net.sqlcipher.**
-keep class net.zetetic.** { *; }
-dontwarn net.zetetic.**

# JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Drift / SQLite
-keep class * extends androidx.room.** { *; }
-dontwarn androidx.room.**
