//
//  AMDispatchQueue.h
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/6.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#ifndef AMDispatchQueue_h
#define AMDispatchQueue_h

#include <stdio.h>

#endif /* AMDispatchQueue_h */

typedef struct QNode{
    void *qItem;/*结点元素，例如task*/
    struct QNode *pNext;/*下一结点*/
    int  priority;/* 0:Default 1:Low 2:Hight */
    const char *identity;/**/
}QNode,*pHead,*pLast;

typedef struct {
    pHead head;
    pLast last;
}AMDispatchQueue;

AMDispatchQueue* createQueue();
void insertNode(AMDispatchQueue *queue,void *item,int priority,const char *identity);

int removeNode(AMDispatchQueue *queue,const char *identity);/*0success -1failed*/

void* deQueue(AMDispatchQueue *queue);

int destroyQueue(AMDispatchQueue *queue);


