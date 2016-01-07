//
//  WYThumbnailImageModel.h
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/7.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// 照片原图路径
#define KOriginalPhotoImagePath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

// 视频URL路径
#define KVideoUrlPath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]

// caches路径
#define KCachesPath   \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define APP_WIDTH [UIScreen mainScreen].bounds.size.width
#define APP_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef void(^CompletionBlock)(UIImage *image);

@class ALAsset;
@interface WYThumbnailImageModel : NSObject

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIImage *thumbnailImage;
/// 通过这个url获取原图
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) long long fileSize;


+ (instancetype)thumbnailImageWithAsset:(ALAsset *)asset;
- (instancetype)initWithAsset:(ALAsset *)asset;

/// 下载原图 -- 将原始图片的URL转化为NSData数据,写入沙盒
- (void)downloadOriginalImageCompletion:(CompletionBlock)completion;
/// 会阻塞主线程的下载
- (UIImage *)downloadOriginalImage;

@end
