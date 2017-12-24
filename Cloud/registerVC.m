//
//  registerVC.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/23.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "registerVC.h"
#import <BmobSDK/Bmob.h>
#import "MbHUDuser.h"
@interface registerVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *checkPassword;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelCheckPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property(nonatomic,strong)MbHUDuser* hudUser;
@end

@implementation registerVC
-(MbHUDuser*)hudUser{
    if (!_hudUser) {
        _hudUser=[[MbHUDuser alloc]init];
    }return _hudUser;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName.tag=101;
    self.phoneNumber.tag=102;
    self.password.tag=103;
    self.checkPassword.tag=104;
    self.email.tag=105;
    self.userName.delegate=self;
    self.phoneNumber.delegate=self;
    self.password.delegate=self;
    self.checkPassword.delegate=self;
    self.email.delegate=self;
    // Do any additional setup after loading the view.
}
//点击相应按钮上移
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag==103||textField.tag==104) {
        [UIView animateWithDuration:0.7 animations:^{
            self.labelUserName.hidden=YES;
            self.labelPhoneNumber.hidden=YES;
            self.userName.hidden=YES;
            self.phoneNumber.hidden=YES;
            self.labelPassword.transform=CGAffineTransformMakeTranslation(0, -85);
            self.labelCheckPassword.transform=CGAffineTransformMakeTranslation(0, -85);
            self.password.transform=CGAffineTransformMakeTranslation(0, -85);
            self.checkPassword.transform=CGAffineTransformMakeTranslation(0, -85);
        }];
    }else if (textField.tag==105){
        [UIView animateWithDuration:0.7 animations:^{
            self.labelUserName.hidden=YES;
            self.labelPhoneNumber.hidden=YES;
            self.userName.hidden=YES;
            self.phoneNumber.hidden=YES;
            self.labelEmail.transform=CGAffineTransformMakeTranslation(0, -185);
            self.email.transform=CGAffineTransformMakeTranslation(0, -185);
        }];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag==104||textField.tag==103) {
        [UIView animateWithDuration:0.5 animations:^{
            self.labelUserName.hidden=NO;
            self.labelPhoneNumber.hidden=NO;
            self.userName.hidden=NO;
            self.phoneNumber.hidden=NO;
            self.labelPassword.transform=CGAffineTransformIdentity;
            self.labelCheckPassword.transform=CGAffineTransformIdentity;
            self.password.transform=CGAffineTransformIdentity;
            self.checkPassword.transform=CGAffineTransformIdentity;
        }];
    }else if (textField.tag==105){
        [UIView animateWithDuration:0.5 animations:^{
            self.labelUserName.hidden=NO;
            self.labelPhoneNumber.hidden=NO;
            self.userName.hidden=NO;
            self.phoneNumber.hidden=NO;
            self.labelEmail.transform=CGAffineTransformIdentity;
            self.email.transform=CGAffineTransformIdentity;
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)BackToLoginPageBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)touchToRegister:(id)sender {
    BmobUser* newUser=[[BmobUser alloc]init];
    [newUser setUsername:self.userName.text];
    if ([self.password.text isEqualToString:self.checkPassword.text]) {
        [newUser setPassword:self.checkPassword.text];
    }else{
        [self.hudUser showHUDWithText:@"密码不一致" inView:self.view];
    }
    [newUser setMobilePhoneNumber:self.phoneNumber.text];
    [newUser setEmail:self.email.text];
    [newUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [self.hudUser showHUDWithText:@"注册成功" inView:self.view];
        }else if (error){
            NSLog(@"%@",error);
            [self.hudUser showHUDWithText:@"相关信息已被注册，请检查重试!亲" inView:self.view];
        }
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.userName resignFirstResponder];
    [self.phoneNumber resignFirstResponder];
    [self.password resignFirstResponder];
    [self.checkPassword resignFirstResponder];
    [self.email resignFirstResponder];
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
