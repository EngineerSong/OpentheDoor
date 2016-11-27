//
//  MyConnection.h
//  LimitDemo
//
//  Created by pk on 15/3/24.
//  Copyright (c) 2015年 pk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyRequest.h"

@interface MyConnection : NSObject

+ (void)connectionWithUrl:(NSString*)url WithValue:(NSString *)value FinishBlock:(FinishBlock)finishBlock FailedBlock:(FailedBlock)failedBlock;

@end
