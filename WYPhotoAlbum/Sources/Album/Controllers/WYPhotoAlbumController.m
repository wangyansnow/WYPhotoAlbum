//
//  WYPhotoAlbumController.m
//  WYPhotoAlbum
//
//  Created by 王俨 on 15/12/5.
//  Copyright © 2015年 wangyan. All rights reserved.
//

#import "WYPhotoAlbumController.h"
#import <AssetsLibrary/AssetsLibrary.h>  // 必须导入
#import "NSString+WYPattern.h"
#import "WYPhotoGroup.h"
#import "WYThumbnailImageModel.h"
#import "WYThumbnailCell.h"
#import "WYPhotoBrowser.h"

#define kReuseId @"thumbnailCell"

typedef void(^DownloadBlock)(CGRect frame);

// MainViewController
@interface WYPhotoAlbumController() <UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic,strong) NSMutableArray        *groupArrays;

@property (nonatomic, strong) NSMutableArray       *photoGroups;
@property (nonatomic, strong) NSMutableArray       *thumbnailImgModels;

/// 数据源
@property (nonatomic, strong) NSMutableArray *dataSource;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, strong) UIButton *previewBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, assign, getter=isPresentFlag) BOOL presentFlag;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *presentImageView;

@end

@implementation WYPhotoAlbumController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Demo";
    self.view.backgroundColor = [UIColor clearColor];
    
    // 测试BarItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(testGetAlbum)];
    
    [self setupUI];
    [self clearCache];
}

- (void)clearCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:KOriginalPhotoImagePath error:nil];
}

- (void)addThumbnailImageMdeol:(WYThumbnailImageModel *)thumbnailImageModel {
    [self.dataSource addObject:thumbnailImageModel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
    });
}

#pragma mark - 设置界面UI
- (void)setupUI {
    [self prepareCollectionView];
    [self prepareBottomToolBar];
    
    [self.view addSubview:_collectionView];
    [self.view addSubview:_bottomToolbar];
    [_bottomToolbar addSubview:_previewBtn];
    [_bottomToolbar addSubview:_sendBtn];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = false;
    _bottomToolbar.translatesAutoresizingMaskIntoConstraints = false;
    _previewBtn.translatesAutoresizingMaskIntoConstraints = false;
    _sendBtn.translatesAutoresizingMaskIntoConstraints = false;
    
    NSDictionary *attrs = @{@"collectionView": _collectionView, @"bottomToolbar": _bottomToolbar, @"previewBtn": _previewBtn, @"sendBtn": _sendBtn};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[collectionView]-0-|" options:0 metrics:nil views:attrs]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-[bottomToolbar(44)]-0-|" options:0 metrics:nil views:attrs]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomToolbar]-0-|" options:0 metrics:nil views:attrs]];
}

- (void)prepareCollectionView {
    CGFloat margin = 5;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((APP_WIDTH - margin * 2) / 3, APP_WIDTH / 3);
    flowLayout.minimumInteritemSpacing = margin * 0.5; //水平间距
    flowLayout.minimumLineSpacing = margin; // 竖直间距
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.bounces = false;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[WYThumbnailCell class] forCellWithReuseIdentifier:kReuseId];
}

- (void)prepareBottomToolBar {
    _bottomToolbar = [[UIToolbar alloc] init];
    _previewBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    _sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_previewBtn sizeToFit];
    [_sendBtn sizeToFit];
    
//    UIBarButtonItem *previewItem = [[UIBarButtonItem alloc] initWithCustomView:_previewBtn];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:_sendBtn];
    
    UIBarButtonItem *previewItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:nil action:nil];
    [previewItem setTintColor:[UIColor blackColor]];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:nil action:nil];
    _bottomToolbar.items = @[previewItem, flexibleItem, sendItem];
}

#pragma mark - 获取相册图片
- (void)testGetAlbum {
    NSLog(@"count = %ld, items = %@", _bottomToolbar.items.count, _bottomToolbar.items);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 相册访问成功block
        ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.groupArrays addObject:group];
            }  else {
                [weakSelf.groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *groupStr = [NSString stringWithFormat:@"%@", obj];
                    NSString *groupName = nil;
                    NSInteger count = 0;
                    [groupStr patternGroupStr:&groupName count:&count];
                    if (count == 0) {
                        NSLog(@"这组没有图片");
                    }
                    WYPhotoGroup *photoGroup = [WYPhotoGroup photoGroup:groupName photoCount:count];
                    [self.photoGroups addObject:photoGroup];
                    [obj enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if ([asset thumbnail] != nil) { // CGImage
                            // 照片
                            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                                WYThumbnailImageModel *thumbnailModel = [WYThumbnailImageModel thumbnailImageWithAsset:asset];
                                [weakSelf addThumbnailImageMdeol:thumbnailModel];
                                [photoGroup.thumbnailPics addObject:thumbnailModel];
                            } else if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) { // 视频
                                NSString *fileName = [[asset defaultRepresentation] filename];
                            }
                        }
                    }];
                }];
            }
        };
        // 相册访问失败block
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            NSString *errorMessage = nil;
            switch ([error code]) {
                case ALAssetsLibraryAccessGloballyDeniedError:
                case ALAssetsLibraryAccessUserDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                default:
                    errorMessage = @"Reason unknown";
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error, cannot access" message:errorMessage delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
                [alertView show];
            });
        };
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupBlock failureBlock:failureBlock];
    });
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WYThumbnailImageModel *thumbnailImageModel = self.dataSource[indexPath.item];
    WYThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseId forIndexPath:indexPath];
    cell.thumbnailModel = thumbnailImageModel;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WYThumbnailImageModel *model = self.dataSource[indexPath.item];
    self.selectedIndexPath = indexPath;
    self.presentImageView.image = model.thumbnailImage;
    WYPhotoBrowser *photoBrowser = [WYPhotoBrowser photoBrowserWithModels:self.dataSource indexPath:indexPath];
    photoBrowser.modalPresentationStyle = UIModalPresentationCustom;
    photoBrowser.transitioningDelegate = self;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presentFlag = true;
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presentFlag = false;
    return self;
}
#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresentFlag) {   //modal出来一个控制器
        UIView *modalView = [transitionContext viewForKey:UITransitionContextToViewKey];
        self.presentImageView.frame = [self imageFrameOnWindowAtIndexPath:self.selectedIndexPath];
        [[transitionContext containerView] addSubview:self.presentImageView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.presentImageView.frame = [self imageFullFrameOnWindowAtIndexpath:self.selectedIndexPath];
        } completion:^(BOOL finished) {
            [[transitionContext containerView] addSubview:modalView];
            [self.presentImageView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else {
        WYPhotoBrowser *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        NSIndexPath *currentIndexPath = fromVC.currentIndexPath;
        UIImageView *temporaryView = [fromVC currentImageView];
        [fromVC.view removeFromSuperview];
        [[transitionContext containerView] addSubview:temporaryView];
        temporaryView.frame = [self imageFullFrameOnWindowAtIndexpath:currentIndexPath];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            temporaryView.frame = [self imageFrameOnWindowAtIndexPath:currentIndexPath];
        } completion:^(BOOL finished) {
            [temporaryView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}


#pragma mark - 计算图片显示位置
/// 计算图片在屏幕上位置
- (CGRect)imageFrameOnWindowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row = %ld", indexPath.item);
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    return [cell convertRect:cell.bounds toCoordinateSpace:[UIApplication sharedApplication].keyWindow];
}

/// 计算图片放大后在屏幕上的位置
- (CGRect)imageFullFrameOnWindowAtIndexpath:(NSIndexPath *)indexPath {
    UIImage *image = self.presentImageView.image;
    CGSize size = image.size;
    CGFloat height = size.height / size.width * APP_WIDTH;
    CGFloat y = 0;
    if (height < APP_HEIGHT) {
        y = (APP_HEIGHT - height) * 0.5;
    }
    return CGRectMake(0, y, APP_WIDTH, height);
}





#pragma mark - 懒加载
- (NSMutableArray *)groupArrays {
    if (_groupArrays == nil) {
        _groupArrays = [NSMutableArray array];
    }
    return _groupArrays;
}

- (NSMutableArray *)photoGroups {
    if (_photoGroups == nil) {
        _photoGroups = [NSMutableArray array];
    }
    return _photoGroups;
}
- (NSMutableArray *)thumbnailImgModels {
    if (_thumbnailImgModels == nil) {
        _thumbnailImgModels = [NSMutableArray array];
    }
    return _thumbnailImgModels;
}
- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UIImageView *)presentImageView {
    if (_presentImageView == nil) {
        _presentImageView = [[UIImageView alloc] init];
    }
    return _presentImageView;
}

@end
