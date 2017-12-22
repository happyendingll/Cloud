//
//  DownloadPhotoViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/15.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "DownloadPhotoViewController.h"
#import "DownloadPhotoTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "MbHUDuser.h"
#import <SDImageCache.h>//导入从缓存中查找uiimage的头文件
@interface DownloadPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* photoTableView;
@property(nonatomic,strong)NSMutableArray* imageInfoArrs;
@property(nonatomic,strong)NSMutableArray* imageUrlArrs;
@property(nonatomic,strong)NSMutableArray* imageArrs;
@property(nonatomic,strong)MbHUDuser* hudUser;
@property(nonatomic,strong)NSMutableArray* imageDateInfos;//图片的上传时间NSString数组
@end

@implementation DownloadPhotoViewController
//懒加载hudUser对象
-(MbHUDuser*)hudUser{
    if (!_hudUser) {
        _hudUser=[[MbHUDuser alloc]init];
    }return _hudUser;
}


-(NSMutableArray*)imageDateInfos{
    if (!_imageDateInfos) {
        _imageDateInfos=[[NSMutableArray alloc]init];
    }return _imageDateInfos;
}


-(NSMutableArray*)imageArrs{
    if (!_imageArrs) {
        _imageArrs=[[NSMutableArray alloc]init];
    }return _imageArrs;
}


-(NSMutableArray*)imageUrlArrs{
    if (!_imageUrlArrs) {
        _imageUrlArrs=[[NSMutableArray alloc]init];
    }return _imageUrlArrs;
}
-(NSMutableArray*)imageInfoArrs{
    if (!_imageInfoArrs) {
        _imageInfoArrs=[[NSMutableArray alloc]init];
    }return _imageInfoArrs;
}
-(UITableView*)photoTableView{
    if (!_photoTableView) {
        _photoTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 110, self.view.bounds.size.width, 400)];
        _photoTableView.backgroundColor=[UIColor clearColor];
        _photoTableView.delegate=self;
        _photoTableView.dataSource=self;
    }return _photoTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self updateData];//进入视图就进行网上数据更新，避免多线程要顺序执行任务导致无法导入数据
    // Do any additional setup after loading the view.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imageUrlArrs.count;
}
//设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadPhotoTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"zhiyuanCell"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"DownloadPhotoTableViewCell" owner:nil options:nil]lastObject];
    }
    [cell loadDataWithimageUrlArr:self.imageUrlArrs imageInfoArr:self.imageInfoArrs imageDateInfos:self.imageDateInfos indexPath:indexPath];
    [cell checkStated:NO];
    return cell;
}


//新增cell可编辑的功能
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* str2=[self.imageInfoArrs objectAtIndex:indexPath.row];
    [self.imageUrlArrs removeObjectAtIndex:indexPath.row];
    [self.imageInfoArrs removeObjectAtIndex:indexPath.row];
    [self.imageDateInfos removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
    
    BmobQuery* queue=[BmobQuery queryWithClassName:@"PhotosLibrary"];
    [queue whereKey:@"photosOwner" equalTo:[BmobUser currentUser].username];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobObject* obj in array) {
                BmobFile* imageFile=[obj objectForKey:@"photo"];
                NSString* imageFileName=imageFile.name;//图片的保存名称
                if ([imageFileName isEqualToString:str2]) {
                    [obj deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                        if (isSuccessful) {
                            [self.hudUser showHUDWithText:@"删除成功" inView:self.view];
                        }else if (error){
                            NSLog(@"%@",error);
                        }
                    }];
                }
            }
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
 
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadPhotoTableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    NSString* strUrl=[self.imageUrlArrs objectAtIndex:indexPath.row];
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:strUrl];//从缓存中查找uiimage
    BOOL currentStated=cell.checkStated;
    //选中添加到self.imageArrs
    if (currentStated==NO) {
        [self.imageArrs addObject:cachedImage];
    }//非选中从self.imageArrs删掉uiimage
    else if (currentStated==YES){
        [self.imageArrs removeObject:cachedImage];
    }
    [cell checkStated:!currentStated];
}
-(void)addTableView{
    [self.view addSubview:self.photoTableView];
}
//收起tableview的方法
- (IBAction)closeTableView:(id)sender {
    [self.photoTableView removeFromSuperview];
}

- (IBAction)update:(id)sender {
    [self updateData];//网上更新数据
    [self performSelector:@selector(addTableView) withObject:nil afterDelay:1];//调用self afterDelay方法延迟执行方法
    //[NSThread sleepForTimeInterval:1];//调用当前线程睡眠一秒再执行的方法
}
//从网上更新数据
-(void)updateData{
    BmobQuery* queue=[BmobQuery queryWithClassName:@"PhotosLibrary"];
    [queue whereKey:@"photosOwner" equalTo:[BmobUser currentUser].username];
    [queue findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array) {
            for (BmobObject* obj in array) {
                NSString* imageUrl=[obj objectForKey:@"photoAdress"];//图片的网络地址
                [self.imageUrlArrs addObject:imageUrl];
                BmobFile* imageFile=[obj objectForKey:@"photo"];
                NSString* imageFileName=imageFile.name;//图片的保存名称
                //NSLog(@"imageFileName=%@",imageFileName);
                [self.imageInfoArrs addObject:imageFileName];
                NSString* DateStr=[obj objectForKey:@"UpLoadDate"];//获取图片的上传时间
                [self.imageDateInfos addObject:DateStr];
            }
            NSLog(@"搜索目录成功");
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
}

//下载事件
- (IBAction)downloadAction:(id)sender {
    //循环保存到本地相册
    for (UIImage* image in self.imageArrs) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
//保存是否成功后的系统回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存失败");
    }else{
        //NSLog(@"保存成功");
        [self.hudUser showHUDWithText:@"保存成功" inView:self.view];
    }
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
