//
//  ChatMessage.h
//  ChatMessageParser
//
//  Created by Mac One on 26/12/2016.
//  Copyright © 2016 spd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONModel.h"
#import "LinkModel.h"

@interface ChatMessage : JSONModel
@property (nonatomic) NSString *message;
@property (nonatomic) NSArray <LinkModel> *links;


@end
