//
//  SBCollectionView.m
//  shebao
//
//  Created by 朱恪帅 on 2017/11/20.
//  Copyright © 2017年 dashuai. All rights reserved.
//

#import "SBCollectionView.h"
const  double image_width = 30;
@interface SBCollectionView ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation SBCollectionView

- (instancetype)initWithCollectionModel:(SBHomeCollectionModel *)collectionModel{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.frame = CGRectMake((Main_Screen_Width/4 - image_width)/2, (Main_Screen_Width/4 - image_width)/2, image_width, image_width);
    }
     return _iconView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:13];
    }
    return _textLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
