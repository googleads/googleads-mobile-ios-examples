//
//  Copyright (C) 2015 Google, Inc.
//
//  DFPPPIDViewController.m
//  APIDemo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <CommonCrypto/CommonDigest.h>

#import "DFPPPIDViewController.h"

#import "Constants.h"

/// DFP - PPID
/// Demonstrates adding a Publisher-Provided Identifier (PPID) value to a DFPRequest.
@interface DFPPPIDViewController ()

/// The DFP banner view.
@property(nonatomic, weak) IBOutlet DFPBannerView *bannerView;

/// The user name text field.
@property(nonatomic, weak) IBOutlet UITextField *usernameTextField;

/// Loads an ad.
- (IBAction)loadAd:(id)sender;

/// Handles user taps to hide keyboard.
- (IBAction)screenTapped:(id)sender;

@end

@implementation DFPPPIDViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)loadAd:(id)sender {
  [self.view endEditing:YES];
  if (self.usernameTextField.text.length) {
    self.bannerView.adUnitID = kDFPPPIDAdUnitID;
    self.bannerView.rootViewController = self;

    DFPRequest *request = [DFPRequest request];
    request.publisherProvidedID =
        [self publisherProvidedIdentifierWithString:self.usernameTextField.text];
    [self.bannerView loadRequest:request];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Load Ad Error"
                                   message:@"Failed to load ad. Username is required."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alert show];
  }
}

- (IBAction)screenTapped:(id)sender {
  [self.view endEditing:YES];
}

/// This is a simple method that takes a sample username string and returns an MD5 hash of the
/// username to use as a PPID. It's being used here as a convenient stand-in for a true
/// Publisher-Provided Identifier. In your own apps, you can decide for yourself how to generate the
/// PPID value, though there are some restrictions on what the values can be. For details, see:
///
/// https://support.google.com/dfp_premium/answer/2880055
- (NSString *)publisherProvidedIdentifierWithString:(NSString *)string {
  // Create pointer to the username string as UTF8 string.
  const char *stringAsUTF8String = [string UTF8String];
  // Create byte array of unsigned characters.
  unsigned char MD5Buffer[CC_MD5_DIGEST_LENGTH];
  /// Create 16 byte MD5 hash value.
  CC_MD5(stringAsUTF8String, (CC_LONG)strlen(stringAsUTF8String), MD5Buffer);
  // Convert MD5 value to NSString of hex values.
  NSMutableString *publisherProvidedIdentifier = [[NSMutableString alloc] init];
  for (int i = 0; i < (sizeof(MD5Buffer) / sizeof(MD5Buffer[0])); ++i) {
    [publisherProvidedIdentifier appendFormat:@"%02x", MD5Buffer[i]];
  }
  return publisherProvidedIdentifier;
}

@end
