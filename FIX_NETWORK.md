# Sửa lỗi call outgoing khi thay đổi network.

## Installation

```dart
flutter pub add connectivity_plus throttling
flutter pub get
```

## Config

- Import thư viện:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:throttling/throttling.dart';
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

## Định nghĩa thêm 2 state:

- checkConnectivity: khi chuyển trạng thái network.
- outPhone: số điện thoại gọi đi
  Ví dụ: trong example dùng riverpod

```dart
final checkConnectivityProvider = StateProvider<ConnectivityResult>((ref) {
  return ConnectivityResult.none;
});

// Lưu ý: phải clear số điện thoại gọi đi mỗi khi call xong hoặc mỗi khi back về màn hình trước call.
final outPhoneProvider = StateProvider<String>((ref) {
  return "";
});
```

## Ở màn hình home_screen.dart, check network

```dart
  @override
  initState() {
    super.initState();
    _checkConnection(); // khởi tạo trạng thái network
  }
  void _checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    // Ví dụ dùng riverpod
    ref.read(checkConnectivityProvider.notifier).state = connectivityResult;
  }
```

## Bổ sung widget PitelVoipCall thêm 2 params mới

```dart
    PitelVoipCall(
        // state số điện thoại gọi ra,.Lưu ý: dev  không hard code vì sẽ clear mỗi khi kết thúc hoặc huỷ cuộc gọi
        outPhone: ref.watch(outPhoneProvider),
        clearOutgoing: () {
        // xoá số điện thoại gọi đi
          ref.read(outPhoneProvider.notifier).state = "";
    },)
```

## Hàm gọi ra

```dart
void _outGoingCall(String phoneNumber) {
    thr.throttle(() async {
      // get state checkConnectivity từ state managerment
      final checkConnectivity = ref.watch(checkConnectivityProvider);
      // setState số điện thoại gọi đi
      ref.read(outPhoneProvider.notifier).state = phoneNumber;

      final PitelCall pitelCall = PitelClient.getInstance().pitelCall;
      final PitelClient pitelClient = PitelClient.getInstance();

     // Logic xử lý hàm gọi đi
      final connectivityResult = await (Connectivity().checkConnectivity());
      // Trường hợp app không kết nối internet
      if (connectivityResult == ConnectivityResult.none) {
        EasyLoading.showToast(
          'Please check your network',
          toastPosition: EasyLoadingToastPosition.center,
        );
        return;
      }
      // Trường hợp đổi network wifi <-> mạng di động
      if (connectivityResult != checkConnectivity) {
        ref.read(checkConnectivityProvider.notifier).state = connectivityResult;
        EasyLoading.show(status: "Connecting...");
        handleRegisterCall();
        return;
      }

      final isRegistered = pitelCall.getRegisterState();
      if (isRegistered == 'Registered') {
        // Trường hợp app đã registered
        pitelClient
            .call(phoneNumber, true)
            .then((value) => value.fold((succ) => "OK", (err) {
                  EasyLoading.showToast(
                    err.toString(),
                    toastPosition: EasyLoadingToastPosition.center,
                  );
                }));
      } else {
        // Trường hợp app chưa register
        EasyLoading.show(status: "Connecting...");
        handleRegisterCall();
      }
    });
}
```
