# Baraba
>from Korean: 
>
>*meaning, **Look at me***
<p>
   <a href="https://github.com/nsoojin/baraba/actions">
      <img src="https://github.com/nsoojin/baraba/workflows/CI/badge.svg">
   </a>
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/Baraba">
      <img src="https://img.shields.io/cocoapods/v/Baraba.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/Baraba">
      <img src="https://img.shields.io/cocoapods/p/Baraba.svg?style=flat" alt="Platform">
   </a>
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
</p>

Make your UIScrollView scroll automatically when user is looking at the screen 👀

## Features

- [x] Automatic scrolling for your UIScrollView when user is looking at the screen📱👀
- [x] Pauses scrolling when user turns away📱🙄 or when starts scrolling 👆
- [x] Face Tracking using ARKit or AVFoundation (Your choice!)
- [x] Adjust scrolling speed appropriate for your content
- [x] Complete [Documentation](https://soojin.ro/baraba/)
- [x] Supports iOS 11 or above

## Demo

### Click below image 👉 YouTube

[![Baraba Demo](etc/baraba_demo.gif)](https://www.youtube.com/watch?v=Hiojxdy_QtM)

## Installation

### CocoaPods

Baraba is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```bash
pod 'Baraba'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Baraba into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "nsoojin/baraba"
```

Run `carthage update` to build the framework and drag the built `Baraba.framework` into your Xcode project. 

## Example

The example application is the best way to see `Baraba` in action. Simply open the `Baraba.xcodeproj` and run the `Example` scheme.

## Basic Usage

### Just three simple lines of code to get it running!

```Swift
// Probably in your view controller.
let baraba = Baraba(configuration: .automatic) // (1) Initialize Baraba

override func viewDidLoad() {
    super.viewDidLoad()
    
    baraba.scrollView = tableView // (2) Set the scroll view for the auto-scroll target
    baraba.delegate = self
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    baraba.resume() // (3) Resume to activate camera and start tracking user's face
}

override func viewWillDisppear(_ animated: Bool) {
    super.viewWillDisppear(animated)
    
    baraba.pause() // Pause to stop accessing camera
}
```

## Configuration

```Swift 
let baraba = Baraba(configuration: .automatic) // Uses ARKit if supported. If not, uses AVFoundation
let baraba = Baraba(configuration: .ar)
let baraba = Baraba(configuration: .av)

Baraba.isConfigurationSupported(.ar) // Check the device availability
```

### What's the difference?

ARKit uses TrueDepth front camera. Not all iOS devices supports this, so refer to [device compatibility](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Cameras/Cameras.html#//apple_ref/doc/uid/TP40013599-CH107-SW1). Generally, ARKit has faster face tracking capability so reacts faster to user movement. However, it consumes more energy and may increase the device temperature when used for a long time. The best way to see the difference is to run it for youself.  Try the Example app.

### Scroll Speed

You can adjust scroll speed with `preferredScrollSpeed` property, which represents speed in 'points per second'. However, the actual scroll speed will be the nearest multiple of 60. The reason is for smooth scrolling, as the device's maximum refresh rate of the display is 60 frames per second. You can check the actual speed with `actualScrollSpeed` property if you want. Default is 180.

```Swift
baraba.preferredScrollSpeed = 240 // baraba.actualScrollSpeed == 240 
baraba.preferredScrollSpeed = 100 // baraba.actualScrollSpeed == 120
```

### Pause Duration

When user starts dragging the scroll view, auto-scrolling pauses. After the dragging finishes, auto-scrolling resumes after this duration.

```Swift
baraba.pauseDuration = 4
```

## ⚠️ Important

If you want to use `BarabaConfiguration.ar`  which uses ARFaceTrackingConfiguration, your app must include a privacy policy describing to users how you intend to use face tracking and face data. (See [Apple's Note](https://developer.apple.com/documentation/arkit/arfacetrackingconfiguration)) 

[Example #1](https://soojin.ro/notableme-privacypolicy) (This has passed the actual App Store Review.)

You can use this [sample](https://github.com/nsoojin/baraba/blob/master/etc/PRIVACY-POLICY-SAMPLE.md) at your own discretion.

Don't forget to add `Privacy - Camera Usage Description` in your app's `info.plist` file.

## FAQ

### What's the origin of the name Baraba?

Baraba(바라봐) is a Korean term which means "Look at me".

## Contributing
Contributions are very welcome 🙌

## License

Baraba is released under the MIT license. See [LICENCE](https://github.com/nsoojin/baraba/blob/master/LICENSE) for details.
