//
//  Copyright 2026 Google LLC
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

#import "SwipeableInterstitialViewController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GoogleMobileAds_Beta.h>
#import "Constants.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AdLoadState) {
  AdLoadStateIdle,
  AdLoadStateLoading,
  AdLoadStateLoaded,
  AdLoadStateFailed,
};

static NSString *AdLoadStateGetStatusText(AdLoadState state) {
  switch (state) {
    case AdLoadStateIdle:
      return @"";
    case AdLoadStateLoading:
      return @"Ad loading...";
    case AdLoadStateLoaded:
      return @"Ad loaded";
    case AdLoadStateFailed:
      return @"Ad failed to load";
  }
}

static UIColor *AdLoadStateGetStatusColor(AdLoadState state) {
  switch (state) {
    case AdLoadStateIdle:
      return [UIColor clearColor];
    case AdLoadStateLoading:
      return [UIColor systemYellowColor];
    case AdLoadStateLoaded:
      return [UIColor systemGreenColor];
    case AdLoadStateFailed:
      return [UIColor systemRedColor];
  }
}

static NSString *const kContentCellID = @"ContentCell";
static NSString *const kAdCellID = @"AdCell";

@interface ContentSlideCell : UICollectionViewCell
@property(nonatomic, copy, nullable) void (^holdDurationHandler)(NSTimeInterval seconds);
- (void)configureWithHoldSeconds:(NSTimeInterval)holdSeconds
                      statusText:(NSString *)statusText
                     statusColor:(UIColor *)statusColor
                  loadedHoldTime:(nullable NSNumber *)loadedHoldTime;
@end

@implementation ContentSlideCell {
  UIScrollView *_scrollView;
  UIStackView *_stackView;
  UILabel *_titleLabel;
  UILabel *_holdOptionLabel;
  UISegmentedControl *_segmentedControl;
  UILabel *_holdTimeLabel;
  UILabel *_statusLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentView.backgroundColor =
        [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_scrollView];

    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 20;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_stackView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Swipe up to see ad";
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    _titleLabel.adjustsFontForContentSizeCategory = YES;
    _titleLabel.textColor = [UIColor whiteColor];

    _holdOptionLabel = [[UILabel alloc] init];
    _holdOptionLabel.text = @"Requested screen hold duration";
    _holdOptionLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _holdOptionLabel.adjustsFontForContentSizeCategory = YES;
    _holdOptionLabel.textColor = [UIColor whiteColor];

    _segmentedControl = [[UISegmentedControl alloc]
        initWithItems:@[ @"0s", @"5s" ]];
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [_segmentedControl addTarget:self
                          action:@selector(segmentedChanged:)
                forControlEvents:UIControlEventValueChanged];

    UIStackView *toggleRow = [[UIStackView alloc]
        initWithArrangedSubviews:@[ _holdOptionLabel, _segmentedControl ]];
    toggleRow.axis = UILayoutConstraintAxisVertical;
    toggleRow.spacing = 10;
    toggleRow.alignment = UIStackViewAlignmentCenter;

    _holdTimeLabel = [[UILabel alloc] init];
    _holdTimeLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _holdTimeLabel.adjustsFontForContentSizeCategory = YES;
    _holdTimeLabel.textColor = [UIColor whiteColor];

    _statusLabel = [[UILabel alloc] init];
    _statusLabel.font =
        [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _statusLabel.adjustsFontForContentSizeCategory = YES;

    [_stackView addArrangedSubview:_titleLabel];
    [_stackView addArrangedSubview:toggleRow];
    [_stackView addArrangedSubview:_holdTimeLabel];
    [_stackView addArrangedSubview:_statusLabel];

    [NSLayoutConstraint activateConstraints:@[
      [_scrollView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
      [_scrollView.bottomAnchor
          constraintEqualToAnchor:self.contentView.bottomAnchor],
      [_scrollView.leadingAnchor
          constraintEqualToAnchor:self.contentView.leadingAnchor],
      [_scrollView.trailingAnchor
          constraintEqualToAnchor:self.contentView.trailingAnchor],

      [_stackView.centerYAnchor
          constraintEqualToAnchor:_scrollView.centerYAnchor],
      [_stackView.centerXAnchor
          constraintEqualToAnchor:_scrollView.centerXAnchor],
      [_stackView.leadingAnchor
          constraintGreaterThanOrEqualToAnchor:_scrollView.leadingAnchor
                                      constant:16],
      [_stackView.trailingAnchor
          constraintLessThanOrEqualToAnchor:_scrollView.trailingAnchor
                                   constant:-16]
    ]];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.holdDurationHandler = nil;
}

- (void)segmentedChanged:(UISegmentedControl *)sender {
  NSArray<NSNumber *> *seconds = @[ @0.0, @5.0 ];
  if (sender.selectedSegmentIndex >= 0 &&
      sender.selectedSegmentIndex < (NSInteger)seconds.count) {
    if (self.holdDurationHandler) {
      NSTimeInterval sec =
          (NSTimeInterval)seconds[sender.selectedSegmentIndex].doubleValue;
      self.holdDurationHandler(sec);
    }
  }
}

- (void)configureWithHoldSeconds:(NSTimeInterval)holdSeconds
                      statusText:(NSString *)statusText
                     statusColor:(UIColor *)statusColor
                  loadedHoldTime:(nullable NSNumber *)loadedHoldTime {
  NSArray<NSNumber *> *seconds = @[ @0.0, @5.0 ];
  NSInteger index = [seconds indexOfObject:@(holdSeconds)];
  _segmentedControl.selectedSegmentIndex = (index != NSNotFound) ? index : 0;

  if (loadedHoldTime) {
    _holdTimeLabel.text =
        [NSString stringWithFormat:@"Loaded hold time: %ld s",
                                   (long)loadedHoldTime.integerValue];
  } else {
    _holdTimeLabel.text = @" ";
  }
  _holdTimeLabel.hidden = NO;

  _statusLabel.text = statusText;
  _statusLabel.textColor = statusColor;
}

@end

@interface AdSlideCell : UICollectionViewCell
- (void)configureWithAd:(nullable GADSwipeableInterstitialAd *)ad
     rootViewController:(nullable UIViewController *)rootViewController;
@end

@implementation AdSlideCell {
  UIView *_Nullable _currentAdView;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentView.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  if (_currentAdView && _currentAdView.superview == self.contentView) {
    [_currentAdView removeFromSuperview];
  }
  _currentAdView = nil;
}

- (void)configureWithAd:(nullable GADSwipeableInterstitialAd *)ad
     rootViewController:(nullable UIViewController *)rootViewController {
  if (_currentAdView && _currentAdView != ad.adView) {
    [_currentAdView removeFromSuperview];
    _currentAdView = nil;
  }

  if (ad) {
    if (ad.adView) {
      _currentAdView = ad.adView;
      if (_currentAdView.superview != self.contentView) {
        [_currentAdView removeFromSuperview];
        [self.contentView insertSubview:_currentAdView atIndex:0];
        _currentAdView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
          [_currentAdView.topAnchor
              constraintEqualToAnchor:self.contentView.topAnchor],
          [_currentAdView.bottomAnchor
              constraintEqualToAnchor:self.contentView.bottomAnchor],
          [_currentAdView.leadingAnchor
              constraintEqualToAnchor:self.contentView.leadingAnchor],
          [_currentAdView.trailingAnchor
              constraintEqualToAnchor:self.contentView.trailingAnchor]
        ]];
      }
      ad.rootViewController = rootViewController;
    } else {
      NSLog(@"Error: swipeable interstitial adView is nil.");
    }
  }
}

@end

@interface SwipeableInterstitialViewController () <
    GADSwipeableInterstitialAdDelegate, GADVideoControllerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation SwipeableInterstitialViewController {
  UICollectionView *_collectionView;
  GADSwipeableInterstitialAd *_Nullable _swipeableInterstitialAd;
  AdLoadState _adLoadState;
  UIButton *_backButton;
  NSTimeInterval _requestedMaxScreenHoldSeconds;
  BOOL _isScrollDisabled;
  NSInteger _scrolledID;
  NSTimer *_Nullable _holdTimer;
  NSDate *_Nullable _holdStartTime;
  NSTimeInterval _holdDuration;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appDidBecomeActive)
             name:UIApplicationDidBecomeActiveNotification
           object:nil];

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  layout.minimumLineSpacing = 0;
  layout.minimumInteritemSpacing = 0;

  _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                       collectionViewLayout:layout];
  _collectionView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _collectionView.backgroundColor = [UIColor blackColor];
  _collectionView.pagingEnabled = YES;
  _collectionView.showsVerticalScrollIndicator = NO;
  _collectionView.dataSource = self;
  _collectionView.delegate = self;

  if (@available(iOS 11.0, *)) {
    _collectionView.contentInsetAdjustmentBehavior =
        UIScrollViewContentInsetAdjustmentNever;
  }

  [_collectionView registerClass:[ContentSlideCell class]
      forCellWithReuseIdentifier:kContentCellID];
  [_collectionView registerClass:[AdSlideCell class]
      forCellWithReuseIdentifier:kAdCellID];

  [self.view addSubview:_collectionView];

  _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_backButton setTitle:@"< Back" forState:UIControlStateNormal];
  _backButton.titleLabel.font =
      [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
  [_backButton setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
  [_backButton addTarget:self
                  action:@selector(backTapped:)
        forControlEvents:UIControlEventTouchUpInside];
  _backButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_backButton];

  [NSLayoutConstraint activateConstraints:@[
    [_backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                          constant:50],
    [_backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                              constant:20]
  ]];

  _adLoadState = AdLoadStateIdle;
  _requestedMaxScreenHoldSeconds = 0;
  _scrolledID = 0;
  [self reloadAd];
}

- (void)backTapped:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)appDidBecomeActive {
  [self checkScreenHoldOnReturn];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_holdTimer invalidate];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)startScreenHoldWithDuration:(NSTimeInterval)duration {
  _isScrollDisabled = YES;
  _collectionView.scrollEnabled = NO;
  _holdStartTime = [NSDate date];
  _holdDuration = duration;
  [_holdTimer invalidate];
  [_collectionView reloadData];

  __weak __typeof__(self) weakSelf = self;
  _holdTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                               repeats:NO
                                                 block:^(NSTimer * _Nonnull timer) {
    __typeof__(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    strongSelf->_isScrollDisabled = NO;
    strongSelf->_collectionView.scrollEnabled = YES;
    strongSelf->_holdStartTime = nil;
    [strongSelf->_collectionView reloadData];
    NSLog(@"Screen hold completed.");
  }];
}

- (void)checkScreenHoldOnReturn {
  if (!_isScrollDisabled || !_holdStartTime) return;
  NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:_holdStartTime];
  if (elapsed >= _holdDuration) {
    [_holdTimer invalidate];
    _isScrollDisabled = NO;
    _collectionView.scrollEnabled = YES;
    _holdStartTime = nil;
    [_collectionView reloadData];
    NSLog(@"Screen hold completed during background/overlay.");
  }
}

- (void)reloadAd {
  if (_adLoadState == AdLoadStateLoading) return;
  [self discardAd];
  _adLoadState = AdLoadStateLoading;
  _isScrollDisabled = YES;
  _collectionView.scrollEnabled = NO;
  [self updateUI];
  [self announceStatus];

  GADRequest *request = [GADRequest request];
  // By default, swipeable interstitial ads match the fullscreen size. If
  // requesting a custom ad size (options.adSize), it must fill at least
  // 60% of the screen size.
  GADSwipeableInterstitialAdOptions *options = nil;
  if (_requestedMaxScreenHoldSeconds > 0.0) {
    options = [[GADSwipeableInterstitialAdOptions alloc] init];
    options.maxScreenHoldDuration = _requestedMaxScreenHoldSeconds;
  }

  __weak __typeof__(self) weakSelf = self;
  [GADSwipeableInterstitialAd
       loadWithAdUnitID:AdUnitIDSwipeableInterstitial
                request:request
                options:options
      completionHandler:^(GADSwipeableInterstitialAd *_Nullable ad,
                          NSError *_Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error) {
          strongSelf->_swipeableInterstitialAd = nil;
          strongSelf->_adLoadState = AdLoadStateFailed;
          NSLog(@"Ad failed to load: %@", error.localizedDescription);
        } else {
          strongSelf->_adLoadState = AdLoadStateLoaded;
          strongSelf->_isScrollDisabled = NO;
          strongSelf->_collectionView.scrollEnabled = YES;
          ad.delegate = strongSelf;
          ad.videoControllerDelegate = strongSelf;
          strongSelf->_swipeableInterstitialAd = ad;
          NSLog(@"Ad loaded.");
        }
        [strongSelf updateUI];
        [strongSelf announceStatus];
      }];
}

- (void)discardAd {
  [_swipeableInterstitialAd.adView removeFromSuperview];
  _swipeableInterstitialAd = nil;
}

- (void)updateUI {
  [_collectionView reloadData];
}

- (void)announceStatus {
  UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,
                                  AdLoadStateGetStatusText(_adLoadState));
}

#pragma mark - GADSwipeableInterstitialAdDelegate

- (void)swipeableInterstitialAdDidRecordImpression:
    (GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad recorded an impression.");
}

- (void)swipeableInterstitialAdDidRecordClick:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad recorded a click.");
}

- (void)swipeableInterstitialAdWillPresentScreen:
    (GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad will present screen.");
}

- (void)swipeableInterstitialAdWillDismissScreen:
    (GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad will dismiss screen.");
}

- (void)swipeableInterstitialAdDidDismissScreen:(GADSwipeableInterstitialAd *)ad {
  NSLog(@"Ad did dismiss screen.");
  [self checkScreenHoldOnReturn];
  [self updateUI];
}

#pragma mark - GADVideoControllerDelegate

- (void)videoControllerDidPlayVideo:(GADVideoController *)videoController {
  // Optional: Pause any app video content when the ad video plays.
  NSLog(@"Video started playing.");
}

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  // Optional: Resume app video content or handle video completion.
  NSLog(@"Video ended.");
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self handleScrollPositionOrder:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self handleScrollPositionOrder:scrollView];
  }
}

- (void)handleScrollPositionOrder:(UIScrollView *)scrollView {
  CGFloat height = scrollView.bounds.size.height;
  if (height <= 0) return;
  NSInteger index = round(scrollView.contentOffset.y / height);
  // Ignore redundant scroll events when snapping back to the same slide
  // after a partial swipe, so we do not restart the hold timer or reload the ad.
  if (index == _scrolledID) return;

  NSInteger previousIndex = _scrolledID;
  _scrolledID = index;
  _backButton.hidden = (_scrolledID % 2 == 1);

  if (index % 2 == 0) {
    [self reloadAd];
  } else if (index % 2 == 1) {
    // When the user scrolls to an ad slide, enforce the screen hold from the response.
    if (previousIndex % 2 == 0 &&
        _swipeableInterstitialAd.minScreenHoldDuration > 0.0) {
      [self startScreenHoldWithDuration:_swipeableInterstitialAd
                                            .minScreenHoldDuration];
    }
  }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item % 2 == 0) {
    ContentSlideCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:kContentCellID
                                  forIndexPath:indexPath];
    NSNumber *loadedHoldTime = nil;
    if (_swipeableInterstitialAd) {
      loadedHoldTime = @((NSInteger)_swipeableInterstitialAd.minScreenHoldDuration);
    }
    [cell configureWithHoldSeconds:_requestedMaxScreenHoldSeconds
                        statusText:AdLoadStateGetStatusText(_adLoadState)
                       statusColor:AdLoadStateGetStatusColor(_adLoadState)
                    loadedHoldTime:loadedHoldTime];
    __weak __typeof__(self) weakSelf = self;
    cell.holdDurationHandler = ^(NSTimeInterval holdSeconds) {
      __typeof__(self) strongSelf = weakSelf;
      if (!strongSelf) return;
      if (strongSelf->_requestedMaxScreenHoldSeconds != holdSeconds) {
        strongSelf->_requestedMaxScreenHoldSeconds = holdSeconds;
        [strongSelf reloadAd];
      }
    };
    return cell;
  } else {
    AdSlideCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:kAdCellID
                                  forIndexPath:indexPath];
    [cell configureWithAd:_swipeableInterstitialAd
       rootViewController:self];
    return cell;
  }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return collectionView.bounds.size;
}

@end

NS_ASSUME_NONNULL_END

// CI Kick
