//
//  FCProgressView.h
//  FCPageController
//
//  Created by fcx on 2018/3/15.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCProgressView : UIView

@property (nonatomic, strong) NSArray *itemFrames;

@property (nonatomic, assign) CGColorRef color;

@property (nonatomic, assign) CGFloat progress;

@end
