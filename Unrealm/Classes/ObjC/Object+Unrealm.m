//
//  Object+Unrealm.m
//  Unrealm
//
//  Created by Artur Mkrtchyan on 1/13/20.
//

#import <objc/runtime.h>
#import "Object+Unrealm.h"
@import RealmSwift.Swift;

@implementation RealmSwiftObject (Unrealm)

+ (NSDictionary *)linkingObjectsProperties
{
	return @{};
}

+ (NSArray *)requiredProperties
{
    return @[];
}

+ (void)prepareUnrealm
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = object_getClass((id)self);

		SEL originalSelector = @selector(_getPropertiesWithInstance:);
        SEL swizzledSelector = @selector(_unrealm_getPropertiesWithInstance:);

        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

		BOOL didAddMethod =
            class_addMethod(class,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
	});

}

+ (nullable NSArray<RLMProperty *> *)_unrealm_getPropertiesWithInstance:(__unused id)obj
{
	if ([self isSubclassOfClass:[RealmSwiftClassPermission class]]
		|| [self isSubclassOfClass:[RealmSwiftPermission class]]
		|| [self isSubclassOfClass:[RealmSwiftPermissionRole class]]
		|| [self isSubclassOfClass:[RealmSwiftPermissionUser class]]
		|| [self isSubclassOfClass:[RealmSwiftRealmPermission class]]
		|| [self isSubclassOfClass:[DynamicObject class]]) {
		return [self _unrealm_getPropertiesWithInstance:obj];
	}

	return nil;
}

@end

void prepareUnrealm(void)
{
	[RealmSwiftObject prepareUnrealm];
}

@implementation NSObject(TypeString)
- (NSString *)typeString
{	
	NSString *str = NSStringFromClass([self class]);
	return  str;
}
@end
