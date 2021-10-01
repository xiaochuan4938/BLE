//
//  LightViewController.h
//  BLELight
//
//  Created by 姚小川 on 9/29/21.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface LightViewController : UIViewController

@property(nonatomic, strong) CBCharacteristic* rwCharacteristic;

@end

NS_ASSUME_NONNULL_END
