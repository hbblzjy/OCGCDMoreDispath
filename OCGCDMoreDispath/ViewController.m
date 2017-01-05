//
//  ViewController.m
//  OCGCDMoreDispath
//
//  Created by healthmanage on 17/1/3.
//  Copyright © 2017年 healthmanager. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //方法执行
    /*注意：
     1.注意循环引用的问题，如果有用到self，要使用弱引用：__weak typeof (self) selfVc = self;这样效果最好，防止循环引用的问题
     */
    
    
    //[self pushRequstData1];//这个是并行异步的方法，oneOne和twoTwo方法会同时进行，所以执行的顺序不是1234567
    
    [self pushRequstData2];//这个是串行异步执行的方法，会等线程一执行完成，才会执行线程二，所以执行的顺序是1234567
    
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    //SDWebImage请求网络图片
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    butt.frame = CGRectMake(100, 100, 200, 100);
    [butt setTitle:@"SDWebimage" forState:UIControlStateNormal];
    [butt setBackgroundColor:[UIColor blueColor]];
    butt.layer.cornerRadius = 5;
    [self.view addSubview:butt];
    [butt addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)btnClick:(UIButton *)btn
{
    OneViewController *oneVC = [OneViewController new];
    [self.navigationController pushViewController:oneVC animated:YES];
}
#pragma mark --------- 并行异步执行的方法：利用GCD并行多个线程并且等待所有线程结束之后再执行其它方法
- (void)pushRequstData1 {
    __weak typeof (self) selfVc = self;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        // 并行执行的线程一
        NSLog(@"11111111");
        [selfVc oneOne];
        NSLog(@".........11111111");
    });
    dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
        // 并行执行的线程二
        NSLog(@"44444444");
        [selfVc twoTwo];
        NSLog(@".........22222222");
    });
    dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
        // 汇总结果
        NSLog(@"这里可以最后刷新数据,更新界面。。。。77777777");
        
    });
}
#pragma mark --------- 串行异步执行的方法：利用GCD串行多个线程，必须等到上一个完成之后，才能执行下一个任务，并且可以等待所有线程结束之后再执行其它方法
- (void)pushRequstData2 {
    __weak typeof (self) selfVc = self;
    //利用GCD串行多个线程，按顺序完成各个任务，并且等待所有线程结束之后再执行其它任务
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queue1, ^{
        // 串行执行的线程一
        NSLog(@"11111111");
        [selfVc oneOne];
    });
    dispatch_group_async(group, queue1, ^{
        // 串行执行的线程二
        NSLog(@"44444444");
        [selfVc twoTwo];
    });
    dispatch_group_notify(group, queue1, ^{
        // 汇总结果
        NSLog(@"这里可以最后刷新数据,更新界面。。。。77777777");
    });
    
}
//方法一:
-(void)oneOne
{
    NSLog(@"22222222");
    [self blockOne:^(id com) {
        NSLog(@"%@",com);
    }];
}
//Block1
-(void)blockOne:(void(^)(id))complete
{
    void (^block1)(void);
    block1 = ^(){
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i < 1000000; i++) {
            [array addObject:[NSString stringWithFormat:@"%d",i]];
        }
    };
    block1();
    complete(@"33333333");
}
//方法二:
-(void)twoTwo
{
    NSLog(@"55555555");
    [self blockTwo:^(id com) {
        NSLog(@"%@",com);
    }];
}
//Block2
-(void)blockTwo:(void(^)(id))complete
{
    void (^block1)(void);
    block1 = ^(){
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i < 1000; i++) {
            [array addObject:[NSString stringWithFormat:@"%d",i]];
        }
    };
    block1();
    complete(@"66666666");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
