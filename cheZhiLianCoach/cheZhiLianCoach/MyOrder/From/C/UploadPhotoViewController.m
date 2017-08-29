//
//  UploadPhotoViewController.m
//  guangda
//
//  Created by Dino on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "UploadPhotoViewController.h"
#import "CZPhotoPickerController.h"
#import "LoginViewController.h"

@interface UploadPhotoViewController ()
//图片view
@property (strong, nonatomic) IBOutlet UIImageView *idCardImageView;
@property (strong, nonatomic) IBOutlet UIImageView *idCardBackImageView;
@property (strong, nonatomic) IBOutlet UIImageView *cardImageView;

//删除按钮
@property (strong, nonatomic) IBOutlet UIButton *idCardBackDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *idCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *cardDeBtn;

@property (strong, nonatomic) UIImage *idCardImage;
@property (strong, nonatomic) UIImage *idCardBackImage;
@property (strong, nonatomic) UIImage *cardImage;

@property (strong, nonatomic) UIImageView *clickImageView;
@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;

@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;
@end

@implementation UploadPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alertDetailView.layer.cornerRadius = 4;
    self.alertDetailView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)uploadPhotoClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 0) {
        //身份证正面
        self.clickImageView = self.idCardImageView;
    }else if (button.tag == 1){
        //身份证反面
        self.clickImageView = self.idCardBackImageView;
    }else if (button.tag == 2){
        //驾照或者学员证
        self.clickImageView = self.cardImageView;
    }
    
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
    
    self.alertView.tag = button.tag;
}

// 选择图片
- (IBAction)clickForImage:(id)sender {
   
    UIButton *button = (UIButton *)sender;
    
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.allowsEditing = NO;
    if (button.tag == 0 && [CZPhotoPickerController canTakePhoto]) {
        //拍照
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (IBAction)delImage:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        //身份证正面
        self.idCardImageView.image = [UIImage imageNamed:@"bg_upload_photo"];
    }else if (button.tag == 1){
        //身份证反面
        self.idCardBackImageView.image = [UIImage imageNamed:@"bg_upload_photo_fan"];
    }else if (button.tag == 2){
        //驾照或者学员证
        self.cardImageView.image = [UIImage imageNamed:@"bg_upload_photo_3"];
    }
    
    button.hidden = YES;
}

#pragma mark 提交资料
- (IBAction)clickForUpload:(id)sender {
    //判断图片是否为空
    if (self.idCardDelBtn.hidden) {
        //身份证正面照为空
        [self makeToast:@"请上传身份证正面照"];
        return;
    }
    
    if (self.idCardBackDelBtn.hidden) {
        //身份证反面照为空
        [self makeToast:@"请上传身份证反面照"];
        return;
    }
    
    if (self.cardDeBtn.hidden) {
        //驾照或者学员证为空
        [self makeToast:@"请上传驾照或者学员证"];
        return;
    }
    
    [self uploadStudentMsg];
}

- (IBAction)removeAlertView:(id)sender {
    [self.alertView removeFromSuperview];
}

#pragma mark - 拍照
- (CZPhotoPickerController *)photoController
{
    typeof(self) weakSelf = self;
    
    return [[CZPhotoPickerController alloc] initWithPresentingViewController:self withCompletionBlock:^(UIImagePickerController *imagePickerController, NSDictionary *imageInfoDict) {
        
        [weakSelf.pickPhotoController dismissAnimated:YES];
        weakSelf.pickPhotoController = nil;
        
        if (imagePickerController == nil || imageInfoDict == nil) {
            return;
        }
        
        UIImage *image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            image = [CommonUtil fixOrientation:image];
        }
        
        if (weakSelf.clickImageView != nil) {
            weakSelf.clickImageView.image = image;
        }
        
        if (weakSelf.alertView.tag == 0) {
            //身份证正面
            weakSelf.idCardImage = image;
            weakSelf.idCardDelBtn.hidden = NO;
        }else if (weakSelf.alertView.tag == 1){
            //身份证反面
            weakSelf.idCardBackImage = image;
            weakSelf.idCardBackDelBtn.hidden = NO;
        }else if (weakSelf.alertView.tag == 2){
            //驾照或者学员证
            weakSelf.cardImage = image;
            weakSelf.cardDeBtn.hidden = NO;
        }
        
        [weakSelf.alertView removeFromSuperview];
    }];
}


#pragma mark - 接口
- (void)uploadStudentMsg{
   
    [DejalBezelActivityView activityViewForView:self.view];
    

}

- (void) backLogin {
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
