//
//  FCMenuView.h
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCMenuView;

@protocol FCMenuViewDelegate <NSObject>

@optional

/**
 Called after the user click the menu item.

 @param menuView menu view
 @param index index
 @param currentIndex currentIndex
 */
- (void)menuView:(FCMenuView *)menuView didSelectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
- (CGFloat)menuView:(FCMenuView *)menuView widthForItemAtIndex:(NSInteger)index;

@end

@interface FCMenuView : UIView

/**
 This array stores the title of the menuItems.
 */
@property(nonatomic, strong) NSArray *items;

/**
 This delegate conforms to the 'FCMenuViewDelegate' protocol of the menuView.
 */
@property(nonatomic, weak) id <FCMenuViewDelegate> delegate;

/**
 This method is used to initialize a menu instance.

 @param frame The menu view's frame.
 @param items The menu view's titles.
 @param backgroundColor The menu view's backgroundColor.
 @param normalSize The menu view's normalSize.
 @param selectedSize The menu view's selectedSize.
 @param normalColor The menu view's normalColor.
 @param selectedColor The menu view's selectedColor.
 @return An FCMenuView instance that has been initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame
                  buttonItems:(NSArray *)items
              backgroundColor:(UIColor *)backgroundColor
                   normalSize:(CGFloat)normalSize
                 selectedSize:(CGFloat)selectedSize
                  normalColor:(UIColor *)normalColor
                selectedColor:(UIColor *)selectedColor;

/**
 The scrolling progress of the menu view.

 @param progress progress
 */
- (void)slideMenuAtProgress:(CGFloat)progress;

@end
