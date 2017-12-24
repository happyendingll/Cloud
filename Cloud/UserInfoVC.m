//
//  UserInfoVC.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/13.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "UserInfoVC.h"
#import <BmobSDK/Bmob.h>
#import "AppDelegate.h"
#import "ViewController.h"
@interface UserInfoVC ()
@property(nonatomic,strong)AppDelegate* app;
@end

@implementation UserInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    //self.userNameLabel.text=self.nameStr;//把用户名显示到界面上
    // Do any additional setup after loading the view.
}
//回到登录页面
- (IBAction)backToFirVC:(id)sender {
    [self writeIsLoginedInPreference];
    [self backToLoginPage];
}
-(void)backToLoginPage{
    ViewController* LoginVC=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVCID"];
    self.app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.app.window.rootViewController=LoginVC;
}

-(void)writeIsLoginedInPreference{
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"isLogined"];
    [userDefaults synchronize];
}
//-(BOOL)readIsLoginedFromPreference{
//    NSUserDefaults* useDefaults=[NSUserDefaults standardUserDefaults];
//    return [useDefaults boolForKey:@"isLogined"];
//}
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
