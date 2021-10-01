//
//  KZColorWheelView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPicker.h"
#import "KZColorPickerHSWheel.h"
#import "HSV.h"
#import "UIColor-Expanded.h"
#import "KZColorCompareView.h"

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface KZColorPicker()
@property (nonatomic, retain) KZColorPickerHSWheel *colorWheel;
@end


@implementation KZColorPicker
@synthesize colorWheel;
@synthesize selectedColor;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
	{
        [self setup];
    }
    return self;
}

- (void) awakeFromNib
{
	[self setup];
}

- (void) setup
{
    KZColorPickerHSWheel *wheel = [[KZColorPickerHSWheel alloc] initAtOrigin:CGPointMake(0, 0)];
    [wheel addTarget:self action:@selector(colorWheelColorChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:wheel];
    self.colorWheel = wheel;
    //默认
    self.selectedColor = [UIColor whiteColor];
    
}

RGBType rgbWithUIColor(UIColor *color)
{
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	
	CGFloat r,g,b,alpha;
    [color getRed:&r green:&g blue:&b alpha:&alpha ];
//	 NSLog(@"%f,%f,%f,%f",r,g,b,alpha);
	switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)))
	{
		case kCGColorSpaceModelMonochrome://单色
			r = g = b = components[0];
			break;
		case kCGColorSpaceModelRGB://RGB
			r = components[0];
			g = components[1];
			b = components[2];
			break;
		default:
			return RGBTypeMake(0, 0, 0);
	}
	
   
	return RGBTypeMake(r, g, b);
}

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
	if (animated) 
	{
		[UIView beginAnimations:nil context:nil];
		self.selectedColor = color;
		[UIView commitAnimations];
	}
	else 
	{
		self.selectedColor = color;
	}
}

- (void) setSelectedColor:(UIColor *)c
{
	
	selectedColor = c;
	RGBType rgb = rgbWithUIColor(c);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.colorWheel.currentHSV = hsv;
    UIColor *keyColor = [UIColor colorWithHue:hsv.h 
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
    
    keyColor = [UIColor colorWithHue:hsv.h 
                          saturation:hsv.s
                          brightness:hsv.v
                               alpha:1.0];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (void) colorWheelColorChanged:(KZColorPickerHSWheel *)wheel
{
	HSVType hsv = wheel.currentHSV;
	self.selectedColor = [UIColor colorWithHue:hsv.h
									saturation:hsv.s
									brightness:1
										 alpha:1];
    if ([self.delegate respondsToSelector:@selector(colorPicker:didChanged:)])
    {
        [self.delegate colorPicker:self
                        didChanged:self.selectedColor];
        
    }
    
    
}



- (void) layoutSubviews
{
    [UIView beginAnimations:nil context:nil];
    [UIView commitAnimations];
}

@end
