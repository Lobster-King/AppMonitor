//
//  AMSerialQueue.c
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/6.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#include "AMSerialQueue.h"
#include <stdlib.h>

/*
 设计思路：
 1.实现基本的入队、出队操作
 2.根据任务的优先级策略实现动态调度&&
 3.增删改查
 */


int checkIsEmpty(AMSerialQueue *queue);

/*创建队列*/
AMSerialQueue* createQueue(){
    AMSerialQueue *queue;
    queue = malloc(sizeof(AMSerialQueue));
    queue->head = NULL;
    queue->last = NULL;
    return queue;
}

/*入队*/
void insertNode(AMSerialQueue *queue,void *item,int priority,const char *identity){
    QNode *newItem = malloc(sizeof(QNode));
    newItem->qItem = item;
    newItem->pNext = NULL;
    newItem->identity = identity;
    newItem->priority = priority;
    
    
    if (!queue->head) {
        //空表
        queue->head = queue->last = newItem;
    }else{
        //非空表
        QNode *pTemp = queue->last;
        pTemp->pNext = newItem;
        queue->last = newItem;
    }
    
}

/*移除元素*/
int removeNode(AMSerialQueue *queue,const char *identity){
    QNode *node = queue->head;
    if (!node) {
        return -1;
    }
    
    QNode *pFrontNode = NULL;
    while (node) {
        if (node->identity == identity) {
            if (node == queue->head) {
                queue->head = node->pNext;
            }
            
            if (node == queue->last) {
                queue->last = pFrontNode;
            }
            
            if (pFrontNode) {
                pFrontNode->pNext = node->pNext;
            }

            free(node);
            break;
        }
        pFrontNode = node;
        node = node->pNext;
    }
    return -1;
}

/*出队*/
void* deQueue(AMSerialQueue *queue){
    if (!queue->head) {
        return NULL;/*空表*/
    }
    QNode *pHead = queue->head;
    if (pHead->pNext) {
        queue->head = pHead->pNext;
    }else{
        queue->head = NULL;
    }
    return pHead->qItem;
}






