//
//  NSString+WYPattern.m
//  正则表达式
//
//  Created by 王俨 on 15/12/5.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "NSString+WYPattern.h"

@implementation NSString (WYPattern)

- (void)patternGroupStr:(NSString **)groupName count:(NSInteger *)count {
    NSString *str = [self stringByAppendingString:@"--"];
    NSString *pattern =  @"ALAssetsGroup - Name:(.*?), Type:Photo Stream, Assets count:(.*?)--";
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSTextCheckingResult *textCheckingResult = [regularExpression firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    
    NSRange range2 = [textCheckingResult rangeAtIndex:1];
    NSRange range3 = [textCheckingResult rangeAtIndex:2];
    
    NSString *str2 = [str substringWithRange:range2];
    NSString *str3 = [str substringWithRange:range3];
    
    *groupName = str2;
    *count = [str3 integerValue];
}


@end
