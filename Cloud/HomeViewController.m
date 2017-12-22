//
//  HomeViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/21.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "HomeViewController.h"
#import "DeviceScreen.h"
@interface HomeViewController (){
    UIScrollView* scrollView;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏样式
//    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.navigationItem.title=@"备份";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    // Do any additional setup after loading the view.
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 266)];
    scrollView.contentSize=CGSizeMake(ScreenWidth*2, ScreenHeight/3);
    scrollView.contentOffset=CGPointMake(0, 0);
    scrollView.pagingEnabled=YES;
    for (int i=0; i<2; i++) {
        NSArray* imageArrs=@[@"滚动图1",@"滚动图2"];
        NSString* imageStr=imageArrs[i];
        UIImageView* imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*ScreenWidth, 0, ScreenWidth, 266)];
        imageView.image=[UIImage imageNamed:imageStr];
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds=YES;
        [scrollView addSubview:imageView];
    }
    [self.view addSubview:scrollView];
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
