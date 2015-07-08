//
//  HDSay.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-24.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSay : NSObject<UIAlertViewDelegate>{


}

- (void)say:(NSString *)s withBlock:(void (^)(NSInteger iPressedIndex))Block;

@end
