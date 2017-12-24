//
//  PhotoBackUpViewController.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/13.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "PhotoBackUpViewController.h"
#import <TZImagePickerController.h>//导入第三方的图片选择器库
#import "PhotoCollectionViewCell.h"
#import <BmobSDK/Bmob.h>
#import "MbHUDuser.h"//导入自己封装的提示框款式
#define Kwidth [UIScreen mainScreen].bounds.size.width
#define Kheight [UIScreen mainScreen].bounds.size.height

#pragma mark 云端图片展示需求头文件
#import "DownloadPhotoTableViewCell.h"
#import <SDImageCache.h>//导入从缓存中查找uiimage的头文件

@interface PhotoBackUpViewController ()<TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *tipView;
@property(nonatomic,strong)UICollectionView* photoCollectionView;
@property(nonatomic,strong)NSMutableArray* photoArray;
@property(nonatomic,strong)NSMutableArray* assestArray;
@property(nonatomic,strong)NSMutableArray* photoDataArray;//用于上传的图片data数组
@property(nonatomic,strong)MbHUDuser* hudUser;
@property BOOL isSelectOriginalPhoto;
#pragma mark 云端图片展示需求属性
@property(nonatomic,strong)UITableView* photoTableView;
@property(nonatomic,strong)NSMutableArray* imageInfoArrs;
@property(nonatomic,strong)NSMutableArray* imageUrlArrs;
@property(nonatomic,strong)NSMutableArray* imageArrs;
@property(nonatomic,strong)NSMutableDictionary* imageArrsDic;
@property(nonatomic,strong)NSMutableArray* imageDateInfos;//图片的上传时间NSString数组
@end

@implementation PhotoBackUpViewController
//懒加载hudUser对象
-(MbHUDuser*)hudUser{
    if (!_hudUser) {
        _hudUser=[[MbHUDuser alloc]init];
    }return _hudUser;
}

-(NSMutableArray*)photoDataArray{
    if (!_photoDataArray) {
        _photoDataArray=[NSMutableArray array];
    }return _photoDataArray;
}
-(NSMutableArray*)photoArray{
    if (!_photoArray) {
        _photoArray=[NSMutableArray array];
    }return _photoArray;
}
-(NSMutableArray*)assestArray{
    if (!_assestArray) {
        _assestArray=[NSMutableArray array];
    }return _assestArray;
}

-(UICollectionView*)photoCollectionView{
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout* flowLayout=[[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize=CGSizeMake((Kwidth-50)/4, (Kwidth-50)/4);
        flowLayout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
        _photoCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 425, Kwidth, 101.25) collectionViewLayout:flowLayout];
        _photoCollectionView.backgroundColor=[UIColor clearColor];
        _photoCollectionView.delegate=self;
        _photoCollectionView.dataSource=self;
    }return _photoCollectionView;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.VcTitle;
//    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.leftBarButtonItem = item;
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(realUpdate)];
    self.navigationItem.rightBarButtonItem=rightItem;
//自动刷新操作
    [self updateData];//网上更新数据
    [self performSelector:@selector(addTableView) withObject:nil afterDelay:1.5];//调用self afterDelay方法延迟执行方法
    
    //[self.photoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"zhiyuanCell"];
    //[self.view addSubview:self.photoCollectionView];
}


-(void)checkLocalPhoto{
    TZImagePickerController* imagePicker=[[TZImagePickerController alloc]initWithMaxImagesCount:30 delegate:self];
    [imagePicker setSortAscendingByModificationDate:NO];
    imagePicker.isSelectOriginalPhoto=_isSelectOriginalPhoto;
    imagePicker.selectedAssets=_assestArray;
    imagePicker.allowPickingVideo=YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    self.photoArray=[NSMutableArray arrayWithArray:photos];
    self.assestArray=[NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto=isSelectOriginalPhoto;
    //[_photoCollectionView reloadData];
    //NSLog(@"assets=%@",self.assestArray);
    //NSLog(@"photos=%@",self.photoArray);
    [self upLoadPhotosData];//选择页面内完成即上传
}
- (IBAction)addphotos:(id)sender {
    [self checkLocalPhoto];
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==_photoArray.count) {
        [self checkLocalPhoto];
    }else{
        TZImagePickerController* imagePickerVc=[[TZImagePickerController alloc]initWithSelectedAssets:_assestArray selectedPhotos:_photoArray index:indexPath.row];
        imagePickerVc.isSelectOriginalPhoto=_isSelectOriginalPhoto;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            _photoArray=[NSMutableArray arrayWithArray:photos];
            _assestArray=[NSMutableArray arrayWithArray:assets];
            _isSelectOriginalPhoto=isSelectOriginalPhoto;
            [_photoCollectionView reloadData];
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _photoArray.count+1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"zhiyuanCell" forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[PhotoCollectionViewCell alloc]init];
    }
    if (indexPath.row==_photoArray.count) {
        cell.imagev.image=[UIImage imageNamed:@"AlbumAddBtn"];
        cell.deleteButton.hidden=YES;
    }
    else{
        cell.imagev.image=_photoArray[indexPath.row];
        cell.imagev.contentMode=UIViewContentModeScaleAspectFill;//设置为按照原比例填充
        cell.imagev.clipsToBounds=YES;//把多余的部分裁剪掉
        //cell.imagev.layer.borderWidth=2.0;
        cell.imagev.layer.cornerRadius=10.0;
        cell.deleteButton.hidden=NO;
    }
    cell.deleteButton.tag=100+indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)deletePhoto:(UIButton*)sender{
    [_photoArray removeObjectAtIndex:sender.tag-100];
    [_assestArray removeObjectAtIndex:sender.tag-100];
    [_photoCollectionView performBatchUpdates:^{
        NSIndexPath* indexPath=[NSIndexPath indexPathForItem:sender.tag-100 inSection:0];
        [_photoCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_photoCollectionView reloadData];
    }];
    NSLog(@"count=%lu",_photoArray.count);
}

-(void)upLoadPhotosData{
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *DateString = [dateFormatter stringFromDate:[NSDate date]];
    //设置当前的用户名
    NSString* localUsername=[BmobUser currentUser].username;
    //批量上传
    for (int i=0; i<_photoArray.count; i++) {
        NSData* imageData=UIImagePNGRepresentation(_photoArray[i]);
        NSDictionary* dic=@{@"filename":[NSString stringWithFormat:@"IMG_%4d.png",arc4random()%2000],@"data":imageData};
        //@{@"filename":@"你的文件名",@"data":图片的data}
        //NSLog(@"dic=%@",dic);
        [self.photoDataArray addObject:dic];
    }
    //NSLog(@"count=%lu",(unsigned long)self.photoDataArray.count);
    
    [BmobFile filesUploadBatchWithDataArray:self.photoDataArray progressBlock:^(int index, float progress) {
        //NSLog(@"index:%d progress %f",index,progress);直接弹窗显示进度
        [self.hudUser showHUDWithIndex:index+1 subProgress:progress andCount:self.photoDataArray.count inView:self.tipView];
        
    } resultBlock:^(NSArray *array, BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [self.photoDataArray removeAllObjects];
            [self.hudUser hidHUDinView:self.tipView];
            [self.hudUser showHUDWithText:@"上传成功" inView:self.view];
            //NSLog(@"上传成功");
        }
        for (int i=0; i<array.count; i++) {
            BmobFile* file=array[i];
            BmobObject* obj=[[BmobObject alloc]initWithClassName:@"PhotosLibrary"];
            [obj setObject:file forKey:@"photo"];
            [obj setObject:file.url forKey:@"photoAdress"];
            [obj setObject:localUsername forKey:@"photosOwner"];
            [obj setObject:DateString forKey:@"UpLoadDate"];
            [obj setObject:self.VcTitle forKey:@"folder"];
            [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (error){
                    NSLog(@"%@",error);
                }
            }];
        }
        if (error){
            NSLog(@"%@",error);
            [self.hudUser showHUDWithText:@"备份失败，请联系开发者进行优化" inView:self.view];
        }
    }];
}

////批量上传方法
//- (IBAction)upLoadBtnAction:(id)sender {
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 云端图片展示区域
////懒加载hudUser对象
//-(MbHUDuser*)hudUser{
//    if (!_hudUser) {
//        _hudUser=[[MbHUDuser alloc]init];
//    }return _hudUser;
//}


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

-(NSMutableDictionary*)imageArrsDic{
    if (!_imageArrsDic) {
        _imageArrsDic=[[NSMutableDictionary alloc]init];
    }return _imageArrsDic;
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
        _photoTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 325)];
        _photoTableView.backgroundColor=[UIColor clearColor];
        _photoTableView.delegate=self;
        _photoTableView.dataSource=self;
    }return _photoTableView;
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
    if (self.imageUrlArrs.count!=0) {
        [tableView reloadData];
    }else{
        [tableView removeFromSuperview];//如果删到没有图片了就把tableview从主视图中移除
    }
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
    //选中添加到self.imageArrsDic
    if (currentStated==NO) {
        [self.imageArrsDic setValue:cachedImage forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }//非选中从self.imageArrsDic删掉uiimage
    else if (currentStated==YES){
        [self.imageArrsDic removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [cell checkStated:!currentStated];
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
}
//取消选中
- (void)deselect
{
    [self.photoTableView deselectRowAtIndexPath:[self.photoTableView indexPathForSelectedRow] animated:YES];
    
}
-(void)addTableView{
    //文件夹数据不为空，才显示表格，避免难看
    if (self.imageUrlArrs.count!=0) {
        [self.view addSubview:self.photoTableView];
    }
    
}
-(void)reloadTableViewData{
    [self.photoTableView reloadData];
}
////收起tableview的方法
//- (IBAction)closeTableView:(id)sender {
//        [self.photoTableView removeFromSuperview];
//}

//手动的刷新操作(真正的刷新操作)
-(void)realUpdate{
    [self updateData];//网上更新数据
    //[self performSelector:@selector(addTableView) withObject:nil afterDelay:3];//调用self afterDelay方法延迟执行方法
    [self performSelector:@selector(reloadTableViewData) withObject:nil afterDelay:1.5];

}
//从网上更新数据
-(void)updateData{
    //把之前的数据清空掉
    [self.imageUrlArrs removeAllObjects];
    [self.imageInfoArrs removeAllObjects];
    [self.imageDateInfos removeAllObjects];
    BmobQuery* queue=[BmobQuery queryWithClassName:@"PhotosLibrary"];
    [queue whereKey:@"photosOwner" equalTo:[BmobUser currentUser].username];
    [queue whereKey:@"folder" equalTo:self.VcTitle];
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
            //NSLog(@"搜索目录成功");
        }else if (error){
            NSLog(@"%@",error);
        }
    }];
}

//下载事件
- (IBAction)downloadAction:(id)sender {
    //循环保存到本地相册
    for (int i=0; i<[self.imageArrsDic allKeys].count; i++) {
        UIImage* image=[self.imageArrsDic valueForKey:[[self.imageArrsDic allKeys]objectAtIndex:i]];
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
@end
