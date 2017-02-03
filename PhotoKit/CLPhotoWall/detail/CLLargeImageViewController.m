//
//  CLLargeImageViewController.m
//  PHPhotoAssetCollection
//
//  Created by 秦传龙 on 16/12/1.
//  Copyright © 2016年 hezhijingwei. All rights reserved.
//

#import "CLLargeImageViewController.h"
#import "CLLoadPhotoAsset.h"
#import "CLLargeImageCollectionViewCell.h"
#import "CLPhotoAssetConst.h"
#import "CLPhotoAssetInfo.h"
#import "CLCollectionViewLayout.h"
#import "UIImage+PhotoAsset.h"


@interface CLLargeImageViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,LargeImageCollectionViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *ToolBar;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIButton *navigationBackItem;

@property(nonatomic,assign)BOOL  isNoFirstLayout;
@property (nonatomic, assign) BOOL isHidden;


@end

@implementation CLLargeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    [self setupFinishBtnLayout];
    [self setupselectBtnLayout];
    [self setupNavigationBackItemLayout];
    [self setupCollectionViewLayout];
    [self toolBarLayout];
    [self navBarLayout];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    
    [self.navigationController setNavigationBarHidden:[viewController isKindOfClass:[self class]] animated:YES];
    
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.isNoFirstLayout) {
        [self.collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self rePreViewByIndex:self.indexPath.row];
        self.isNoFirstLayout = YES;
    }
    
}



- (void)finishBtnClick {
    
    NSDictionary *dict = @{CLPhotoAssetSelectImageNotificationUserInfoKey:self.selectArr};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLPhotoAssetSelectImageNotificationName object:nil userInfo:dict];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)selectBtnClick {
    
    NSInteger index = (NSInteger)self.collectionView.contentOffset.x/self.collectionView.frame.size.width;
    
    CLPhotoAssetInfo *info = self.dataSource[index];
    
    if (info.selected) {
        
        info.selected = NO;
        [self.selectArr removeObject:info];
        [self.selectBtn setBackgroundImage:[self imageNamed:@"def_picker"] forState:UIControlStateNormal];
        
        
    } else {
        
        if (self.selectArr.count + self.didSelectCount >=5) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"你最多选择%ld张图片", 5-self.didSelectCount] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
            return;
            
        }
        
        
        info.selected = YES;
        [self.selectArr addObject:info];
        [self.selectBtn setBackgroundImage:[self imageNamed:@"sel_picker"] forState:UIControlStateNormal];
    }
    
    [self.dataSource replaceObjectAtIndex:index withObject:info];
    
    
}


// 图片路径
#define CLPhotoWallSrcName(file) [@"CLPhotoWall.bundle" stringByAppendingPathComponent:file]

- (UIImage *)imageNamed:(NSString *)imageName {

    return [UIImage imageNamed:CLPhotoWallSrcName(imageName)];
    
}



- (void)navigationBackItemClick {
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(largeImagePopView:dataSource:)]) {
        [_delegate largeImagePopView:self.selectArr dataSource:self.dataSource];
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}


- (void)navBarLayout {
    
    [self.view addSubview:self.navBar];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_navBar(60)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBar)]];
    
}



- (UIView *)navBar {
    
    if (!_navBar) {
        
        _navBar = [[UIView alloc] init];
        _navBar.translatesAutoresizingMaskIntoConstraints = NO;
        _navBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        
    }
    return _navBar;
    
}

- (void)setupNavigationBackItemLayout {
    
    [self.navBar addSubview:self.navigationBackItem];
    
    [self.navBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_navigationBackItem(20)]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navigationBackItem)]];
    [self.navBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_navigationBackItem(20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navigationBackItem)]];
    
}


- (UIButton *)navigationBackItem {
    
    if (!_navigationBackItem) {
        
        _navigationBackItem = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_navigationBackItem setBackgroundImage:[self imageNamed:@"nagation_back"] forState:UIControlStateNormal];
        _navigationBackItem.translatesAutoresizingMaskIntoConstraints = NO;
        [_navigationBackItem addTarget:self action:@selector(navigationBackItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _navigationBackItem;
}



- (void)setupselectBtnLayout {
    
    [self.navBar addSubview:self.selectBtn];
    
    [self.navBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_selectBtn(30)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_selectBtn)]];
    [self.navBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_selectBtn(30)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_selectBtn)]];
    
}


- (UIButton *)selectBtn {
    
    if (!_selectBtn) {
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_selectBtn setBackgroundImage:[self imageNamed:@"def_picker"] forState:UIControlStateNormal];
        _selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_selectBtn addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectBtn;
}




- (void)setupFinishBtnLayout {
    
    [self.ToolBar addSubview:self.finishBtn];
    
    [self.ToolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_finishBtn]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_finishBtn)]];
    [self.ToolBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_finishBtn(50)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_finishBtn)]];
    
}


- (UIButton *)finishBtn {
    
    if (!_finishBtn) {
        
        _finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_finishBtn setTitleColor:[UIColor colorWithRed:26.0/255.0 green:178.0/255.0 blue:10.0/255.0 alpha:1] forState:UIControlStateNormal];
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _finishBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _finishBtn;
}


- (void)toolBarLayout {
    
    [self.view addSubview:self.ToolBar];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_ToolBar(45)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_ToolBar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_ToolBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_ToolBar)]];
    
}



- (UIView *)ToolBar {
    
    if (!_ToolBar) {
        
        _ToolBar = [[UIView alloc] init];
        _ToolBar.translatesAutoresizingMaskIntoConstraints = NO;
        _ToolBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        
    }
    return _ToolBar;
    
}





- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}


- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
        
    }
    
    return _dataSource;
}


- (NSMutableArray *)selectArr {
    
    if (!_selectArr) {
        
        _selectArr = [NSMutableArray array];
        
    }
    
    return _selectArr;
}


- (void)setupCollectionViewLayout {
    [self.view addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    

    
    
    
}



- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        CLCollectionViewLayout *flowLayout = [[CLCollectionViewLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,self.view.frame.size.height);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[CLLargeImageCollectionViewCell class] forCellWithReuseIdentifier:@"collectionView"];
        
    }
    
    return _collectionView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CLLargeImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionView" forIndexPath:indexPath];
    CLPhotoAssetInfo *info = self.dataSource[indexPath.row];
    
    cell.assetInfo = info;
    cell.delegate = self;
    
    return cell;
}








- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataSource.count;
    
}


//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//
//
//}


#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat x = scrollView.contentOffset.x;
    
    NSInteger count = (NSInteger)x/self.collectionView.frame.size.width;
    
    [self rePreViewByIndex:count];
    
}


- (void)rePreViewByIndex:(NSInteger)count {
    
    if (count > self.dataSource.count-1) {
        return;
    }
    
    CLPhotoAssetInfo *info = self.dataSource[count];
    
    if (!info.selected) {
        
        [self.selectBtn setBackgroundImage:[self imageNamed:@"def_picker"] forState:UIControlStateNormal];
        
    } else {
        
        [self.selectBtn setBackgroundImage:[self imageNamed:@"sel_picker"] forState:UIControlStateNormal];
        
    }
    
}


#pragma mark - LargeImageCollectionViewDelegate

- (void)largeImageCollectionViewDidClick:(UITapGestureRecognizer *)tap {
    
    if (self.isHidden) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.navBar.alpha = 1;
            self.ToolBar.alpha = 1;
            
        }];
        
        
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.navBar.alpha = 0;
            self.ToolBar.alpha = 0;
            
        }];
        
    }
    
    self.isHidden = !self.isHidden;
    
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x < -100) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
