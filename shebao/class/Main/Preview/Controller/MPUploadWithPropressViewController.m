//
//  MPUploadWithPropressViewController.m
//  MobileProject
//
//  Created by wujunyang on 16/7/22.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "MPUploadWithPropressViewController.h"

@interface MPUploadWithPropressViewController()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate>
@property (nonatomic,strong) UITableView         *myTableView;
@property (strong, nonatomic) MPUploadImageHelper *curUploadImageHelper;
@end

@implementation MPUploadWithPropressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"上传图片有进度值";
    
    //初始化
    _curUploadImageHelper=[MPUploadImageHelper MPUploadImageForSend:YES];
    
    //初始化表格
    if (!_myTableView) {
        _myTableView  = [[UITableView alloc] initWithFrame:CGRectMake(0,0, Main_Screen_Width, Main_Screen_Height) style:UITableViewStylePlain];
        _myTableView.tableFooterView=[UIView new];
        _myTableView.showsVerticalScrollIndicator   = NO;
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView.dataSource                     = self;
        _myTableView.delegate                       = self;
        [_myTableView registerClass:[MPImageUploadProgressCell class] forCellReuseIdentifier:NSStringFromClass([MPImageUploadProgressCell class])];
        [self.view addSubview:_myTableView];
        [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    
    //设置右边
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,30)];
    [rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(myAction)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

#pragma mark UITableViewDataSource, UITableViewDelegate相关内容

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MPImageUploadProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MPImageUploadProgressCell class]) forIndexPath:indexPath];
    MPWeakSelf(self);
    cell.accessoryType    = UITableViewCellAccessoryNone;
    cell.curUploadImageHelper=self.curUploadImageHelper;
    cell.addPicturesBlock = ^(){
        MPStrongSelf(self);
        [self showActionForPhoto];
    };
    cell.deleteImageBlock = ^(MPImageItemModel *toDelete){
        MPStrongSelf(self);
        [self.curUploadImageHelper deleteAImage:toDelete];
        [self.myTableView reloadData];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MPImageUploadProgressCell cellHeightWithObj:self.curUploadImageHelper];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //拍照
        if (![cameraHelper checkCameraAuthorizationStatus]) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //相册
        if (![cameraHelper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        [imagePickerController.selectedAssetURLs removeAllObjects];
        [imagePickerController.selectedAssetURLs addObjectsFromArray:self.curUploadImageHelper.selectedAssetURLs];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.maximumNumberOfSelection = kupdateMaximumNumberOfImage;
        imagePickerController.allowsMultipleSelection = YES;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    MPWeakSelf(self);
    [assetsLibrary writeImageToSavedPhotosAlbum:[pickerImage CGImage] orientation:(ALAssetOrientation)pickerImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        MPStrongSelf(self);
        [self.curUploadImageHelper addASelectedAssetURL:assetURL];
        //局部刷新 根据布局相应调整
        [self partialTableViewRefresh];
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UINavigationControllerDelegate, QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    NSMutableArray *selectedAssetURLs = [NSMutableArray new];
    [imagePickerController.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedAssetURLs addObject:obj];
    }];
    MPWeakSelf(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPStrongSelf(self)
        self.curUploadImageHelper.selectedAssetURLs = selectedAssetURLs;
        dispatch_async(dispatch_get_main_queue(), ^{
            MPStrongSelf(self)
            //局部刷新 根据布局相应调整
            [self partialTableViewRefresh];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 自定义代码

//弹出选择框
-(void)showActionForPhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册选择",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

//上传图后局部刷新图片行 根据布局相应调整
-(void)partialTableViewRefresh
{
    [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

//上传图片
-(void)myAction
{
    if (self.curUploadImageHelper.selectedAssetURLs.count==0) {
        [MBProgressHUD showAutoMessage:@"请选择照片进行上传" ToView:nil];
        return;
    }

    //是否已经全部上传
    BOOL isAllComplete=YES;
    for (MPImageItemModel *item in self.curUploadImageHelper.imagesArray) {
        if (item.upServicePath.length==0) {
            isAllComplete=NO;
            break;
        }
    }
    
    //是否未完成
    if(!isAllComplete)
    {
        [MBProgressHUD showAutoMessage:@"照片还未全部上传" ToView:nil];
        return;
    }
    
    //可以接着处理逻辑，上传成功会把服务端的图片地址写在upServicePath,就可以写入到业务逻辑中
}


@end
