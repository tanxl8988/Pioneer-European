//
//  APKSettingsContentController.m
//  Pioneer
//
//  Created by Mac on 17/9/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSettingsContentController.h"
#import "APKDVR.h"

@implementation APKSettingsContentController

#pragma mark - UITableViewDelegate

/*
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (dvr.connectState == APKDVRConnectStateConnected) {
        for (int i = 0; i < self.tableCellArray.count; i++) {
            
            UITableViewCell *cell = self.tableCellArray[i];
            cell.backgroundColor = [UIColor whiteColor];
        }
    }

}
 

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"connectState"]) {
        
        APKDVRConnectState connectState = [change[@"new"] integerValue];
        
        if (connectState == APKDVRConnectStateDisconnected) {
            
       
        }
        else if (connectState == APKDVRConnectStateConnected){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (int i = 0; i < self.tableCellArray.count; i++) {
                    
                    UITableViewCell *cell = self.tableCellArray[i];
                    cell.backgroundColor = [UIColor whiteColor];
                }
            });
            
        }
    }
}*/

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.wifiPasswordLabel.text = @"初期値：88888888";
    
    NSString *isDark = [[NSUserDefaults standardUserDefaults] objectForKey:@"DARKMODE"];
    NSMutableArray *cellArr = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableCellArr) {
        if (cell != self.formatSDCardCell) {
            [cellArr addObject:cell];
            if ([isDark isEqualToString:@"YES"]) {
                cell.backgroundColor = [UIColor blackColor];
            }
        }
    }
    int index = cellArr.count -1;
    [cellArr exchangeObjectAtIndex:6 withObjectAtIndex:index];//调整cell顺序
    [cellArr exchangeObjectAtIndex:7 withObjectAtIndex:index];
    [cellArr exchangeObjectAtIndex:8 withObjectAtIndex:index];
    [cellArr exchangeObjectAtIndex:9 withObjectAtIndex:index];
    [cellArr exchangeObjectAtIndex:10 withObjectAtIndex:index];


    self.tableCellArr = [NSArray arrayWithArray:cellArr];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectctedCell:)]) {
        
        [self.delegate didSelectctedCell:cell];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([APKDVR sharedInstance].deviceNumber != APKDVRDeviceDZ500)
        return self.tableCellArr.count - 1;
    else
        return self.tableCellArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableArray *D700CellArr = [NSMutableArray arrayWithArray:self.tableCellArr];
    [D700CellArr removeObjectAtIndex:5];

    if ([APKDVR sharedInstance].deviceNumber != APKDVRDeviceDZ500){
        UITableViewCell *cell = D700CellArr[indexPath.row];
        return cell;
    }
    else{
        UITableViewCell *cell = self.tableCellArr[indexPath.row];
        return cell;
    }
}

@end
