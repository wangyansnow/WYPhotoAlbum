//
//  NSString+WYPattern.h
//  正则表达式
//
//  Created by 王俨 on 15/12/5.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WYPattern)

- (void)patternGroupStr:(NSString **)groupName count:(NSInteger *)count;

@end
