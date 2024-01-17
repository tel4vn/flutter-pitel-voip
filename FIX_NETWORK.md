# Sửa lỗi call outgoing khi thay đổi network.

## Installation

```dart
flutter pub get
```

- Cấu hình Easy Loading (sdk có dùng thư viện này để show message, loading khi thực hiện callout)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EasyLoading',
      home: MyHomePage(title: 'Flutter EasyLoading'),
      builder: EasyLoading.init(),  // thêm dòng config này
    );
  }
}
```

## Hàm gọi ra

```dart
void outGoingCall(String phoneNumber) {
    final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
    pitelCall.outGoingCall(
      phoneNumber: phoneNumber,
      handleRegisterCall: handleRegisterCall,
    );
  }
```
