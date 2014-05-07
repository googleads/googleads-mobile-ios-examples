// Copyright (c) 2014 Google. All rights reserved.

#import "InAppPurchaseExampleAppDelegate.h"

#import "GADInAppPurchase.h"

@implementation InAppPurchaseExampleAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

#pragma mark GADInAppPurchaseDelegate implementation

- (void)didReceiveInAppPurchase:(GADInAppPurchase *)purchase {
  NSLog(@"Received event to start in-app purchase for product %@, quantity %lu.",
        purchase.productID, (unsigned long)purchase.quantity);
  self.purchase = purchase;

  // At this point, you can use the purchase information to launch an in-app purchase request to
  // the user. When the transaction is complete, make sure to call reportPurchaseStatus to record
  // the result. Note that reportPurchaseStatus should be called for all results, not just success.

  // In practice, this will be called asychonronously when the purchase is complete. But for this
  // example, we'll demonstrate a success purchase report here.
  [purchase reportPurchaseStatus:kGADInAppPurchaseStatusSuccessful];
}

@end
