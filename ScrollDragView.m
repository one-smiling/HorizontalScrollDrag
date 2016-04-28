//
//  ScrollDragView.m
//  HorizontalScrollDrag
//
//  Created by Simay on 16/4/28.
//  Copyright © 2016年 Simay. All rights reserved.
//

#import "ScrollDragView.h"


static const CGFloat DELETE_BUTTON_RADIUS = 15; //删除按钮的半径


@interface ItemView : UIView

@end

@implementation ItemView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == nil) {
        if (fabs(point.y) <= DELETE_BUTTON_RADIUS &&
            fabs(point.x - self.frame.size.width) <= DELETE_BUTTON_RADIUS  ) {
            
            for (UIView *touchView in self.subviews) {
                if ([touchView isKindOfClass:[UIButton class]]) {
                    return touchView;
                }
            }
            
        }
    
    }
    return view;
}



@end

@interface ScrollDragView() {
    NSInteger _pickUpIndex;         //已经选中的item索引 移动中随时
    NSInteger _toIndex;             //已经选中的item索引
    NSInteger _lastToIndex;         //上次到达的toIndex
    
    BOOL _isMoving;         //是否正在移动
    BOOL _isDragViewPickedUp;
    
    CGRect _pickUpRect;
    CGRect _lasrPickUpLastRect;
}
@property (strong,nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSMutableArray *itemViews;
@property (nonatomic, strong) UIView *dragView;
@property (nonatomic, strong ,readwrite) UIButton *addItemButton;


@end

@implementation ScrollDragView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initData];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}

-(void)initData{
    
    self.itemViews = [NSMutableArray arrayWithCapacity:10];
    self.itemSize = CGSizeMake(80, 140);
    self.spacingWidth = 10;
    self.itemInsert = UIEdgeInsetsMake(10, 10, 10, 10);
    self.addItemButton = [[UIButton alloc] init];
    
}

-(void)didMoveToSuperview{
    [self configView];
}


-(void)configView{
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    self.addItemButton.frame =CGRectMake(_itemInsert.left, _itemInsert.top, _itemSize.width, _itemSize.height);
        [self addSubview:_addItemButton];
}

- (void)addItem:(UIView *)item {
    [self insertItem:item atIndex:self.itemViews.count];
}

- (void)insertItem:(UIView *)itemView atIndex:(NSUInteger)index {
    
    //把差号和图片合成一个view
    ItemView *itemBackgroundView=[[ItemView alloc] initWithFrame:CGRectMake(_itemInsert.left + index * (_itemSize.width + _spacingWidth), _itemInsert.top, _itemSize.width, _itemSize.height)];
    

    
    UIButton *delButton=[[UIButton alloc] initWithFrame:CGRectMake(_itemSize.width-15, -15, 30, 30)];
    [delButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [delButton addTarget:self action:@selector(removeItemFromScrollView:) forControlEvents:UIControlEventTouchUpInside];
    
    [itemBackgroundView addSubview:itemView];
    [itemBackgroundView addSubview:delButton];
    [self addSubview:itemBackgroundView];
    
    [_itemViews addObject:itemBackgroundView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        for (NSInteger i = index; i < _itemViews.count; i++) {
            [self moveItemView:_itemViews[i] toIndex:i];
        }
        
        [self refreshAddButtonAndScrollView];
        self.contentOffset = CGPointMake(self.contentSize.width- self.frame.size.width, self.contentOffset.y);
    }];
}



//图片移除后动态改变所剩图片的位置
-(void)removeItemFromScrollView:(id)sender{
    
    UIButton *btn=(UIButton*)sender;
    
    
    
    NSInteger index = [_itemViews indexOfObject:btn.superview];
    [self removeUploadItemWithIndex:index];
    [UIView animateWithDuration:0.5 animations:^{
        
        for (NSInteger i = index; i < _itemViews.count; i++) {
            [self moveItemView:_itemViews[i] toIndex:i];
        }
        
        [self refreshAddButtonAndScrollView];

        
    } completion:^(BOOL finished) {
        
    }];

}

- (void)refreshAddButtonAndScrollView {
    NSUInteger count = self.itemViews.count;
    float width = _itemInsert.left+ _itemInsert.right + _itemSize.width *(count+1) + count * _spacingWidth;
    self.contentSize = CGSizeMake(MAX(width, self.frame.size.width), self.frame.size.height);
    _addItemButton.frame = CGRectMake( count * (_itemSize.width + _spacingWidth ) + _itemInsert.left, _itemInsert.top, _itemSize.width, _itemSize.height);
}

#pragma mark - image的拖动

-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        
        NSInteger itemIndex = [self indexOfViewTouchPoint:touchPoint];
        CGRect viewRect = [self viewFrameWithIndex:itemIndex];
        if (CGRectContainsPoint(viewRect, touchPoint)) {
            _dragView = _itemViews[itemIndex];
            [self growAnimationAtPoint:touchPoint forView:_dragView];
            [self bringSubviewToFront:_dragView];
            _isDragViewPickedUp = YES;
            _pickUpRect  = _lasrPickUpLastRect= viewRect;
            _pickUpIndex = _lastToIndex = itemIndex;
        }
        
        NSLog(@"");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        if (_isDragViewPickedUp) {
            
            CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
            _dragView.center = touchPoint;
            
            [self moveItem];
            [self scrollTheView];
        }
    }
    else{
        if (_isDragViewPickedUp) {
            [self stopScrollTimer];
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 _dragView.transform = CGAffineTransformIdentity;
                                 
                                 CGRect frame = _dragView.frame;
                                 frame.origin = _pickUpRect.origin;
                                 _dragView.frame = frame;
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                 //                            [self moveItemfromIndex:_pickUpIndex toIndex:_lastToIndex];
                                 
                                 
                                 _isDragViewPickedUp = NO;
                                 _dragView = nil;
                             }];
            
            
        }
        
    }
}


- (void)anminateViewToViewIndex:(NSInteger)toIndex rect:(CGRect)toRect{
    if (_isMoving) return;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         _isMoving = YES;
                         
                         //从前往后拖
                         if (_lastToIndex < toIndex) {
                             
                             for (NSInteger index = MAX(0, _lastToIndex + 1); index <= MIN(toIndex, _itemViews.count - 1); index++) {
                                 [weakSelf moveItemView:_itemViews[index] steps:-1];
                                 
                             }
                         }
                         //从后往前拖
                         else{
                             for (NSInteger index = MAX(0, toIndex); index <= MIN(_lastToIndex - 1, _itemViews.count - 1); index++) {
                                 [weakSelf moveItemView:_itemViews[index] steps:1];
                             }
                             
                         }
                         
                         [weakSelf moveItemfromIndex:_lastToIndex toIndex:toIndex];
                         
                         _lastToIndex = toIndex;
                         _pickUpRect = toRect;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         _isMoving = NO;
                         
                     }];
    
    
    
}

- (void)moveItemView:(UIView *)itemView toIndex:(NSInteger)toIndex{

    CGRect frame =itemView.frame;
    frame.origin.x = toIndex * (_itemSize.width + _spacingWidth) + _itemInsert.left;
    itemView.frame = frame;
    
}
- (void)moveItemView:(UIView *)itemView steps:(NSInteger)steps {
    itemView.center = CGPointMake(itemView.center.x + steps * (_itemSize.width + _spacingWidth),itemView.center.y);
}

-(void)moveItem{
    NSInteger itemIndex = [self indexOfViewTouchPoint:_dragView.center];
    CGRect viewRect = [self viewFrameWithIndex:itemIndex];
    
    
    //    NSLog(@"itemIndex: %ld lat: %ld",(long)itemIndex,(long)_lastToIndex);
    
    if (CGRectContainsPoint(viewRect, _dragView.center) && _lastToIndex != itemIndex) {
        [self anminateViewToViewIndex:itemIndex rect:viewRect];
    }
    
}

-(CGRect)viewFrameWithIndex:(NSInteger)index{
    
    return  CGRectMake(_itemInsert.left+(_itemSize.width + _spacingWidth)*index, _itemInsert.top, _itemSize.width, _itemSize.height+10);
}

-(NSInteger)indexOfViewTouchPoint:(CGPoint)touchPoint{
    
    CGFloat firstItemWidth = _itemSize.width+ _itemInsert.left+_spacingWidth/2;
    CGFloat middleItemWidth = _itemSize.width + _spacingWidth;
    NSInteger index;
    if (touchPoint.x < firstItemWidth) {
        index = 0;
    }
    else{
        index = MIN(floorf((touchPoint.x - firstItemWidth)/middleItemWidth + 1), _itemViews.count-1);
    }
    return index;
}

- (void)growAnimationAtPoint:(CGPoint)point forView:(UIView *)view {
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         view.center = point;
                     }
                     completion:NULL];
}

- (void)stopScrollTimer {
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_displayLink invalidate];
    _displayLink = nil;
}


-(void)scrollTheView{
    
    if (!_displayLink) {
        // Note: See http://stackoverflow.com/questions/358207/iphone-how-to-get-current-milliseconds for speed comparation
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTheView)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    CGFloat startScrollArea = 60;
    CGFloat distanceFromLeft = _dragView.center.x - self.contentOffset.x;
    //
    CGFloat rate = 4;
    
    //左边
    if (distanceFromLeft < startScrollArea) {
        if (self.contentOffset.x > 0) {
            self.contentOffset = CGPointMake(self.contentOffset.x - rate, self.contentOffset.y);
            _dragView.center = CGPointMake(_dragView.center.x - rate, _dragView.center.y);
            
            [self moveItem];
            
        }
        
    }
    //右边
    if (distanceFromLeft > self.frame.size.width - startScrollArea) {
        if (self.contentOffset.x < self.contentSize.width - self.frame.size.width) {
            self.contentOffset = CGPointMake(self.contentOffset.x + rate, self.contentOffset.y);
            _dragView.center = CGPointMake(_dragView.center.x + rate, _dragView.center.y);
            
            [self moveItem];
        }
    }
    
    
    
}
-(void)moveItemfromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    //图片的移动
    id obj = _itemViews[fromIndex];
    [_itemViews removeObjectAtIndex:fromIndex];
    [_itemViews insertObject:obj atIndex:toIndex];
    
}

-(void)removeUploadItemWithIndex:(NSInteger)index{
    
    [_itemViews[index] removeFromSuperview];
    [_itemViews removeObjectAtIndex:index];
    
}

-(NSUInteger)itemCount {
    return self.itemViews.count;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
