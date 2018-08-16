//
//  Copyright (C) 2016 Google, Inc.
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

#import "TableViewController.h"

#import "MenuItem.h"
#import "MenuItemTableViewCell.h"

static NSString *const GADAdUnitID = @"ca-app-pub-3940256099942544/2934735716";
static const CGFloat GADAdViewHeight = 100;

@interface TableViewController () <GADBannerViewDelegate> {
  /// UITableView source items.
  NSMutableArray *_tableViewItems;
  /// List of ads remaining to be preloaded.
  NSMutableArray<GADBannerView *> *_adsToLoad;
  /// Mapping of GADBannerView ads to their load state.
  NSMutableDictionary<NSString *, NSNumber *> *_loadStateForAds;
  /// A banner ad is placed in the UITableView once per adInterval.
  NSInteger _adInterval;
}
@end

@implementation TableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _tableViewItems = [[NSMutableArray alloc] init];
  _adsToLoad = [[NSMutableArray alloc] init];
  _loadStateForAds = [[NSMutableDictionary alloc] init];

  // A banner ad is placed in the UITableView once per adInterval. iPads will have a
  // larger ad interval to avoid mutliple ads being on screen at the same time.
  _adInterval = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 16 : 8;

  [self.tableView registerNib:[UINib nibWithNibName:@"MenuItem" bundle:nil]
       forCellReuseIdentifier:@"MenuItemViewCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"BannerAd" bundle:nil]
       forCellReuseIdentifier:@"GADBannerViewCell"];

  // Allow row height to be determined dynamically while optimizing with an estimated row height.
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 135;

  // Load the sample data.
  [self addMenuItems];
  [self addBannerAds];
  [self preloadNextAd];
}

// Return string containing memory address location of a GADBannerView to be used to
// uniquely identify the object.
- (NSString *)referenceKeyForAdView:(GADBannerView *)adView {
  return [[NSString alloc] initWithFormat:@"%p", adView];
}

// MARK: - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _tableViewItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_tableViewItems[indexPath.row] isKindOfClass:[GADBannerView class]]) {
    GADBannerView *adView = _tableViewItems[indexPath.row];
    BOOL isLoaded = [_loadStateForAds[[self referenceKeyForAdView:adView]] boolValue];
    return isLoaded ? GADAdViewHeight : 0;
  }

  return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_tableViewItems[indexPath.row] isKindOfClass:[GADBannerView class]]) {
    UITableViewCell *reusableAdCell =
        [self.tableView dequeueReusableCellWithIdentifier:@"GADBannerViewCell"
                                             forIndexPath:indexPath];

    // Remove previous GADBannerView from the content view before adding a new one.
    for (UIView *subview in reusableAdCell.contentView.subviews) {
      [subview removeFromSuperview];
    }

    GADBannerView *adView = _tableViewItems[indexPath.row];
    [reusableAdCell.contentView addSubview:adView];
    // Center GADBannerView in the table cell's content view.
    adView.center = reusableAdCell.contentView.center;

    return reusableAdCell;
  } else {
    MenuItem *menuItem = _tableViewItems[indexPath.row];
    MenuItemTableViewCell *reusableMenuItemCell =
        [self.tableView dequeueReusableCellWithIdentifier:@"MenuItemViewCell"
                                             forIndexPath:indexPath];

    reusableMenuItemCell.nameLabel.text = menuItem.name;
    reusableMenuItemCell.descriptionLabel.text = menuItem.itemDescription;
    reusableMenuItemCell.priceLabel.text = menuItem.price;
    reusableMenuItemCell.categoryLabel.text = menuItem.category;
    reusableMenuItemCell.photoView.image = menuItem.photo;

    return reusableMenuItemCell;
  }
}

// MARK: - GADBannerView delegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  // Mark banner ad as succesfully loaded.
  _loadStateForAds[[self referenceKeyForAdView:bannerView]] = @YES;
  // Load the next ad in the adsToLoad list.
  [self preloadNextAd];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad: %@", error.localizedDescription);
  // Load the next ad in the adsToLoad list.
  [self preloadNextAd];
}

// MARK: - UITableView source data generation

/// Adds banner ads to the tableViewItems list.
- (void)addBannerAds {
  NSInteger index = _adInterval;
  // Ensure subview layout has been performed before accessing subview sizes.
  [self.tableView layoutIfNeeded];

  while (index < _tableViewItems.count) {
    GADBannerView *adView = [[GADBannerView alloc]
        initWithAdSize:GADAdSizeFromCGSize(
                           CGSizeMake(self.tableView.contentSize.width, GADAdViewHeight))];
    adView.adUnitID = GADAdUnitID;
    adView.rootViewController = self;
    adView.delegate = self;

    [_tableViewItems insertObject:adView atIndex:index];
    [_adsToLoad addObject:adView];
    _loadStateForAds[[self referenceKeyForAdView:adView]] = @NO;

    index += _adInterval;
  }
}

/// Preloads banner ads sequentially. Dequeues and loads next ad from adsToLoad list.
- (void)preloadNextAd {
  if (!_adsToLoad.count) {
    return;
  }
  GADBannerView *adView = _adsToLoad.firstObject;
  [_adsToLoad removeObjectAtIndex:0];
  GADRequest *request = [GADRequest request];
  request.testDevices = @[ kGADSimulatorID ];
  [adView loadRequest:request];
}

/// Parse menuItemsJSON.json file and populate MenuItems in the tableViewItems list.
- (void)addMenuItems {
  NSError *error = nil;
  NSString *JSONPath = [[NSBundle mainBundle] pathForResource:@"menuItemsJSON" ofType:@"json"];
  NSData *JSONData = [NSData dataWithContentsOfFile:JSONPath options:0 error:&error];
  if (error) {
    NSLog(@"Failed to parse JSON file containing menu item data with error: %@", error);
    return;
  }
  NSArray *JSONArray = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
  if (error) {
    NSLog(@"Failed to load menu item JSON data with error: %@", error);
    return;
  }

  // Create custom objects from JSON array.
  for (NSDictionary *dict in JSONArray) {
    MenuItem *menuIem = [[MenuItem alloc] initWithDictionary:dict];
    [_tableViewItems addObject:menuIem];
  }
}

@end
