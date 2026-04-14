 ## Flutter Policy Card
 
 - Widget: `lib/policy_card_widget.dart`
 - Offline cache: `lib/policy_card_cache.dart` (stores JSON in `SharedPreferences`)
 
 ### Add dependency
 In your Flutter app's `pubspec.yaml`:
 
 ```yaml
 dependencies:
   shared_preferences: ^2.2.3
 ```
 
 ### Offline state
 Pass `isOffline` from your connectivity logic (e.g., `connectivity_plus`) to show the offline banner and rely on cached cards.
