//
//  KZColorWheelView.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZColorPickerHSWheel;
@class KZColorPicker;

@protocol KZColorPickerDelegate <NSObject>

- (void)colorPicker:(KZColorPicker*)picker didChanged:(UIColor *)color;

@end

@interface KZColorPicker : UIControl
{
    KZColorPickerHSWheel *colorWheel;
}

@property (strong,nonatomic) UIColor *selectedColor;
@property (weak, nonatomic) id <KZColorPickerDelegate> delegate;

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated;

@end
