//
//  SchoolSelectViewController.m
//  guangda
//
//  Created by Ray on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SchoolSelectViewController.h"
#import "SchoolSelectTableViewCell.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface SchoolSelectViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (nonatomic, strong) NSMutableArray *showItems;
@property (nonatomic, copy) NSMutableArray *allItems;

@end

@implementation SchoolSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.allItems = [[NSMutableArray alloc]init];
    
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    
    self.search.delegate = self;
    self.search.placeholder = @"请输入驾校名称";
    [self getCarSchool];
}

- (void)resetFrame
{
    CGRect bounds =  self.searchDisplayController.searchResultsTableView.superview.bounds;
    CGFloat offset = CGRectGetMinY(bounds);
    if (offset == 0)
    {
        self.searchDisplayController.searchResultsTableView.superview.bounds =CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-80);
    }
    
    //CGRect r1=  self.searchDisplayController.searchBar.frame;
    CGRect r2=  self.search.frame;
    CGRect r3=  self.searchDisplayController.searchResultsTableView.superview.frame;
    r3.origin.y = r2.origin.y+r2.size.height;
    [self.searchDisplayController.searchResultsTableView.superview setFrame:r3];
    //CGRect r4=  self.search.superview.frame;
    
    
    CGRect tableFrame= self.searchDisplayController.searchResultsTableView.frame;
    //tableFrame.origin.y=10;
    [self.searchDisplayController.searchResultsTableView setFrame:tableFrame];
    for(UIView * v in self.searchDisplayController.searchResultsTableView.superview.subviews)
    {
        //NSLog(@"%@---------%f",[v class],v.alpha);
        if([v isMemberOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")])
        {
            [v setFrame:tableFrame]; //
            v.alpha=0.5;
            //v.backgroundColor=[UIColor whiteColor];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showItems.count !=0) {
        return self.showItems.count;
    }else{
        return self.allItems.count;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=@"选择医院";
}

//这里绘制的tableview只需要绘制一个就够了，因为搜索结果可以直接显示在原有的tableview上—————————————————————————————————————————————————————————————————

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"SchoolSelectTableViewCell";
    SchoolSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SchoolSelectTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = [[NSDictionary alloc]init];
    if (self.showItems.count==0) {
        dic = [self.allItems objectAtIndex:indexPath.row];
    }else{
        dic = [self.showItems objectAtIndex:indexPath.row];
    }
    cell.schoolName.text = [dic[@"name"] description];
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [self.navigationController popViewControllerAnimated:YES];
    [self.search resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    //[searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // 用NSPredicate来过滤数组。
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains  %@",searchText];
    self.showItems = [[NSMutableArray alloc]init];
    NSMutableArray *mutableAry = [[NSMutableArray alloc]init];
    for (int i=0; i<self.allItems.count; i++) {
        NSDictionary *dic = self.allItems[i];
        NSString *name = dic[@"name"];
        [mutableAry addObject:name];
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:[mutableAry filteredArrayUsingPredicate:predicate]];
    for (int i=0; i<self.allItems.count; i++) {
        NSDictionary *dic = [self.allItems objectAtIndex:i];
        NSString *name = [[dic objectForKey:@"name"] description];
        for (int m=0; m<array.count; m++) {
            NSString *searchSchoolName = [array objectAtIndex:m];
            if ([searchSchoolName isEqualToString:name]) {
                [self.showItems addObject:dic];
                break;
            }
        }
    }
    
    [self.mainTableView reloadData];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //搜尋結束後，恢復原狀，如果要產生動畫效果，要另外執行animation代碼
    //    [self.searchDisplayController setActive:NO animated:NO];
    return YES;
}

// 通过这个函数来获得searchBar上输入的string，而后根据NSPredicate来过滤数组————————————————————————————————————————————————————————————————————————————————————

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar==self.search) {
        NSString *email = searchBar.text;
        if (email.length == 0) {
            self.showItems = [NSMutableArray arrayWithArray:self.allItems];
        }else{
            [self filterContentForSearchText:email scope:   nil];
        }
    }
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (searchBar==self.search) {
        NSString *email = searchBar.text;
        if (email.length == 0) {
            self.showItems = [NSMutableArray arrayWithArray:self.allItems];
        }else{
            [self filterContentForSearchText:email scope:   nil];
        }
    }
    return YES;
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    //    [self.searchDisplayController setActive:NO animated:NO];
    
}

/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    //    [self.searchDisplayController setActive:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title=@"";
}

#pragma mark - 接口
// 获取所有驾校信息
- (void)getCarSchool{
   
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
//以下两句话用于键盘事件的增删————————————————————————————————————————————————————————————————————————————————————
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame)
                                                 name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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

@end
