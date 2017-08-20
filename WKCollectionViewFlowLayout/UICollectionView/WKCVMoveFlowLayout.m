//
//  WKCVMoveFlowLayout.m
//  UICollectionView
//
//  Created by apple on 15/11/9.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import "WKCVMoveFlowLayout.h"

//自动滚动的方向
typedef NS_ENUM(NSInteger, WKScrollDirction) {
    WKScrollDirctionNone,
    WKScrollDirctionUp,
    WKScrollDirctionDown,
    WKScrollDirctionLeft,
    WKScrollDirctionRight
};

@interface UIImageView (WKCollectionViewMoveFlowLayout)

- (void)setCellCopiedImage:(UICollectionViewCell *)cell;

@end

@implementation UIImageView (WKCollectionViewMoveFlowLayout)

//获得移动图
- (void)setCellCopiedImage:(UICollectionViewCell *)cell {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 4.f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = image;
}

@end

@interface WKCVMoveFlowLayout ()

//长按后鼠标获取到的图片的视图
@property (nonatomic, strong) UIImageView *cellFakeView;
//用于刷新界面 自动滚动
@property (nonatomic, strong) CADisplayLink *displayLink;
//用于设定滚动方向
@property (nonatomic, assign) WKScrollDirction myScrollDirection;
//需要被移动的cell的indexpath
@property (nonatomic, strong) NSIndexPath *reorderingCellIndexPath;
//被移动的cell的中心店
@property (nonatomic, assign) CGPoint reorderingCellCenter;
@property (nonatomic, assign) CGPoint cellFakeViewCenter;
//拖动手势偏移量
@property (nonatomic, assign) CGPoint panTranslation;
//自动滚到有效范围
@property (nonatomic, assign) UIEdgeInsets scrollTrigerEdgeInsets;
@property (nonatomic, assign) BOOL setUped;
@property (nonatomic, assign) BOOL needsUpdateLayout;



@end

@implementation WKCVMoveFlowLayout

- (id<WKCVMoveFlowLayoutDelegate>)delegate
{
    return (id<WKCVMoveFlowLayoutDelegate>)self.collectionView.delegate;
}

- (id<WKCVMoveFlowLayoutDataSource>)datasource
{
    return (id<WKCVMoveFlowLayoutDataSource>)self.collectionView.dataSource;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _recordingSize = CGSizeMake(60, 60);

    
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        self.minimumInteritemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    //获得规划的同组内 根据排列方式不同，为不同行之间的间距/不同列之间的间距
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        self.minimumLineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        self.sectionInset = [self.delegate insetsForCollectionView:self.collectionView];
    }
    
    //gesture
    [self setUpCollectionViewGesture];
    //scroll triger insets
    //用于DisPlayLink 自动滚动
    //当长按后生成的图片移动时，离顶部或者底部XX距离时，触发滚动
    _scrollTrigerEdgeInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(autoScrollTrigerEdgeInsets:)]) {
        _scrollTrigerEdgeInsets = [self.delegate autoScrollTrigerEdgeInsets:self.collectionView];
    }

}


//是否更新约束数组
- (BOOL)shouldUpdateAttributesArray
{
    if (_needsUpdateLayout) {
        _needsUpdateLayout = NO;
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - Methods


//必须要两个手势，才能正确计算被拖动的view的正确偏移量，试过只有长按手势问题严峻~ 移动不平滑
- (void)setUpCollectionViewGesture
{
    if (!_setUped) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                //覆盖原本的长按手势
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture]; }}
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}

//自动刷新屏幕
- (void)setUpDisplayLink
{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    //加入此NSRunLoop避免与scrollview滚动的RunLoop冲突
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

-  (void)invalidateDisplayLink
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)autoScroll
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGSize contentSize = self.collectionView.contentSize;
    CGSize boundsSize = self.collectionView.bounds.size;
    CGFloat increment = 0;
    
    UICollectionViewScrollDirection scrollD = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection;
    
    
    //计算移动距离，最大移动距离为每一次刷新10
    if (self.myScrollDirection == WKScrollDirctionDown) {
        //算出实际移动距离
        //移动视图的在CollectionView上的MaxY和colltctionView
        CGFloat percentage = (((CGRectGetMaxY(_cellFakeView.frame) - contentOffset.y) - (boundsSize.height - _scrollTrigerEdgeInsets.bottom )) / _scrollTrigerEdgeInsets.bottom);
        increment = 10 * percentage;
        if (increment >= 10.f) {
            increment = 10.f;
        }
    }else if (self.myScrollDirection == WKScrollDirctionUp) {
        CGFloat percentage = (1.f - ((CGRectGetMinY(_cellFakeView.frame) - contentOffset.y ) / _scrollTrigerEdgeInsets.top));
        increment = - 10.f * percentage;
        if (increment <= - 10.f) {
            increment = - 10.f;
        }
    } else if (self.myScrollDirection == WKScrollDirctionRight)
    {
        CGFloat percentage = (((CGRectGetMaxX(_cellFakeView.frame) - contentOffset.x) - (boundsSize.width - _scrollTrigerEdgeInsets.right)) / _scrollTrigerEdgeInsets.right);
        increment = 10.f * percentage;
        if (increment >= 10.f) {
            increment = 10.f;
        }
        
    } else if (self.myScrollDirection == WKScrollDirctionLeft)
    {
        CGFloat percentage = (1.f - ((CGRectGetMinX(_cellFakeView.frame) - contentOffset.x ) / _scrollTrigerEdgeInsets.left));
        increment = - 10.f * percentage;
        if (increment <= -10.f) {
            increment = - 10.f;
        }
    }
    
    
    if (scrollD == UICollectionViewScrollDirectionVertical) {
        //到顶
        if (contentOffset.y + increment <= -contentInset.top) {
            [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGFloat diff = -contentInset.top - contentOffset.y;
                self.collectionView.contentOffset = CGPointMake(contentOffset.x, -contentInset.top);
                _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + diff);
                _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            } completion:nil];
            [self invalidateDisplayLink];
            return;
            //到底
        }else if (contentOffset.y + increment >= contentSize.height - boundsSize.height - contentInset.bottom) {
            [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGFloat diff = contentSize.height - boundsSize.height - contentInset.bottom - contentOffset.y;
                self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentSize.height - boundsSize.height - contentInset.bottom);
                _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + diff);
                _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            } completion:nil];
            [self invalidateDisplayLink];
            return;
        }
    }
    else
    {
        if (contentOffset.x + increment <= -contentInset.left) {
            [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGFloat diff = - contentInset.left - contentOffset.x;
                self.collectionView.contentOffset = CGPointMake(-contentInset.left, contentOffset.y);
                _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x + diff, _cellFakeViewCenter.y );
                _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            } completion:nil];
            [self invalidateDisplayLink];
            return;
        }
        else if (contentOffset.x + increment >= contentSize.width - boundsSize.width - contentInset.right)
        {
            [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGFloat diff = contentSize.width - boundsSize.width - contentInset.right - contentOffset.x;
                self.collectionView.contentOffset = CGPointMake(contentSize.width - boundsSize.width - contentInset.right, contentOffset.y);
                _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x + diff, _cellFakeViewCenter.y );
                _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            } completion:nil];
            [self invalidateDisplayLink];
            return;
        }
    }
    
    //刷新collectionView 修改偏移量 更改视图位置
    [self.collectionView performBatchUpdates:^{
        if (scrollD == UICollectionViewScrollDirectionVertical) {
            _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + increment);
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + increment);
        }
        else
        {
            _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x + increment, _cellFakeViewCenter.y );
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            self.collectionView.contentOffset = CGPointMake(contentOffset.x  + increment, contentOffset.y);
        }

    } completion:nil];
    [self moveItemIfNeeded];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            //indexPath
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            
            //can move
            if ([self.datasource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
                if (![self.datasource collectionView:self.collectionView canMoveItemAtIndexPath:indexPath]) {
                    return;
                }
            }
            //will begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
            }
            //手势触发后，需要更新手势
            _needsUpdateLayout = YES;
            //indexPath
            _reorderingCellIndexPath = indexPath;

            //得到cell
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            _cellFakeView = [[UIImageView alloc] initWithFrame:cell.frame];
            _cellFakeView.layer.shadowColor = [UIColor blackColor].CGColor;
            _cellFakeView.layer.shadowOffset = CGSizeMake(0, 0);
            _cellFakeView.layer.shadowOpacity = .5f;
            _cellFakeView.layer.shadowRadius = 3.f;
            [_cellFakeView setCellCopiedImage:cell];
            [self.collectionView addSubview:_cellFakeView];
//            [self.collectionView.superview insertSubview:_cellFakeView atIndex:0];


            //set center
            _reorderingCellCenter = cell.center;
            _cellFakeViewCenter = _cellFakeView.center;
            [self invalidateLayout];
            //animation
            CGRect fakeViewRect = CGRectMake(cell.center.x - (self.recordingSize.width / 2.f), cell.center.y - (self.recordingSize.height / 2.f), self.recordingSize.width, self.recordingSize.height);
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _cellFakeView.center = cell.center;
                _cellFakeView.frame = fakeViewRect;
                _cellFakeView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            } completion:^(BOOL finished) {
                cell.hidden = YES;
            }];
            //did begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self didBeginDraggingItemAtIndexPath:indexPath];
            }
            break;
        }
            
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            NSIndexPath *currentCellIndexPath = [_reorderingCellIndexPath copy];
            //will end dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentCellIndexPath];
            }
            _needsUpdateLayout = YES;

            [self invalidateDisplayLink];

            CGPoint point = [longPress locationInView:self.collectionView];
            NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:point];

            
            BOOL canMove = YES;
            if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)]) {
                canMove = [self.datasource collectionView:self.collectionView itemAtIndexPath:currentCellIndexPath canMoveToIndexPath:toIndexPath];
            }
            
            
            if (toIndexPath == nil) {
                //判断 当前点是否在  cv的contentsize内，内则不消失，外则消失
                CGRect rect = self.collectionView.frame;
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionVertical:
                        if (rect.size.height > self.collectionView.contentSize.height) {
                            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.collectionView.contentSize.height);
                        }
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        if (rect.size.width > self.collectionView.contentSize.width) {
                            rect = CGRectMake(rect.origin.x, rect.origin.y, self.collectionView.contentSize.width, rect.size.height);
                        }
                        break;
                    default:
                        break;
                }
                
                canMove = CGRectContainsPoint(rect, point);
            }
            
            //回归动画
            //如果是删除操作，首先得到model
            //如果不可移动 则删除
            if (!canMove) {
                UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
                [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    _cellFakeView.transform = CGAffineTransformMakeScale(0.05, 0.05);
                    _cellFakeView.alpha = 0;
                } completion:^(BOOL finished) {
                    [_cellFakeView removeFromSuperview];
                    _cellFakeView = nil;
                    _reorderingCellIndexPath = nil;
                    _reorderingCellCenter = CGPointZero;
                    _cellFakeViewCenter = CGPointZero;
                    if (finished) {
                        if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:isDelete:)]) {
                            [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:currentCellIndexPath isDelete:YES];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.23 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            cell.hidden = NO;
                        });

                    }
                }];
            }
            else
            {
            
            
            //返回动画
            //得到之前的位置，然后得到frame，用动画返回
                UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:currentCellIndexPath];
                [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _cellFakeView.transform = CGAffineTransformIdentity;
                    _cellFakeView.frame = attributes.frame;
                } completion:^(BOOL finished) {
                    [_cellFakeView removeFromSuperview];
                    _cellFakeView = nil;
                    _reorderingCellIndexPath = nil;
                    _reorderingCellCenter = CGPointZero;
                    _cellFakeViewCenter = CGPointZero;
                    if (finished) {
                        cell.hidden = NO;
                        if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:isDelete:)]) {
                            [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:currentCellIndexPath isDelete:NO];
                        }
                    }
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            //translation
            _panTranslation = [pan translationInView:self.collectionView];
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            //move layout
            [self moveItemIfNeeded];
            //scroll
            //计算滚动方向，自动滚动开启/关闭
            if (((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection == UICollectionViewScrollDirectionVertical) {
                //上下滚动
                if (CGRectGetMaxY(_cellFakeView.frame) >= self.collectionView.contentOffset.y + (self.collectionView.bounds.size.height - _scrollTrigerEdgeInsets.bottom)) {
                    if (ceilf(self.collectionView.contentOffset.y) < self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
                        self.myScrollDirection = WKScrollDirctionDown;
                        [self setUpDisplayLink];
                    }
                }else if (CGRectGetMinY(_cellFakeView.frame) <= self.collectionView.contentOffset.y + _scrollTrigerEdgeInsets.top ) {
                    if (self.collectionView.contentOffset.y > -self.collectionView.contentInset.top) {
                        self.myScrollDirection = WKScrollDirctionUp;
                        [self setUpDisplayLink];
                    }
                }else  {
                    self.myScrollDirection = WKScrollDirctionNone;
                    [self invalidateDisplayLink];
                }
            } else
            {
                //左右滚动
                if (CGRectGetMaxX(_cellFakeView.frame) >= self.collectionView.contentOffset.x + (self.collectionView.width - _scrollTrigerEdgeInsets.right)) {
                    if (ceilf(self.collectionView.contentOffset.x) < self.collectionView.contentSize.width - self.collectionView.width ) {
                        self.myScrollDirection = WKScrollDirctionRight;
                        [self setUpDisplayLink];
                    }
                }else if(CGRectGetMinX(_cellFakeView.frame) <= self.collectionView.contentOffset.x + _scrollTrigerEdgeInsets.left)
                {
                    if (self.collectionView.contentOffset.x > - self.collectionView.contentInset.top) {
                        self.myScrollDirection = WKScrollDirctionLeft;
                        [self setUpDisplayLink];
                    }
                }else
                {
                    self.myScrollDirection = WKScrollDirctionNone;
                    [self invalidateDisplayLink];
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self invalidateDisplayLink];
            break;
            
        default:
            break;
    }
}

- (void)moveItemIfNeeded
{
    NSIndexPath *atIndexPath = _reorderingCellIndexPath;
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    
    //修正toIndexPath 防止由于 fakeview 自动滚动后 由于没有toIndexPath 导致cell丢失
    if (nil == toIndexPath ) {
        CGPoint position = CGPointMake(_cellFakeView.center.x, _cellFakeView.center.y - _cellFakeView.size.height/2.0f);
        toIndexPath = [self.collectionView indexPathForItemAtPoint:position];
    }
    
    // 位置不变时，不做操作 前面个条件不能少，少了会出很异常的情况
    if (nil == toIndexPath || [atIndexPath isEqual:toIndexPath]) {
        return;
    }
    
    //can move
    if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)]) {
        if (![self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath canMoveToIndexPath:toIndexPath]) {
            return;
        }
    }
    
    //will move
    if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
        [self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath willMoveToIndexPath:toIndexPath];
    }
    _needsUpdateLayout = YES;
    //move
    _reorderingCellIndexPath = toIndexPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized (self) {
            @try {
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
                    
                } completion:^(BOOL finished) {
                    if (finished) {
                        if ([self.datasource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
                            [self.datasource collectionView:self.collectionView itemAtIndexPath:atIndexPath didMoveToIndexPath:toIndexPath];
                        }
                    }
                }];
            } @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
            } @finally {
                
            }
            
        }
    });

}


#pragma mark - UIGestureRecognizerDelegate methods

//手势冲突解决
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state != 0 && _longPressGesture.state != 5) {
            if ([_longPressGesture isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if ([_panGesture isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }
    return YES;
}


@end
