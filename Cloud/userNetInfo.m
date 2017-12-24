//
//  userNetInfo.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/23.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "userNetInfo.h"
#import <BmobSDK/Bmob.h>
@interface userNetInfo ()
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelQQNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelWeiChatNumber;

@end

@implementation userNetInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelUserName.text=[[BmobUser currentUser]username];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    BmobQuery* queue=[BmobUser query];
    [queue whereKey:@"username" equalTo:[[BmobUser currentUser]username]];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobUser* user in array) {
                NSLog(@"%@",user);
                self.labelPhoneNumber.text=user.mobilePhoneNumber;
                self.labelEmail.text=user.email;
            }
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
    [self performSelector:@selector(viewDidLoad) withObject:nil afterDelay:2];
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
