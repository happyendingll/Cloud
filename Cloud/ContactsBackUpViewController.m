//
//  ContactsBackUpViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/17.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "ContactsBackUpViewController.h"
#import <ContactsUI/ContactsUI.h>
#import <BmobSDK/Bmob.h>
#import "MbHUDuser.h"
@interface ContactsBackUpViewController ()<CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *localContactNum;
@property (weak, nonatomic) IBOutlet UILabel *cloudContactNum;
@property(nonatomic,strong)NSMutableArray* contactListArr;
@property(nonatomic,strong)NSArray* contactListArrFromNet;
@property(nonatomic,strong)MbHUDuser* hudUser;
@end

@implementation ContactsBackUpViewController


//懒加载hudUser对象
-(MbHUDuser*)hudUser{
    if (!_hudUser) {
        _hudUser=[[MbHUDuser alloc]init];
    }return _hudUser;
}





//懒加载方法初始化联系人列表数组
-(NSMutableArray*)contactListArr{
    if (!_contactListArr) {
        _contactListArr=[[NSMutableArray alloc]init];
    }return _contactListArr;
}

-(NSArray*)contactListArrFromNet{
    if (!_contactListArrFromNet) {
        _contactListArrFromNet=[[NSArray alloc]init];
    }return _contactListArrFromNet;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"通讯录备份";
    [self Authorized];
    [self loadDataFromLocal];
    [self loadDataFormNet];
    // Do any additional setup after loading the view.
}
- (IBAction)backToHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//进入选择联系人列表
- (IBAction)enterToContactsList:(id)sender {
    CNContactPickerViewController* ContactPickerVC=[[CNContactPickerViewController alloc]init];
    ContactPickerVC.delegate=self;
    [self presentViewController:ContactPickerVC animated:YES completion:nil];
}
//选择完联系人后回调的方法
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts{
    for (CNContact* contact in contacts) {
        //建立单个联系人信息的字典结构
        NSMutableDictionary* contactInfoDic=[[NSMutableDictionary alloc]init];
        NSString* familyName=contact.familyName;
        NSString* givenName=contact.givenName;
        [contactInfoDic setValue:familyName forKey:@"familyName"];
        [contactInfoDic setValue:givenName forKey:@"givenName"];
        int i=1;//刚开始是第一个电话号码;
        for (CNLabeledValue* labeledValue in contact.phoneNumbers) {
            CNPhoneNumber* phoneNumber=labeledValue.value;
            NSLog(@"手机号码是:%@",phoneNumber.stringValue);
            [contactInfoDic setValue:phoneNumber.stringValue forKey:[NSString stringWithFormat:@"phoneNumber%d",i]];
            i++;//循环记录是有多少个电话号码;
        }
        //NSLog(@"%@",contactInfoDic);
        [self.contactListArr addObject:contactInfoDic];
}
    //NSLog(@"count=%lu",(unsigned long)self.contactListArr.count);
}

//真正的上传操作
-(void)realUpLoadContacts{
    //设置当前的用户名
    NSString* localUsername=[BmobUser currentUser].username;
    BmobObject* contactObj=[BmobObject objectWithClassName:@"Contactslist"];
    [contactObj setObject:self.contactListArr forKey:@"contactListArr"];
    [contactObj setObject:[NSNumber numberWithUnsignedLong:self.contactListArr.count] forKey:@"contactsNum"];//设置上传联系人数量
    [contactObj setObject:localUsername forKey:@"contactsOwner"];
    [contactObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [self.hudUser showHUDWithText:@"上传成功" inView:self.view];
        }else if (error){
            [self.hudUser showHUDWithText:@"上传失败" inView:self.view];
        }
    }];
}


//上传通讯录列表数组结构
- (IBAction)UploadContactsList:(id)sender {
    
    //每次上传前先把之前的数据删掉
    BmobQuery* queue=[BmobQuery queryWithClassName:@"Contactslist"];
    [queue whereKey:@"contactsOwner" equalTo:[BmobUser currentUser].username];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobObject* obj in array) {
                [obj deleteInBackground];
            }
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
    //删除完后隔一秒钟进行数据的更新上传
    [self performSelector:@selector(realUpLoadContacts) withObject:nil afterDelay:5];
    
    [self performSelector:@selector(loadDataFormNet) withObject:nil afterDelay:3];//点击上传后隔了一秒钟进行网上数据刷新
}

-(void)Authorized{
    //如果还没有授权就进行，授权请求
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]==CNAuthorizationStatusNotDetermined) {
        CNContactStore* store=[[CNContactStore alloc]init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
//                NSLog(@"授权成功");
                [self loadDataFromLocal];
            }else{
//                NSLog(@"授权失败");
            }
        }];
    }
}
//查询本地通讯录的联系人数量
-(void)loadDataFromLocal{
    //如果授权成功就获取通讯录信息
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]==CNAuthorizationStatusAuthorized){
        //获取联系人仓库
        CNContactStore* myStore=[[CNContactStore alloc]init];
        //创建联系人信息的请求keys
        NSArray* keys=@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
        //根据请求keys，创建请求对象
        CNContactFetchRequest* fetchRequest=[[CNContactFetchRequest alloc]initWithKeysToFetch:keys];
        //发送请求
        [myStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            NSMutableDictionary* contactInfoDic=[[NSMutableDictionary alloc]init];
            NSString* familyName=contact.familyName;
            NSString* givenName=contact.givenName;
            [contactInfoDic setValue:familyName forKey:@"familyName"];
            [contactInfoDic setValue:givenName forKey:@"givenName"];
            int i=1;//刚开始是第一个电话号码;
            for (CNLabeledValue* labeledValue in contact.phoneNumbers) {
                CNPhoneNumber* phoneNumber=labeledValue.value;
                //NSLog(@"手机号码是:%@",phoneNumber.stringValue);
                [contactInfoDic setValue:phoneNumber.stringValue forKey:[NSString stringWithFormat:@"phoneNumber%d",i]];
                i++;//循环记录是有多少个电话号码;
            }
            //NSLog(@"dic=%@",contactInfoDic);
            [self.contactListArr addObject:contactInfoDic];
        }];
    }
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]==CNAuthorizationStatusDenied){
        NSLog(@"您已拒绝访问通讯录，请前往设置更改");
    }
    self.localContactNum.text=[NSString stringWithFormat:@"%lu",self.contactListArr.count];
}



-(void)loadDataFormNet{
    BmobQuery* queue=[BmobQuery queryWithClassName:@"Contactslist"];
    [queue whereKey:@"contactsOwner" equalTo:[BmobUser currentUser].username];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobObject* obj in array) {
                self.contactListArrFromNet=[obj objectForKey:@"contactListArr"];
                NSNumber* nsnumber=[obj objectForKey:@"contactsNum"];
                self.cloudContactNum.text=[NSString stringWithFormat:@"%lu",nsnumber.unsignedLongValue];
            }
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
}
//写回本地的方法
- (IBAction)loadToLocal:(id)sender {
    //NSLog(@"count=%lu",(unsigned long)self.contactListArrFromNet.count);
    //NSLog(@"%@",self.contactListArrFromNet);
    //NSMutableArray* phoneNumbers;
    for (NSDictionary* cnDic in self.contactListArrFromNet) {
        NSString* familyName=[cnDic valueForKey:[[cnDic allKeys]objectAtIndex:0]];
        NSString* givenName=[cnDic valueForKey:[[cnDic allKeys]objectAtIndex:1]];
        unsigned long numberCount=[cnDic allKeys].count-2;
        //NSLog(@"count=%lu",(unsigned long)[cnDic allKeys].count);
        //unsigned long count=[cnDic allKeys].count;
        NSMutableArray* phoneNumbersArr=[[NSMutableArray alloc]init];
        
        //增加到本地的操作
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]==CNAuthorizationStatusAuthorized){
            //获取联系人仓库
            CNContactStore* myStore=[[CNContactStore alloc]init];
            CNMutableContact* newContact=[[CNMutableContact alloc]init];
            newContact.familyName=familyName;
            newContact.givenName=givenName;
            //NSLog(@"%@%@",newContact.familyName,newContact.givenName);
            for (int i=0; i<numberCount; i++) {
                CNPhoneNumber* phoneNumber=[[CNPhoneNumber alloc]initWithStringValue:[cnDic valueForKey:[[cnDic allKeys]objectAtIndex:i+2]]];
                CNLabeledValue* labeledValue=[[CNLabeledValue alloc]initWithLabel:CNLabelPhoneNumberMobile value:phoneNumber];
                [phoneNumbersArr addObject:labeledValue];
            }
            newContact.phoneNumbers=phoneNumbersArr;
            
            CNSaveRequest* saveRequest=[[CNSaveRequest alloc]init];
            [saveRequest addContact:newContact toContainerWithIdentifier:nil];
            [myStore executeSaveRequest:saveRequest error:nil];
            //NSLog(@"保存成功");
        }
    }
    [self.hudUser showHUDWithText:@"成功导回" inView:self.view];
    
    //写回本地后再本地查询一下，以用来刷新UI
    [self loadDataFromLocal];
    
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
