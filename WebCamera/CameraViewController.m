//
//  CameraViewController.m
//  WebCamera
//
//  Created by John on 2020/12/7.
//

#import "CameraViewController.h"
#import "PSWebSocketServer.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController () <PSWebSocketServerDelegate>

@property (nonatomic) PSWebSocketServer *webSocketServer;
@property (nonatomic) UIImageView *cameraImageView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    self.view.backgroundColor = UIColor.blackColor;
    self.webSocketServer = [PSWebSocketServer serverWithHost:nil port:44445];
    self.webSocketServer.delegate = self;
    [self.webSocketServer start];
    
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:@"http://localhost:44446"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }] resume];
    
    self.cameraImageView = [[UIImageView alloc] init];
    self.cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.cameraImageView];
}

- (void)viewDidLayoutSubviews
{
    self.cameraImageView.frame = self.view.bounds;
}

#pragma mark - PSWebSocketServerDelegate
- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Server did start…");
    NSLog(@"open webCamera.html"); //打开摄像头web页，退出扫码后web页会自动关闭
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:@"http://localhost:44446?cmd=open"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }] resume];
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Server did stop…");
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"Server did fail error: %@", error);
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    NSLog(@"Server should accept request: %@", request);
    return YES;
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    //NSLog(@"Server websocket did receive message: %@", message);
    if ([message isKindOfClass:NSData.class]) {
        UIImage *image = [UIImage imageWithData:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraImageView.image = image;
        });
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
        NSArray *feature = [detector featuresInImage:ciImage];
        CIQRCodeFeature *result = feature.firstObject;
        if (result.messageString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completeBlock(result.messageString);
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Server websocket did open");
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}

@end
