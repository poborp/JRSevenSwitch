//
//  JRSevenSwitch.h
//  ShellB2C
//
//  Created by Jacobo Rodriguez on 16/11/16.
//  Copyright © 2016 Jacobo Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRSevenSwitch : UIControl

@property (nonatomic, assign, getter=isOn) BOOL on;
@property (nonatomic, strong) UIColor *activeColor;
@property (nonatomic, strong) UIColor *inactiveColor;
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *thumbTintColor;
@property (nonatomic, strong) UIColor *onThumbTintColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign, getter=isRounded) BOOL rounded;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, strong) UIImage *offImage;
@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, assign, getter=isLoading) BOOL loading;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
