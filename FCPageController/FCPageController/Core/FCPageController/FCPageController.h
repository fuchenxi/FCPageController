//
//  FCPageController.h
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCMenuView.h"

@interface FCPageController : UIViewController

/**
 This array stores the class of the childViewControllers.
 */
@property(nonatomic, strong) NSArray *viewControllerClasses;

/**
 This array stores the title of the childViewControllers.
 */
@property(nonatomic, strong) NSArray *titles;

/**
 The current controller.
 */
@property(nonatomic, strong) UIViewController *currentViewController;

/**
 The current selection of the controller's index.
 */
@property(nonatomic, assign) int selectedIndex;

/**
 default NO. if YES, stop on multiples of view bounds
 */
@property(nonatomic, assign) BOOL pageAnimatable;

/**
 The size of the selected title of the menu view.
 */
@property(nonatomic, assign) CGFloat titleSizeSelected;

/**
 The size of the normal title of the menu view.
 */
@property(nonatomic, assign) CGFloat titleSizeNormal;

/**
 The color of the selected title of the menu view.
 */
@property(nonatomic, strong) UIColor *titleColorSelected;

/**
 The color of the normal title of the menu view.
 */
@property(nonatomic, strong) UIColor *titleColorNormal;

/**
 Customize menu view's height.
 */
@property(nonatomic, assign) CGFloat menuHeight;

/**
 Customize menu view item's height.
 */
@property(nonatomic, assign) CGFloat menuItemWidth;

/**
 Customize the background color of the menu view.
 */
@property(nonatomic, strong) UIColor *menuBackgroundColor;

/**
 The array stores the width of each item, and the type is NSNumber.
 */
@property (nonatomic, strong) NSArray *itemsWidths;

/**
 The menu view progress style. Default is 'FCMenuViewStyleLine'.
 */
@property (nonatomic, assign) FCMenuViewStyle menuViewStyle;

/**
 Initialize a pageController instance with the classes of the child controller and their title.

 @param classes Classes of the child controllers.
 @param titles Titles of the child controllers.
 @return An FCPageController's instance that has been initialized.
 */
- (instancetype)initWithViewControllerClasses:(NSArray *)classes andThierTitles:(NSArray *)titles;

@end
