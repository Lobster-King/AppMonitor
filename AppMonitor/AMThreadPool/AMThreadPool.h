//
//  AMThreadPool.h
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/3.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AMThreadTaskStatus){
    AMThreadPoolWaitingMutex        = 0,/*等待signal*/
    AMThreadPoolBeginExecuteTask    = 1,/*开始执行任务*/
    AMThreadPoolEndExecuteTask      = 2,/*任务执行结束*/
    AMThreadPoolTaskCanceled        = 3,/*取消任务执行（未开始的任务可取消）*/
};/*任务状态机*/

typedef NS_ENUM(NSInteger,AMTaskPriority) {
    AMTaskPriorityDefault = 0,/*默认*/
    AMTaskPriorityLow     = 1,/*低*/
    AMTaskPriorityHigh    = 2,/*高*/
};/*任务执行优先级*/

typedef void (^AMThreadTaskBlock)(AMThreadTaskStatus status);

@interface AMThreadPool : NSObject

+ (instancetype)shareInstance;

- (void)executeTask:(void(^)())task
             withId:(NSString *)identity
           priority:(AMTaskPriority)priority
         taskStatus:(AMThreadTaskBlock)status;

- (void)removeTaskWithId:(NSString *)identity withError:(NSError **)error;

@end




NS_ASSUME_NONNULL_END
