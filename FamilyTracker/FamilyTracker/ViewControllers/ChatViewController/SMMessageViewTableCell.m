//
//  SMMessageViewTableCell.m
//  JabberClient
//
//  Created by cesarerocchi on 9/8/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "SMMessageViewTableCell.h"


@implementation SMMessageViewTableCell

@synthesize senderNameLabel;
@synthesize messageContentView;
@synthesize senderAndTimeLabel;

@synthesize bgImageView;
@synthesize containerImageView;
@synthesize containerView;
@synthesize circleProgressBar;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //---Set Message containerView---//
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor clearColor];
        
        //---Set ContainerBgImageView---//
        self.containerImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [containerView addSubview:self.containerImageView];
        
        //---Set PhotoThumbnail---//
        self.photoThumbnail = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.photoThumbnail.layer.cornerRadius = 10.0f;
        self.photoThumbnail.clipsToBounds = YES;
        [containerView addSubview:self.photoThumbnail];
        
        //---circleProgressBar---//
        circleProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectZero];
        circleProgressBar.backgroundColor = [UIColor clearColor];
        circleProgressBar.hintHidden = YES;
        circleProgressBar.progressBarWidth = 4;
        circleProgressBar.progressBarProgressColor = [UIColor greenColor];
        circleProgressBar.progressBarTrackColor = [UIColor blueColor];
        circleProgressBar.hintViewSpacing = 0;
        circleProgressBar.hintViewBackgroundColor = [UIColor clearColor];
        circleProgressBar.startAngle = 0;
        [containerView addSubview:circleProgressBar];
        
        //---Set PhotoShowBtn---//
        self.photoShowBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.photoShowBtn.frame = CGRectZero;
        [self.photoShowBtn setTitle:@"" forState:UIControlStateNormal];
        self.photoShowBtn.backgroundColor = [UIColor clearColor];
//        [self.photoShowBtn setImage:[UIImage imageNamed:@"thumbnailPlayBtn"] forState:UIControlStateNormal];
        [containerView addSubview:self.photoShowBtn];
        
        //---Set VideoPlayBtn---//
        self.videoPlayBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.videoPlayBtn.frame = CGRectZero;
        [self.videoPlayBtn setTitle:@"" forState:UIControlStateNormal];
        self.videoPlayBtn.backgroundColor = [UIColor clearColor];
        [self.videoPlayBtn setImage:[UIImage imageNamed:@"thumbnailPlayBtn"] forState:UIControlStateNormal];
        [containerView addSubview:self.videoPlayBtn];
        
        //---Set VideoPlayBtn---//
        self.audioPlayBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.audioPlayBtn.frame = CGRectZero;
        [self.audioPlayBtn setTitle:@"" forState:UIControlStateNormal];
        self.audioPlayBtn.backgroundColor = [UIColor clearColor];
        [self.audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
        [containerView addSubview:self.audioPlayBtn];
        
        //---Set sender Name---//
        senderNameLabel = [[UILabel alloc] init];
        senderNameLabel.textAlignment = NSTextAlignmentLeft;
        senderNameLabel.font = [UIFont systemFontOfSize:13.0];
        [self boldFontForLabel:senderNameLabel];
        senderNameLabel.textColor = [UIColor blackColor];
        [containerView addSubview:senderNameLabel];
        
        //---Set send Msg---//
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        messageContentView.editable = NO;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
        [containerView addSubview:messageContentView];
        
        //---Set Sending Time---//
		senderAndTimeLabel = [[UILabel alloc] init];
		senderAndTimeLabel.textAlignment = NSTextAlignmentLeft;
		senderAndTimeLabel.font = [UIFont systemFontOfSize:10.0];
		senderAndTimeLabel.textColor = [UIColor darkGrayColor];
		[containerView addSubview:senderAndTimeLabel];
        
        //---User Thumbnail Image---//
		bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:bgImageView];
		[self.contentView addSubview:containerView];
    }
	
    return self;
	
}

- (void)boldFontForLabel:(UILabel *)label{
    UIFont *currentFont = label.font;
    UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
    label.font = newFont;
}

//- (IBAction)photoViewAction:(id)sender {
//    
//    UIButton *btn = (UIButton*)sender;
//    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
//    [m setObject:[NSString stringWithFormat:@"%ld",(long)btn.tag] forKey:@"photoBtnTag"];
//    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"photoFullScreenViewNotification"
//     object:self userInfo:m];
//    
//}
//
//- (IBAction)videoPlayAction:(id)sender {
//    
//    UIButton *btn = (UIButton*)sender;
//    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
//    [m setObject:[NSString stringWithFormat:@"%ld",(long)btn.tag] forKey:@"photoBtnTag"];
//    
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"photoFullScreenViewNotification"
//     object:self userInfo:m];
//    
//}

@end
