//
//  FCPageConst.m
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import <UIKit/UIKit.h>

//  标题的尺寸(选中/非选中)
#define kFCTitleSizeSelected 18
#define kFCTitleSizeNormal   15

//  标题的颜色(选中/非选中) (P.S.标题颜色是可动画的，请确保颜色具有RGBA分量，如通过RGBA创建)
#define kFCTitleColorSelected [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1]
#define kFCTitleColorNormal   [UIColor colorWithRed:0 green:0 blue:0 alpha:1]

//  导航菜单栏的背景颜色
#define kFCMenuBGColor [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0]
//  导航菜单栏的高度
#define kFCMenuHeight  44
//  导航菜单栏每个item的宽度
#define kFCMenuItemWidth 65


static NSString *const FCControllerDidFinishInitNotification = @"FCControllerDidFinishInitNotification";

static NSString *const FCControllerDidFullyDisplayedNotification = @"FCControllerDidFullyDisplayedNotification";

