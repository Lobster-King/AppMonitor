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
@property (nonatomic,assign)BOOL idleCondition;

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
    
    AMThreadItem *threadItem = idleConditionThreadItem();
    [self performSelector:@selector(executeTask:) onThread:threadItem.threadObj withObject:@[item,threadItem] waitUntilDone:NO];
}

- (void)removeTaskWithId:(NSString *)identity withError:(NSError **)error{
    AMTaskItem *taskItem = _taskPool[identity];
    if(taskItem.status != AMThreadPoolBeginExecuteTask)
        *error = [[NSError alloc]initWithDomain:TaskErrorDomain code:AMThreadPoolBeginExecuteTask userInfo:nil];
    else
        [_taskPool removeObjectForKey:identity];
}
/*获取空闲的线程，若没有达到maxMutex则去创建，并递归调用，直到返回合适的线程*/
static AMThreadItem * idleConditionThreadItem(){
    for (AMThreadItem *threadItem in [threadPoolInstance.pool allValues]) {
        if(threadItem.idleCondition){
            threadItem.idleCondition = NO;
            return threadItem;
            break;
        }
    }
    if (threadPoolInstance.pool.count < maxMutex){
        AMCreatePersistentThread();
        return idleConditionThreadItem();
    }
    dispatch_semaphore_wait(threadPoolInstance.semaphore, DISPATCH_TIME_FOREVER);
    return idleConditionThreadItem();
}

static void AMCreatePersistentThread(){
    static int random = 0;
    AMThreadItem *item = [AMThreadItem new];
    item.threadId      = [NSString stringWithFormat:@"%@_%d",kAMPersistentKey,random++];
    item.idleCondition = YES;
    item.policy        = AMPersistent;
    NSThread *thread   = [[NSThread alloc]initWithTarget:threadPoolInstance selector:@selector(amRunloopFire) object:nil];
    item.threadObj = thread;
    [threadPoolInstance.pool setObject:item forKey:item.threadId];
    [thread start];
}

static void AMCreateNonePersistentThread(){
    static int random = 0;
    AMThreadItem *item = [AMThreadItem new];
    item.threadId      = [NSString stringWithFormat:@"%@_%d",kAMNonePersistentKey,random++];
    item.idleCondition = YES;
    item.policy        = AMNonePersistent;
    NSThread *thread   = [NSThread new];
    item.threadObj = thread;
    [thread start];
    [threadPoolInstance.pool setObject:item forKey:item.threadId];
}

- (void)executeTask:(NSArray *)items{
    
    AMTaskItem *taskItem = items[0];
    AMThreadItem*threadItem = items[1];
    taskItem.taskBlock(AMThreadPoolBeginExecuteTask);
    taskItem.task();
    threadItem.idleCondition = YES;
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
        threadPoolInstance.semaphore= dispatch_semaphore_create(0);
    });
    return threadPoolInstance;
}












@end
