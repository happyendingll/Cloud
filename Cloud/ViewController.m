//
//  ViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/11/19.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "ViewController.h"
#import "DeviceScreen.h"//导入设备屏幕尺寸类
#import <BmobSDK/Bmob.h>
#import "MbHUDuser.h"//导入提示框自己封装好的包
//#import "UserInfoVC.h"//导入的目的是把登录的信息传入到“我的设置”页面，不再需要属性传值了
#import "CloudTabBarController.h"//导入的目的是用登录验证的方式进入子视图，而不是靠点击
#import "CloudTabBarController.h"
#import "AppDelegate.h"
@interface ViewController ()<UITextFieldDelegate>{
    CloudTabBarController* cloudTarBar;
    UIScrollView* scrollView;
}
@property (weak, nonatomic) IBOutlet UILabel *labeluserName;
@property (weak, nonatomic) IBOutlet UILabel *labelPassword;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property(nonatomic,strong)MbHUDuser* hudUser;
@property(nonatomic,strong)AppDelegate* app;
@end

@implementation ViewController

//懒加载hudUser对象
-(MbHUDuser*)hudUser{
    if (!_hudUser) {
        _hudUser=[[MbHUDuser alloc]init];
    }return _hudUser;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName.tag=101;
    self.passWord.tag=102;
    self.userName.delegate=self;
    self.passWord.delegate=self;
    self.passWord.secureTextEntry=YES;
    BOOL firstLoad=[self readDataFromPreference];
    
    if (!firstLoad) {
        scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        scrollView.contentSize=CGSizeMake(ScreenWidth*4, ScreenHeight);
        scrollView.contentOffset=CGPointMake(0, 0);
        scrollView.pagingEnabled=YES;
        for (int i=0; i<4; i++) {
            NSArray* imageArr=@[@"引导图1（普通版）",@"引导图2（普通版）",@"引导图3（普通版）",@"引导图4（普通版）"];
            NSString* imageStr=imageArr[i];
            UIImageView* imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*ScreenWidth, 0, ScreenWidth, ScreenHeight)];
            imageView.image=[UIImage imageNamed:imageStr];
            [scrollView addSubview:imageView];
        }
        CGFloat btn_w=ScreenWidth*0.6;
        CGFloat btn_h=40;
        CGFloat btn_x=ScreenWidth*3+(ScreenWidth-btn_w)/2;
        CGFloat btn_y=ScreenHeight-btn_h-40;
        UIButton* btn_enter=[[UIButton alloc]initWithFrame:CGRectMake(btn_x, btn_y, btn_w, btn_h)];
        [btn_enter setTitle:@"开始使用" forState:UIControlStateNormal];
        [btn_enter setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        btn_enter.layer.cornerRadius=5.0;
        btn_enter.layer.borderWidth=2.0;
        btn_enter.layer.borderColor=[UIColor colorWithRed:50/255.0 green:195/255.0 blue:170/255.0 alpha:1.0].CGColor;
        [btn_enter addTarget:self action:@selector(enterapp) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn_enter];
        [self.view addSubview:scrollView];
        [self writeDataPreference:YES];
    }
   
}
-(void)enterapp{
//    cloudTarBar=[self.storyboard instantiateViewControllerWithIdentifier:@"zhiyuan_Cloud"];
//    self.app=(AppDelegate*)[[UIApplication sharedApplication]delegate];
//    self.app.window.rootViewController=cloudTarBar;
    [scrollView removeFromSuperview];
}
-(void)writeDataPreference:(BOOL)flag{
    NSUserDefaults* userdefaults=[NSUserDefaults standardUserDefaults];
    [userdefaults setBool:flag forKey:@"isFirstLoad"];
    [userdefaults synchronize];
}
-(BOOL)readDataFromPreference{
    NSUserDefaults* userdefaults=[NSUserDefaults standardUserDefaults];
    return [userdefaults boolForKey:@"isFirstLoad"];
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.hudUser showHUDWithText:@"你好游客" inView:self.view];
}


//点击空白处停止键盘响应
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag==101) {
        [textField resignFirstResponder];
    }else if (textField.tag==102){
        [textField resignFirstResponder];
    }return YES;
}
//输入框上升
-(void)textFieldDidBeginEditing:(UITextField *)textField{
   if (textField.tag==102){
        [UIView animateWithDuration:0.7 animations:^{
            textField.transform=CGAffineTransformMakeTranslation(0, -101);
            self.labelPassword.transform=CGAffineTransformMakeTranslation(0, -104);
            self.userName.hidden=YES;
            self.labeluserName.hidden=YES;
        }];
    }
}
//输入框还原
-(void)textFieldDidEndEditing:(UITextField *)textField{
 if (textField.tag==102){
        [UIView animateWithDuration:0.5 animations:^{
            textField.transform=CGAffineTransformIdentity;
            self.labelPassword.transform=CGAffineTransformIdentity;
            self.userName.hidden=NO;
            self.labeluserName.hidden=NO;
        }];
    }
}
//注册方法
- (IBAction)registerAction:(id)sender {
    BmobUser* newUser=[[BmobUser alloc]init];
    [newUser setUsername:self.userName.text];//设置用户名
    [newUser setPassword:self.passWord.text];//设置密码
    [newUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //NSLog(@"注册成功");
            [self.hudUser showHUDWithText:@"注册成功" inView:self.view];
        }else if (error){
            //NSLog(@"%@",error);
            [self.hudUser showHUDWithText:@"此用户名已被注册，换个名称注册吧，亲" inView:self.view];
        }
    }];
}
//登录方法
- (IBAction)loginAction:(id)sender {
    [BmobUser loginWithUsernameInBackground:self.userName.text password:self.passWord.text block:^(BmobUser *user, NSError *error) {
        if (user) {
            //NSLog(@"登录成功");
            [self.hudUser showHUDWithText:@"登录成功" inView:self.view];
            //已经用bmob的userdefault方式传递用户名了，不再需要属性传值了
            //self.localUserName=user.username;
            //self.localPassword=user.password;
            //同样调用进入子视图的方法
            [self reachToSubVC];
            NSString *homePath=NSHomeDirectory();
            NSLog(@"homePath=%@",homePath);
        }else if (error){
            //NSLog(@"%@",error);
            [self.hudUser showHUDWithText:@"登录名或密码错误，请重试哈，亲" inView:self.view];
        }
    }];
}
//进入子视图的方法
-(void)reachToSubVC{
    CloudTabBarController* cloudSubVc=[self.storyboard instantiateViewControllerWithIdentifier:@"zhiyuan_Cloud"];
    //已经用bmob的userdefault方式传递用户名了，不再需要属性传值了
    //UserInfoVC* infoVc=cloudSubVc.viewControllers[1];
    //infoVc.nameStr=self.localUserName;
    [self presentViewController:cloudSubVc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
