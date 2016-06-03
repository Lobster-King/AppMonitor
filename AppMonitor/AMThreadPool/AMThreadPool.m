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
static NSInteger const maxMutex = 5;
static NSString *const TaskErrorDomain  = @"com.taskerror.domain";
static NSString *const kAMPersistentKey = @"AMPersistentONE";
static NSString *const kAMNonePersistentKey = @"AMPersistentTWO";

typedef NS_ENUM(NSInteger,AMThreadPolicy){
    AMPersistent        = 0,   /*常驻线程never die*/
    AMNonePersistent    = 1,   /*非常驻线程*/
};/*线程策略*/

@interface AMThreadItem : NSObject

@property (nonatomic,copy)NSString *threadId;
@property (nonatomic,strong)NSThread *threadObj;
@property (nonatomic,assign)AMThreadPolicy policy;

@end

@implementation AMThreadItem
@end

@interface AMTaskItem : NSObject

@property (nonatomic,copy)NSString *taskId;
@property (nonatomic,copy)void(^task) ();
@property (nonatomic,copy)AMThreadTaskBlock taskBlock;
@property (nonatomic,assign)AMThreadTaskStatus status;
@property (nonatomic,assign)AMTaskPriority policy;

@end

@implementation AMTaskItem
@end

@interface AMThreadPool ()

@property (nonatomic,retain)NSMutableDictionary *pool;
@property (nonatomic,retain)NSMutableDictionary *taskPool;
@property (nonatomic,strong)dispatch_semaphore_t semaphore;/*信号量*/

@end

@implementation AMThreadPool

- (void)executeTask:(void (^)())task withId:(NSString *)identity priority:(AMTaskPriority)priority taskStatus:(AMThreadTaskBlock)status{
    AMTaskItem *item = [AMTaskItem new];
    item.taskId = identity;
    item.task   = task;
    item.taskBlock = status;
    item.policy = priority;
    [_taskPool setObject:item forKey:identity];
    
    
    item.taskBlock(AMThreadPoolWaitingMutex);
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    AMThreadItem *threadItem = [_pool objectForKey:kAMPersistentKey];
    [self performSelector:@selector(executeTask:) onThread:threadItem.threadObj withObject:item waitUntilDone:NO];
}

- (void)removeTaskWithId:(NSString *)identity withError:(NSError **)error{
    AMTaskItem *taskItem = _taskPool[identity];
    if(taskItem.status != AMThreadPoolBeginExecuteTask)
        *error = [[NSError alloc]initWithDomain:TaskErrorDomain code:AMThreadPoolBeginExecuteTask userInfo:nil];
    else
        [_taskPool removeObjectForKey:identity];
}

static AMThreadItem * idleConditionThreadItem(){
    
    if (threadPoolInstance.pool.count <= maxMutex)
        AMCreatePersistentThread();
    for (AMThreadItem *threadItem in [threadPoolInstance.pool allValues]) {
        if(threadItem.threadObj.isFinished)
            return threadItem;
        break;
    }
    return nil;
}

static void AMCreatePersistentThread(){
    AMThreadItem *item = [AMThreadItem new];
    item.threadId      = kAMPersistentKey;
    item.policy        = AMPersistent;
    NSThread *thread   = [[NSThread alloc]initWithTarget:threadPoolInstance selector:@selector(amRunloopFire) object:nil];
    item.threadObj = thread;
    [thread start];
    [threadPoolInstance.pool setObject:item forKey:kAMPersistentKey];
    dispatch_semaphore_signal(threadPoolInstance.semaphore);
}

static void AMCreateNonePersistentThread(){
    AMThreadItem *item = [AMThreadItem new];
    item.threadId      = kAMNonePersistentKey;
    item.policy        = AMNonePersistent;
    NSThread *thread   = [NSThread new];
    item.threadObj = thread;
    [thread start];
    [threadPoolInstance.pool setObject:item forKey:kAMNonePersistentKey];
    dispatch_semaphore_signal(threadPoolInstance.semaphore);
}

- (void)executeTask:(AMTaskItem *)taskItem{
    taskItem.taskBlock(AMThreadPoolBeginExecuteTask);
    taskItem.task();
    taskItem.taskBlock(AMThreadPoolEndExecuteTask);
    dispatch_semaphore_signal(self.semaphore);
}


-(void)amRunloopFire{
    [[NSRunLoop currentRunLoop]addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

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
        threadPoolInstance.pool = [NSMutableDictionary dictionaryWithCapacity:maxMutex];
        threadPoolInstance.taskPool = [NSMutableDictionary new];
        threadPoolInstance.semaphore= dispatch_semaphore_create(1);
    });
    return threadPoolInstance;
}












@end
