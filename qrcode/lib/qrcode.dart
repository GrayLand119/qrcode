import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef CaptureCallback(String data);

enum CaptureTorchMode { on, off }

class QRCaptureController {
  MethodChannel _methodChannel;
  CaptureCallback _capture;

  QRCaptureController();

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('plugins/qr_capture/method_$id');
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onCaptured') {
        if (_capture != null && call.arguments != null) {
          _capture(call.arguments.toString());
        }
      }
    });
  }

  void pause() {
    _methodChannel?.invokeMethod('pause');
  }

  void resume() {
    _methodChannel?.invokeMethod('resume');
  }

  void setRecognizeType(int type) {
    _methodChannel?.invokeMethod('setRecognizeType', {"recognizeType":type});
  }

  void onCapture(CaptureCallback capture) {
    _capture = capture;
  }

  set torchMode(CaptureTorchMode mode) {
    var isOn = mode == CaptureTorchMode.on;
    _methodChannel?.invokeMethod('setTorchMode', isOn);
  }
}

class QRCaptureView extends StatefulWidget {
  final QRCaptureController controller;
  final String permissionAlertTitle;
  final String permissionAlertContent;
  final String permissionAlertCancelTitle;
  final String permissionAlertOkTitle;

  QRCaptureView(
      {Key key,
      this.controller,
      this.permissionAlertTitle,
      this.permissionAlertContent,
      this.permissionAlertCancelTitle,
      this.permissionAlertOkTitle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QRCaptureViewState();
  }
}

class QRCaptureViewState extends State<QRCaptureView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'plugins/qr_capture_view',
        creationParams: {
          'permissionAlertTitle': widget.permissionAlertTitle,
          'permissionAlertContent': widget.permissionAlertContent,
          'permissionAlertCancelTitle': widget.permissionAlertCancelTitle,
          'permissionAlertOkTitle': widget.permissionAlertOkTitle,
        },
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    } else {
      return AndroidView(
        viewType: 'plugins/qr_capture_view',
        creationParams: {
          'permissionAlertTitle': widget.permissionAlertTitle,
          'permissionAlertContent': widget.permissionAlertContent,
          'permissionAlertCancelTitle': widget.permissionAlertCancelTitle,
          'permissionAlertOkTitle': widget.permissionAlertOkTitle,
        },
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    }
  }
}
