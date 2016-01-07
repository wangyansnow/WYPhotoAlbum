//
//  WYPhotoBrowser.h
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/7.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYPhotoBrowser : UIViewController

@property (nonatomic, strong) NSArray *thumbnailImageModels;
/// 当前显示图片索引
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

+ (instancetype)photoBrowserWithModels:(NSArray *)thumbnailImageModels indexPath:(NSIndexPath *)indexPath;
- (instancetype)initWithModels:(NSArray *)thumbnailImageModels indexPath:(NSIndexPath *)indexPath;

/// 返回当前浏览图片
- (UIImageView *)currentImageView;
@end
