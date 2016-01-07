//
//  WYThumbnailImageModel.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/7.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYThumbnailImageModel.h"


@implementation WYThumbnailImageModel

+ (instancetype)thumbnailImageWithAsset:(ALAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(ALAsset *)asset {
    if (self = [super init]) {
        self.asset = asset;
    }
    return self;
}


- (void)setAsset:(ALAsset *)asset {
    _asset = asset;
    
    self.date = [asset valueForProperty:ALAssetPropertyDate];
    self.thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
    self.fileName = [[asset defaultRepresentation] filename];
   self.url = [[asset defaultRepresentation] url];   // 通过这个URL获取原图
    self.fileSize = [[asset defaultRepresentation] size];
    
//    NSLog(@"date = %@", self.date);
//    NSLog(@"image = %@", self.thumbnailImage);
//    NSLog(@"fileName = %@", self.fileName);
//    NSLog(@"url = %@", self.url);
//    NSLog(@"fileSize = %lld", self.fileSize);
}

/// 下载原图 -- 将原始图片的URL转化为NSData数据,写入沙盒
- (void)downloadOriginalImageCompletion:(CompletionBlock)completion {
    NSAssert(completion != nil, @"必须要有回调");
    NSFileManager * fileManager = [NSFileManager defaultManager];
    // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
    NSString *filePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:self.fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"图片已经保存在本地了,不再需要转化");
        completion([UIImage imageWithContentsOfFile:filePath]);
        return;
    }
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        NSLog(@"kOriginalPhotoImagePath = %@", KOriginalPhotoImagePath);
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.url) {
            // 主要方法
            [assetLibrary assetForURL:self.url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([UIImage imageWithData:data]);
                });
                [data writeToFile:filePath atomically:YES];
            } failureBlock:nil];
        }
    });
}

/// 会阻塞主线程的下载
- (UIImage *)downloadOriginalImage {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
    NSString *filePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:self.fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"图片已经保存在本地了,不再需要转化");
        return [UIImage imageWithContentsOfFile:filePath];
    }
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        NSLog(@"kOriginalPhotoImagePath = %@", KOriginalPhotoImagePath);
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (self.url) {
        // 主要方法
        __block UIImage *image = nil;
        [assetLibrary assetForURL:self.url resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            [data writeToFile:filePath atomically:YES];
            
            image =  [UIImage imageWithData:data];
        } failureBlock:nil];
        if (image == nil) {
            NSLog(@"我查,没有图片");
        }
        return image;
    }
    NSLog(@"返回空图片了");
    return nil;
}

@end
