//
//  WYPhotoGroup.h
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/5.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYPhotoGroup : NSObject

/// 相册组名称
@property (nonatomic, copy) NSString *groupName;
/// 相册图片数
@property (nonatomic, assign) NSInteger photoCount;
/// 该组显示的一张缩略图
@property (nonatomic, strong) UIImage *thumbnailImage;
/// 缩略图数组
@property (nonatomic, strong) NSMutableArray *thumbnailPics;

+ (instancetype)photoGroup:(NSString *)groupName photoCount:(NSInteger)photoCount;
- (instancetype)initWithPhotoGroup:(NSString *)groupName photoCount:(NSInteger)photoCount;



@end
