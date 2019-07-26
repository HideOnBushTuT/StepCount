//
//  HealthManager.m
//  SetpCount
//
//  Created by CBReno on 2019/3/26.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "HealthManager.h"

@implementation HealthManager

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(stepCountCallbackEvent:(RCTResponseSenderBlock)callback) {
  [self fetchSetpCountFromHealthKit:callback];
}

RCT_EXPORT_METHOD(stepCountWithTimes:(NSInteger)times) {
  NSLog(@"need to get %ld times records", (long)times);
  self.times = times;
}

- (void)fetchSetpCountFromHealthKit:(RCTResponseSenderBlock)callback {
  NSLog(@"%s:今天需要获取前%ld天的步数数据", __FUNCTION__,(long)self.times);
  //查看healthKit在设备上是否可用，ipad不支持HealthKit
  if (![HKHealthStore isHealthDataAvailable]) {
    NSLog(@"设备不支持healthkit");
    return;
  }
  
  //创建healthStore实例对象
  self.healthStore = [[HKHealthStore alloc] init];
  self.stepsArr = [NSMutableArray arrayWithCapacity:self.times];
  
  //设置需要获取的权限这里仅设置了步数/
  HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
  
  NSSet *healthSet = [NSSet setWithObjects:stepCount, nil];
  
  //从健康应用中获取权限
  [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
    if (!success) {
      NSLog(@"获取步数失败");
      return;
    }
    NSLog(@"获取步数权限成功");
    [self readStepCount:callback];
  }];
}


- (void)readStepCount:(RCTResponseSenderBlock)callback {
  for (NSInteger times = 1; times <= self.times; times++) {
    [self readOneDaySteps:times];
  }
  
//  callback(@[[NSNull null],  self.stepsArr]);
}


//- (void)readStepCount:(RCTResponseSenderBlock)callback {
//  //查询采样信息
//  HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//
//  //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
//  NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
//  NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
//
//  NSDate *now = [NSDate date];
//  NSCalendar *calender = [NSCalendar currentCalendar];
//  NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
//  NSDateComponents *dateComponent = [calender components:unitFlags fromDate:now];
//  int hour = (int)[dateComponent hour];
//  int minute = (int)[dateComponent minute];
//  int second = (int)[dateComponent second];
//  NSDate *nowDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second + 24 * 3600 * 60) ];
//  //时间结果与想象中不同是因为它显示的是0区
//  NSLog(@"今天%@",nowDay);
//  NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second)  + 86400];
//  NSLog(@"明天%@",nextDay);
//  NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nowDay endDate:nextDay options:(HKQueryOptionNone)];
//
//  /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
//   HKSample类所以对应的查询类就是HKSampleQuery。
//   下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
//   */
//  HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//    //    //打印查询结果
////    NSLog(@"resultCount = %ld result = %@",results.count,results);
//    //    //把结果装换成字符串类型
//    //    HKQuantitySample *result = results[0];
//    //    HKQuantity *quantity = result.quantity;
//    //    NSString *stepStr = (NSString *)quantity;
//    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//    //
//    //      //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
//    //      NSLog(@"最新步数：%@",stepStr);
//    //    }];
//    //设置一个int型变量来作为步数统计
//    int allStepCount = 0;
//    for (int i = 0; i < results.count; i ++) {
//      //把结果转换为字符串类型
//      HKQuantitySample *result = results[i];
//      HKQuantity *quantity = result.quantity;
//      NSMutableString *stepCount = (NSMutableString *)quantity;
//      NSString *stepStr =[ NSString stringWithFormat:@"%@",stepCount];
//      //获取51 count此类字符串前面的数字
//      NSString *str = [stepStr componentsSeparatedByString:@" "][0];
//      NSInteger stepNum = [str integerValue];
//      NSLog(@"%ld",(long)stepNum);
//      //把一天中所有时间段中的步数加到一起
//      allStepCount += stepNum;
//    }
//    NSLog(@"今天的总步数＝＝＝＝%ld",(long)allStepCount);
//    NSLog(@"今天需要获取前%ld天的y步数数据", (long)self.times);
//    callback(@[[NSNull null],  @[@(allStepCount)]]);
//  }];
//  //执行查询
//  [self.healthStore executeQuery:sampleQuery];
//
//
//}


- (void)readOneDaySteps:(NSInteger)day {
  //查询采样信息
  HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
  
  //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
  NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
  NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
  
  NSDate *now = [NSDate date];
  NSCalendar *calender = [NSCalendar currentCalendar];
  NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
  NSDateComponents *dateComponent = [calender components:unitFlags fromDate:now];
  int hour = (int)[dateComponent hour];
  int minute = (int)[dateComponent minute];
  int second = (int)[dateComponent second];
  
  NSDate *nowDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second + 24 * 3600 * day)];
  //时间结果与想象中不同是因为它显示的是0区
  NSLog(@"day 天前%@",nowDay);
  NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second + 24 * 3600 * (day - 1))];
  NSLog(@"day 天 -1 %@",nextDay);
  NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nowDay endDate:nextDay options:(HKQueryOptionNone)];
  
  /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
   HKSample类所以对应的查询类就是HKSampleQuery。
   下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
   */
  
  __block int allStepCount = 0;
  HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
    //    //打印查询结果
    //    NSLog(@"resultCount = %ld result = %@",results.count,results);
    //    //把结果装换成字符串类型
    //    HKQuantitySample *result = results[0];
    //    HKQuantity *quantity = result.quantity;
    //    NSString *stepStr = (NSString *)quantity;
    //    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //
    //      //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
    //      NSLog(@"最新步数：%@",stepStr);
    //    }];
    //设置一个int型变量来作为步数统计
    
    for (int i = 0; i < results.count; i ++) {
      //把结果转换为字符串类型
      HKQuantitySample *result = results[i];
      HKQuantity *quantity = result.quantity;
      NSMutableString *stepCount = (NSMutableString *)quantity;
      NSString *stepStr =[ NSString stringWithFormat:@"%@",stepCount];
      //获取51 count此类字符串前面的数字
      NSString *str = [stepStr componentsSeparatedByString:@" "][0];
      NSInteger stepNum = [str integerValue];
      NSLog(@"%ld",(long)stepNum);
      //把一天中所有时间段中的步数加到一起
      allStepCount += stepNum;
    }
    NSLog(@"今天的总步数＝＝＝＝%ld",(long)allStepCount);
    NSLog(@"今天需要获取前%ld天的y步数数据", (long)self.times);
    [self.stepsArr addObject:[NSNumber numberWithInt:allStepCount]];
    NSLog(@"stepArr: %@", self.stepsArr);
  }];
  //执行查询
  [self.healthStore executeQuery:sampleQuery];
}
@end
