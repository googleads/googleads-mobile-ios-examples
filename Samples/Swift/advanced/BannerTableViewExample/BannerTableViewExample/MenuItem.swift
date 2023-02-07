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

class MenuItem {

  var name: String
  var description: String
  var price: String
  var category: String
  var photo: UIImage

  init(name: String, description: String, price: String, category: String, photo: UIImage) {

    // Initialize stored properties.
    self.name = name
    self.description = description
    self.price = price
    self.category = category
    self.photo = photo
  }

  convenience init?(dictionary: [String: Any]) {

    guard let name = dictionary["name"] as? String,
      let description = dictionary["description"] as? String,
      let price = dictionary["price"] as? String,
      let category = dictionary["category"] as? String,
      let photoFileName = dictionary["photo"] as? String,
      let photo = UIImage(named: photoFileName)
    else {
      return nil
    }

    self.init(name: name, description: description, price: price, category: category, photo: photo)
  }
}
