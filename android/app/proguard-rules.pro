# Evita que R8 elimine clases necesarias del SDK de Stripe
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
