//
//  ViewController.m
//  HorizontalScrollDrag
//
//  Created by Simay on 16/4/28.
//  Copyright © 2016年 Simay. All rights reserved.
//

#import "ViewController.h"
#import "ScrollDragView.h"

@interface ViewController ()
@property (nonatomic ,strong) ScrollDragView *scrollDragView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollDragView = [[ScrollDragView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    
    [_scrollDragView.addItemButton setBackgroundImage:[UIImage imageNamed:@"pd_pic_add"] forState:UIControlStateNormal];
    [_scrollDragView.addItemButton addTarget:self action:@selector(clickToAddPic:) forControlEvents:UIControlEventTouchUpInside];


    _scrollDragView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:_scrollDragView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)clickToAddPic:(UIButton *)sender {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _scrollDragView.itemSize.width, _scrollDragView.itemSize.height)];
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = [NSString stringWithFormat:@"%d",_scrollDragView.itemCount];
    label.font = [UIFont systemFontOfSize:100];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [_scrollDragView addItem:label];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [_scrollDragView addImage:[UIImage imageNamed:@"04_568h"]];
    
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
