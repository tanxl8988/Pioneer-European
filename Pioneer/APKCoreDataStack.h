//
//  APKCoreDataStack.h
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface APKCoreDataStack : NSObject

@property (readonly,strong,nonatomic) NSManagedObjectContext *context;

+ (instancetype)sharedInstance;

@end
