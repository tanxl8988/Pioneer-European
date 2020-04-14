//
//  APKSettingsContentController.h
//  Pioneer
//
//  Created by Mac on 17/9/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseTableViewController.h"

@protocol APKSettingsContentDelegate <NSObject>

- (void)didSelectctedCell:(UITableViewCell *)cell;

@end

@interface APKSettingsContentController : APKBaseTableViewController

@property (weak,nonatomic) id<APKSettingsContentDelegate> delegate;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableCellArray;

@property (weak, nonatomic) IBOutlet UILabel *clipDurationLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *clipDurationSC;
@property (weak, nonatomic) IBOutlet UILabel *videoFormatLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoFormatSC;
@property (weak, nonatomic) IBOutlet UILabel *syncTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *syncTimeSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *wifiNameCell;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameInfoLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *wifiPasswordCell;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatSDCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *factoryResetLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *firmwareVersionCell;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionInfoLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *formatSDCardCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *factoryResetCell;
@property (weak, nonatomic) IBOutlet UILabel *specificationL;
@property (weak, nonatomic) IBOutlet UITableViewCell *specificationCell;
@property (weak, nonatomic) IBOutlet UILabel *passwordTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionL;
@property (weak, nonatomic) IBOutlet UITableViewCell *EULACell;
@property (weak, nonatomic) IBOutlet UILabel *sourceCodeL;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableCellArr;
@property (weak, nonatomic) IBOutlet UILabel *appVersionL;
@property (weak, nonatomic) IBOutlet UILabel *instructionL;
@property (weak, nonatomic) IBOutlet UILabel *EULALabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *infoCell;
@end
