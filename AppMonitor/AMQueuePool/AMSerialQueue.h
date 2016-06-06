//
//  AMSerialQueue.h
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/6.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#ifndef AMSerialQueue_h
#define AMSerialQueue_h

#include <stdio.h>

#endif /* AMSerialQueue_h */

typedef struct QNode{
    void *qItem;/*结点元素，例如task*/
    struct QNode *pNext;/*下一结点*/
    int  priority;/* 0:Default 1:Low 2:Hight */
    const char *identity;/**/
}QNode,*pHead,*pLast;

typedef struct {
    pHead head;
    pLast last;
}AMSerialQueue;

AMSerialQueue* createQueue();
void insertNode(AMSerialQueue *queue,void *item,int priority,const char *identity);
int removeNode(AMSerialQueue *queue,const char *identity);/*0success -1failed*/
