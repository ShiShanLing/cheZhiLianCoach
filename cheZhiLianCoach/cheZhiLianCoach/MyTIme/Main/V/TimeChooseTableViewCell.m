//
//  TimeChooseTableViewCell.m
//  timeChoose
//
//  Created by 石山岭 on 2017/8/3.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "TimeChooseTableViewCell.h"
#import "timeStateCVCell.h"

@interface TimeChooseTableViewCell ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching, UICollectionViewDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;

@end

@implementation TimeChooseTableViewCell {


    NSMutableArray *_DATAARRAY;

}




-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.PeriodTimeLabel = [[UILabel alloc] init];
        _PeriodTimeLabel.text = @"上\n午";
        _PeriodTimeLabel.textColor = [UIColor whiteColor];
        _PeriodTimeLabel.font = [UIFont systemFontOfSize:12];
        _PeriodTimeLabel.layer.cornerRadius = 5;
        _PeriodTimeLabel.numberOfLines = 2;
        _PeriodTimeLabel.textAlignment = 1;
        _PeriodTimeLabel.layer.masksToBounds = YES;
        _PeriodTimeLabel.backgroundColor = MColor(115, 118, 128);
        [self.contentView addSubview:_PeriodTimeLabel];
        
        _PeriodTimeLabel.sd_layout.leftSpaceToView(self.contentView, kFit(9)).topSpaceToView(self.contentView, kFit(5)).bottomSpaceToView(self.contentView, kFit(5)).widthIs(kFit(29));
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(kFit(70), kFit(80));
        layout.minimumLineSpacing = kFit(5);
        layout.minimumInteritemSpacing = kFit(5);
        
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(kFit(45), kFit(5), kScreen_widht-kFit(45),kFit(165)) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[timeStateCVCell class] forCellWithReuseIdentifier:@"timeStateCVCell"];
        [self.contentView addSubview:_collectionView];
        self.collectionView.sd_layout.leftSpaceToView(self.contentView, kFit(45)).topSpaceToView(self.contentView, kFit(5)).rightSpaceToView(self.contentView, 0).bottomSpaceToView(self.contentView, 0);
        UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOr:)];
        [swipeLeftGR setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.collectionView addGestureRecognizer:swipeLeftGR];
        
        // 右扫手势
        UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOr:)];
        //    [swipeRightGR setCancelsTouchesInView:YES];
        [swipeRightGR setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.collectionView addGestureRecognizer:swipeRightGR];
        
    }
    return self;
}

- (void)handleSwipeOr:(UISwipeGestureRecognizer *)swipe {
    if ([_delegate respondsToSelector:@selector(handleSwipeFrom:)]) {
        [_delegate handleSwipeFrom:swipe];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _DATAARRAY.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    timeStateCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeStateCVCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 5;
    CoachTimeListModel *model = _DATAARRAY[0];
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:model.periodStr];
    [tempStr insertString:@"\n" atIndex:1];
    _PeriodTimeLabel.text = tempStr;
    [cell ModifyState:_DATAARRAY[indexPath.row] indexPath:indexPath section:_cellSection];;
    cell.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.cellSection];
    if ([_delegate respondsToSelector:@selector(ClickIndex:)]) {
        [_delegate ClickIndex:tempIndexPath];
    }
    
    
}

//返回每个cell的布局左右上下间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return   UIEdgeInsetsMake(0, kFit(5), kFit(5), kFit(10));
}

- (void)setStoreArray:(NSMutableArray *)storeArray {
    
}
#pragma mark - UICollectionViewDelegateFlowLayout
//在这个方法里面给cell赋值

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}



- (void)setDataArray:(NSMutableArray *)dataArray {
    _DATAARRAY = dataArray;
    if (dataArray.count == 0) {
    _PeriodTimeLabel.hidden  = YES;
    }else {
    _PeriodTimeLabel.hidden  = NO;
    }
    [self.collectionView reloadData];
}


@end
