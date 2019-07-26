//
//  HealthManager.h
//  SetpCount
//
//  Created by CBReno on 2019/3/26.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HealthManager : NSObject<RCTBridgeModule>

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *stepsArr;
@end

NS_ASSUME_NONNULL_END
