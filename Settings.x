// Settings.x
// Thanks to the original codes from YTUHD by PoomSmart - https://github.com/PoomSmart/YTUHD/blob/0e735616fd8fc6546339da7fdc78466f16f23ffd/Settings.x

#import <PSHeader/Misc.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/GOOHeaderViewController.h>
#import <YouTubeMusicHeader/YTMSettingsResponseViewController.h>
#import <YouTubeMusicHeader/YTMSettingsSectionController.h>
#import <YouTubeMusicHeader/YTMSettingsSectionItem.h>

#define TweakName @"FLEXHelperForYT"

#define EnablesTweakKey @"FLEXHelperForYTActivateTweak"
#define ShakeKey @"FLEXHelperForYTShakeToActivate"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

static const NSInteger TweakSection = 'fhyt';

@interface YTSettingsSectionItemManager (FLEXHelperForYT)
- (void)updateFLEXHelperForYTSectionWithEntry:(id)entry;
@end

@interface FLEXManager : NSObject
- (void)sharedManager;
- (void)showExplorer;
@end

BOOL EnablesTweak() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnablesTweakKey];
}

BOOL Shake() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:ShakeKey];
}

static NSBundle *FLEXHelperForYTBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:TweakName ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:PS_ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), TweakName]];
    });
    return bundle;
}

static void pushCollectionViewController(YTMSettingsResponseViewController *self, NSString *title, NSMutableArray <YTMSettingsSectionItem *> *settingItems) {
    YTMSettingsResponseViewController *responseVC = [[%c(YTMSettingsResponseViewController) alloc] initWithService:[self valueForKey:@"_service"] parentResponder:self];
    responseVC.title = title;
    YTMSettingCollectionSectionController *scsc = [[%c(YTMSettingCollectionSectionController) alloc] initWithTitle:@"" items:settingItems parentResponder:responseVC];
    [responseVC collectionViewController].sectionControllers = @[scsc];
    GOOHeaderViewController *headerVC = [[%c(GOOHeaderViewController) alloc] initWithContentViewController:responseVC];
    [self.navigationController pushViewController:headerVC animated:YES];
}

static void makeSelecty(YTMSettingsSectionItem *item) {
    item.indicatorIconType = YT_CHEVRON_RIGHT;
    item.inkEnabled = YES;
}

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(TweakSection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(TweakSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateFLEXHelperForYTSectionWithEntry:(id)entry {
    NSMutableArray <YTSettingsSectionItem *> *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = FLEXHelperForYTBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    // Tweak Version (at the top)
    // Thanks to the original codes from YTweaks by fosterbarnes - https://github.com/fosterbarnes/YTweaks/blob/e921591a89b87256a2b37c4788bd99282f70d9c2/Settings.x
    YTSettingsSectionItem *tweakVersion = [YTSettingsSectionItemClass itemWithTitle:@"FLEXHelperForYT v1.1.0"
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return NO;
        }];
    [sectionItems addObject:tweakVersion];

    // Auto activates FLEX
    YTSettingsSectionItem *enablesTweak = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"AUTO_ACTIVATE")
        titleDescription:LOC(@"AUTO_ACTIVATE_DESC")
        accessibilityIdentifier:nil
        switchOn:EnablesTweak()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnablesTweakKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:enablesTweak];

    // Shake to activates FLEX
    YTSettingsSectionItem *shake = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"SHAKE_TO_ACTIVATE")
        titleDescription:LOC(@"SHAKE_TO_ACTIVATE_DESC")
        accessibilityIdentifier:nil
        switchOn:Shake()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ShakeKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:shake];

    // Activate FLEX
    YTSettingsSectionItem *activate = [YTSettingsSectionItemClass itemWithTitle:LOC(@"ACTIVATE")
        titleDescription:LOC(@"ACTIVATE_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
        }
    ];
    [sectionItems addObject:activate];

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_SETTINGS;
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName icon:icon titleDescription:nil headerHidden:NO];
    } else
        [settingsViewController setSectionItems:sectionItems forCategory:TweakSection title:TweakName titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == TweakSection) {
        [self updateFLEXHelperForYTSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

// Adapted from YTMABConfig (https://github.com/PoomSmart/YTMABConfig)
%hook YTMSettingsResponseViewController

- (NSArray <YTMSettingsSectionController *> *)sectionControllersFromSettingsResponse:(id)response {
    Class YTMSettingsSectionItemClass = %c(YTMSettingsSectionItem);
    NSBundle *tweakBundle = FLEXHelperForYTBundle();
    NSMutableArray <YTMSettingsSectionController *> *newSectionControllers = [NSMutableArray arrayWithArray:%orig];
    YTMSettingsSectionItem *settingMenuItem = [%c(YTMSettingsSectionItem) itemWithTitle:TweakName accessibilityIdentifier:nil detailTextBlock:nil selectBlock:nil];
    makeSelecty(settingMenuItem);
    settingMenuItem.selectBlock = ^BOOL(YTSettingsCell *cell, NSUInteger arg1) {
        NSMutableArray <YTMSettingsSectionItem *> *settingItems = [NSMutableArray new];

        // Tweak Version (at the top)
        YTMSettingsSectionItem *tweakVersion = [YTMSettingsSectionItemClass itemWithTitle:@"FLEXHelperForYT v1.1.0"
            titleDescription:nil
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:nil];
        [settingItems insertObject:tweakVersion atIndex:0];

        // Auto activates FLEX
        YTMSettingsSectionItem *enablesTweak = [YTMSettingsSectionItemClass switchItemWithTitle:LOC(@"AUTO_ACTIVATE")
            titleDescription:LOC(@"AUTO_ACTIVATE_DESC")
            accessibilityIdentifier:nil
            switchOn:EnablesTweak()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnablesTweakKey];
                return YES;
            }
            settingItemId:0];
        [settingItems insertObject:enablesTweak atIndex:0];

        // Shake to activates FLEX
        YTMSettingsSectionItem *shake = [YTMSettingsSectionItemClass switchItemWithTitle:LOC(@"SHAKE_TO_ACTIVATE")
            titleDescription:LOC(@"SHAKE_TO_ACTIVATE_DESC")
            accessibilityIdentifier:nil
            switchOn:Shake()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ShakeKey];
                return YES;
            }
            settingItemId:0];
        [settingItems insertObject:shake atIndex:0];

        // Activate FLEX
        YTMSettingsSectionItem *activate = [YTMSettingsSectionItemClass itemWithTitle:LOC(@"ACTIVATE")
            titleDescription:LOC(@"ACTIVATE_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                return [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
            }
        ];
        [settingItems insertObject:activate atIndex:0];

        pushCollectionViewController(self, TweakName, settingItems);
        return YES;
    };
    YTMSettingsSectionController *settings = [[%c(YTMSettingsSectionController) alloc] initWithTitle:@"" items:@[settingMenuItem] parentResponder:[self parentResponder]];
    settings.categoryID = 'fhyt';
    [newSectionControllers insertObject:settings atIndex:0];
    return newSectionControllers;
}

%end