//
//  WKCollectionViewFlowLayout.m
//  UICollectionView
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import "WKCollectionViewFlowLayout.h"




@interface WKCollectionViewFlowLayout()

@property (nonatomic, assign) NSInteger numberOfCells;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat sectionSpacing;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, strong) NSArray *oldArray;
//每个分组内item大小相同，然而我只有一个分组
@property (nonatomic, strong) NSMutableArray * itemSizeForSections;




@end

@implementation WKCollectionViewFlowLayout

//准备布局
- (void)prepareLayout
{
    [super prepareLayout];
    
    
    
    self.delegate = (id<WKCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    _collectionViewSize = self.collectionView.bounds.size;
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionSpacing = 0;
    _insets = UIEdgeInsetsMake(0, 0, 0, 0);
    _recordingSize = CGSizeMake(60, 60);
    //获得规划的cell间距（根据排列方式不同，为同行cell间距/同列cell间距）
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    //获得规划的同组内 根据排列方式不同，为不同行之间的间距/不同列之间的间距
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    //获得规划的分组间距
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        _sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    //默认一个分组中cell同大小
    if ([self.delegate respondsToSelector:@selector(collectionView:sizeForItemsInSection:)]) {
        
        for (NSUInteger i = 0; i < self.collectionView.numberOfSections; i ++) {
            CGSize iitemSize = [self.delegate collectionView:self.collectionView sizeForItemsInSection:i];
            if (nil == _itemSizeForSections) {
                _itemSizeForSections = [NSMutableArray array];
            }
            _itemSizeForSections[i] = [NSValue valueWithCGSize:iitemSize];
        }
    }

}


- (id<WKCollectionViewDelegateFlowLayout>)delegate
{
    return (id<WKCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
}

- (BOOL)shouldUpdateAttributesArray
{
    return NO;
}

//计算内容区域
- (CGSize)collectionViewContentSize
{

    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return [self collectionViewContentSizeOfVertical];
    }
    else if(self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
    {
        return [self collectionViewContentSizeOfHorizontal];
    }
    else
    {
        return CGSizeZero;
    }
    
}


- (CGSize)collectionViewContentSizeOfHorizontal
{
    
    CGSize contentSize = CGSizeMake(0, _collectionViewSize.height);


    
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        
        //每一列的cell数量
        NSUInteger itemOfRow = ceil((_collectionViewSize.height - _insets.top - _insets.bottom - _lineSpacing) / ([_itemSizeForSections[i] CGSizeValue].height + _lineSpacing));
        //分组的列数
        NSInteger numberOfLines = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / itemOfRow);
        CGFloat lineWidth = numberOfLines * ([_itemSizeForSections[i] CGSizeValue].width + _lineSpacing) - _lineSpacing;
        contentSize.width += lineWidth;
    }
    contentSize.width += _insets.left + _insets.right + _sectionSpacing * (self.collectionView.numberOfSections - 1);
    return contentSize;
}

- (CGSize)collectionViewContentSizeOfVertical
{
    
    
    CGSize contentSize = CGSizeMake(_collectionViewSize.width, 0);
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        
        //每一行cell的个数
        NSUInteger itemOfLine =ceil(((_collectionViewSize.width - _insets.left - _insets.right + _itemSpacing)/([_itemSizeForSections[i] CGSizeValue].width + _itemSpacing)));
        //分组的行数
        NSInteger numberOfLines = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / itemOfLine);
        CGFloat lineHeight = numberOfLines * ([_itemSizeForSections[i] CGSizeValue].height + _lineSpacing) - _lineSpacing;
        contentSize.height += lineHeight;
    }
    //计算分组之间的距离以及分组与collectionView的上下边距
    contentSize.height += _insets.top + _insets.bottom + _sectionSpacing * (self.collectionView.numberOfSections - 1);
    return contentSize;
}

//判断当前区域是是否需要刷新
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    BOOL shouldUpdate = [self shouldUpdateAttributesArray];
    if (CGRectEqualToRect(_oldRect, rect) && !shouldUpdate) {
        return _oldArray;
    }
    _oldRect = rect;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfCellsInSection = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfCellsInSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            //关键方法在这里，获得每一个item的约束，可不可以减少这个轮训
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            
            //判断需要重新约束的矩形是否和collectionView交叉，交叉则需要重新约束，则将其约束加入数组
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    _oldArray = attributesArray;
    return  attributesArray;
}

//目的是获得每一个cell的布局约束
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //cellSize
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            [self HorizontalLayoutAttributesForItemAtIndexPath:indexPath attributes:attributes];
            break;
        case UICollectionViewScrollDirectionVertical:
            [self VerticalLayoutAttributesForItemAtIndexPath:indexPath attributes:attributes];
            break;
        default:
            break;
    }

    return attributes;
}
/**
 *  横向滚动Cell约束
 *
 *  @param indexPath  cell坐标
 *  @param attributes 约束变量
 */
- (void)HorizontalLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath attributes:(UICollectionViewLayoutAttributes *)attributes
{
    
    
    //计算一列有多少个Cell
    CGSize itemOfSection = [_itemSizeForSections[indexPath.section] CGSizeValue];

    //x * cell.height + _insets.top + bottom + (x-1) * spaceing <=  collectionView.Height
    NSUInteger itemOfRow = ceil((_collectionViewSize.height - _insets.top - _insets.bottom - _lineSpacing) / (itemOfSection.height + _lineSpacing));
    
    //section width
    CGFloat sectionWidth = 0;
    for (NSInteger i = 0; i <= indexPath.section - 1; i++) {
        //得到分组的item个数
        NSInteger cellsCount = [self.collectionView numberOfItemsInSection:i];
        //得到分组中cell的宽度度
        //一列两个cell，算出有分组中有多少列
        NSInteger lines = ceil((CGFloat)cellsCount / itemOfRow);
        
        //分组宽度= 列数 *（分割线宽度 + 一行中最大cell的宽度）+ 分组之间的间隔线
        sectionWidth += lines * (_lineSpacing + itemOfSection.width) + _sectionSpacing;
        
    }
    //减去一个分组内分割线宽度，分组宽度中多乘了一个_lineSpacing，理论上应该乘以lines - 1
    if (sectionWidth > 0) {
        sectionWidth -= _lineSpacing;
    }
    //计算当前位置的cell的起始位置
    
    //行数
    NSInteger line = indexPath.item % itemOfRow;
    //列数
    NSInteger row = indexPath.item / itemOfRow;
    //行间隔
    CGFloat lineSpaceForIndexPath = _itemSpacing * line;
    //列间隔
    CGFloat itemSpaceForIndexPath = _lineSpacing * row;
    //计算Y轴
    CGFloat lineOriginY = _insets.top + line * itemOfSection.height + lineSpaceForIndexPath ;
    //计算X轴
    CGFloat lineOriginX = _insets.left + row * itemOfSection.width + itemSpaceForIndexPath + sectionWidth;
    
    attributes.frame = CGRectMake(lineOriginX, lineOriginY, itemOfSection.width, itemOfSection.width);
}
/**
 *  竖向滚动Cell约束
 *
 *  @param indexPath  cell坐标
 *  @param attributes 约束变量
 */
- (void)VerticalLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath attributes:(UICollectionViewLayoutAttributes *)attributes
{
    
    
    //计算一行包含多少个Cell
    
    //左，右边框距离+x * cell.width + (x - 1) * itemSpace <= collectionViewSize.width
    
    NSUInteger itemOfLine =ceil(((_collectionViewSize.width - _insets.left - _insets.right + _itemSpacing)/([_itemSizeForSections[indexPath.section] CGSizeValue].width + _itemSpacing)));
    
    
    //Cellsize
    CGSize itemOfSection = [_itemSizeForSections[indexPath.section] CGSizeValue];
    //section height
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i <= indexPath.section - 1; i++) {
        //得到分组的item个数
        NSInteger cellsCount = [self.collectionView numberOfItemsInSection:i];
        //得到分组中cell的高度
        //一行两个cell，算出有分组中有多少行
        NSInteger lines = ceil((CGFloat)cellsCount / itemOfLine);
        
        sectionHeight += lines * (_lineSpacing + itemOfSection.height) + _sectionSpacing;
        
    }
    if (sectionHeight > 0) {
        sectionHeight -= _lineSpacing;
    }
    //计算当前位置的cell的起始位置
    
    //行数
    NSInteger line = indexPath.item / itemOfLine;
    //列数
    NSInteger row = indexPath.item % itemOfLine;
    //行间隔
    CGFloat lineSpaceForIndexPath = _lineSpacing * line;
    //列间隔
    CGFloat itemSpaceForIndexPath = _itemSpacing * row;
    //计算Y轴
    CGFloat lineOriginY = _insets.top + line * itemOfSection.height + lineSpaceForIndexPath + sectionHeight;
    //计算X轴
    CGFloat lineOriginX = _insets.left + row * itemOfSection.width + itemSpaceForIndexPath;

    attributes.frame = CGRectMake(lineOriginX, lineOriginY, itemOfSection.width, itemOfSection.width);
}




@end
