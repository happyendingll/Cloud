//
//  FileMangerTableViewCell.h
//  Cloud
//
//  Created by 曾志远 on 2017/12/22.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileMangerTableViewCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UIButton *reNameBtn;//改用长按重命名
-(void)loadDataWithFileName:(NSString*)fileName;
@end
