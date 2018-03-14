//
//  FCMenuView.m
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import "FCMenuView.h"
#import "FCMenuItem.h"

#define kFCMaskWidth 20
#define kFCItemWidth 60
#define kFCMargin    0
#define kFCTagGap    6250
#define kFCBGColor [UIColor colorWithRed:172.0/255.0 green:165.0/255.0 blue:162.0/255.0 alpha:1.0]

@interface FCMenuView () <UIScrollViewDelegate, FCMenuItemDelegate> {
    
    CGFloat _normalSize;
    CGFloat _selectedSize;
    UIColor *_normalColor;
    UIColor *_selectedColor;
}

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) FCMenuItem *selectedItem;

@property(nonatomic, strong) UIColor *bgColor;

@end

@implementation FCMenuView

- (instancetype)initWithFrame:(CGRect)frame
                  buttonItems:(NSArray *)items
              backgroundColor:(UIColor *)backgroundColor
                   normalSize:(CGFloat)normalSize
                 selectedSize:(CGFloat)selectedSize
                  normalColor:(UIColor *)normalColor
                selectedColor:(UIColor *)selectedColor {
    
    if (self = [super initWithFrame:frame]) {
        
        self.items = items;
        if (backgroundColor) {
            self.bgColor = backgroundColor;
        } else {
            self.bgColor = kFCBGColor;
        }
        _normalSize = normalSize;
        _selectedSize = selectedSize;
        _normalColor = normalColor;
        _selectedColor = selectedColor;
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    
    [super willMoveToWindow:newWindow];
    [self configureScrollView];
    [self configureItems];
}

- (void)configureScrollView {
    
    self.scrollView = ({
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.backgroundColor = self.bgColor;
        [self addSubview:scrollView];
        scrollView;
    });
}

- (void)configureItems {
    
    CGFloat contentWidth = kFCMargin;
    for (int i = 0; i < self.items.count; i++) {
        
        CGFloat itemWidth = kFCItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemWidth = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemWidth, self.frame.size.height);
        contentWidth += itemWidth;
        FCMenuItem *item = [[FCMenuItem alloc] initWithFrame:frame];
        item.tag = kFCTagGap + i;
        item.title = self.items[i];
        item.delegate = self;
        item.backgroundColor = self.bgColor;
        if (_normalSize > 0.0001) {
            item.normalSize = _normalSize;
        }
        if (_selectedSize > 0.0001) {
            item.selectedSize = _selectedSize;
        }
        if (_normalColor) {
            item.normalColor = _normalColor;
        }
        if (_selectedColor) {
            item.selectedColor = _selectedColor;
        }
        if (i == 0) {
            [item selectedItemWithoutAnimation];
            self.selectedItem = item;
        }
        [self.scrollView addSubview:item];
    }
    contentWidth += kFCMargin;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (void)didPressedMenuItem:(FCMenuItem *)menuItem {
    
    if (self.selectedItem == menuItem) return;
    NSInteger currentIndex = self.selectedItem.tag - kFCTagGap;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelectedIndex:(menuItem.tag - kFCTagGap) currentIndex:currentIndex];
    }
    menuItem.selected = YES;
    self.selectedItem.selected = NO;
    self.selectedItem = menuItem;
    [self refreshContentOffset];
}

- (void)refreshContentOffset {
    
    CGRect itemFrame = self.selectedItem.frame;
    CGFloat itemX = itemFrame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width / 2) {

        CGFloat targetX;
        if (itemX >= contentSize.width - width / 2) {
            
            targetX = contentSize.width - width;

        } else {
            targetX = itemX + itemFrame.size.width / 2 - width / 2;
        }

        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (void)slideMenuAtProgress:(CGFloat)progress {
    
    NSInteger tag = (NSInteger)progress + kFCTagGap;
    CGFloat rate = progress - tag + kFCTagGap;
    FCMenuItem *currentItem = (FCMenuItem *)[self viewWithTag:tag];
    FCMenuItem *nextItem = (FCMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        rate = 1.0;
        [self.selectedItem deselectedItemWithoutAnimation];
        self.selectedItem = currentItem;
        [self.selectedItem selectedItemWithoutAnimation];
        [self refreshContentOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

@end
