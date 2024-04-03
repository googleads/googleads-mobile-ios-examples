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

import UIKit

class MenuItemViewCell: UITableViewCell {

  /// Displays MenuItem's name.
  @IBOutlet weak var nameLabel: UILabel!

  /// Displays MenuItem's description.
  @IBOutlet weak var descriptionLabel: UILabel!

  /// Displays MenuItem's price.
  @IBOutlet weak var priceLabel: UILabel!

  /// Displays MenuItem's category.
  @IBOutlet weak var categoryLabel: UILabel!

  /// Displays MenuItem's photo.
  @IBOutlet weak var photoView: UIImageView!
}
