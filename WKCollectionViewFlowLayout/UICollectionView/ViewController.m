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




//collectionViewStyle解析类——读取plist文件得到视图配置基本信息
@interface ConfigurationFile : NSObject

@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) CGFloat   itemSpacing;
@property (nonatomic, assign) CGFloat   sectionSpacing;
@property (nonatomic, assign) CGFloat   LineSpacing;
@property (nonatomic, assign) UIEdgeInsets scrollTrigerEdgeInsets;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) UIEdgeInsets insets;

+ (ConfigurationFile *)shared;

@end
static ConfigurationFile * CF = nil;
@implementation ConfigurationFile

+ (ConfigurationFile *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CF = [ConfigurationFile new];
        [CF DataInitialization];
    });
    
    
    return CF;
}

//数据初始化
- (void)DataInitialization
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"CollectionViewStyle" ofType:@"plist"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSAssert(nil != dict, @"%@ isn't exist",path );
    
    //Cell间距
    NSNumber * itemSpacing    = dict[@"ItemSpacing"];
    //分组间距
    NSNumber * sectionSpacing = dict[@"SectionSpacing"];
    //排列方式间距
    NSNumber * linespacing    = dict[@"LineSpacing"];


    self.itemSpacing    = [itemSpacing floatValue];
    self.sectionSpacing = [sectionSpacing floatValue];
    self.LineSpacing    = [linespacing floatValue];

    NSNumber * width    = dict[@"CellSize"][@"Width"];
    NSNumber * height   = dict[@"CellSize"][@"Height"];
    //Cell尺寸
    self.cellSize       = CGSizeMake([width floatValue], [height floatValue]);
    
    NSNumber * top    = dict[@"MaximumEffectiveRangeOfAutoScroll"][@"Top"];
    NSNumber * left   = dict[@"MaximumEffectiveRangeOfAutoScroll"][@"Left"];
    NSNumber * bottom = dict[@"MaximumEffectiveRangeOfAutoScroll"][@"Bottom"];
    NSNumber * right  = dict[@"MaximumEffectiveRangeOfAutoScroll"][@"Right"];
    //自动滚动尺寸
    self.scrollTrigerEdgeInsets = UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]);

    
    NSNumber * VORH = dict[@"VORH"];
    //collectionView排序方式
    self.scrollDirection = [VORH integerValue] > 0 ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    
    top    = dict[@"Insets"][@"Top"];
    left   = dict[@"Insets"][@"Left"];
    bottom = dict[@"Insets"][@"Bottom"];
    right  = dict[@"Insets"][@"Right"];
    //collectionView中Cell与边框的间距
    self.insets = UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]);
}

@end


static NSString * cellID = @"WKCollectionViewCell";



@interface ViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,WKCVMoveFlowLayoutDataSource,WKCVMoveFlowLayoutDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> * datasource;

//视图style
@property (nonatomic, strong) ConfigurationFile * collectinViewStyle;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _datasource = [NSMutableArray array];

    //style描述文件
    _collectinViewStyle = [ConfigurationFile shared];

    //FlowLayout样式
    WKCVMoveFlowLayout * flowLayout = [[WKCVMoveFlowLayout alloc] init];
    [flowLayout setScrollDirection:_collectinViewStyle.scrollDirection];
    
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
    NSLog(@"%@",NSStringFromSelector(_cmd));
    //规定可被交换的范围
//    toIndexPath.row > 1 && toIndexPath.section <= 0
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
#pragma waring 此处定义 item是否可移动
    return YES;
}

#pragma mark WKCollectionViewDelegateFlowLayout Methods

//参数相关
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemsInSection:(NSInteger)section
{
    return _collectinViewStyle.cellSize;
}
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return _collectinViewStyle.insets;
}
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return _collectinViewStyle.LineSpacing;
}
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return _collectinViewStyle.itemSpacing;
}
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return _collectinViewStyle.LineSpacing;
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return _collectinViewStyle.scrollTrigerEdgeInsets;
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
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath isDelete:(BOOL)isDelete
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (isDelete) {
        [_datasource[indexPath.section] removeObjectAtIndex:indexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
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
