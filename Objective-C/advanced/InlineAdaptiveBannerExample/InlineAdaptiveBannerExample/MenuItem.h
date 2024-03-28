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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MenuItem : NSObject

/// The name of the MenuItem.
@property(nonatomic, copy) NSString *name;

/// The description of the MenuItem.
@property(nonatomic, copy) NSString *itemDescription;

/// The price of the MenuItem.
@property(nonatomic, copy) NSString *price;

/// The category of the MenuItem.
@property(nonatomic, copy) NSString *category;

/// The photo of the MenuItem.
@property(nonatomic, strong) UIImage *photo;

/// Initializes and returns the MenuItem.
- (instancetype)initWithName:(NSString *)name
                 description:(NSString *)description
                       price:(NSString *)price
                    category:(NSString *)category
                       photo:(UIImage *)photo;

/// Initializes from a NSDictionary and returns the MenuItem.
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
