//
//  WKCollectionViewFlowLayout.h
//  UICollectionView
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol WKCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemsInSection:(NSInteger)section;
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView;
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView;

@end

@protocol WKCollectionViewDataSourceFlowLayout <UICollectionViewDataSource>


@end
@interface WKCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) id<WKCollectionViewDelegateFlowLayout> delegate;
@property (nonatomic, assign) id<WKCollectionViewDataSourceFlowLayout> datasource;
@property (nonatomic, assign) CGSize recordingSize;//用于生成移动图的大小

- (BOOL)shouldUpdateAttributesArray; 


@end
