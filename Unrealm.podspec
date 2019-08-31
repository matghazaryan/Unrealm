#
# Be sure to run `pod lib lint Unrealm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Unrealm'
  s.swift_version    = '5.0'
  s.version          = '0.1.1'
  s.summary          = 'Unrealm is an extension on RealmCocoa, which enables Swift native types to be saved in Realm.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Unrealm enables you to easily store Swift native Classes, Structs and Enums into Realm.
Benefits:
Enables you to store Swift native types (Structs, Classes, Enums, Arrays, Dictionaries, etc...)
Getting rid of redundant inheriting from Object class
Getting rid of Realm crashes like "Object has been deleted or invalidated"
Getting rid of Realm crashes like "Realm accessed from incorrect thread"
Getting rid of boiletplate code such @objc dynamic var. Use just var or let
                       DESC

  s.homepage         = 'https://github.com/arturdev/Unrealm'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arturdev' => 'mkrtarturdev@gmail.com' }
  s.source           = { :git => 'https://github.com/arturdev/Unrealm.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Unrealm/Classes/**/*.{h,m,swift}'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'

  s.dependency 'RealmSwift', '3.17.3'
  s.dependency 'Runtime', '2.1.0'
end
