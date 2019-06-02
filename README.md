<p align="center">
   <img width="750" src="https://raw.githubusercontent.com/arturdev/Unrealm/assets/unrealm.png" alt="Unrealm Header Logo">
</p>
                                                                                                                               <br><br>

<p align="center">
  <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
  </a>
  <a href="https://travis-ci.com/arturdev/Unrealm">
      <img src="https://travis-ci.com/arturdev/Unrealm.svg?branch=master" alt="Build Status">
  </a>
  <a href="https://cocoapods.org/pods/Unrealm">
      <img src="https://img.shields.io/cocoapods/v/Unrealm.svg?style=flat" alt="Version">
  </a>
  <a href="https://cocoapods.org/pods/Unrealm">
      <img src="https://img.shields.io/cocoapods/l/Unrealm.svg?style=flat" alt="License">
  </a>
  <a href="https://cocoapods.org/pods/Unrealm">
      <img src="https://img.shields.io/cocoapods/p/Unrealm.svg?style=flat" alt="Platform">
  </a>

</p>
  
<br/>

<p align="center">
  Unrealm enables you to easily store Swift native <b>Classes</b>, <b>Structs</b> and <b>Enums</b> into <a href="https://github.com/realm/realm-cocoa">Realm <img width="18" src = "https://raw.githubusercontent.com/arturdev/Unrealm/assets/realmLogoSmall.png"></a>.<br/>Stop inheriting from <b>Object</b>! Go for Protocol-Oriented programming!<br>
Made with ❤️ by <a href="https://github.com/arturdev">arturdev</a>
</p>
<br>

<p align="center">
<img width="1024" src="https://raw.githubusercontent.com/arturdev/Unrealm/assets/preview.png">
</p>
<br>

## Features
Unrealm support the following types:

- [x] Swift Primitives
- [x] Swift Structs
- [x] Swift Classes
- [x] Swift Enums
- [x] Swift Arrays
- [x] Swift Dictionaries
- [x] Swift Optionals (String, Data, Date)
- [x] Nested Classes/Structs
- [ ] Swift Optionals of primitives (Int, Double, etc..)


## Example Project
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
All you have to do is 
1. Conform your Classes/Structs to `Realmable` protocol instead of inheriting from `Object`.
2. Register your Classes/Structs in AppDelegate's `didFinishLaunchingWithOptions`.
```Swift
Realm.registerRealmables(ToDoItem.self)
```
Thats it! Now you can store your Struct or Class object into Realm as usualy you do with Objc Classes.

## Pros and Cons 

#### Pros 🎉
- Enables you to store Swift native types (Structs, Classes, Enums, Arrays, Dictionaries, etc...)
- Getting rid of redundant inheriting from Object class
- Getting rid of Realm crashes like "Object has been deleted or invalidated"
- Getting rid of Realm crashes like "Realm accessed from incorrect thread"
- Getting rid of boiletplate code such `@objc dynamic var`. Use just `var` or `let`

#### Cons 🍟
- Losing "Live Objects" feature. Which means when you modify an object got from Realm the other ones will not be updated automatically. So after modifying an object you should manually update it in realm.
f.e.;
```Swift
let realm = try! Realm()
var todoItem = realm.object(ofType: ToDoItem.self, forPrimaryKey: "1")
todoItem.text = "Modified text"
try! realm.write {
    realm.add(todoItem, update: true) //<- force Realm to update the object
}
```



## Installation

Unrealm is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Unrealm'
```

## Author

arturdev, mkrtarturdev@gmail.com

## License

Unrealm is available under the MIT license. See the LICENSE file for more info.
