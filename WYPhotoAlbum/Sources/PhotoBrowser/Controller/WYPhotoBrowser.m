//
//  WYPhotoBrowser.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/7.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYPhotoBrowser.h"
#import "WYThumbnailImageModel.h"
#import "UIView+Extension.h"
#import "WYPhotoBrowserCell.h"

#define kPageMargin 20

@interface WYPhotoBrowser ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation WYPhotoBrowser

+ (instancetype)photoBrowserWithModels:(NSArray *)thumbnailImageModels indexPath:(NSIndexPath *)indexPath; {
    return [[self alloc] initWithModels:thumbnailImageModels indexPath:indexPath];
}
- (instancetype)initWithModels:(NSArray *)thumbnailImageModels indexPath:(NSIndexPath *)indexPath; {
    if (self = [super init]) {
        [self setupUI];
        self.currentIndexPath = indexPath;
        NSLog(@"firstIndex = %ld", indexPath.item);
        self.thumbnailImageModels = thumbnailImageModels;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark - setupUI
- (void)setupUI {
    [self prepareUI];
    
    [self.view addSubview:_collectionView];
}

- (void)prepareUI {
    self.view.width += kPageMargin;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    NSLog(@"frame = %@", NSStringFromCGRect(flowLayout.collectionView.bounds));
    flowLayout.itemSize = self.view.bounds.size;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.bounces = false;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[WYPhotoBrowserCell class] forCellWithReuseIdentifier:kReuseId];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailImageModels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WYThumbnailImageModel *thumbnailImageModel = self.thumbnailImageModels[indexPath.item];
    WYPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseId forIndexPath:indexPath];
    cell.thumbnailImageModel = thumbnailImageModel;
    cell.dismissBlock = ^(){
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffset = scrollView.contentOffset.x;
    int page = contentOffset / (APP_WIDTH + kPageMargin);
    self.currentIndexPath = [NSIndexPath indexPathForItem:page inSection:0];
    NSLog(@"self.currentpage = %d", page);
}

/// 返回当前浏览图片
- (UIImageView *)currentImageView {
    NSLog(@"visibleCell = %@", _collectionView.visibleCells[0]);
    WYPhotoBrowserCell *cell = (WYPhotoBrowserCell *)_collectionView.visibleCells[0];
    NSLog(@"indexPath.item = %ld", self.currentIndexPath.item);
    NSLog(@"cell = %@, cell.imageView = %@", cell, cell.imageView);
    return cell.imageView;
}

@end
