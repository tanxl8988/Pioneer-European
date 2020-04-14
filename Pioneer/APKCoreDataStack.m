//
//  APKCoreDataStack.m
//  Pioneer
//
//  Created by Mac on 17/9/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCoreDataStack.h"

@implementation APKCoreDataStack

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self createCoreDataStack];
    }
    return self;
}

+ (instancetype)sharedInstance{
    
    static APKCoreDataStack *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APKCoreDataStack alloc] init];
    });
    return instance;
}

#pragma mark - private method

- (void)createCoreDataStack{
    
    NSURL *momUrl = [[NSBundle mainBundle] URLForResource:@"PioneerModal" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
    NSAssert(mom, @"create NSManagedObjectModel failure");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = psc;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *psUrl = [documentsDirectory URLByAppendingPathComponent:@"PioneerData.sqlite"];
        
        NSError *error;
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:psUrl options:nil error:&error];
        NSAssert(!error, error.description);
        
        self.context = context;
    });
}

- (void)setContext:(NSManagedObjectContext *)context{
    
    _context = context;
}

@end
