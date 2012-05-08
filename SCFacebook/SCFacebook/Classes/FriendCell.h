//
//  FriendCell.h
//  SCFacebook
//
//  Created by Lucas Correa on 25/11/11.
//  Copyright (c) 2011 SiriusCode Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface FriendCell : UITableViewCell{
    
    IBOutlet EGOImageView *photoImageView;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic,retain)  EGOImageView *photoImageView;
@property (nonatomic,retain)  UILabel *nameLabel;


@end
