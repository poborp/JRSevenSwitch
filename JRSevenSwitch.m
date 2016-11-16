//
//  JRSevenSwitch.m
//  ShellB2C
//
//  Created by Jacobo Rodriguez on 16/11/16.
//  Copyright © 2016 Jacobo Rodriguez. All rights reserved.
//

#import "JRSevenSwitch.h"

@interface JRSevenSwitch ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIImageView *onImageView;
@property (nonatomic, strong) UIImageView *offImageView;
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UIActivityIndicatorView *onLoadingActivityIndicatorView;
@property (nonatomic, strong) UIActivityIndicatorView *offLoadingActivityIndicatorView;

@property (nonatomic, assign) BOOL currentVisualValue;
@property (nonatomic, assign) BOOL startTrackingValue;
@property (nonatomic, assign) BOOL didChangeWhileTracking;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) BOOL userDidSpecifyOnThumbTintColor;
@property (nonatomic, assign) BOOL switchValue;

@end

@implementation JRSevenSwitch

- (instancetype)init {
    
    return [self initWithFrame:CGRectMake(0, 0, 60, 30)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _activeColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
        _inactiveColor = [UIColor clearColor];
        _onTintColor = [UIColor colorWithRed:0.3 green:0.85 blue:0.39 alpha:1.0];
        _borderColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];
        _thumbTintColor = [UIColor whiteColor];
        _onThumbTintColor = [UIColor whiteColor];
        _shadowColor = [UIColor grayColor];
        _rounded = YES;
        
        _currentVisualValue = NO;
        _startTrackingValue = NO;
        _didChangeWhileTracking = NO;
        _animating = NO;
        _userDidSpecifyOnThumbTintColor = NO;
        _switchValue = NO;
        
        _backgroundView = [UIView new];
        _backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.layer.cornerRadius = self.frame.size.height * 0.5;
        _backgroundView.layer.borderColor = self.borderColor.CGColor;
        _backgroundView.layer.borderWidth = 1.0;
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.clipsToBounds = YES;
        [self addSubview:_backgroundView];
        
        _onImageView = [UIImageView new];
        _onImageView.frame = CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height);
        _onImageView.alpha = 1.0;
        _onImageView.contentMode = UIViewContentModeCenter;
        [_backgroundView addSubview:_onImageView];
        
        _onLoadingActivityIndicatorView = [UIActivityIndicatorView new];
        _onLoadingActivityIndicatorView.frame = _onImageView.frame;
        _onLoadingActivityIndicatorView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        _onLoadingActivityIndicatorView.hidesWhenStopped = YES;
        [_backgroundView addSubview:_onLoadingActivityIndicatorView];
        
        _offImageView = [UIImageView new];
        _offImageView.frame = CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height);
        _offImageView.alpha = 1.0;
        _offImageView.contentMode = UIViewContentModeCenter;
        [_backgroundView addSubview:_offImageView];
        
        _offLoadingActivityIndicatorView = [UIActivityIndicatorView new];
        _offLoadingActivityIndicatorView.frame = _offImageView.frame;
        _offLoadingActivityIndicatorView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        _offLoadingActivityIndicatorView.hidesWhenStopped = YES;
        [_backgroundView addSubview:_offLoadingActivityIndicatorView];
        
        _onLabel = [UILabel new];
        _onLabel.frame = CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height);
        _onLabel.textAlignment = NSTextAlignmentCenter;
        _onLabel.textColor = [UIColor lightGrayColor];
        _onLabel.font = [UIFont systemFontOfSize:12];
        [_backgroundView addSubview:_onLabel];
        
        _offLabel = [UILabel new];
        _offLabel.frame = CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height);
        _offLabel.textAlignment = NSTextAlignmentCenter;
        _offLabel.textColor = [UIColor lightGrayColor];
        _offLabel.font = [UIFont systemFontOfSize:12];
        [_backgroundView addSubview:_offLabel];
        
        _thumbView = [UIView new];
        _thumbView.frame = CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2);
        _thumbView.backgroundColor = self.thumbTintColor;
        _thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1;
        _thumbView.layer.shadowColor = self.shadowColor.CGColor;
        _thumbView.layer.shadowRadius = 2.0;
        _thumbView.layer.shadowOpacity = 0.5;
        _thumbView.layer.shadowOffset = CGSizeMake(0, 3);
        _thumbView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_thumbView.bounds cornerRadius:_thumbView.layer.cornerRadius].CGPath;
        _thumbView.layer.masksToBounds = false;
        _thumbView.userInteractionEnabled = false;
        [self addSubview:_thumbView];
        
        _thumbImageView = [UIImageView new];
        _thumbImageView.frame = CGRectMake(0, 0, _thumbView.frame.size.width, _thumbView.frame.size.height);
        _thumbImageView.contentMode = UIViewContentModeCenter;
        _thumbImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_thumbView addSubview:_thumbImageView];
        
        self.on = NO;
    }
    
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super beginTrackingWithTouch:touch withEvent:event];
    
    self.startTrackingValue = self.on;
    self.didChangeWhileTracking = NO;
    
    CGFloat activeKnobWidth = self.bounds.size.height - 2 + 5;
    self.animating = YES;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.on) {
            self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
            self.backgroundView.backgroundColor = self.onTintColor;
            self.thumbView.backgroundColor = self.onThumbTintColor;
        } else {
            self.thumbView.frame = CGRectMake(self.thumbView.frame.origin.x, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
            self.backgroundView.backgroundColor = self.activeColor;
            self.thumbView.backgroundColor = self.thumbTintColor;
        }
    } completion:^(BOOL finished) {
        self.animating = NO;
    }];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super continueTrackingWithTouch:touch withEvent:event];
    
    // Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    // update the switch to the correct visuals depending on if
    // they moved their touch to the right or left side of the switch
    if (lastPoint.x > self.bounds.size.width * 0.5) {
        [self showOnAnimated:YES];
        if (!self.startTrackingValue) {
            self.didChangeWhileTracking = YES;
        }
    } else {
        [self showOffAnimated:YES];
        if (self.startTrackingValue) {
            self.didChangeWhileTracking = YES;
        }
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super endTrackingWithTouch:touch withEvent:event];
    
    BOOL previousValue = self.on;
    
    if (self.didChangeWhileTracking) {
        [self setOn:self.currentVisualValue animated:YES];
    } else {
        [self setOn:!self.on animated:YES];
    }
    
    if (previousValue != self.on) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
    [super cancelTrackingWithEvent:event];
    
    // just animate back to the original value
    if (self.on) {
        [self showOnAnimated:YES];
    } else {
        [self showOffAnimated:YES];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (!self.isAnimating) {
        CGRect frame = self.frame;
        
        // background
        self.backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.backgroundView.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2;
        
        // images
        self.onImageView.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height);
        self.offImageView.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height);
        self.onLabel.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height);
        self.offLabel.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height);
        
        // thumb
        CGFloat normalKnobWidth = frame.size.height - 2;
        if (self.on) {
            self.thumbView.frame = CGRectMake(frame.size.width - (normalKnobWidth + 1), 1, frame.size.height - 2, normalKnobWidth);
        } else {
            self.thumbView.frame = CGRectMake(1, 1, normalKnobWidth, normalKnobWidth);
        }
        
        self.thumbView.layer.cornerRadius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2;
    }
}

#pragma mark - Public Actions

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    
    _on = on;
    _switchValue = on;
    
    if (on) {
        [self showOnAnimated:animated];
    } else {
        [self showOffAnimated:animated];
    }
}

#pragma mark - Setter

- (void)setOn:(BOOL)on {
    
    [self setOn:on animated:YES];
}

- (void)setActiveColor:(UIColor *)activeColor {
    
    _activeColor = activeColor;
    
    if (self.on && !self.isTracking) {
        self.backgroundView.backgroundColor = activeColor;
    }
}

- (void)setInactiveColor:(UIColor *)inactiveColor {
    
    _inactiveColor = inactiveColor;
    
    if (!self.on && !self.isTracking) {
        self.backgroundView.backgroundColor = inactiveColor;
    }
}

- (void)setOnTintColor:(UIColor *)onTintColor {

    _onTintColor = onTintColor;
    
    if (self.on && !self.isTracking) {
        self.backgroundView.backgroundColor = onTintColor;
        self.backgroundView.layer.borderColor = onTintColor.CGColor;
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    
    if (!self.on) {
        self.backgroundView.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    
    _thumbTintColor = thumbTintColor;
    
    if (!self.userDidSpecifyOnThumbTintColor) {
        self.onThumbTintColor = thumbTintColor;
    }
    if ((!self.userDidSpecifyOnThumbTintColor || !self.on) && !self.isTracking) {
        self.thumbView.backgroundColor = thumbTintColor;
    }
}

- (void)setOnThumbTintColor:(UIColor *)onThumbTintColor {
    
    _onThumbTintColor = onThumbTintColor;
    
    self.userDidSpecifyOnThumbTintColor = YES;
    if (self.on && !self.isTracking) {
        self.thumbView.backgroundColor = onThumbTintColor;
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    
    _shadowColor = shadowColor;
    
    self.thumbView.layer.shadowColor = shadowColor.CGColor;
}

- (void)setRounded:(BOOL)rounded {
    
    _rounded = rounded;
    
    if (rounded) {
        self.backgroundView.layer.cornerRadius = self.frame.size.height * 0.5;
        self.thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1;
    } else {
        self.backgroundView.layer.cornerRadius = 4;
        self.thumbView.layer.cornerRadius = 4;
    }
    
    self.thumbView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.thumbView.bounds cornerRadius:self.thumbView.layer.cornerRadius].CGPath;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    
    _thumbImage = thumbImage;
    
    self.thumbImageView.image = thumbImage;
}

- (void)setOnImage:(UIImage *)onImage {
    
    _onImage = onImage;
    
    self.onImageView.image = onImage;
}

- (void)setOffImage:(UIImage *)offImage {
    
    _offImage = offImage;
    
    self.offImageView.image = offImage;
}

- (void)setOnLabel:(UILabel *)onLabel {
    
    _onLabel = onLabel;
}

- (void)setOffLabel:(UILabel *)offLabel {
    
    _offLabel = offLabel;
}

- (void)setLoading:(BOOL)loading {
    
    _loading = loading;
    
    self.onImageView.hidden = loading;
    self.offImageView.hidden = loading;
    
    if (loading) {
        if (self.on) {
            [self.onLoadingActivityIndicatorView startAnimating];
        } else {
            [self.offLoadingActivityIndicatorView startAnimating];
        }
    } else {
        [self.onLoadingActivityIndicatorView stopAnimating];
        [self.offLoadingActivityIndicatorView stopAnimating];
    }
}

#pragma mark - Private

- (void)showOnAnimated:(BOOL)animated {
    
    CGFloat normalKnobWidth = self.bounds.size.height - 2;
    CGFloat activeKnobWidth = normalKnobWidth + 5;
    
    if (animated) {
        
        self.animating = YES;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.isTracking) {
                self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
            } else {
                self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
            }
            
            self.backgroundView.backgroundColor = self.onTintColor;
            self.backgroundView.layer.borderColor = self.onTintColor.CGColor;
            self.thumbView.backgroundColor = self.onThumbTintColor;
            self.onImageView.alpha = 1.0;
            self.offImageView.alpha = 0;
            self.onLabel.alpha = 1.0;
            self.offLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.animating = NO;
        }];
        
    } else {
        
        if (self.isTracking) {
            self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + 1), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
        } else {
            self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
        }
        
        self.backgroundView.backgroundColor = self.onTintColor;
        self.backgroundView.layer.borderColor = self.onTintColor.CGColor;
        self.thumbView.backgroundColor = self.onThumbTintColor;
        self.onImageView.alpha = 1.0;
        self.offImageView.alpha = 0;
        self.onLabel.alpha = 1.0;
        self.offLabel.alpha = 0;
    }
    
    self.currentVisualValue = YES;
}

- (void)showOffAnimated:(BOOL)animated {
    
    CGFloat normalKnobWidth = self.bounds.size.height - 2;
    CGFloat activeKnobWidth = normalKnobWidth + 5;
    
    if (animated) {
        
        self.animating = YES;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.isTracking) {
                self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
                self.backgroundView.backgroundColor = self.activeColor;
            } else {
                self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
                self.backgroundView.backgroundColor = self.inactiveColor;
            }
            
            self.backgroundView.layer.borderColor = self.borderColor.CGColor;
            self.thumbView.backgroundColor = self.thumbTintColor;
            self.onImageView.alpha = 0;
            self.offImageView.alpha = 1.0;
            self.onLabel.alpha = 0;
            self.offLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.animating = NO;
        }];
        
    } else {
        
        if (self.isTracking) {
            self.thumbView.frame = CGRectMake(1, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
            self.backgroundView.backgroundColor = self.activeColor;
        } else {
            self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + 1), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
            self.backgroundView.backgroundColor = self.inactiveColor;
        }
        
        self.backgroundView.layer.borderColor = self.borderColor.CGColor;
        self.thumbView.backgroundColor = self.thumbTintColor;
        self.onImageView.alpha = 0;
        self.offImageView.alpha = 1.0;
        self.onLabel.alpha = 0;
        self.offLabel.alpha = 1.0;
    }
    
    self.currentVisualValue = NO;
}

@end
