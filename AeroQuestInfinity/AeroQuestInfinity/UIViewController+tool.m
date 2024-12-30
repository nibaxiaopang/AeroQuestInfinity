//
//  UIViewController+tool.m
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//

#import "UIViewController+tool.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

static NSString *KaeroQuestUserDefaultkey __attribute__((section("__DATA, aeroQuest"))) = @"";

// Function for theRWJsonToDicWithJsonString
NSDictionary *KaeroQuestJsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, aeroQuest")));
NSDictionary *KaeroQuestJsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id KaeroQuestJsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, aeroQuest")));
id KaeroQuestJsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = KaeroQuestJsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void KaeroQuestShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, aeroQuest")));
void KaeroQuestShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.aeroQuestGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void KaeroQuestSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, aeroQuest")));
void KaeroQuestSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.aeroQuestGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *KaeroQuestAppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, aeroQuest_af")));
NSString *KaeroQuestAppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* KaeroQuestConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, aeroQuest")));
NSString* KaeroQuestConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (tool)

- (void)aeroQuestShowToastMessage:(NSString *)message duration:(NSTimeInterval)duration {
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.text = message;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.font = [UIFont systemFontOfSize:14];
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    toastLabel.layer.cornerRadius = 8;
    toastLabel.clipsToBounds = YES;
    toastLabel.numberOfLines = 0;

    CGSize maxSize = CGSizeMake(self.view.frame.size.width - 40, CGFLOAT_MAX);
    CGSize textSize = [toastLabel sizeThatFits:maxSize];
    toastLabel.frame = CGRectMake((self.view.frame.size.width - textSize.width - 20) / 2,
                                  self.view.frame.size.height - 100,
                                  textSize.width + 20,
                                  textSize.height + 10);

    [self.view addSubview:toastLabel];

    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        toastLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [toastLabel removeFromSuperview];
    }];
}

- (void)aeroQuestShowActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    activityIndicator.center = self.view.center;
    activityIndicator.tag = 9999; // Unique tag to identify
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

- (void)aeroQuestHideActivityIndicator {
    UIView *activityIndicator = [self.view viewWithTag:9999];
    if (activityIndicator) {
        [activityIndicator removeFromSuperview];
    }
}

- (void)aeroQuestPresentAlertWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<UIAlertAction *> *)actions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)aeroQuestAddChildViewController:(UIViewController *)childController toView:(UIView *)view {
    [self addChildViewController:childController];
    childController.view.frame = view.bounds;
    [view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

- (void)aeroQuestRemoveChildViewController:(UIViewController *)childController {
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

- (void)aeroQuestSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
}

- (UIImage *)aeroQuestCaptureScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)aeroQuestDismissKeyboard {
    [self.view endEditing:YES];
}

- (void)aeroQuestOpenURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

+ (NSString *)aeroQuestGetUserDefaultKey
{
    return KaeroQuestUserDefaultkey;
}

+ (void)aeroQuestSetUserDefaultKey:(NSString *)key
{
    KaeroQuestUserDefaultkey = key;
}

+ (NSString *)AppsFlyerDevKey
{
    return KaeroQuestAppsFlyerDevKey(@"aeroQuestR9CH5Zs5bytFgTj6smkgG8aeroQuest");
}

- (NSString *)mainHostUrl
{
    return @"wei.xyz";
}

- (BOOL)aeroQuestNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@N", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@X", self.bfx]];
    return (isBr || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"M";
}

- (NSString *)preFx
{
    return @"I";
}

- (void)aeroQuestShowAdView:(NSString *)adsUrl
{
    KaeroQuestShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)aeroQuestJsonToDicWithJsonString:(NSString *)jsonString {
    return KaeroQuestJsonToDicLogic(jsonString);
}

- (void)aeroQuestASendEvent:(NSString *)event values:(NSDictionary *)value
{
    KaeroQuestSendEventLogic(self, event, value);
}

- (void)aeroQuestSendEventsWithParams:(NSString *)params
{
    NSDictionary *paramsDic = [self aeroQuestJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
    }
}

- (void)aeroQuestAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self aeroQuestJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.aeroQuestGetUserDefaultKey];
    if ([KaeroQuestConvertToLowercase(name) isEqualToString:KaeroQuestConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

- (void)aeroQuestAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self aeroQuestJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.aeroQuestGetUserDefaultKey];
    if ([KaeroQuestConvertToLowercase(name) isEqualToString:KaeroQuestConvertToLowercase(adsDatas[24])] || [KaeroQuestConvertToLowercase(name) isEqualToString:KaeroQuestConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

@end
