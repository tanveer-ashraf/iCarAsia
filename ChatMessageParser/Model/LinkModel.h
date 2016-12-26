//
//  LinkModel.h
//  TestRegularExpression
//
//  Created by Mac One on 21/12/2016.
//  Copyright © 2016 spd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol LinkModel;

@interface LinkModel : JSONModel

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *title;


@end
