//
//  UIColor+A.h
//  ARMRef
//
//  Created by James Emrich (EvilPenguin) on 7/3/20.
//  Copyright © 2020 James Emrich (EvilPenguin). All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (A)

+ (instancetype) colorFromHex:(int64_t)hex;
+ (CGColorRef) cgColorFromhex:(int64_t)hex;

@end

NS_ASSUME_NONNULL_END
