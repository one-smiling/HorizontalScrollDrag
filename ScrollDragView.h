//
//  ScrollDragView.h
//  HorizontalScrollDrag
//
//  Created by Simay on 16/4/28.
//  Copyright © 2016年 Simay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollDragView : UIScrollView

@property (nonatomic, assign) CGSize        itemSize;
@property (nonatomic, assign) UIEdgeInsets  itemInsert;//上下左右margin
@property (nonatomic, assign) CGFloat       spacingWidth; //间距大小
@property (nonatomic, assign,readonly) NSUInteger    itemCount; //item数量
@property (nonatomic, assign) BOOL isHaveAddButton;
@property (nonatomic, strong ,readonly) UIButton *addItemButton;

//- (void)addImage:(UIImage *)image;
- (void)addItem:(UIView *)item;

//- (void)addImage:(UIImage *)image;
//- (void)insertImage:(UIImage *)image atIndex:(NSUInteger)index;

@end
