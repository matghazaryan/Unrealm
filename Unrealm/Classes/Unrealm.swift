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
import Runtime

internal var objectsAndRealmables: [String:RealmableBase.Type] = [:]

public protocol RealmableEnum {
    func rlmValue() -> Any
    init?(rlmValue: Any)
}

public extension RealmableEnum where Self : RawRepresentable {
    func rlmValue() -> Any {
        return rawValue
    }
    
    init?(rlmValue: Any) {
        guard let rawVal = rlmValue as? Self.RawValue else {return nil}
        self.init(rawValue: rawVal)
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
}

public protocol RealmableBase {
    mutating func readValues(from obj: Object)
    func toObject() -> Object?
    static var realmClassPrefix: String {get}
    
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
    
    internal func objectType() -> Object.Type? {
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
    
    internal static func objectType() -> Object.Type? {
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
    func observe(_ block: @escaping (ObjectChange) -> Void) -> NotificationToken {
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

public protocol Realmable: RealmableBase,  RealmCollectionValue {
    
}

public extension Realmable {
    
    func toObject() -> Object? {
        guard let cls = objectType() else {return nil}
        let obj = convert(val: self, to: cls) as! Object
        return obj
    }
    
    mutating func readValues(from obj: Object) {
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        guard let info = try? typeInfo(of: type(of: self)) else {return}
        
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
                            for i in 0..<realmArray.count {
                                let o = realmArray[i]
                                selfArray.append(o)
                            }
                            try property.set(value: selfArray, on: &self)
                        }
                    } else {
                        if let t = property.type as? RealmableEnum.Type, let val = t.init(rlmValue: value) {
                            try property.set(value: val, on: &self)
                        } else if child.value is [AnyHashable:Any], let data = value as? Data {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            try property.set(value: json, on: &self)
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
        let objTypeString = self.typeStr()
        if let type = objectsAndRealmables[objTypeString] {
            let convertedObj = self.toRealmable(of: type)
            return convertedObj as? RealmableBase
        }
        return nil
    }
}

extension Object {
    func typeStr() -> String {
        let t = String(describing: self)
        if let match = t.range(of: "[a-zA-Z0-9_.]+", options: .regularExpression) {
            return String(t[match])
        }
        return ""
    }
}

fileprivate func convert<T: NSObject>(val: Any, to objectType: T.Type) -> AnyObject? {
    let mirror = Mirror(reflecting: val)
    var children = mirror.children
    if let opt = val as? OptionalPrtc {
        if !(opt.val is NSNull) {
            children = Mirror(reflecting: opt.val).children
        } else {
            return nil
        }
    }
    
    let obj = objectType.init()
    children.filter({$0.label != nil}).forEach({
        let label = $0.label!
        guard obj.responds(to: NSSelectorFromString(label)) else {return}
        let value = $0.value
        if value is RealmableBase {
            guard let className = propertyClassName(label, objectType) else {return}
            let fullClassName = objectsAndRealmables.keys.first(where: {$0.contains(className)}) ?? className
            guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
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
                            let fullClassName = objectsAndRealmables.keys.first(where: {$0.contains(className)}) ?? className
                            guard let c = NSClassFromString(fullClassName) as? NSObject.Type else {return}
                            if let o = convert(val: value, to: c) {
                                realmArray.add(o)
                            }
                        } else {
                            realmArray.add(value as AnyObject)
                        }
                    })
                } else {
                    obj.setValue(value, forKey: label)
                }
            } else if let dic = value as? [AnyHashable:Any] {
                if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                    obj.setValue(data, forKey: label)
                }
            } else {
                obj.setValue(value, forKey: label)
            }
        }
    })
    return obj
}
