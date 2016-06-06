//
//  AMDispatchQueue.c
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/6.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#include "AMDispatchQueue.h"
#include <stdlib.h>

/*
 设计思路：
 1.实现基本的入队、出队操作
 2.增删改查
 */


int checkIsEmpty(AMDispatchQueue *queue);

/*创建队列*/
AMDispatchQueue* createQueue(){
    AMDispatchQueue *queue;
    queue = malloc(sizeof(AMDispatchQueue));
    queue->head = NULL;
    queue->last = NULL;
    return queue;
}

/*入列*/
void insertNode(AMDispatchQueue *queue,void *item,int priority,const char *identity){
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
int removeNode(AMDispatchQueue *queue,const char *identity){
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

/*出列*/
void* deQueue(AMDispatchQueue *queue){
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

/*销毁队列*/
int destroyQueue(AMDispatchQueue *queue){
    if (!queue) {
        return -1;
    }
    QNode *pHead = queue->head;
    while (pHead) {
        QNode *pTemp = pHead;
        pHead = pHead->pNext;
        free(pTemp);
    }
    queue->head = NULL;
    queue->last = NULL;
    return 0;
}



