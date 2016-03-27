//
//  InboxTableViewCell.m
//  MailByInVision
//
//  Created by Michal Kalis on 25/03/16.
//  Copyright © 2016 Michal Kalis. All rights reserved.
//

#import "InboxTableViewCell.h"
#import "Message.h"
#import "UIColor+ApplicationSpecific.h"
#import "NSDate+Utils.h"

@implementation InboxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.fromLabel.textColor = [UIColor applicationUnreadLabel];
    self.subjectLabel.textColor = [UIColor applicationUnreadLabel];
    self.bodyLabel.textColor = [UIColor applicationReadLabel];
    self.receivedAtLabel.textColor = [UIColor applicationBlue];
}

- (void)configureForObject:(Message *)message {
    self.fromLabel.attributedText = [message formattedFromText];
    self.subjectLabel.text = message.subject;
    self.bodyLabel.text = message.body;
    self.unreadIcon.hidden = message.read.boolValue;
    self.attachmentIcon.hidden = message.attachmentURLString == nil;
    
    NSDate *receivedAtDate = [NSDate dateWithTimeIntervalSince1970:message.receivedAt.doubleValue];
    if (receivedAtDate) {
        self.receivedAtLabel.text = [receivedAtDate wordsExpression];
    }
    
    [self setupColorsWithMessage:message];
}

#pragma mark - Private

- (void)setupColorsWithMessage:(Message *)message {
    UIColor *resultColor = message.read.boolValue ? [UIColor applicationReadLabel] : [UIColor applicationUnreadLabel];
    self.fromLabel.textColor = resultColor;
    self.subjectLabel.textColor = resultColor;
}

@end