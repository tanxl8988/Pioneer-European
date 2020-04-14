//
//  APKLocalFile.m
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalFile.h"

@implementation APKLocalFile

@dynamic name,type,date,localIdentifier;
@synthesize asset = _asset;

+ (APKLocalFile *)createLocalFileWithName:(NSString *)name type:(int16_t)type date:(NSDate *)date localIdentifier:(NSString *)localIdentifier context:(NSManagedObjectContext *)context{
    
    APKLocalFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"APKLocalFile" inManagedObjectContext:context];
    file.name = name;
    file.type = type;
    file.date = date;
    file.localIdentifier = localIdentifier;
    return file;
}

@end
