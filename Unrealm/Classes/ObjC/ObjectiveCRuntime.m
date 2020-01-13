//
//  ObjectiveCRuntime.m
//  Unrealm
//
//  Created by Artur Mkrtchyan on 5/12/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

#import "ObjectiveCRuntime.h"
@import ObjectiveC.runtime;

@interface NSString (CapitalizeFirst)
- (NSString *)capitalizeFirst;
- (NSString *)deCapitalizeFirst;
@end

@implementation NSString (CapitalizeFirst)
- (NSString *)capitalizeFirst {
    if ( self.length <= 1 ) {
        return [self uppercaseString];
    }
    
    return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

- (NSString *)deCapitalizeFirst {
    if ( self.length <= 1 ) {
        return [self lowercaseString];
    }
    
    return [[[self substringToIndex:1] lowercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

- (NSString *)removeLastChar {
    return [self substringToIndex:self.length - 1];
}

@end

id propertyGetter(id self, SEL _cmd) {
    NSString *ivarName = [NSString stringWithFormat:@"_%@", NSStringFromSelector(_cmd)];
    return objc_getAssociatedObject(self, NSSelectorFromString(ivarName));
}

void propertySetter(id self, SEL _cmd, id value) {
    NSString *propertyName = [[[NSStringFromSelector(_cmd) substringFromIndex:3] deCapitalizeFirst] removeLastChar];
    NSString *ivarName = [NSString stringWithFormat:@"_%@", propertyName];
    objc_setAssociatedObject(self, NSSelectorFromString(ivarName), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

Class createClass(NSString * _Nonnull className, Class _Nonnull base) {
    Class class =  objc_allocateClassPair(base, [className UTF8String], 0);
    objc_registerClassPair(class);
    [class load];
    return class;
}

void addPropertyToClass(Class className, NSString *name, NSString *typeName) {
    NSString *ivarName = [NSString stringWithFormat:@"_%@", name];
    
    id typeStr;
    if (typeName.length > 1) {
        typeStr = [NSString stringWithFormat:@"@\"%@\"", typeName];
    } else {
        typeStr = typeName;
    }
    
    objc_property_attribute_t type = { "T", [typeStr UTF8String]};
    objc_property_attribute_t backingIvar = { "V", [ivarName UTF8String]};
    objc_property_attribute_t dynamic = { "D", ""};
    objc_property_attribute_t nonAtomic = { "N", ""};
    objc_property_attribute_t and = { "&", ""};
    objc_property_attribute_t attrs[] = { type, dynamic, nonAtomic, backingIvar, and };
    if (!class_addProperty(className, [name UTF8String], attrs, 5)) {
        return;
    }
    
    class_addMethod(className, NSSelectorFromString(name), (IMP)propertyGetter, "@@:");
    
    
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [name capitalizeFirst]]);
    class_addMethod(className, setter, (IMP)propertySetter, "v@:@");        
}

NSString * __nullable propertyClassName(NSString *name, Class className) {
    NSString *returnValue;
    unsigned int pCount;
    objc_property_t *properties = class_copyPropertyList(className, &pCount);
    for (int i = 0; i < pCount; i++) {
        objc_property_t property = properties[i];
        NSString *pName = [NSString stringWithUTF8String: property_getName(property)];
        if ([pName isEqualToString:name]) {
            unsigned int count;
            objc_property_attribute_t *attrs = property_copyAttributeList(property, &count);
            for (size_t i = 0; i < count; ++i) {
                switch (*attrs[i].name) {
                    case 'T': {
                        NSString *cName = [NSString stringWithUTF8String:attrs[i].value];
                        cName = [cName stringByReplacingOccurrencesOfString:@"@" withString:@""];
                        cName = [cName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        returnValue = cName;
                        break;
                    }
                    default:
                        break;
                }
            }
            free(attrs);
            break;
        }
    }
    free(properties);
    return returnValue;
}


#pragma mark - Class method additions

void addPrimaryKeyMethodToClass(Class _Nonnull className, NSString * __nullable resultValue) {
    Class class = object_getClass(className);
    IMP imp = imp_implementationWithBlock(^{
        return resultValue;
    });
    class_addMethod(class, NSSelectorFromString(@"primaryKey"), imp, nil);
}

void addIgnoredPropertiesMethodToClass(Class _Nonnull className, NSArray * _Nonnull ignoredProperties) {
    Class class = object_getClass(className);
    IMP imp = imp_implementationWithBlock(^{
        return ignoredProperties;
    });
    class_addMethod(class, NSSelectorFromString(@"ignoredProperties"), imp, nil);}

void addIndexedPropertiesMethodToClass(Class _Nonnull className, NSArray * _Nonnull ignoredProperties) {
    Class class = object_getClass(className);
    IMP imp = imp_implementationWithBlock(^{
        return ignoredProperties;
    });
    class_addMethod(class, NSSelectorFromString(@"indexedProperties"), imp, nil);
}

void addClassMethodToClass(Class _Nonnull className, NSString * _Nonnull selectorName, id __nullable resultValue) {
    Class class = object_getClass(className);
    IMP imp = imp_implementationWithBlock(^{
        return resultValue;
    });
    class_addMethod(class, NSSelectorFromString(selectorName), imp, nil);
}
