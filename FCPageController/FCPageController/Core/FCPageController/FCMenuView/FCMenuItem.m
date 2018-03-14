//
//  FCMenuItem.m
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import "FCMenuItem.h"

#define kFCSelectedSize 18
#define kFCNormolSize   15
#define kFCAnimateStep  0.2
#define kFCAnimateRate  0.1

#define kFCBGColor        [UIColor whiteColor]
#define kFCSelectedColor  [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1]
#define kFCNormalColor    [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

@interface FCMenuItem () {
    
    CGFloat _rgba[4];
    CGFloat _rgbaGap[4];
    BOOL _hasRGBA;
}

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) CGFloat sizeGap;

@end

@implementation FCMenuItem

- (void)selectedItemWithoutAnimation {
    
    self.titleColor = self.selectedColor;
    self.font = [UIFont systemFontOfSize:self.selectedSize];
    _rate = 1.0;
    _selected = YES;
    [self setNeedsDisplay];
}

- (void)deselectedItemWithoutAnimation {
    
    self.titleColor = self.normalColor;
    self.font = [UIFont systemFontOfSize:self.normalSize];
    _rate = 0;
    _selected = NO;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([self.delegate respondsToSelector:@selector(didPressedMenuItem:)]) {
        
        [self.delegate didPressedMenuItem:self];
    }
}

#pragma mark - Init Methods
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = kFCBGColor;
        _hasRGBA = NO;
    }
    return self;
}

#pragma mark - Setter Mehtods
- (void)setSelected:(BOOL)selected {
    
    _selected = selected;
    if (self.link) return;
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeTitle)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setRate:(CGFloat)rate {
    
    _rate = rate;
    [self updateFontAndRGBA];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font{
    _font = font;
    
    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    
    [self setNeedsDisplay];
}

#pragma mark - Getter Mehtods
- (CGFloat)normalSize {
    if (!_normalSize) {
    
        _normalSize = kFCNormolSize;
    }
    return _normalSize;
}

- (CGFloat)selectedSize {
    
    if (!_selectedSize) {
    
        _selectedSize = kFCSelectedSize;
    }
    return _selectedSize;
}

- (CGFloat)sizeGap {
    
    if (!_sizeGap) {
        
        _sizeGap = self.selectedSize - self.normalSize;
    }
    return _sizeGap;
}
- (UIColor *)selectedColor {
    
    if (!_selectedColor) {
        
        _selectedColor = kFCSelectedColor;
    }
    return _selectedColor;
}
- (UIColor *)normalColor {
    
    if (!_normalColor) {
        
        _normalColor = kFCNormalColor;
    }
    return _normalColor;
}

- (void)drawRect:(CGRect)rect {
    
    if (!self.title) return;
    if (self.font == nil)
        self.font = [UIFont systemFontOfSize:self.normalSize];
    if (self.titleColor == nil)
        self.titleColor = self.normalColor;
    NSDictionary *attributes = @{NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : self.titleColor
                                 };
    
    CGSize size = [self.title sizeWithAttributes:attributes];
    CGFloat x = (self.frame.size.width - size.width) / 2;
    CGFloat y = (self.frame.size.height - size.height) / 2;
    [self.title drawAtPoint:CGPointMake(x, y) withAttributes:attributes];
}

- (void)changeTitle {
    
    if (!_hasRGBA) {
        
        [self setRGBA];
    }
    if (self.isSelected) {
        
        if (self.rate < 1.0f) {
            self.rate += kFCAnimateRate;
        } else {
            [self.link invalidate];
            self.link = nil;
        }
    } else {
        if (self.rate > 0.0f) {
            self.rate -= kFCAnimateRate;
        } else {
            [self.link invalidate];
            self.link = nil;
        }
    }
}

- (void)setRGBA {
    
    int numNormal = (int)CGColorGetNumberOfComponents(self.normalColor.CGColor);
    int numSelected = (int)CGColorGetNumberOfComponents(self.selectedColor.CGColor);
    if (numNormal == 4 && numSelected == 4) {
        
        const CGFloat *norComponents = CGColorGetComponents(self.normalColor.CGColor);
        const CGFloat *selComponents = CGColorGetComponents(self.selectedColor.CGColor);
        _rgba[0] = norComponents[0];
        _rgba[1] = norComponents[1];
        _rgba[2] = norComponents[2];
        _rgba[3] = norComponents[3];
        
        _rgbaGap[0] = selComponents[0] - _rgba[0];
        _rgbaGap[1] = selComponents[1] - _rgba[1];
        _rgbaGap[2] = selComponents[2] - _rgba[2];
        _rgbaGap[3] = selComponents[3] - _rgba[3];
    }
    _hasRGBA = YES;
}

- (void)updateFontAndRGBA {
 
    if (!_hasRGBA) {
        [self setRGBA];
    }
    CGFloat fontSize = self.normalSize + self.sizeGap * self.rate;
    
    CGFloat r = _rgba[0] + _rgbaGap[0] * self.rate;
    CGFloat g = _rgba[1] + _rgbaGap[1] * self.rate;
    CGFloat b = _rgba[2] + _rgbaGap[2] * self.rate;
    CGFloat a = _rgba[3] + _rgbaGap[3] * self.rate;
    
    self.titleColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    self.font = [UIFont systemFontOfSize:fontSize];
}

@end
