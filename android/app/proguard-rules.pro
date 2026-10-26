# Intercom
-keep class io.intercom.android.** { *; }
-keep interface io.intercom.android.** { *; }

# Ably (used by Intercom)
-keep class io.ably.lib.** { *; }
-dontwarn io.ably.lib.**

# MessagePack (used by Ably/Intercom)
-keep class org.msgpack.** { *; }
-keepclassmembers class org.msgpack.** { *; }
-dontwarn org.msgpack.**

# WebSocket (used by Ably)
-keep class org.java_websocket.** { *; }
-dontwarn org.java_websocket.**

# Keep constructors that are accessed via reflection
-keepclassmembers class * {
    public <init>(...);
}
