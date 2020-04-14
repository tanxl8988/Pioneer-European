//
//  APKLocalFile.h
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Photos/Photos.h>

@interface APKLocalFile : NSManagedObject

@property (strong,nonatomic) NSString *name;
@property (nonatomic) int16_t type;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) NSString *localIdentifier;
@property (strong,nonatomic) PHAsset *asset;

+ (APKLocalFile *)createLocalFileWithName:(NSString *)name type:(int16_t)type date:(NSDate *)date localIdentifier:(NSString *)localIdentifier context:(NSManagedObjectContext *)context;

@end
