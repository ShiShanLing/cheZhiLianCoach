//
//  CoachRuleViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachRuleViewController.h"

@interface CoachRuleViewController ()<UITextViewDelegate,UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CoachRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.delegate = self;
    self.textView.editable = NO;
    
    self.textView.hidden = YES;
    
    self.webView.delegate = self;
    NSURLRequest *request;
    if ([self.fromVC intValue]==1) {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xiaobaxueche.com/servicestandard.html"]];
        self.titleLabel.text = @"服务标准及约定";
    }else if([self.fromVC intValue]==2){
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xiaobaxueche.com/popularcoaches.html"]];
        self.titleLabel.text = @"小巴明星教练服务协议";
    }else if([self.fromVC intValue]==3){
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.xiaobaxueche.com/serviceprotocol-c.html"]];
        self.titleLabel.text = @"小巴陪驾服务协议";
    }
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.fromVC intValue]==1) {
        self.titleLabel.text = @"服务标准及约定";
    }else if([self.fromVC intValue]==2){
        self.titleLabel.text = @"小巴明星教练服务协议";
    }else if([self.fromVC intValue]==2){
        self.titleLabel.text = @"小巴陪驾服务协议";
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.textView setContentOffset:CGPointMake(0, 0)];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSRange range;
    range.location = 0;
    range.length = 0;
    textView.selectedRange = range;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (IBAction)backWebView:(id)sender {
//    [self.webView goBack];
//}
@end
