//
//  WYPhotoGroup.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/5.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYPhotoGroup.h"

@implementation WYPhotoGroup

+ (instancetype)photoGroup:(NSString *)groupName photoCount:(NSInteger)photoCount {
    return [[self alloc] initWithPhotoGroup:groupName photoCount:photoCount];
}
- (instancetype)initWithPhotoGroup:(NSString *)groupName photoCount:(NSInteger)photoCount {
    if (self = [super init]) {
        self.groupName = groupName;
        self.photoCount = photoCount;
    }
    return self;
}

#pragma mark - 懒加载
- (NSMutableArray *)thumbnailPics {
    if (_thumbnailPics == nil) {
        _thumbnailPics = [NSMutableArray array];
    }
    return _thumbnailPics;
}

@end
