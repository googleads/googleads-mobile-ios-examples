//
//  Copyright 2021 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MainViewController.h"

#import "GoogleMobileAdsConsentManager.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.privacySettingsButton.enabled =
      GoogleMobileAdsConsentManager.sharedInstance.isPrivacyOptionsRequired;
}

- (IBAction)privacySettingsTapped:(UIBarButtonItem *)sender {
  [GoogleMobileAdsConsentManager.sharedInstance
      presentPrivacyOptionsFormFromViewController:self
                                completionHandler:^(NSError *_Nullable formError) {
                                  if (formError) {
                                    UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:formError.localizedDescription
                                                         message:@"Please try again later."
                                                  preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *defaultAction =
                                        [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction *action){
                                                               }];

                                    [alertController addAction:defaultAction];
                                    [self presentViewController:alertController
                                                       animated:YES
                                                     completion:nil];
                                  }
                                }];
}

@end
