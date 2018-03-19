//
//  FCPageController.m
//  FCPageController
//
//  Created by fcx on 2018/3/14.
//  Copyright © 2018年 fuchenxi. All rights reserved.
//

#import "FCPageController.h"
#import "FCPageConst.m"

@interface FCPageController () <UIScrollViewDelegate, FCMenuViewDelegate> {
    
    CGFloat _viewHeight;
    CGFloat _viewWidth;
    BOOL _animate;
}

/**
 Menu view.
 */
@property(nonatomic, strong) FCMenuView *menuView;

/**
 Scroll view.
 */
@property(nonatomic, strong) UIScrollView *scrollView;

/**
 This array stores the frame of the childViewControllers' view.
 */
@property(nonatomic, strong) NSMutableArray *childViewFrames;

/**
 This dictionary stores the controller that has been displayed.
 */
@property(nonatomic, strong) NSMutableDictionary *displayVC;

@end

@implementation FCPageController

#pragma mark - Public Methods
- (void)setSelectIndex:(int)selectIndex {
    
    _selectIndex = selectIndex;
    if (self.menuView) {
        [self.menuView selectItemAtIndex:selectIndex];
    }
}

- (void)setItemsWidths:(NSArray *)itemsWidths {
    
    if (itemsWidths.count != self.titles.count) return;
    _itemsWidths = itemsWidths;
    
}

#pragma mark - Init Method
- (instancetype)initWithViewControllerClasses:(NSArray *)classes andThierTitles:(NSArray *)titles {
    
    if (self = [super init]) {
        
        self.viewControllerClasses = classes;
        self.titles = titles;
        self.titleSizeNormal = kFCTitleSizeNormal;
        self.titleSizeSelected = kFCTitleSizeSelected;
        self.titleColorNormal = kFCTitleColorNormal;
        self.titleColorSelected = kFCTitleColorSelected;
        self.menuHeight = kFCMenuHeight;
        self.menuItemWidth = kFCMenuItemWidth;
        self.menuBackgroundColor = kFCMenuBGColor;
    }
    return self;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.titleSizeNormal = kFCTitleSizeNormal;
        self.titleSizeSelected = kFCTitleSizeSelected;
        self.titleColorNormal = kFCTitleColorNormal;
        self.titleColorSelected = kFCTitleColorSelected;
        self.menuHeight = kFCMenuHeight;
        self.menuItemWidth = kFCMenuItemWidth;
        self.menuBackgroundColor = kFCMenuBGColor;
    }
    return self;
}

#pragma mark - View Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self calculateSize];
    [self configureScrollView];
    [self configureMenuView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self addViewControllerAtIndex:0];
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

#pragma mark - Configure
- (void)configureScrollView {
    
    self.scrollView = ({
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:scrollView];
        scrollView;
    });
}

- (void)configureMenuView {
    
    self.menuView = ({
        
        FCMenuView *menuView = [[FCMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.menuHeight)
                                                     buttonItems:self.titles
                                                 backgroundColor:self.menuBackgroundColor
                                                      normalSize:self.titleSizeNormal
                                                    selectedSize:self.titleSizeSelected
                                                     normalColor:self.titleColorNormal
                                                   selectedColor:self.titleColorSelected];
        menuView.delegate = self;
        menuView.style = self.menuViewStyle;
        [self.view addSubview:menuView];
        menuView;
    });
    if (self.selectIndex != 0) {
        [self.menuView selectItemAtIndex:self.selectIndex];
    }
}

#pragma mark -
#pragma mark - Private Methods
- (void)addViewControllerAtIndex:(int)index {
    
    Class vcClass = self.viewControllerClasses[index];
    UIViewController *vc = [[vcClass alloc] init];
    vc.view.frame = [self.childViewFrames[index] CGRectValue];
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    [self.scrollView addSubview:vc.view];
    self.currentViewController = vc;
    [self.displayVC setObject:vc forKey:@(index)];
    
    [self postFinishInitNotificationWithIndex:index];
}

// 移除控制器，且从display中移除
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index{
    
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    
    [self.displayVC removeObjectForKey:@(index)];
}

- (void)calculateSize {
    
    _viewHeight = self.view.frame.size.height - self.menuHeight;
    _viewWidth = CGRectGetWidth(self.view.frame);
    
    _childViewFrames = [NSMutableArray array];
    for (int i = 0; i < self.viewControllerClasses.count; i++) {
        
        CGRect frame = CGRectMake(i * _viewWidth, 0, _viewWidth, _viewHeight);
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (BOOL)isInScreen:(CGRect)frame {
    
    CGFloat x = frame.origin.x;
    CGFloat screenWidth = self.scrollView.frame.size.width;
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < screenWidth) {
        return YES;
    } else {
        return NO;
    }
}

- (void)resetMenuView {
    
    FCMenuView *oldMenuView = self.menuView;
    [self configureMenuView];
    [oldMenuView removeFromSuperview];
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    // 第一次 或者 屏幕状态改变？
    // 计算宽高及子控制器的视图frame
    [self calculateSize];
    
    CGRect scrollFrame = CGRectMake(0, self.menuHeight, _viewWidth, _viewHeight);
    
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = CGSizeMake(self.titles.count * _viewWidth, _viewHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectIndex * _viewWidth, 0)];
    self.currentViewController.view.frame = [self.childViewFrames[self.selectIndex] CGRectValue];
    
    [self resetMenuView];
    
    [self.view layoutIfNeeded];
}

- (void)layoutChildViewControllers {
    
    int currentPage = self.scrollView.contentOffset.x / _viewWidth;
    
    int start, end;
    if (currentPage == 0) {
        start = currentPage;
        end = currentPage + 1;
    } else if (currentPage + 1 == self.viewControllerClasses.count) {
        
        start = currentPage - 1;
        end = currentPage;
    } else {
        
        start = currentPage - 1;
        end = currentPage + 1;
    }
    
    for (int i = start; i < end; i++) {
        
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        if ([self isInScreen:frame]) {
            
            if (!vc) {
                
                [self addViewControllerAtIndex:i];
            }
        } else {
            
            if (vc) {
                
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                [self.displayVC removeObjectForKey:@(i)];
            }
        }
    }
}

#pragma mark - Lazy Loading Methods
- (NSMutableDictionary *)displayVC {
    
    if (!_displayVC) {
        
        _displayVC = [NSMutableDictionary dictionary];
    }
    return _displayVC;
}

#pragma mark - Notification Mehtods
- (void)postFinishInitNotificationWithIndex:(NSInteger)index {
    
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index" : @(index),
                           @"title" : self.titles[index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:FCControllerDidFullyDisplayedNotification object:info];
}

- (void)postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":self.titles[index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:FCControllerDidFullyDisplayedNotification
                                                        object:info];
}


#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self layoutChildViewControllers];
    if (!_animate) return;
    CGFloat width = scrollView.frame.size.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    CGFloat rate = contentOffsetX / width;
    [self.menuView slideMenuAtProgress:rate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _animate = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    _selectIndex = (NSInteger)scrollView.contentOffset.x / _viewWidth;
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

#pragma mark - Menu View Delegate
- (void)menuView:(FCMenuView *)menuView didSelectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    
    NSInteger gap = (NSInteger)labs(index - currentIndex);
    _animate = NO;
    [self.scrollView setContentOffset:CGPointMake(_viewWidth * index, 0) animated:gap > 1 ? NO : self.pageAnimatable];
    if (gap > 1 || !self.pageAnimatable) {
        [self postFullyDisplayedNotificationWithCurrentIndex:(int)index];
        // 由于不触发-scrollViewDidScroll: 手动清除控制器..
        UIViewController *vc = [self.displayVC objectForKey:@(currentIndex)];
        if (vc) {
            [self removeViewController:vc atIndex:currentIndex];
        }
    }
}

- (CGFloat)menuView:(FCMenuView *)menuView widthForItemAtIndex:(NSInteger)index {
    
    if (self.itemsWidths) {
        return [self.itemsWidths[index] floatValue];
    }
    return self.menuItemWidth;
}

@end
