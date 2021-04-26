
# qrcode

BaseOn: [SiriDx - qrcode](https://github.com/SiriDx/qrcode)

A flutter plugin for scanning QR codes. Use AVCaptureSession in iOS and zxing in Android.

Current version: 1.0.7

## What this lib modified?

- Add `setRecognizeType` method to set QRCode recognize type, set `recognizeType` to 0 - defualt, 1 - inverted mode, 2 - mixed mode.
- Add permission alert api for customize title/content/canceTitle/okTitle

## Usage

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
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            QRCaptureView(controller: _captureController),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildToolBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar() {
    return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                _captureController.pause();
              },
              child: Text('pause'),
            ),
            FlatButton(
              onPressed: () {
                if (_isTorchOn) {
                  _captureController.torchMode = CaptureTorchMode.off;
                } else {
                  _captureController.torchMode = CaptureTorchMode.on;
                }
                _isTorchOn = !_isTorchOn;
              },
              child: Text('torch'),
            ),
            FlatButton(
              onPressed: () {
                _captureController.resume();
              },
              child: Text('resume'),
            ),
          ],
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
