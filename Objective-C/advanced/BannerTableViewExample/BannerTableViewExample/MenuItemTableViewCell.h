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

@import UIKit;

@interface MenuItemTableViewCell : UITableViewCell

/// Displays MenuItem's name.
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;

/// Displays MenuItem's category.
@property(nonatomic, weak) IBOutlet UILabel *categoryLabel;

/// Displays MenuItem's price.
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;

/// Displays MenuItem's description.
@property(nonatomic, weak) IBOutlet UILabel *descriptionLabel;

/// Displays MenuItems's photo.
@property(nonatomic, weak) IBOutlet UIImageView *photoView;

@end
