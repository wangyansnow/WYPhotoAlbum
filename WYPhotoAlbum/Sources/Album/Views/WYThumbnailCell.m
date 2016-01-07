//
//  WYThumbnailCell.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/7.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYThumbnailCell.h"
#import "WYThumbnailImageModel.h"

@interface WYThumbnailCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation WYThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)setupUI {
    _imageView = [[UIImageView alloc] init];
    _selectBtn = [[UIButton alloc] init];
    [_selectBtn setImage:[UIImage imageNamed:@"hook"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"hook_selected"] forState:UIControlStateSelected];
    [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_imageView];
    [self.contentView addSubview:_selectBtn];
    
    _imageView.translatesAutoresizingMaskIntoConstraints = false;
    _selectBtn.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView": _imageView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView": _imageView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[selectBtn(32)]-0-|" options:0 metrics:nil views:@{@"selectBtn": _selectBtn}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selectBtn(32)]" options:0 metrics:nil views:@{@"selectBtn": _selectBtn}]];
}

- (void)selectBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
}

- (void)setThumbnailModel:(WYThumbnailImageModel *)thumbnailModel {
    _thumbnailModel = thumbnailModel;
    
    _imageView.image = thumbnailModel.thumbnailImage;
}


@end
