//
//  FileMangerViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/22.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "FileMangerViewController.h"
#import <BmobSDK/Bmob.h>
#import "FileMangerTableViewCell.h"
#import "DeviceScreen.h"
#import "PhotoBackUpViewController.h"
#import "MbHUDuser.h"
@interface FileMangerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* fileMangerTableView;
@property(nonatomic,strong)NSMutableArray* fileMangerArrs;
@property(nonatomic,strong)MbHUDuser* HudUser;
@end

@implementation FileMangerViewController

-(MbHUDuser*)HudUser{
    if (!_HudUser) {
        _HudUser=[[MbHUDuser alloc]init];
    }return _HudUser;
}

-(NSMutableArray*)fileMangerArrs{
    if (!_fileMangerArrs) {
        _fileMangerArrs=[[NSMutableArray alloc]init];
    }return _fileMangerArrs;
}
-(UITableView*)fileMangerTableView{
    if (!_fileMangerTableView) {
        _fileMangerTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight/2)];
        _fileMangerTableView.backgroundColor=[UIColor clearColor];//设置为透明背景
        _fileMangerTableView.delegate=self;
        _fileMangerTableView.dataSource=self;
    }return _fileMangerTableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileMangerArrs.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileMangerTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"zhiyuan.fileManger"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"FileMangerTableViewCell" owner:nil options:nil]lastObject];
    }
    [cell loadDataWithFileName:self.fileMangerArrs[indexPath.row]];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//    //添加重命名方法
//    cell.reNameBtn.tag=101+indexPath.row;
//    [cell.reNameBtn addTarget:self action:@selector(reNameAction:) forControlEvents:UIControlEventTouchUpInside];
    //添加长按重命名
    UILongPressGestureRecognizer* LongPressGestureRecognizer=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [cell addGestureRecognizer:LongPressGestureRecognizer];
    return cell;
}
//长按重命名方法
-(void)longPressAction:(UILongPressGestureRecognizer*)sender{
    if (sender.state==UIGestureRecognizerStateBegan) {
        NSIndexPath* indexPath=[self.fileMangerTableView indexPathForRowAtPoint:[sender locationInView:self.fileMangerTableView]];
        UIAlertController* reNameAlertController=[UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [reNameAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"文件名";
        }];
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField* FileNameField=reNameAlertController.textFields.firstObject;
            [self.fileMangerArrs replaceObjectAtIndex:indexPath.row withObject:FileNameField.text];
            [self writeDataToPreference];//写入用户偏好存储
            [self.fileMangerTableView reloadData];//点击完成刷新数据
        }];
        [reNameAlertController addAction:okAction];
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [reNameAlertController addAction:cancelAction];
        [self presentViewController:reNameAlertController animated:YES completion:nil];
    }
}
//增加重命名方法（改用长按重命名）
//-(void)reNameAction:(UIButton*)btn{
//   UIAlertController* reNameAlertController=[UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [reNameAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder=@"文件名";
//    }];
//    UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UITextField* FileNameField=reNameAlertController.textFields.firstObject;
//        NSInteger index=btn.tag-101;//tag用来传递是哪个button
//        [self.fileMangerArrs replaceObjectAtIndex:index withObject:FileNameField.text];
//        [self writeDataToPreference];//写入用户偏好存储
//        [self.fileMangerTableView reloadData];//点击完成刷新数据
//    }];
//    [reNameAlertController addAction:okAction];
//    UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    [reNameAlertController addAction:cancelAction];
//    [self presentViewController:reNameAlertController animated:YES completion:nil];
//}


//设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=@"图片备份";
    self.fileMangerArrs=[NSMutableArray arrayWithArray:[self readDataFromPreference]];
    //文件夹不为空才展示tableview
    if (self.fileMangerArrs.count!=0) {
        [self.view addSubview:self.fileMangerTableView];
    }
}
//新建文件夹
- (IBAction)addNewFileManger:(id)sender {
   UIAlertController* NewAlertController=[UIAlertController alertControllerWithTitle:@"输入文件名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [NewAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"文件名";
    }];
    UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.fileMangerArrs.count==0) {
            [self.view addSubview:self.fileMangerTableView];
        }
        UITextField* FileNameField=NewAlertController.textFields.firstObject;
        [self.fileMangerArrs addObject:FileNameField.text];
        [self.fileMangerTableView reloadData];//点击完成刷新数据
        [self writeDataToPreference];//写入用户偏好存储
    }];
    [NewAlertController addAction:okAction];
    UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [NewAlertController addAction:cancelAction];
    [self presentViewController:NewAlertController animated:YES completion:nil];
}

//删除文件夹并且删掉里面所属的图片
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController* deleteAlertController=[UIAlertController alertControllerWithTitle:@"删除文件夹" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* deleteAction=[UIAlertAction actionWithTitle:@"确定删除该目录下的所有文件吗" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSString* floderName=self.fileMangerArrs[indexPath.row];
        [self.fileMangerArrs removeObjectAtIndex:indexPath.row];
        //当剩下0个的时候就不能在偏好存储中保存数据了
        if (self.fileMangerArrs.count!=0) {
            [self writeDataToPreference];
        }
        if (self.fileMangerArrs.count==0) {
            [self deleteDataFromPreference];//删除偏好存储
        }
        if (self.fileMangerArrs.count!=0) {
            [self.fileMangerTableView reloadData];
        }else{
            [self.fileMangerTableView removeFromSuperview];
        }
        [self deleteAllPhotosInFloderName:floderName];//后台删除数据只能在最后面就开始做
    }];
    [deleteAlertController addAction:deleteAction];
    UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [deleteAlertController addAction:cancelAction];
    [self presentViewController:deleteAlertController animated:YES completion:nil];
}
//网上删除数据的操作
-(void)deleteAllPhotosInFloderName:(NSString*)floderName{
    BmobQuery* queue=[BmobQuery queryWithClassName:@"PhotosLibrary"];
    [queue whereKey:@"photosOwner" equalTo:[BmobUser currentUser].username];
    [queue whereKey:@"folder" equalTo:floderName];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobObject* obj in array) {
                [obj deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        [self.HudUser showHUDWithText:@"删除成功" inView:self.view];
                    }else if (error){
                        NSLog(@"%@",error);
                        [self.HudUser showHUDWithText:@"网络故障" inView:self.view];
                    }
                }];
            }
        }else if (error){
            NSLog(@"%@",error);
            [self.HudUser showHUDWithText:@"网络故障" inView:self.view];
        }
    }];
}




//点击某一个cell的时候进入相应的视图
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoBackUpViewController* photoBackUpVc=[self.storyboard instantiateViewControllerWithIdentifier:@"photoBackUpid"];
    photoBackUpVc.VcTitle=self.fileMangerArrs[indexPath.row];
    [self.navigationController pushViewController:photoBackUpVc animated:YES];
}

//文件夹的数据持久化的读与写操作
//写操作
-(void)writeDataToPreference{
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.fileMangerArrs forKey:@"localFileMangers"];
    [userDefaults synchronize];
}
//读操作
-(NSArray*)readDataFromPreference{
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray* fileArrays=[userDefaults objectForKey:@"localFileMangers"];
    return fileArrays;
}
//删除操作
-(void)deleteDataFromPreference{
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"localFileMangers"];
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
