//
//  ViewController.h
//  UICollectionView
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 王琨. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SameExchange = 0,
    AllExchange,
    SameExchangeLimit,
    AllExchangeLimit,
    AllExchangeAndAutoInsert_Delete
} WKStyle;

@interface ViewController : UIViewController

@property (nonatomic, assign) WKStyle type;

@end

