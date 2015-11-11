//
//  UIImage+createImagewithColor.m
//  NewProject
//
//  Created by ljk on 15/10/13.
//  Copyright © 2015年 ljk. All rights reserved.
//

#import "UIImage+createImagewithColor.h"

@implementation UIImage (createImagewithColor)
+(UIImage *)createImageWithColor:(UIColor*)color{
    CGRect   rect=(CGRect){0, 0, 60, 40};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef  context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage  *image=UIGraphicsGetImageFromCurrentImageContext();
    return image;
}



@end
