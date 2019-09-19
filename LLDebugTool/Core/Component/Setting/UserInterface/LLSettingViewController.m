//
//  LLSettingViewController.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLSettingViewController.h"
#import "LLFactory.h"
#import "LLThemeManager.h"
#import "LLSettingCategoryModel.h"
#import "LLTitleSwitchCell.h"
#import "LLDetailTitleSelectorCell.h"
#import "LLConfig.h"
#import "LLTitleView.h"
#import "LLMacros.h"
#import "LLConfigHelper.h"
#import "LLSettingManager.h"
#import "NSObject+LL_Runtime.h"
#import "LLImageNameConfig.h"
#import "LLConst.h"
#import "LLTitleSliderCell.h"

static NSString *const kSwitchCellID = @"SwitchCellID";
static NSString *const kMultipleCellID = @"MultipleCellID";

@interface LLSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray <LLSettingCategoryModel *>*dataArray;

@end

@implementation LLSettingViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpUI];
}

#pragma mark - Over write
- (void)primaryColorChanged {
    [super primaryColorChanged];
    [_tableView setSeparatorColor:[LLThemeManager shared].primaryColor];
    [_tableView reloadData];
}

- (void)backgroundColorChanged {
    [super backgroundColorChanged];
    _tableView.backgroundColor = [LLThemeManager shared].backgroundColor;
    [_tableView reloadData];
}

#pragma mark - Primary
- (void)initial {
    [self initUI];
    [self initData];
}

- (void)initUI {
    self.title = @"Setting";
    [self.view addSubview:self.tableView];
}

- (void)initData {
    NSMutableArray *settings = [[NSMutableArray alloc] init];
    
    // Short Cut
    [settings addObject:[self getDoubleClickComponentModel]];
    LLSettingCategoryModel *category0 = [[LLSettingCategoryModel alloc] initWithTitle:@"Short Cut" settings:settings];
    [settings removeAllObjects];
    
    // ColorStyle
    [settings addObject:[self getColorStyleModel]];
    [settings addObject:[self getStatusBarStyleModel]];
    
    LLSettingCategoryModel *category1 = [[LLSettingCategoryModel alloc] initWithTitle:@"Color" settings:settings];
    [settings removeAllObjects];
    
    // EntryWindowStyle
    [settings addObject:[self getEntryWindowStyleModel]];
    [settings addObject:[self getShrinkToEdgeWhenInactiveModel]];
    [settings addObject:[self getShakeToHideModel]];
    LLSettingCategoryModel *category2 = [[LLSettingCategoryModel alloc] initWithTitle:@"Entry Window" settings:settings];
    [settings removeAllObjects];
    
    // Log
    [settings addObject:[self getLogStyleModel]];
    LLSettingCategoryModel *category3 = [[LLSettingCategoryModel alloc] initWithTitle:@"Log" settings:settings];
    [settings removeAllObjects];
    
    // Magnifier
    [settings addObject:[self getMagnifierZoomLevelModel]];
    [settings addObject:[self getMagnifierSizeModel]];
    LLSettingCategoryModel *category4 = [[LLSettingCategoryModel alloc] initWithTitle:@"Magnifier" settings:settings];
    [settings removeAllObjects];
    
    self.dataArray = @[category0, category1, category2, category3, category4];
    [self.tableView reloadData];
}

- (void)setUpUI {
    self.tableView.frame = self.view.bounds;
}

- (LLTitleCellModel *)getDoubleClickComponentModel {
    __weak typeof(self) weakSelf = self;
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Double Click" detailTitleSelector:[LLConfigHelper doubleClickComponentDescription]];
    model.block = ^{
        [weakSelf showDoubleClickAlert];
    };
    return model;
}

- (void)showDoubleClickAlert {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSInteger i = LLDebugToolActionSetting; i < LLDebugToolActionWidgetBorder + 1; i++) {
        NSString *action = [LLConfigHelper componentDescription:i];
        if (action) {
            [actions addObject:action];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self showActionSheetWithTitle:@"Double Click Event" actions:actions currentAction:[LLConfigHelper doubleClickComponentDescription] completion:^(NSInteger index) {
        [weakSelf setNewDoubleClick:index + LLDebugToolActionSetting];
    }];
}

- (void)setNewDoubleClick:(LLDebugToolAction)action {
    [LLConfig shared].doubleClickAction = action;
    [LLSettingManager shared].doubleClickAction = @(action);
    [self initData];
}

- (LLTitleCellModel *)getShakeToHideModel {
    __weak typeof(self) weakSelf = self;
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Shake To Hide" flag:[LLConfig shared].isShakeToHide];
    model.changePropertyBlock = ^(id  _Nullable obj) {
        [weakSelf setNewShakeToHide:[obj boolValue]];
    };
    return model;
}

- (void)setNewShakeToHide:(BOOL)isShakeToHide {
    [LLConfig shared].shakeToHide = isShakeToHide;
    [LLSettingManager shared].shakeToHide = @(isShakeToHide);
}

- (LLTitleCellModel *)getColorStyleModel {
    __weak typeof(self) weakSelf = self;
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Style" detailTitleSelector:[LLConfigHelper colorStyleDetailDescription]];
    model.block = ^{
        [weakSelf showColorStyleAlert];
    };
    return model;
}

- (void)showColorStyleAlert {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 3; i++) {
        NSString *action = [LLConfigHelper colorStyleDescription:i];
        if (action) {
            [actions addObject:action];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self showActionSheetWithTitle:@"Color Style" actions:actions currentAction:[LLConfigHelper colorStyleDescription] completion:^(NSInteger index) {
        [weakSelf setNewColorStyle:index];
    }];
}

- (void)setNewColorStyle:(LLConfigColorStyle)style {
    if (style == [LLConfig shared].colorStyle) {
        return;
    }
    if (style == LLConfigColorStyleCustom) {
        
    } else {
        [LLConfig shared].colorStyle = style;
        [LLSettingManager shared].colorStyle = @(style);
        [self initData];
    }
}

- (LLTitleCellModel *)getStatusBarStyleModel {
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Status Bar" detailTitleSelector:[LLConfigHelper statusBarStyleDescription]];
    __weak typeof(self) weakSelf = self;
    model.block = ^{
        [weakSelf showStatusBarStyleAlert];
    };
    return model;
}

- (void)showStatusBarStyleAlert {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
#ifdef __IPHONE_13_0
    NSInteger count = 4;
#else
    NSInteger count = 3;
#endif
    for (NSInteger i = 0; i < count; i++) {
        NSString *action = [LLConfigHelper statusBarStyleDescription:i];
        if (action) {
            [actions addObject:action];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self showActionSheetWithTitle:@"Status Bar Style" actions:actions currentAction:[LLConfigHelper statusBarStyleDescription] completion:^(NSInteger index) {
        [weakSelf setNewStatusBarStyle:index];
    }];
}

- (void)setNewStatusBarStyle:(UIStatusBarStyle)style {
    if (style == [LLThemeManager shared].statusBarStyle) {
        return;
    }
    
    [[LLConfig shared] configStatusBarStyle:style];
    [LLSettingManager shared].statusBarStyle = @(style);
    [self initData];
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:YES];
}

- (LLTitleCellModel *)getEntryWindowStyleModel {
    __weak typeof(self) weakSelf = self;
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Style" detailTitleSelector:[LLConfigHelper entryWindowStyleDescription]];
    model.block = ^{
        [weakSelf showEntryWindowStyleAlert];
    };
    return model;
}

- (void)showEntryWindowStyleAlert {
#ifdef __IPHONE_13_0
    NSInteger count = 4;
#else
    NSInteger count = 6;
#endif
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < count; i++) {
        NSString *action = [LLConfigHelper entryWindowStyleDescription:i];
        if (action) {
            [actions addObject:action];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self showActionSheetWithTitle:@"Entry Window Style" actions:actions currentAction:[LLConfigHelper entryWindowStyleDescription] completion:^(NSInteger index) {
        [weakSelf setNewEntryWindowStyle:index];
    }];
}

- (void)setNewEntryWindowStyle:(LLConfigEntryWindowStyle)style {
    if (style == [LLConfig shared].entryWindowStyle) {
        return;
    }
    
    [LLConfig shared].entryWindowStyle = style;
    [LLSettingManager shared].entryWindowStyle = @(style);
    [self initData];
}

- (LLTitleCellModel *)getShrinkToEdgeWhenInactiveModel {
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Shrink To Edge" flag:[LLConfig shared].isShrinkToEdgeWhenInactive];
    __weak typeof(self) weakSelf = self;
    model.changePropertyBlock = ^(id  _Nullable obj) {
        [weakSelf setNewShrinkToEdgeWhenInactive:[obj boolValue]];
    };
    return model;
}

- (void)setNewShrinkToEdgeWhenInactive:(BOOL)isShrinkToEdgeWhenInactive {
    [LLConfig shared].shrinkToEdgeWhenInactive = isShrinkToEdgeWhenInactive;
    [LLSettingManager shared].shrinkToEdgeWhenInactive = @(isShrinkToEdgeWhenInactive);
}

- (LLTitleCellModel *)getLogStyleModel {
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Style" detailTitleSelector:[LLConfigHelper logStyleDescription]];
    __weak typeof(self) weakSelf = self;
    model.block = ^{
        [weakSelf showLogStyleAlert];
    };
    return model;
}

- (void)showLogStyleAlert {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 5; i++) {
        NSString *action = [LLConfigHelper logStyleDescription:i];
        if (action) {
            [actions addObject:action];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self showActionSheetWithTitle:@"Log Style" actions:actions currentAction:[LLConfigHelper logStyleDescription] completion:^(NSInteger index) {
        [weakSelf setNewLogStyle:index];
    }];
}

- (void)setNewLogStyle:(LLConfigLogStyle)style {
    if (style == [LLConfig shared].logStyle) {
        return;
    }
    
    [LLConfig shared].logStyle = style;
    [LLSettingManager shared].logStyle = @(style);
    [self initData];
}

- (LLTitleCellModel *)getMagnifierZoomLevelModel {
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Zoom Level" value:[LLConfig shared].magnifierZoomLevel minValue:kLLMagnifierWindowMinZoomLevel maxValue:kLLMagnifierWindowMaxZoomLevel];
    __weak typeof(self) weakSelf = self;
    model.changePropertyBlock = ^(id  _Nullable obj) {
        [weakSelf setNewMagnifierZoomLevel:[obj integerValue]];
    };
    return model;
}

- (void)setNewMagnifierZoomLevel:(NSInteger)zoomLevel {
    [LLConfig shared].magnifierZoomLevel = zoomLevel;
    [LLSettingManager shared].magnifierZoomLevel = @(zoomLevel);
    [self initData];
}

- (LLTitleCellModel *)getMagnifierSizeModel {
    LLTitleCellModel *model = [[LLTitleCellModel alloc] initWithTitle:@"Size" value:[LLConfig shared].magnifierSize minValue:kLLMagnifierWindowMinSize maxValue:kLLMagnifierWindowMaxSize];
    __weak typeof(self) weakSelf = self;
    model.changePropertyBlock = ^(id  _Nullable obj) {
        [weakSelf setNewMagnifierSize:[obj integerValue]];
    };
    return model;
}

- (void)setNewMagnifierSize:(NSInteger)size {
    [LLConfig shared].magnifierSize = size;
    [LLSettingManager shared].magnifierSize = @(size);
    [self initData];
}

- (void)showActionSheetWithTitle:(NSString *)title actions:(NSArray *)actions currentAction:(NSString *)currentAction completion:(void (^ __nullable)(NSInteger index))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < actions.count; i++) {
        NSString *actionTitle = actions[i];
        __block NSInteger index = i;
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(index);
            }
        }];
        if ([actionTitle isEqualToString:currentAction]) {
            action.enabled = NO;
            [action setValue:[UIImage LL_imageNamed:kSelectImageName] forKey:@"image"];
        }
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLTitleCellModel *model = self.dataArray[indexPath.section].settings[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.cellClass];
    [cell setValue:model forKey:@"model"];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LLTitleView *view = [[LLTitleView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 40)];
    LLSettingCategoryModel *model = self.dataArray[section];
    view.titleLabel.text = model.title;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LLTitleCellModel *model = self.dataArray[indexPath.section].settings[indexPath.row];
    if (model.block) {
        model.block();
    }
}

#pragma mark - Getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [LLFactory getTableView:nil frame:self.view.bounds delegate:self style:UITableViewStylePlain];
        _tableView.bounces = NO;
        _tableView.backgroundColor = [LLThemeManager shared].backgroundColor;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        [_tableView setSeparatorColor:[LLThemeManager shared].primaryColor];
        [_tableView registerClass:[LLTitleSwitchCell class] forCellReuseIdentifier:NSStringFromClass([LLTitleSwitchCell class])];
        [_tableView registerClass:[LLDetailTitleSelectorCell class] forCellReuseIdentifier:NSStringFromClass([LLDetailTitleSelectorCell class])];
        [_tableView registerClass:[LLTitleSliderCell class] forCellReuseIdentifier:NSStringFromClass([LLTitleSliderCell class])];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        }
    }
    return _tableView;
}

@end
