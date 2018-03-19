//
//  FCMenuView.m
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import "FCMenuView.h"
#import "FCMenuItem.h"
#import "FCProgressView.h"

#define kFCMaskWidth 20
#define kFCItemWidth 60
#define kFCMenuMargin 0
#define kFCTagGap    6250
#define kFCBGColor [UIColor colorWithRed:172.0/255.0 green:165.0/255.0 blue:162.0/255.0 alpha:1.0]

static CGFloat const FCProgressHeight = 2.0;

@interface FCMenuView () <UIScrollViewDelegate, FCMenuItemDelegate> {
    
    CGFloat _normalSize;
    CGFloat _selectedSize;
    UIColor *_normalColor;
    UIColor *_selectedColor;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) FCMenuItem *selectedItem;

@property (nonatomic, strong) FCProgressView *progressView;

@property (nonatomic, strong) NSMutableArray *frames;

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation FCMenuView

#pragma mark - Public Methods
- (void)didPressedMenuItem:(FCMenuItem *)menuItem {
    
    if (self.selectedItem == menuItem) return;
    NSInteger currentIndex = self.selectedItem.tag - kFCTagGap;
    
    CGFloat progress = menuItem.tag - kFCTagGap;
    self.progressView.progress = progress;
    
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelectedIndex:(menuItem.tag - kFCTagGap) currentIndex:currentIndex];
    }
    menuItem.selected = YES;
    self.selectedItem.selected = NO;
    self.selectedItem = menuItem;
    [self refreshContentOffset];
}

- (void)slideMenuAtProgress:(CGFloat)progress {
    
    if (self.style == FCMenuViewStyleLine) {
        self.progressView.progress = progress;
    }
    
    NSInteger tag = (NSInteger)progress + kFCTagGap;
    CGFloat rate = progress - tag + kFCTagGap;
    
    FCMenuItem *currentItem = (FCMenuItem *)[self viewWithTag:tag];
    FCMenuItem *nextItem = (FCMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        rate = 1.0;
        self.selectedItem.rate = 0.f;
        [self.selectedItem deselectedItemWithoutAnimation];
        self.selectedItem = currentItem;
        self.selectedItem.rate = 1.f;
        [self.selectedItem selectedItemWithoutAnimation];
        [self refreshContentOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

- (void)selectItemAtIndex:(NSInteger)index {
    
    NSInteger tag = index + kFCTagGap;
    NSInteger currentIndex = self.selectedItem.tag - kFCTagGap;
    FCMenuItem *item = (FCMenuItem *)[self viewWithTag:tag];
    [self.selectedItem deselectedItemWithoutAnimation];
    self.selectedItem = item;
    [self.selectedItem selectedItemWithoutAnimation];
    self.progressView.progress = index;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelectedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelectedIndex:index currentIndex:currentIndex];
    }
    [self refreshContentOffset];
}

#pragma mark - Init Methods
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

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    [self configureScrollView];
    [self configureItems];
    if (self.style == FCMenuViewStyleLine) {
        [self configureProgressView];
    }
}

#pragma mark - Configure Methods
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
    
    [self calculateItemFrames];
    
    for (int i = 0; i < self.items.count; i++) {
        
        FCMenuItem *item = [[FCMenuItem alloc] initWithFrame:[self.frames[i] CGRectValue]];
        item.tag = kFCTagGap + i;
        item.title = self.items[i];
        item.delegate = self;
        item.backgroundColor = [UIColor clearColor];
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
}

- (void)configureProgressView {
    
    self.progressView = ({
        
        FCProgressView *progressView = [[FCProgressView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - FCProgressHeight, self.scrollView.contentSize.width, FCProgressHeight)];
        progressView.itemFrames = self.frames;
        progressView.color = _selectedColor.CGColor;
        progressView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:progressView];
        progressView;
    });
}

#pragma mark - Getter Methods
- (NSMutableArray *)frames {
    
    if (!_frames) {
        
        _frames = [NSMutableArray array];
    }
    return _frames;
}

- (UIColor *)lineColor {
    
    if (!_lineColor) {
        
        _lineColor = _selectedColor;
    }
    return _lineColor;
}

#pragma mark - Private Methods
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

- (void)calculateItemFrames {
    
    CGFloat contentWidth = kFCMenuMargin;
    
    for (int i = 0; i < self.items.count; i++) {
        
        CGFloat itemWidth = kFCItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemWidth = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemWidth, self.frame.size.height);
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemWidth;
    }
    
    contentWidth += kFCMenuMargin;
    
    if (contentWidth < self.frame.size.width) {
        
        CGFloat distance = self.frame.size.width - contentWidth;
        CGFloat gap = distance / (self.items.count + 1);
        
        for (int i = 0; i < self.frames.count; i++) {
            
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += gap * (i + 1);
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.frame.size.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

@end
