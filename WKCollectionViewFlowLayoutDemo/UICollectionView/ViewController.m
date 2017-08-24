//
//  ViewController.m
//  UICollectionView
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import "ViewController.h"
#import "WKCollectionViewCell.h"
#import "UIViewExt.h"
#import "WKCVMoveFlowLayout.h"


//collectionView内容显示高度
#define kWKCollectionViewSize_Height 200



static NSString * cellID = @"WKCollectionViewCell";



@interface ViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,WKCVMoveFlowLayoutDataSource,WKCVMoveFlowLayoutDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> * datasource;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _datasource = [NSMutableArray array];


    //FlowLayout样式
    WKCVMoveFlowLayout * flowLayout = [[WKCVMoveFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.isAutoDelete = self.type == AllExchangeAndAutoInsert_Delete;
    flowLayout.isAutoInsert = self.type == AllExchangeAndAutoInsert_Delete;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height ) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor blackColor];
    [_collectionView registerClass:[WKCollectionViewCell class] forCellWithReuseIdentifier:cellID];

    [self.view addSubview:_collectionView];
    
    //数据源的由来
//    for (NSUInteger i = 0 ; i < 3; i ++)
    NSMutableArray * one = [NSMutableArray array];
    NSMutableArray * two = [NSMutableArray array];

    for (NSUInteger i = 1; i <= 12; i ++) {
        if (i <= 6) {
            [one addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%lu",(unsigned long)i]]];

        }
        else
        {
            [two addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%lu",(unsigned long)i]]];
        }
    }
    
    [_datasource addObject:one];
    [_datasource addObject:two];


 
}


- (void)viewDidAppear:(BOOL)animated
{

}

//继承关系
#pragma mark UICollectionViewDataSource Methods
#pragma mark WKCVMoveFlowLayoutDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return _datasource[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    WKCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [cell setImage:_datasource[indexPath.section][indexPath.row] name:[NSString stringWithFormat:@"%d-%d",indexPath.section,indexPath.item]];
    return cell;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _datasource.count;
}



//collectionView item之间交换的方法

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    

    switch (self.type) {
        case AllExchange:
        case AllExchangeAndAutoInsert_Delete:
            return YES;
            break;
        case AllExchangeLimit:
            return toIndexPath.row > 2;
        case SameExchange:
            return fromIndexPath.section == toIndexPath.section;
        default:
            return fromIndexPath.section == toIndexPath.section && toIndexPath.row > 2;

            break;
    }
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
    //规定可被交换的范围
//     && toIndexPath.section <= 0
#pragma waring 此处定义item可交换区域
//    fromIndexPath.section == toIndexPath.section 同组内交换
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    
    if (fromIndexPath.section != toIndexPath.section) {
            NSMutableArray * sourceArr = _datasource[fromIndexPath.section];
            [_datasource[toIndexPath.section] insertObject:sourceArr[fromIndexPath.item] atIndex:toIndexPath.item];
            [sourceArr removeObjectAtIndex:fromIndexPath.item];

    }
    else
    {
            UIImage * img = _datasource[fromIndexPath.section][fromIndexPath.item];
            [_datasource[fromIndexPath.section] removeObjectAtIndex:fromIndexPath.item];
            [_datasource[fromIndexPath.section] insertObject:img atIndex:toIndexPath.item];

    }
    NSLog(@"%@",NSStringFromSelector(_cmd));
    

}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    //限定可移动的item
//    indexPath.section <= 0 && indexPath.row > 1
    
    switch (self.type) {
        case AllExchange:
        case AllExchangeAndAutoInsert_Delete:
        case SameExchange:
            return YES;
            break;
        case AllExchangeLimit:
        case SameExchangeLimit:
            return indexPath.row > 2;
    }
    
#pragma waring 此处定义 item是否可移动
    return YES;
}

#pragma mark WKCollectionViewDelegateFlowLayout Methods

//参数相关
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemsInSection:(NSInteger)section
{
    return CGSizeMake(60, 60);
}
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 20;
}
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 20;
}
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 20;
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

//准备拖动图标
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

}
//已经拖动图标
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

}
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",NSStringFromSelector(_cmd));

}

//重新刷新数据
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath state:(WKFlowLayoutState)state
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    switch (state) {
        case WKFlowLayoutState_Move:
            break;
        case WKFlowLayoutState_Delete:
        {
            [_datasource[indexPath.section] removeObjectAtIndex:indexPath.row];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
            break;
    }
}



#pragma mark UICollectionViewDelegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"item======%ld",(long)indexPath.item);
    NSLog(@"row=======%ld",(long)indexPath.row);
    NSLog(@"section===%ld",(long)indexPath.section);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



@end
