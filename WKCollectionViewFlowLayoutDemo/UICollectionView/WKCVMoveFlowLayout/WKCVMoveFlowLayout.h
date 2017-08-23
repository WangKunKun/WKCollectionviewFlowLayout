//
//  WKCVMoveFlowLayout.h
//  UICollectionView
//
//  Created by apple on 15/11/9.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WKFlowLayoutState_Move,
    WKFlowLayoutState_Delete,
} WKFlowLayoutState;


@protocol WKCVMoveFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional

//触发范围
- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView;

//是否可拖动
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
//最后一个参数 是否执行删除操作
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath state:(WKFlowLayoutState)state;

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemsInSection:(NSInteger)section;
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView;

@end

@protocol WKCVMoveFlowLayoutDataSource <UICollectionViewDataSource>

@optional


- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;


@end



@interface WKCVMoveFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<WKCVMoveFlowLayoutDelegate> delegate;
@property (nonatomic, assign) id<WKCVMoveFlowLayoutDataSource> datasource;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGSize recordingSize;//用于生成移动图的大小
//默认开启
@property (nonatomic, assign) BOOL isAutoDelete;//拖动处有效区域自动删除
@property (nonatomic, assign) BOOL isAutoInsert;//拖动到section范围的空白区域 自动插入

@end

