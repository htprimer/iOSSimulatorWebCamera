//
//  ViewController.m
//  WebCamera
//
//  Created by John on 2020/12/6.
//

#import "ViewController.h"
#import "PSWebSocketServer.h"
#import "CameraViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    
}

- (IBAction)scanAction:(id)sender
{
    __auto_type camera = [[CameraViewController alloc] init];
    [camera setCompleteBlock:^(NSString *result) {
        self.resultLabel.text = result;
    }];
    [self presentViewController:camera animated:YES completion:nil];
}

@end
