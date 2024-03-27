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

#import "MenuItem.h"

@implementation MenuItem

- (instancetype)initWithName:(NSString *)name
                 description:(NSString *)description
                       price:(NSString *)price
                    category:(NSString *)category
                       photo:(UIImage *)photo {
  self = [self init];
  if (self) {
    _name = [name copy];
    _itemDescription = [description copy];
    _price = [price copy];
    _category = [category copy];
    _photo = photo;
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [self init];
  if (self) {
    _name = [dict[@"name"] copy];
    _itemDescription = [dict[@"description"] copy];
    _price = [dict[@"price"] copy];
    _category = [dict[@"category"] copy];
    _photo = [UIImage imageNamed:dict[@"photo"]];
  }
  return self;
}

@end
