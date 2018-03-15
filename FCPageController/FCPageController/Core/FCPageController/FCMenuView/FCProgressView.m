//
//  FCProgressView.m
//  FCPageController
//
//  Created by fcx on 2018/3/15.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import "FCProgressView.h"

@implementation FCProgressView {
    
    CADisplayLink *_link;
    CGFloat _gap;
    int _sign;
    CGFloat _step;
}

- (void)setProgress:(CGFloat)progress {
    
    if (self.progress == progress) return;
    if (fabs(progress - _progress) >= 0.94 && fabs(progress - _progress) < 1.2) {
        
        _gap = fabs(self.progress - progress);
        _sign = self.progress > progress ? -1 : 1;
        _step = _gap / 20.0;
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(progressChanged)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)progressChanged {
    
    if (_gap >= 0.0) {
        
        self.progress += _sign * _step;
        _gap -= _step;
        
    } else {
        
        self.progress = (int)(self.progress + 0.5);
        [_link invalidate];
        _link = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    int index = (int)self.progress;
    
    CGFloat rate = self.progress - index;
    CGRect currentFrame = [self.itemFrames[index] CGRectValue];
    CGFloat currentWidth = currentFrame.size.width;
    
    int nextIndex = index + 1 < self.itemFrames.count ? index + 1 : index;
    
    CGFloat nextWidth = [self.itemFrames[nextIndex] CGRectValue].size.width;
    CGFloat height = self.frame.size.height;
    CGFloat constY = height / 2;
    CGFloat startX = currentFrame.origin.x + currentWidth * rate;
    CGFloat endX = startX + currentWidth + (nextWidth - currentWidth)*rate;
    
    CGContextMoveToPoint(ctx, startX, constY);
    CGContextAddLineToPoint(ctx, endX, constY);
    CGContextSetLineWidth(ctx, height);
    CGContextSetStrokeColorWithColor(ctx, self.color);
    CGContextStrokePath(ctx);
}

- (void)dealloc {
    
    [_link invalidate];
    _link = nil;
}

@end
