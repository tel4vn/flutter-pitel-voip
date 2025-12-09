# Example

A simple example demonstrating how to use the `flutter_pitel_voip` package.

## Features Demonstrated

- Initializing Pitel client
- Registering SIP account with push notification support
- Setting up call event listeners
- Making and receiving VoIP calls
- Managing call states (mute, hold, video on/off)

## Getting Started

1. Replace the placeholder values in `main.dart`:

   - `YOUR_TEAM_ID`: Your Apple Developer Team ID (for iOS)
   - `com.example.app`: Your app's bundle identifier
   - SIP credentials (username, password, domain)

2. Run the example:
   ```bash
   dart run example/main.dart
   ```

## Key Concepts

### Initialization

```dart
final pitelClient = PitelClient.getInstance();
final pitelService = PitelServiceImpl();
```

### Registration

```dart
final pitelSettings = await pitelService.setExtensionInfo(
  sipInfoData,
  pushNotifParams,
);
```

### Call Management

```dart
// Make a call
await pitelCall.call('extension_number');

// Answer incoming call
await pitelCall.answer();

// Hang up
await pitelCall.hangup();

// Mute/Unmute
await pitelCall.mute();
await pitelCall.unmute();
```

## More Information

Please checkout repo github to get [example](https://github.com/tel4vn/pitel-ui-kit)
For more details, see the [main documentation](https://github.com/tel4vn/flutter-pitel-voip).
