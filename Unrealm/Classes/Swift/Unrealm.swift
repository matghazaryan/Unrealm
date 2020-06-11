//
//  Unrealm.swift
//  Unrealm
//
//  Created by Artur Mkrtchyan on 4/28/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RuntimeNew

public typealias Realm = RealmSwift.Realm
public typealias NotificationToken = RealmSwift.NotificationToken

#if canImport(UnrealmObjC)
import UnrealmObjC
#endif

internal var objectsAndRealmables: [String:RealmableBase.Type] = [:]
internal var enumsAndRealmables: [String:RealmableEnum.Type] = [:]

public protocol RealmableEnum {
    func rlmValue() -> Any
    init?(rlmValue: Any)
	static var rawValueType: Any.Type { get }
}

public protocol RealmableEnumInt: RealmableEnum {}
public protocol RealmableEnumString: RealmableEnum {}

public extension RealmableEnum where Self : RawRepresentable {
    func rlmValue() -> Any {
        return rawValue
    }
    
    init?(rlmValue: Any) {
        guard let rawVal = rlmValue as? Self.RawValue else {return nil}
        self.init(rawValue: rawVal)
    }

	static var rawValueType: Any.Type {
		return Self.RawValue.self
	}
}

extension Array where Element: RealmableEnum {
	var elementType: Any.Type {
		return Element.rawValueType
	}
}

extension Optional where Wrapped: RealmableEnum {
    
}

extension Optional: RealmableBase where Wrapped: RealmableBase {
    public mutating func readValues(from obj: Object) {
        var tmp = Wrapped.init()
        tmp.readValues(from: obj)
        self = tmp
    }
    
    public func toObject() -> Object? {
        switch self {
        case .none:
            return nil
        case .some(let wrapped):
            return wrapped.toObject()
        }
    }
    
    public init() {
        self = Wrapped.init()
    }
}

public protocol OptionalPrtc {
    var val: Any {get}
	var type: Any.Type {get}
}

extension Optional: OptionalPrtc {
    public var val: Any {
        switch self {
        case .none:
            return NSNull()
        case .some(let wrapped):
            return wrapped
        }
    }

	public var type: Any.Type {
	    return Wrapped.self
	}
}

public protocol RealmableBase {
    mutating func readValues(from obj: Object)
    func toObject() -> Object?
    static var realmClassPrefix: String {get}
    static func className() -> String

    /**
     Implement this method to specify the name of a property to be used as the primary key.
     
     Only properties of types `String` and `Int` can be designated as the primary key. Primary key properties enforce
     uniqueness for each value whenever the property is set, which incurs minor overhead. Indexes are created
     automatically for primary key properties.
     
     - returns: The name of the property designated as the primary key, or `nil` if the model has no primary key.
     */
    static func primaryKey() -> String?
    
    /**
     Implement this method to specify the names of properties to ignore. These properties will not be managed by
     the Realm that manages the object.
     
     - returns: An array of property names to ignore.
     */
    static func ignoredProperties() -> [String]
    
    /**
     Returns an array of property names for properties which should be indexed.
     
     Only string, integer, boolean, `Date`, and `NSDate` properties are supported.
     
     - returns: An array of property names.
     */
    static func indexedProperties() -> [String]

    init()
}

public extension RealmableBase {
    static var realmClassPrefix: String {
        return "RLM"
    }

	static func className() -> String {
		let typeName = exctractTypeComponents(from: self).1
		return realmClassPrefix + typeName
	}
    
    func objectType() -> Object.Type? {
        var className = ""
        for key in objectsAndRealmables.keys {
            if objectsAndRealmables[key] == type(of: self) {
                className = key
                break
            }
        }
        
        guard !className.isEmpty else {
            fatalError("Make sure you've registered type '\(type(of: self))'")
        }
        
        guard let cls = NSClassFromString(className) as? Object.Type else {return nil}
        return cls
    }
    
	static func objectType() -> Object.Type? {
        var className = ""
        for key in objectsAndRealmables.keys {
            if objectsAndRealmables[key] == self {
                className = key
                break
            }
        }
        
        guard !className.isEmpty else {
            fatalError("Make sure you've registered type '\(type(of: self))'")
        }
        
        guard let cls = NSClassFromString(className) as? Object.Type else {return nil}
        return cls
    }
}

fileprivate struct StoredVarKeys {
    static var realmKey = "_realmKey"
}

public extension RealmableBase {
    var realm: Realm? {
        get {
            return objc_getAssociatedObject(self, &StoredVarKeys.realmKey) as? Realm
        }
    }
    
    static func primaryKey() -> String? {
        return nil
    }
    
    internal func setRealm(_ realm: Realm?) {
        objc_setAssociatedObject(self, &StoredVarKeys.realmKey, realm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    static func ignoredProperties() -> [String] { return [] }
    static func indexedProperties() -> [String] { return [] }
}

public extension RealmableBase {
    /**
     Registers a block to be called each time the object changes.
     
     The block will be asynchronously called after each write transaction which
     deletes the object or modifies any of the managed properties of the object,
     including self-assignments that set a property to its existing value.
     
     For write transactions performed on different threads or in different
     processes, the block will be called when the managing Realm is
     (auto)refreshed to a version including the changes, while for local write
     transactions it will be called at some point in the future after the write
     transaction is committed.
     
     Notifications are delivered via the standard run loop, and so can't be
     delivered while the run loop is blocked by other activity. When
     notifications can't be delivered instantly, multiple notifications may be
     coalesced into a single notification.
     
     Unlike with `List` and `Results`, there is no "initial" callback made after
     you add a new notification block.
     
     Only objects which are managed by a Realm can be observed in this way. You
     must retain the returned token for as long as you want updates to be sent
     to the block. To stop receiving updates, call `invalidate()` on the token.
     
     It is safe to capture a strong reference to the observed object within the
     callback block. There is no retain cycle due to that the callback is
     retained by the returned token and not by the object itself.
     
     - warning: This method cannot be called during a write transaction, or when
     the containing Realm is read-only.
     
     - parameter block: The block to call with information about changes to the object.
     - returns: A token which must be held for as long as you want updates to be delivered.
     */
	func observe(_ block: @escaping (ObjectChange<Object>) -> Void) -> NotificationToken {
        guard let info = try? typeInfo(of: type(of: self)), info.kind == .class else {
            fatalError("Unrealm: Only class instances can observe for changes")
        }
        
        guard let rlmDBObject = self.toObject() else {
            fatalError("Unrealm: Could not convert \(type(of: self)) to RealmSwift.Object")
        }
        
        guard let objectType = objectType() else {
            fatalError()
        }
        
        guard let primaryKeyName = type(of: self).primaryKey() else {
            fatalError()
        }
        
        guard let primaryKeyValue = rlmDBObject.value(forKey: primaryKeyName) else {
            fatalError("Unrealm: In order to observe property changes you must set a primary key")
        }
        
        guard let rlmObject = realm?.object(ofType: objectType, forPrimaryKey: primaryKeyValue) else {
            fatalError()
        }
        
        return rlmObject.observe(block)
    }
}

public protocol Realmable: RealmableBase {
    
}

public extension Realmable {
    
    func toObject() -> Object? {
        guard let cls = objectType() else {return nil}
        let obj = convert(val: self, to: cls) as! Object
        return obj
    }
    
    mutating func readValues(from obj: Object) {
        let mirror = Mirror(reflecting: self)
        let children = mirror.childrenIncludingSuperclass(subject: self)
        guard let info = try? typeInfo(of: type(of: self)) else {return}

		let nilProperties = obj.value(forKey: "__nilProperties") as? RLMArray<NSString>
        
        for child in children {
            guard let propertyName = child.label else {continue}
            guard let property = try? info.property(named: propertyName) else {continue}
            guard obj.responds(to: NSSelectorFromString(propertyName)) else {continue}
            guard let value = obj.value(forKey: propertyName) else {continue}
            
            if let value = value as? Object {
                var childValue = child.value as? RealmableBase
                if childValue == nil {
                    childValue = try? createInstance(of: (type(of: child.value) as! RealmableBase.Type)) as? RealmableBase //.init()
                }
                childValue!.readValues(from: value)
                do {
                    try property.set(value: childValue!, on: &self)
                }
                catch {
                    print(error)
                }
            } else {
                do {
					if let index = nilProperties?.index(of: propertyName as NSString), index != NSNotFound {
						continue
					}

                    if value is NSFastEnumeration {
                        let realmArray = value as! RLMArray<AnyObject>                        
                        if realmArray.firstObject() is Object {
                            let objectsArray = realmArray as! RLMArray<Object>
                            var convertedArray: [Any] = []
                            for i in 0..<objectsArray.count {
                                let obj = objectsArray[i]
                                if let convertedObj = obj.toRealmable() {
                                    convertedArray.append(convertedObj)
                                }
                            }
                            
                            try property.set(value: convertedArray, on: &self)
                        } else {
                            var selfArray = [Any]()
							let generic = getGeneric(from: String(describing: type(of: child.value)))

                            for i in 0..<realmArray.count {
                                let o = realmArray[i]

								if let enumType = enumsAndRealmables[generic], let enumVal = enumType.init(rlmValue: o) {
									selfArray.append(enumVal)
								} else {
									selfArray.append(o)
								}
                            }
                            try property.set(value: selfArray, on: &self)
                        }
                    } else {
                        if let t = property.type as? RealmableEnum.Type, let val = t.init(rlmValue: value) {
                            try property.set(value: val, on: &self)
                        } else if child.value is [AnyHashable:Any], let data = value as? Data {
							if let json = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) {
								try property.set(value: json, on: &self)
							}
                        } else {
                            try property.set(value: value, on: &self)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
}

public extension Object {
    func toRealmable<T>(of type: T.Type) -> T {
        var realmbale: RealmableBase = (type as! RealmableBase.Type).init()
        realmbale.readValues(from: self)
        return realmbale as! T
    }
    
    func toRealmable(of type: Any.Type) -> Any {
        var realmbale: RealmableBase = (type as! RealmableBase.Type).init()
        realmbale.readValues(from: self)
        return realmbale
    }
    
    func toRealmable() -> RealmableBase? {
        let objTypeString = self.typeString() ?? ""
		if let type = objectsAndRealmables.filter({objTypeString.contains($0.key)}).map({($0, $1)}).sorted(by: {$0.0 > $1.0}).first?.1 {
            let convertedObj = self.toRealmable(of: type)
            return convertedObj as? RealmableBase
        }
        return nil
    }
}

fileprivate func convert<T: NSObject>(val: Any, to objectType: T.Type) -> AnyObject? {
    let mirror = Mirror(reflecting: val)
    let children = mirror.childrenIncludingSuperclass(subject: val)

    let obj = objectType.init()
	let nilProperties = (obj.value(forKey: "__nilProperties") as! RLMArray<NSString>)

    children.filter({$0.label != nil}).forEach({
        let label = $0.label!
        guard obj.responds(to: NSSelectorFromString(label)) else {return}
        let value = $0.value

		if let nilable = value as? OptionalPrtc {
			if !(nilable.val is NSNull) {
				let index = nilProperties.index(of: label as NSString)
				if index != NSNotFound {
					nilProperties.removeObject(at: index)
				}
			} else {
				nilProperties.add(label as NSString)
			}
		}

        if value is RealmableBase {
            guard let className = propertyClassName(label, objectType) else {return}
            let fullClassName = objectsAndRealmables.keys.first(where: {$0 == className}) ?? className
            guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
			if let opt = value as? OptionalPrtc, (opt.val is NSNull) {
				return
			}
            let o = convert(val: value, to: c)
            obj.setValue(o, forKey: label)
        } else if value is RealmableEnum {
            let rlmValue = (value as! RealmableEnum).rlmValue()
            obj.setValue(rlmValue, forKey: label)
        } else {
            if let values = value as? [Any] {
                
                if let realmArray = obj.value(forKey: label) as? RLMArray<AnyObject> {
                    values.forEach({value in
                        if value is RealmableBase {
                            guard let className = realmArray.objectClassName else {return}
                            let fullClassName = objectsAndRealmables.keys.first(where: {$0 == className}) ?? className
                            guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
                            if let o = convert(val: value, to: c) {
                                realmArray.add(o)
                            }
						} else if let enumValue = value as? RealmableEnum {
							let rawValue = enumValue.rlmValue()
							if let intValue = rawValue as? Int {
								realmArray.add(NSNumber(value: intValue) as AnyObject)
							} else {
								realmArray.add(rawValue as AnyObject)
							}
                        } else {
                            realmArray.add(value as AnyObject)
                        }
                    })
                } else {
                    obj.setValue(value, forKey: label)
                }
            } else if let dic = value as? [AnyHashable:Any] {

				#if os(iOS)
				if #available(iOS 11.0, *) {
					if let data = try? NSKeyedArchiver.archivedData(withRootObject: dic, requiringSecureCoding: true) {
						obj.setValue(data, forKey: label)
					}
				} else {
					let data = NSKeyedArchiver.archivedData(withRootObject: dic)
					obj.setValue(data, forKey: label)
				}
				#elseif os(OSX)
				if #available(OSX 10.13, *) {
					if let data = try? NSKeyedArchiver.archivedData(withRootObject: dic, requiringSecureCoding: true) {
						obj.setValue(data, forKey: label)
					}
				} else {
					let data = NSKeyedArchiver.archivedData(withRootObject: dic)
					obj.setValue(data, forKey: label)
				}
				#endif
            } else {
				if let number = NSNumber(value: value) {
					obj.setValue(number, forKey: label)
				} else {
					if let nilable = value as? OptionalPrtc {
						if !(nilable.val is NSNull) {
							obj.setValue(value, forKey: label)
						}
					} else {
						obj.setValue(value, forKey: label)
					}
				}
            }
        }
    })
    return obj
}

extension Mirror {
	func childrenIncludingSuperclass(subject obj: Any) -> [Mirror.Child] {
		var result = children.map({$0})

		if let opt = obj as? OptionalPrtc {
			if !(opt.val is NSNull) {
				let val = opt.val
				result = Mirror(reflecting: opt.val).childrenIncludingSuperclass(subject: val)
			} else {
				result = []
			}
		}

		if let superMirror = self.superclassMirror {
			result.append(contentsOf: superMirror.childrenIncludingSuperclass(subject: obj))
		}
		return result
	}
}

extension NSNumber {
	convenience init?(value: Any) {
		if let value = value as? Int8 {
			self.init(value: value)
		} else if let value = value as? Int16 {
			self.init(value: value)
		} else if let value = value as? Int32 {
			self.init(value: value)
		} else if let value = value as? Int {
			self.init(value: value)
		} else if let value = value as? Int64 {
			self.init(value: value)
		} else if let value = value as? UInt8 {
			self.init(value: value)
		} else if let value = value as? UInt16 {
			self.init(value: value)
		} else if let value = value as? UInt32 {
			self.init(value: value)
		} else if let value = value as? UInt64 {
			self.init(value: value)
		} else if let value = value as? UInt16 {
			self.init(value: value)
		} else if let value = value as? Float {
			self.init(value: value)
		} else if let value = value as? Double {
			self.init(value: value)
		} else if let value = value as? Bool {
			self.init(value: value)
		}
		return nil
	}
}
