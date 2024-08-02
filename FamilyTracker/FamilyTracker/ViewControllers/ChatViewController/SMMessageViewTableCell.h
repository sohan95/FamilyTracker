//
//  SMMessageViewTableCell.h
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressBar.h"

@interface SMMessageViewTableCell : UITableViewCell {

    UILabel *senderNameLabel;
	UILabel	*senderAndTimeLabel;
	UITextView *messageContentView;
	UIImageView *bgImageView;
    UIImageView *containerImageView;
    UIView *containerView;
    CircleProgressBar *circleProgressBar;
    
}
@property (nonatomic,strong) UILabel *senderNameLabel;
@property (nonatomic,strong) UILabel *senderAndTimeLabel;
@property (nonatomic,strong) UITextView *messageContentView;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIImageView *containerImageView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) CircleProgressBar *circleProgressBar;

@property (nonatomic,strong) UIImageView *photoThumbnail;
@property (nonatomic,strong) UIButton *photoShowBtn;
@property (nonatomic,strong) UIButton *videoPlayBtn;
@property (nonatomic,strong) UIButton *audioPlayBtn;

@end
