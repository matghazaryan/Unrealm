//
//  Realm+Unrealm.swift
//  Unrealm
//
//  Created by Artur Mkrtchyan on 4/28/19.
//  Copyright © 2019 arturdev. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RuntimeNew

#if canImport(UnrealmObjC)
import UnrealmObjC
#endif

public extension Realm {
    
    // MARK: Object Retrieval
    
    /**
     Returns all objects of the given type stored in the Realm.
     
     - parameter type: The type of the objects to be returned.
     
     - returns: A `Results` containing the objects.
     */
    func objects<RealmableElement: Realmable>(_ type: RealmableElement.Type) -> Unrealm.Results<RealmableElement> {
        let fullType = String(reflecting: RealmableElement.self)
        var components = fullType.components(separatedBy: ".")
        let typeName = components.removeLast()
        let realmTypeName = RealmableElement.realmClassPrefix + typeName
        components.append(realmTypeName)
        
        let realmClass = components.joined(separator: ".")
        let cls = (NSClassFromString(realmClass) ?? NSClassFromString(realmTypeName)) as! Object.Type
        
        let results = self.objects(cls)
        return Unrealm.Results(rlmResult: results)
    }
	
	func anyObjectArray(_ type: Realmable.Type) -> AnyResults {
        let fullType = String(reflecting: type)
        var components = fullType.components(separatedBy: ".")
        let typeName = components.removeLast()
        let realmTypeName = type.realmClassPrefix + typeName
        components.append(realmTypeName)
        
        let realmClass = components.joined(separator: ".")
        let cls = (NSClassFromString(realmClass) ?? NSClassFromString(realmTypeName)) as! Object.Type
        
        let results = self.objects(cls)
		return AnyResults(rlmResult: results)
    }
    
    /**
     Retrieves the single instance of a given object type with the given primary key from the Realm.
     
     This method requires that `primaryKey()` be overridden on the given object class.
     
     - see: `Object.primaryKey()`
     
     - parameter type: The type of the object to be returned.
     - parameter key:  The primary key of the desired object.
     
     - returns: An object of type `type`, or `nil` if no instance with the given primary key exists.
     */
    func object<RealmableElement: Realmable, KeyType>(ofType type: RealmableElement.Type, forPrimaryKey key: KeyType) -> RealmableElement? {
        guard let objectType = type.objectType() else {
            fatalError()
        }
        return self.object(ofType: objectType, forPrimaryKey: key)?.toRealmable() as? RealmableElement
    }
	
	func anyObject<KeyType>(_ type: Realmable.Type, forPrimaryKey key: KeyType) -> Realmable? {
		guard let objectType = type.objectType() else {
            fatalError()
        }
		return self.object(ofType: objectType, forPrimaryKey: key)?.toRealmable() as? Realmable
	}
    
    // MARK: Adding and Creating objects
    
    /**
     Adds or updates an existing object into the Realm.
     
     Only pass `true` to `update` if the object has a primary key. If no object exists in the Realm with the same
     primary key value, the object is inserted. Otherwise, the existing object is updated with any changed values.
     
     When added, all child relationships referenced by this object will also be added to the Realm if they are not
     already in it. If the object or any related objects are already being managed by a different Realm an error will be
     thrown. Instead, use one of the `create` functions to insert a copy of a managed object into a different Realm.
     
     The object to be added must be valid and cannot have been previously deleted from a Realm (i.e. `isInvalidated`
     must be `false`).
     
     - parameter object: The object to be added to this Realm.
     - parameter update: If `true`, the Realm will try to find an existing copy of the object (with the same primary
     key), and update it. Otherwise, the object will be added.
     */
	@available(*, deprecated, message: "Pass .error, .modified or .all rather than a boolean. .error is equivalent to false and .all is equivalent to true.")
    func add(_ realmable: Realmable, update: Bool) {
		add(realmable, update: update ? .all : .error)
    }

	/**
	Adds an unmanaged object to this Realm.

	If an object with the same primary key already exists in this Realm, it is updated with the property values from
	this object as specified by the `UpdatePolicy` selected. The update policy must be `.error` for objects with no
	primary key.

	Adding an object to a Realm will also add all child relationships referenced by that object (via `Object` and
	`List<Object>` properties). Those objects must also be valid objects to add to this Realm, and the value of
	the `update:` parameter is propagated to those adds.

	The object to be added must either be an unmanaged object or a valid object which is already managed by this
	Realm. Adding an object already managed by this Realm is a no-op, while adding an object which is managed by
	another Realm or which has been deleted from any Realm (i.e. one where `isInvalidated` is `true`) is an error.

	To copy a managed object from one Realm to another, use `create()` instead.

	- warning: This method may only be called during a write transaction.

	- parameter object: The object to be added to this Realm.
	- parameter update: What to do if an object with the same primary key alredy exists. Must be `.error` for objects
	without a primary key.
	*/
	func add(_ realmable: Realmable, update: UpdatePolicy = .error) {
		guard let obj = realmable.toObject() else {
			fatalError("Cannot convert \(realmable) to Object")
		}

		self.add(obj, update: update)
		realmable.setRealm(self)
	}
    /**
     Adds or updates all the objects in a collection into the Realm.
     
     - see: `add(_:update:)`
     
     - warning: This method may only be called during a write transaction.
     
     - parameter objects: A sequence which contains objects to be added to the Realm.
     - parameter update: If `true`, objects that are already in the Realm will be updated instead of added anew.
     */
    func add<S: Sequence>(_ objects: S, update: Bool = false) where S.Iterator.Element: Realmable {
        for obj in objects {
			add(obj, update: update ? .all : .error)
        }
    }
    
    // MARK: Deleting objects
    
    /**
     Deletes an object from the Realm. Once the object is deleted it is considered invalidated.
     
     - warning: This method may only be called during a write transaction.
     
     - parameter object: The object to be deleted.
     */
    func delete(_ realmable: Realmable) {
        guard let obj = realmable.toObject() else {
            fatalError("Cannot convert \(realmable) to Object")
        }
        				
        guard let objectType = realmable.objectType(), let pk = type(of: realmable).primaryKey() else {
            fatalError("Only objects with primary keys can be deleted from realm")
        }
        guard let pkValue = obj.value(forKey: pk) else {return}
        guard let rlmObj = self.object(ofType: objectType, forPrimaryKey: pkValue) else {
            return
        }
        self.delete(rlmObj)
    }
    
    /**
     Deletes zero or more objects from the Realm.
     
     Do not pass in a slice to a `Results` or any other auto-updating Realm collection
     type (for example, the type returned by the Swift `suffix(_:)` standard library
     method). Instead, make a copy of the objects to delete using `Array()`, and pass
     that instead. Directly passing in a view into an auto-updating collection may
     result in 'index out of bounds' exceptions being thrown.
     
     - warning: This method may only be called during a write transaction.
     
     - parameter objects:   The objects to be deleted. This can be a `List<Object>`,
     `Results<Object>`, or any other Swift `Sequence` whose
     elements are `Object`s (subject to the caveats above).
     */
    func delete<S: Sequence>(_ objects: S) where S.Iterator.Element: Realmable {
        for obj in objects {
            delete(obj)
        }
    }
    
    // MARK: Realmables registration
    /**
     Unrealm requires to register all the types conforming to Realmable protocol
     - parameter realmables: Types to be registereds
    */
    static func registerRealmables(_ realmables: [RealmableBase.Type], enums: [RealmableEnum.Type] = []) {
		prepareUnrealm()

		for en in enums {
			let types = exctractTypeComponents(from: en)
            let typeName = types.1
			enumsAndRealmables[typeName] = en
		}

        //Creating all classes
        realmables.forEach({
            var superClass: AnyClass = Object.self
            if !($0 is NSObject.Type) { //is swift type
                if let c = ($0 as? AnyClass)?.superclass(), let cRealmable = c as? RealmableBase.Type {
                    let types = exctractTypeComponents(from: cRealmable)
                    let typeName = types.1
                    let className = cRealmable.realmClassPrefix + typeName
                    self.registerRealmables(cRealmable)
                    superClass = NSClassFromString(className) ?? Object.self
                }
            }
            
            let types = exctractTypeComponents(from: $0)
            let typeName = types.1
            
            let className = $0.realmClassPrefix + typeName
            if NSClassFromString(className) == nil { //If not already created
                createClass(className, superClass)
            }
            
            guard let clzz = NSClassFromString(className) else {
                fatalError("Unrealm: Could not create Realm class '\(className)'")
            }
            
            if let primaryKey = $0.primaryKey() {
                addClassMethodToClass(clzz, "primaryKey", primaryKey)
            }
            
            if !$0.ignoredProperties().isEmpty {
                addClassMethodToClass(clzz, "ignoredProperties", $0.ignoredProperties())
            }
            
            if !$0.indexedProperties().isEmpty {
                addClassMethodToClass(clzz, "indexedProperties", $0.indexedProperties())
            }
        })
        
        for realmable in realmables {
            let types = exctractTypeComponents(from: realmable)
            let typeName = types.1
            let realmClassName = realmable.realmClassPrefix + typeName
            
            objectsAndRealmables[realmClassName] = realmable
            
            guard let clazz: AnyClass = NSClassFromString(realmable.realmClassPrefix + typeName) else {continue}
            let inst = realmable.init() //try! createInstance(of: realmable)
            addProperties(of: inst, to: clazz, ignoreProperties: realmable.ignoredProperties())
        }
    }
    
	static func registerRealmables(_ realmables:RealmableBase.Type..., enums: [RealmableEnum.Type] = []) {
        registerRealmables(realmables, enums: enums)
    }
}

internal func exctractTypeComponents<Subject>(from subject: Subject) -> (String, String) {
    var fullType = String(describing: subject)
    if let match = fullType.range(of: "[a-zA-Z0-9_.]+", options: .regularExpression) {
        fullType = String(fullType[match])
    }
    
    var components = fullType.components(separatedBy: ".")
    let typeName = components.removeLast()
    return (components.joined(separator: "."), typeName)
}

fileprivate func addProperties(of value: RealmableBase, to className: AnyClass, ignoreProperties: [String]) {
    let mirror = Mirror(reflecting: value)
    let children = mirror.children.reversed()
    for child in children {
        guard let name = child.label else {continue}
		//Check for Realmable children
		let childType = type(of: child.value)
		if let t = childType as? RealmableBase.Type {
			Realm.registerRealmables(t)
		} else if let t = (child.value as? OptionalPrtc).type as? RealmableBase.Type {
			Realm.registerRealmables(t)
		}

        if ignoreProperties.contains(name) {continue}
        let typeStr: String
        let types = exctractTypeComponents(from: child.value)
        if let base = child.value as? RealmableBase, types.1 != "Optional", types.1 != "nil" {
            typeStr = type(of: base).realmClassPrefix + types.1
        } else if let optionalWrappedType = getOptionalWrappedTypeName(optionalType: type(of: child.value)) {
            if let realmableType = objectsAndRealmables.first(where: {String(describing: $0.value).components(separatedBy: ".").last == optionalWrappedType})?.value {
                
                typeStr = realmableType.realmClassPrefix + optionalWrappedType
            } else {
                typeStr = getTypeString(from: child.value)
            }
        } else {
            typeStr = getTypeString(from: child.value)
        }
        
        addPropertyToClassIfNeeded(className: className, name: name, typeStr: typeStr)
    }
	addPropertyToClassIfNeeded(className: className, name: "__nilProperties", typeStr: "Array<String>")
}

fileprivate func addPropertyToClassIfNeeded(className: AnyObject.Type, name: String, typeStr: String) {
    var numberObProperties: UInt32 = 0
    if let list = class_copyPropertyList(className, &numberObProperties) {
        for i in 0..<Int(numberObProperties) {
            let property = list[i]
            let propertyName = NSString(utf8String: property_getName(property)) ?? ""
            if (propertyName as String) == name {
                //Already exists
                return
            }
        }
    }
    var typeStr = typeStr
    if typeStr.contains("Array<") && className.isSubclass(of: Object.self) {
        typeStr = getRealmArrayType(from: typeStr)
    }
    
    addPropertyToClass(className, name, typeStr)
}

internal func getGeneric(from type: String) -> String {
    if let match = type.range(of: "(?<=<)[^>]+", options: .regularExpression) {
        return String(type[match])
    }
    return ""
}

fileprivate func getTypeString(from value: Any) -> String {
    if (value is Int) || (value is CShort) || (value is CLong) || (value is CLongLong) {
        return "q"
    } else if (value is Float) {
        return "f"
    } else if (value is Double) {
        return "d"
    } else if (value is Bool) {
        return "B"
    } else if (value is String) {
        return "NSString"
    } else if (value is Data) {
        return "NSData"
    } else if (value is Date) {
        return "NSDate"
    }
    
    var typeStr = String(describing: type(of: value))
    if typeStr.hasPrefix("Optional<") {
        typeStr = getOptionalWrappedTypeName(optionalType: type(of: value))!
        
        if let realmableType = objectsAndRealmables.first(where: {String(describing: $0.value).components(separatedBy: ".").last == typeStr}) {
            typeStr = realmableType.key
		} else {

			switch typeStr {
			case "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64", "Float", "Float32", "Float64", "Double", "Bool":
				typeStr = "NSNumber<RLM" + typeStr + ">"
			default: break
			}
		}
    }
    
    if typeStr.hasPrefix("Dictionary<") {
        return "NSData"
    }

	if typeStr.hasPrefix("Array<") {
		let generic = getGeneric(from: typeStr)
		if let enumType = enumsAndRealmables[generic] {
			let rawValueType = enumType.rawValueType
			typeStr = "Array<" + String(describing: rawValueType) + ">"
			return typeStr
		}
	}
    
    if let typeinfo = try? typeInfo(of: type(of: value)) {
        if typeinfo.kind == .enum {
            if let enm = value as? RealmableEnum {
                let rawValue = enm.rlmValue()
                return getTypeString(from: rawValue)
            } else {
                return ""
            }
        }
    }
    
    if ["String", "Data", "Date"].contains(typeStr) {
        typeStr = "NS" + typeStr
    }
    
    return typeStr
}

internal func getRealmArrayType(from type: String) -> String {
    var typeStr = type
    if typeStr.contains("Array<") {
        typeStr = typeStr.replacingOccurrences(of: "Array", with: "RLMArray")
        let generic = getGeneric(from: typeStr)
		typeStr = typeStr.replacingOccurrences(of: generic, with: "RLM" + generic)
    }
    
    return typeStr
}

internal func getOptionalWrappedTypeName(optionalType: Any.Type) -> String? {
    var typeStr = String(describing: optionalType)
    guard typeStr.hasPrefix("Optional<") else { return nil }
    typeStr = typeStr.replacingOccurrences(of: "Optional<", with: "")
    typeStr.removeLast()
    return typeStr
}
