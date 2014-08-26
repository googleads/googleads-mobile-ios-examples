// Copyright (c) 2014 Google. All rights reserved.

#import "GADBannerView.h"
#import "GADRequest.h"

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Replace this ad unit ID with your own ad unit ID.
  self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
  self.bannerView.rootViewController = self;

  GADRequest *request = [GADRequest request];
  // Requests test ads on devices you specify. Your test device ID is printed to the console when
  // an ad request is made.
  request.testDevices = @[ GAD_SIMULATOR_ID, @"MY_TEST_DEVICE_ID" ];
  [self.bannerView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
