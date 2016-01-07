//
//  WYPhotoBrowserCell.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/9.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYPhotoBrowserCell.h"
#import "WYThumbnailImageModel.h"

@interface WYPhotoBrowserCell ()

@property (nonatomic, assign) CGFloat scale;

@end

@implementation WYPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)setupUI {
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_imageView];
    
    [self addGesture];
    self.scale = 1.0;
}

- (void)addGesture {
    UITapGestureRecognizer *tapGestureOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClickOne:)];
    tapGestureOnce.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *tapGestureTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClickTwice:)];
    tapGestureTwice.numberOfTapsRequired = 2;
    
    [tapGestureOnce requireGestureRecognizerToFail:tapGestureTwice];
    [_imageView addGestureRecognizer:tapGestureOnce];
    [_imageView addGestureRecognizer:tapGestureTwice];
}

- (void)tapGestureClickOne:(UITapGestureRecognizer *)tapGesture {
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
- (void)tapGestureClickTwice:(UITapGestureRecognizer *)tapGesture {
    self.scale = self.scale == 1 ? 2: 1;
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
    }];
}


- (void)setThumbnailImageModel:(WYThumbnailImageModel *)thumbnailImageModel {
    _thumbnailImageModel = thumbnailImageModel;
    [thumbnailImageModel downloadOriginalImageCompletion:^(UIImage *image) {
        _imageView.image = image;
        CGFloat height = image.size.height / image.size.width * APP_WIDTH;
        CGFloat marginY = 0;
        if (height < APP_HEIGHT) {
            marginY = (APP_HEIGHT - height) * 0.5;
        }
        _imageView.frame = CGRectMake(0, marginY, APP_WIDTH, height);
    }];
}

@end
