
# qrcode

BaseOn: [SiriDx - qrcode](https://github.com/SiriDx/qrcode)

A flutter plugin for scanning QR codes. Use AVCaptureSession in iOS and zxing in Android.

Current version: 1.0.7

## What this lib modified?

- Add `setRecognizeType` method to set QRCode recognize type, set `recognizeType` to 0 - defualt, 1 - inverted mode, 2 - mixed mode.
- Add permission alert api for customize title/content/canceTitle/okTitle


## Usage

### Use this package as a library

#### Add dependency

Add this to your package's pubspec.yaml file:

```dart
dependencies:
  qrcode:
    git:
      url: git://github.com/GrayLand119/qrcode.git
      path: qrcode
```

#### Install it

You can install packages from the command line:

with Flutter:

```
$ flutter pub get
```

#### Import it

Now in your Dart code, you can use:

```dart
import 'package:qrcode/qrcode.dart';
```

### Basic

```dart
class _MyAppState extends State<MyApp> {
  QRCaptureController _captureController = QRCaptureController();

  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();

    _captureController.onCapture((data) {
      print('onCapture----$data');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫一扫'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: QRCaptureView(
              permissionAlertTitle: "提示",
              permissionAlertCancelTitle: "返回",
              permissionAlertContent: "需要访问相机来扫描二维码",
              permissionAlertOkTitle: "去设置",
              controller: _captureController,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 56),
            child: AspectRatio(
              aspectRatio: 264 / 258.0,
              child: Stack(
                alignment: _animation.value,
                children: <Widget>[
                  Image.asset('images/sao@3x.png'),
                  Image.asset('images/tiao@3x.png')
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildToolBar(),
          ),
          Container(
            child: Text('$_captureText'),
          )
        ],
      ),
    );
  }
}
```

## Integration

### iOS
To use on iOS, you must add the following to your Info.plist


```
<key>NSCameraUsageDescription</key>
<string>Camera permission is required for qrcode scanning.</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```
