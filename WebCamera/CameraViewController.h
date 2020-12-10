//
//  CameraViewController.h
//  WebCamera
//
//  Created by John on 2020/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController

@property (nonatomic) void (^completeBlock)(NSString *);

@end

NS_ASSUME_NONNULL_END
