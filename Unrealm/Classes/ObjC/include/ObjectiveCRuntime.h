//
//  ObjectiveCRuntime.h
//  Unrealm
//
//  Created by Artur Mkrtchyan on 5/12/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

#import <Foundation/Foundation.h>

Class _Nonnull createClass(NSString * _Nonnull className, Class _Nonnull base);
void addPropertyToClass(Class _Nonnull className, NSString * _Nonnull name, NSString * _Nonnull typeName);
NSString * __nullable propertyClassName(NSString * _Nonnull name, Class _Nonnull className);

void addPrimaryKeyMethodToClass(Class _Nonnull className, NSString * __nullable resultValue);
void addIgnoredPropertiesMethodToClass(Class _Nonnull className, NSArray * _Nonnull ignoredProperties);
void addIndexedPropertiesMethodToClass(Class _Nonnull className, NSArray * _Nonnull ignoredProperties);
void addClassMethodToClass(Class _Nonnull className, NSString * _Nonnull selectorName, id __nullable resultValue);
