//
//  AMFlowDetect.m
//  AppMonitor
//
//  Created by 秦志伟 on 16/6/5.
//  Copyright (c) 2016年 AppMonitor. All rights reserved.
//

#import "AMFlowDetect.h"
#import "AMThreadPool.h"

@interface AMFlowDetect ()

@end

@implementation AMFlowDetect

- (void)amFlowDetectStart{
    __weak __typeof(self)weakSelf = self;
    [[AMThreadPool shareInstance] executeTask:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf amRegisterObserver];
    } withId:@"com.lobster.AMFlowDetect" priority:0 taskStatus:NULL];
}

static void AMRunloopCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    if (activity == kCFRunLoopBeforeSources || activity == kCFRunLoopAfterWaiting) {
        NSLog(@"卡顿啊。。");
    }
}

- (void)amRegisterObserver{
    CFRunLoopObserverContext context;
    context.version = 0;
    context.info    = (__bridge void *)self;
    context.release = NULL;
    context.retain  = NULL;
    context.copyDescription = NULL;
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, 1, 0, &AMRunloopCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}

- (void)amFlowDetectStop{
    CFRunLoopObserverContext context;
    context.version = 0;
    context.info    = (__bridge void *)self;
    context.release = NULL;
    context.retain  = NULL;
    context.copyDescription = NULL;
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, 1, 0, &AMRunloopCallBack, &context);
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}

@end
