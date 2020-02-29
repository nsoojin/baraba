//
// Baraba.swift
//
// Copyright (c) 2020 Soojin Ro (https://github.com/nsoojin)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import QuartzCore
import os

/**
 The main object that you use to add auto-scrolling to a scroll view.
*/
public class Baraba: NSObject {
    /**
     Returns a boolean value indicating whether a given configuration is supported by the device.
    */
    public static func isConfigurationSupported(_ configuration: BarabaConfiguration) -> Bool {
        return type(of: configuration.tracker).isSupported
    }
    
    /**
     The scroll view that will be auto-scrolled when user is looking at the device.
    */
    public weak var scrollView: UIScrollView? {
        didSet {
            if let scrollView = scrollView {
                addScrollViewObservers(scrollView)
            } else {
                removeScrollViewObservers()
            }
        }
    }
    
    /**
     The delegate for the Baraba object.
    */
    public weak var delegate: BarabaDelegate?
    
    /**
     The duration of pause after user finishes dragging the scroll view. Default value is `2.0` seconds.
     
     After this amount of duration, auto-scrolling resumes.
    */
    public var pauseDuration: TimeInterval {
        set {
            _pauseDuration = newValue
            suspendDebouncer = Debouncer(delay: _pauseDuration)
        }
        get {
            _pauseDuration
        }
    }
    
    /**
     The preferred speed for auto-scrolling the scroll view, represented in points per second.
     
     The actual speed chosen is the nearest multiple of `60`. For example, if you set this value to `140`, the actual speed will be `120` as it is closer to `120` than `180`. Check the `actualScrollSpeed` property.
     
     Default value is `180`. The minimum is `60`.
    */
    public var preferredScrollSpeed: Int = 180 {
        didSet {
            _speed = preferredScrollSpeed
        }
    }
    
    /**
     The actual scroll speed, represented in points per second.
     
     If you want to change the scroll speed, set the value to `preferredScrollSpeed`. It will be rounded to the nearest multiple of 60, which is the actual scroll speed.
     
     Default value is `180`.
    */
    public var actualScrollSpeed: Int {
        _speed
    }
    
    /**
     A Boolean value that indicates whether this Baraba object is active and tracking user's face.
     
     This is a read-only property. If you want to make Baraba active, call `resume()` on the receiver.
    */
    public private(set) var isActive: Bool = false
    
    /**
     A Boolean value that indicates whether the scroll view is being auto-scrolled. Read-only.
    */
    public var isScrolling: Bool {
        displayLink?.isPaused == false
    }
    
    /**
     Starts the tracking of user's face for auto-scrolling.
     
     If the object fails to resume, `func baraba(_ baraba: Baraba, didFailWithError error: Error)` will be called on the delegate.
    */
    public func resume() {
        if isActive {
            Log.info("resume() called on an already running object, which has no effect.")
            return
        }
        
        if scrollView == nil {
            Log.error("Failed to resume. Its scrollView property is nil. Please designate a scrollView before calling resume()")
            return
        }
        
        if type(of: tracker).isSupported == false {
            Log.default("Failed to resume (BarabaError.unsupportedConfiguration). Implement BarabaDelegate's 'func baraba(_:, didFailWithError:)' to add fallback.")
            delegate?.baraba(self, didFailWithError: BarabaError.unsupportedConfiguration)
            return
        }
        
        if type(of: tracker).isHardwareDenied {
            Log.default("Failed to resume (BarabaError.cameraUnauthorized). Implement BarabaDelegate's 'func baraba(_:, didFailWithError:)' to add fallback.")
            delegate?.baraba(self, didFailWithError: BarabaError.cameraUnauthorized)
            return
        }
        
        Log.info("Resumed")
        setupDisplayLink()
        isActive = true
        tracker.resume()
    }
    
    /**
     Pauses the tracking of user's face.
     
     Call this method when you no longer need to track user's face. For example, inside `func viewWillDisappear(_ animated:)` of a view controller.
    */
    public func pause() {
        if isActive {
            Log.info("Paused")
            isActive = false
            isSuspended = false
            isFacing = false
            invalidateDisplayLink()
            tracker.pause()
        }
    }
    
    /**
     Creates a new Baraba object with the specified configuration.
     
     Before initializing, you can check if the device supports the configuration by looking at `isSupported` property of a configuration object.
     
     Using an unsupported configuration will invoke `func baraba(_ baraba: Baraba, didFailWithError error: Error)` call to the delegate.
     
     - Parameters:
        - configuration: A configuration object that specifies which feature to use to track user's face.
    */
    public init(configuration: BarabaConfiguration) {
        tracker = configuration.tracker
        workQueue = DispatchQueue(label: "\(Constant.bundleIdentifier).queue", qos: .userInitiated, autoreleaseFrequency: .workItem)
        suspendDebouncer = Debouncer(delay: 0)
        
        super.init()
        
        suspendDebouncer = Debouncer(delay: _pauseDuration)
        tracker.delegate = self
    }

    @objc
    internal func scroll(displayLink: CADisplayLink) {
        guard let scrollView = scrollView else {
            Log.error("Pausing because scrollView is nil. Please designate a scrollView before calling resume()")
            pause()
            return
        }
        
        guard shouldScroll == true else {
            return
        }
        
        let actualFramesPerSecond = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
        let scrollOffset = round(max((Double(_speed) / actualFramesPerSecond), 1))
        let target = CGPoint(x: 0, y: scrollView.contentOffset.y + CGFloat(scrollOffset))
        
        if target.y + scrollView.bounds.height <= scrollView.contentSize.height + scrollView.adjustedContentInset.bottom {
            scrollView.contentOffset = target
        }
    }
    
    private func addScrollViewObservers(_ scrollView: UIScrollView) {
        contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new, .old], changeHandler: observeContentOffset(_:_:))
    }
    
    private func removeScrollViewObservers() {
        contentOffsetObservation = nil
    }

    private func observeContentOffset(_ scrollView: UIScrollView, _ change: NSKeyValueObservedChange<CGPoint>) {
        if scrollView.isDragging, isActive {
            if isSuspended == false {
                isSuspended = true
            }
            
            suspendDebouncer.schedule {
                self.resumeScroll()
            }
        }
    }
    
    private func resumeScroll() {
        if scrollView?.isDragging == false {
            isSuspended = false
        } else {
            suspendDebouncer.schedule {
                self.resumeScroll()
            }
        }
    }
    
    private func setupDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(scroll))
        displayLink.add(to: .main, forMode: .default)
        displayLink.isPaused = true
        
        self.displayLink = displayLink
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
    }
    
    private func evaluate() {
        guard let displayLink = displayLink, isActive else {
            return
        }
        
        if shouldScroll == true && displayLink.isPaused == true {
            displayLink.isPaused = false
            Log.debug("Did start scrolling")
            DispatchQueue.main.async { self.delegate?.barabaDidStartScrolling(self) }
        } else if shouldScroll == false && displayLink.isPaused == false {
            displayLink.isPaused = true
            Log.debug("Did stop scrolling")
            DispatchQueue.main.async { self.delegate?.barabaDidStopScrolling(self) }
        }
    }
    
    private var shouldScroll: Bool {
        return isFacing && isActive && isSuspended == false
    }
    
    private var isFacing: Bool = false {
        didSet {
            workQueue.async { self.evaluate() }
        }
    }
    
    private var isSuspended: Bool = false {
        didSet {
            workQueue.async { self.evaluate() }
        }
    }
    
    @Multiple(multiplier: 60)
    private var _speed: Int = 180
    
    @Minimum(min: 0)
    private var _pauseDuration: Double = 2.0
    
    private weak var displayLink: CADisplayLink?
    private var contentOffsetObservation: NSKeyValueObservation?
    private var suspendDebouncer: Debouncer
    private let tracker: FaceTracker
    private let workQueue: DispatchQueue
}

extension Baraba: FaceTrackerDelegate {
    internal func trackerDidStartTrackingFace(_ tracker: FaceTracker) {
        isFacing = true
    }
    
    internal func trackerDidEndTrackingFace(_ tracker: FaceTracker) {
        isFacing = false
    }
    
    internal func trackerWasInterrupted(_ tracker: FaceTracker) {
        Log.info("Interrupted")
        isSuspended = true
    }
    
    internal func trackerInterruptionEnded(_ tracker: FaceTracker) {
        Log.info("Interruption Ended")
        isSuspended = false
    }
    
    internal func tracker(_ tracker: FaceTracker, didFailWithError error: Error) {
        pause()
        delegate?.baraba(self, didFailWithError: BarabaError.cameraFailed(error))
    }
}
