//
//  WYPhotoBrowserCell.h
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/9.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissBlock)();
#define kReuseId @"photoBrowserCell"

@class WYThumbnailImageModel;
@interface WYPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong) WYThumbnailImageModel *thumbnailImageModel;
@property (nonatomic, copy) DismissBlock dismissBlock;
@property (nonatomic, strong) UIImageView *imageView;

@end
