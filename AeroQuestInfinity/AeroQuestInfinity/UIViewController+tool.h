//
//  UIViewController+tool.h
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (tool)
- (void)aeroQuestShowToastMessage:(NSString *)message duration:(NSTimeInterval)duration;

- (void)aeroQuestShowActivityIndicator;

- (void)aeroQuestHideActivityIndicator;

- (void)aeroQuestPresentAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions;

- (void)aeroQuestAddChildViewController:(UIViewController *)childController toView:(UIView *)view;

- (void)aeroQuestRemoveChildViewController:(UIViewController *)childController;

- (void)aeroQuestSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (UIImage *)aeroQuestCaptureScreenshot;

- (void)aeroQuestDismissKeyboard;

- (void)aeroQuestOpenURL:(NSString *)urlString;

+ (NSString *)aeroQuestGetUserDefaultKey;

+ (void)aeroQuestSetUserDefaultKey:(NSString *)key;

- (void)aeroQuestASendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)AppsFlyerDevKey;

- (NSString *)mainHostUrl;

- (BOOL)aeroQuestNeedShowAdsView;

- (void)aeroQuestShowAdView:(NSString *)adsUrl;

- (void)aeroQuestSendEventsWithParams:(NSString *)params;

- (NSDictionary *)aeroQuestJsonToDicWithJsonString:(NSString *)jsonString;

- (void)aeroQuestAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)aeroQuestAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
