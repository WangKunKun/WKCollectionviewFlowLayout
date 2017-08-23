//
//  WKCollectionViewself.m
//  UICollectionView
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import "WKCollectionViewCell.h"
#import "UIImage+createImagewithColor.h"
@interface WKCollectionViewCell()

@property (nonatomic,strong) UIImageView  * imageView;
@property (nonatomic,strong) UILabel * nameLabel;

@end


@implementation WKCollectionViewCell



- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.alpha = .7f;
    }else {
        _imageView.alpha = 1.f;
    }
}

//懒惰加载
-(void) setImage:(UIImage *)image name:(NSString *)name
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_imageView];
    }
    if (nil == _nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.contentMode = UIViewContentModeScaleAspectFill;
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_nameLabel];
    }
    

    _imageView.width = self.width;
    _imageView.height = self.height - 20;
    _nameLabel.top = self.height - 20;
    _nameLabel.width = self.width;
    _nameLabel.height = 20;
    
    if (nil == image) {
        image = [UIImage createImageWithColor:[UIColor brownColor]];
    }
    _imageView.image = image;
    _nameLabel.backgroundColor = [UIColor yellowColor];
    _nameLabel.textColor = [UIColor brownColor];
    _nameLabel.text = name;
}

@end
