//
//  UserInfoVC.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/13.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "UserInfoVC.h"
#import <BmobSDK/Bmob.h>
@interface UserInfoVC ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end

@implementation UserInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.userNameLabel.text=self.nameStr;//把用户名显示到界面上
    self.userNameLabel.text=[BmobUser currentUser].username;
    
    
    // Do any additional setup after loading the view.
}
//回到登录页面
- (IBAction)backToFirVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
