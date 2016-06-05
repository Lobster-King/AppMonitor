//
//  ViewController.m
//  AppMonitor
//
//  Created by qinzhiwei on 16/6/3.
//  Copyright © 2016年 AppMonitor. All rights reserved.
//

#import "ViewController.h"
#import "AMFlowDetect.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    AMFlowDetect *flowDetect = [AMFlowDetect new];
    [flowDetect amFlowDetectStart];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
