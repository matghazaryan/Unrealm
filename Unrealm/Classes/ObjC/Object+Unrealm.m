//
//  Object+Unrealm.m
//  Unrealm
//
//  Created by Artur Mkrtchyan on 1/13/20.
//

#import <objc/runtime.h>
#import "Object+Unrealm.h"
@import Realm.Swift;
@import Realm;

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
        _Pragma("clang diagnostic push")
        _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")
		SEL originalSelector = @selector(_getProperties);
		SEL swizzledSelector = @selector(_unrealm_getProperties);

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
        _Pragma("clang diagnostic pop")
	});

}

+ (nullable NSArray<RLMProperty *> *)_unrealm_getProperties
{
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
