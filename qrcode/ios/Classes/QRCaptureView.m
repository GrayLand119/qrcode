//
//  QRCaptureView.m
//  Pods-Runner
//
//  Created by cdx on 2019/10/28.
//

#import "QRCaptureView.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCaptureView () <AVCaptureMetadataOutputObjectsDelegate, FlutterPlugin>

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) FlutterMethodChannel *channel;
@property(nonatomic, weak) AVCaptureVideoPreviewLayer *captureLayer;
@property(nonatomic, strong) NSString *permissionAlertTitle;
@property(nonatomic, strong) NSString *permissionAlertContent;
@property(nonatomic, strong) NSString *permissionAlertCancelTitle;
@property(nonatomic, strong) NSString *permissionAlertOkTitle;
@property (nonatomic, assign) NSInteger recognizeType;

@end

@implementation QRCaptureView

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if (self = [super initWithFrame:frame]) {
        NSString *name = [NSString stringWithFormat:@"plugins/qr_capture/method_%lld", viewId];
        FlutterMethodChannel *channel = [FlutterMethodChannel
                                         methodChannelWithName:name
                                         binaryMessenger:registrar.messenger];
        
        if (args != nil &&
            [args isKindOfClass:NSDictionary.class]) {
            NSDictionary *dict = (NSDictionary *)args;
            _permissionAlertTitle = dict[@"permissionAlertTitle"];
            _permissionAlertContent = dict[@"permissionAlertContent"];
            _permissionAlertCancelTitle = dict[@"permissionAlertCancelTitle"];
            _permissionAlertOkTitle = dict[@"permissionAlertOkTitle"];
        }
        
        _recognizeType = 0;
        
        if (!_permissionAlertTitle) {
            _permissionAlertTitle = @"Prompt";
        }
        if (!_permissionAlertCancelTitle) {
            _permissionAlertCancelTitle = @"Cancel";
        }
        if (!_permissionAlertOkTitle) {
            _permissionAlertOkTitle = @"Go Setting";
        }
        if (!_permissionAlertContent) {
            _permissionAlertContent = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSCameraUsageDescription"];
        }
        
        self.channel = channel;
        [registrar addMethodCallDelegate:self channel:channel];
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized || status == AVAuthorizationStatusNotDetermined) {
            
            AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            self.captureLayer = layer;
            
            layer.backgroundColor = [UIColor blackColor].CGColor;
            [self.layer addSublayer:layer];
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
            AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
            [self.session addInput:input];
            [self.session addOutput:output];
            self.session.sessionPreset = AVCaptureSessionPresetHigh;
            
            output.metadataObjectTypes = output.availableMetadataObjectTypes;
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [output setMetadataObjectTypes:@[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  [self.session startRunning];
             });

        } else {
        
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:_permissionAlertTitle message:_permissionAlertContent preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:_permissionAlertCancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
            }]];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:_permissionAlertOkTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication]
                             openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }]];
            
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
        
            // Deprecated, iOS > 9.0
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_permissionAlertTitle message:_permissionAlertContent delegate:self cancelButtonTitle:_permissionAlertCancelTitle otherButtonTitles:_permissionAlertOkTitle, nil];
//                [alert show];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.captureLayer.frame = self.bounds;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"pause"]) {
        [self pause];
    } else if ([call.method isEqualToString:@"resume"]) {
        [self resume];
    } else if ([call.method isEqualToString:@"setRecognizeType"]) {
        NSInteger type = (NSInteger)call.arguments[@"recognizeType"];
        [self setRecognizeType:type];
    } else if ([call.method isEqualToString:@"setTorchMode"]) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (!device.hasTorch) {
            return;
        }
        NSNumber *isOn = call.arguments;
        [device lockForConfiguration:nil];
        if (isOn.boolValue) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

- (void)resume {
    [self.session startRunning];
}

- (void)pause {
    [self.session stopRunning];
}

- (void)setRecognizeType:(NSInteger)type {
    
//    setRecognizeType(type)
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *value = metadataObject.stringValue;
        if (value.length && self.channel) {
            [self.channel invokeMethod:@"onCaptured" arguments:value];
        }
    }
}

- (void)dealloc {
    [self.session stopRunning];
}

@end
