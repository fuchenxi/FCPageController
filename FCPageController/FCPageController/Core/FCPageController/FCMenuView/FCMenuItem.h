//
//  FCMenuItem.h
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCMenuItem;

@protocol FCMenuItemDelegate <NSObject>

@optional

/**
 The press event of the item.

 @param menuItem menuItem
 */
- (void)didPressedMenuItem:(FCMenuItem *)menuItem;

@end

@interface FCMenuItem : UIView

/**
 The rate is used to control the title refresh state.
 */
@property (nonatomic, assign) CGFloat rate;

/**
 The font of the item.
 */
@property (nonatomic, strong) UIFont *font;

/**
 The title's color of the item.
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 The title of the item.
 */
@property (nonatomic, copy) NSString *title;

/**
 The normal font size of the item.
 */
@property (nonatomic, assign) CGFloat normalSize;

/**
 The selected font size of the item.
 */
@property (nonatomic, assign) CGFloat selectedSize;

/**
 The normal color of the item.
 */
@property (nonatomic, strong) UIColor *normalColor;

/**
 The selected color of the item.
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 The selected status of the item.
 */
@property (nonatomic, assign, getter = isSelected) BOOL selected;

/**
 This delegate conforms to the 'FCMenuItemDelegate' protocol of the item.
 */
@property (nonatomic, weak) id<FCMenuItemDelegate> delegate;

/**
 Without animation to select item.
 */
- (void)selectedItemWithoutAnimation;

/**
 Without animation to deselect item.
 */
- (void)deselectedItemWithoutAnimation;

@end
