//
//  AMThreadPool.m
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/3.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#import "AMThreadPool.h"
#import "AMTest.h"

static AMThreadPool *threadPoolInstance = nil;
static const NSInteger maxMutex = 5;

typedef NS_ENUM(NSInteger,AMThreadPolicy){
    AMPersistent        = 0,   /*常驻线程never die*/
    AMNonePersistent    = 1,   /*非常驻线程*/
};/*线程策略*/

@interface AMThreadItem : NSObject

@property (nonatomic,assign)NSInteger threadId;
@property (nonatomic,strong)NSThread *threadObj;
@property (nonatomic,assign)AMThreadPolicy policy;

@end

@interface AMThreadPool ()

@property (nonatomic,copy)NSMutableArray *pool;
@property (nonatomic,copy)NSMutableDictionary *taskPool;
@property (nonatomic,assign)dispatch_semaphore_t semaphore;/*信号量*/

@end

@implementation AMThreadPool





+ (instancetype)shareInstance{
    static dispatch_once_t onceToken = 0x00;
    dispatch_once(&onceToken, ^{
        threadPoolInstance = [self new];
        [AMTest test];
    });
    return threadPoolInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken = 0x00;
    dispatch_once(&onceToken, ^{
        threadPoolInstance = [super allocWithZone:zone];
        threadPoolInstance.pool = [NSMutableArray arrayWithCapacity:maxMutex];
        threadPoolInstance.taskPool = [NSMutableDictionary new];
    });
    return threadPoolInstance;
}












@end
