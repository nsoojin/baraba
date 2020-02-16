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

public class Baraba: NSObject {
    
    public weak var scrollView: UIScrollView? {
        didSet {
            if let scrollView = scrollView {
                addScrollViewObservers(scrollView)
            } else {
                removeScrollViewObservers()
            }
        }
    }
    
    public weak var delegate: BarabaDelegate?
    
    public private(set) var isActive: Bool = false
    
    public var isScrolling: Bool {
        displayLink?.isPaused == false
    }
    
    /// The speed in which to auto-scroll the scrollView. Represented in points per second. Default value is `200.0`.
    public var speed: Double = 200.0
    
    public var pauseDuration: TimeInterval {
        suspendDebouncer.delay
    }
    
    public func resume() {
        if scrollView == nil {
            print("Baraba(\(self)) failed to resume. Its scrollView property is nil. Please designate a scrollView before calling resume()")
            return
        }
        
        if isActive {
            print("Baraba is already running.")
            return
        }
        
        print("resume baraba")
        setupDisplayLink()
        tracker.resume()
        isActive = true
    }
    
    public func pause() {
        if isActive {
            print("pause baraba")
            isActive = false
            isSuspended = false
            isFacing = false
            invalidateDisplayLink()
            tracker.pause()
        }
    }
    
    public init(configuration: BarabaConfiguration) {
        tracker = configuration.trackerType.init()
        
        let debouncerQueue = DispatchQueue(label: "\(Constant.bundleIdentifier).suspendDebouncer.queue",
                                           qos: .userInitiated,
                                           autoreleaseFrequency: .workItem)
        
        suspendDebouncer = Debouncer(queue: debouncerQueue, delay: configuration.pauseDuration)
        logger = Baraba.makeLogger()
        
        super.init()
        
        tracker.delegate = self
    }

    @objc
    internal func scroll(displayLink: CADisplayLink) {
        logger(displayLink.timestamp)
        
        guard let scrollView = scrollView else {
            return
        }
        
        let actualFramesPerSecond = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
        let scrollOffset = round(speed / actualFramesPerSecond)
        
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
        if scrollView.isDragging {
            if isSuspended == false {
                isSuspended = true
            }
            
//            print("@@@@@@@ schedule")
            suspendDebouncer.schedule {
                print("----------------- debounced suspend")
                self.isSuspended = false
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
        print("evaluate: \(shouldScroll), isPaused: \(displayLink?.isPaused)")
        precondition(displayLink != nil, "displayLink should not be nil.")
        if shouldScroll == true && displayLink?.isPaused == true {
            displayLink?.isPaused = false
            delegate?.barabaDidStartScrolling(self)
        } else if shouldScroll == false && displayLink?.isPaused == false {
            displayLink?.isPaused = true
            delegate?.barabaDidStopScrolling(self)
        }
    }
    
    private static func makeLogger() -> (CFTimeInterval) -> Void {
        var lastLoggedTime = 0
        return { interval in
            let second = Int(floor(interval))
            
            if lastLoggedTime + 1 <= second {
                lastLoggedTime = second
//                print("scrolling...")
            }
        }
    }
    
    private weak var displayLink: CADisplayLink?
    private var logger: (CFTimeInterval) -> Void
    private var contentOffsetObservation: NSKeyValueObservation?
    private let suspendDebouncer: Debouncer
    private let tracker: FaceTracker
    
    private var shouldScroll: Bool {
        return isFacing && isActive && isSuspended == false
    }
    
    private var isFacing: Bool = false {
        didSet {
            evaluate()
        }
    }
    
    private var isSuspended: Bool = false {
        didSet {
            evaluate()
        }
    }
}

extension Baraba: FaceTrackerDelegate {
    func trackerDidStartTrackingFace(_ tracker: FaceTracker) {
        print("------- facing content")
        isFacing = true
    }
    
    func trackerDidEndTrackingFace(_ tracker: FaceTracker) {
        print("------- looking away")
        isFacing = false
    }
    
    func trackerWasInterrupted(_ tracker: FaceTracker) {
        print("------- interrupted")
        isSuspended = true
    }
    
    func trackerInterruptionEnded(_ tracker: FaceTracker) {
        print("------- interruption ended")
        isSuspended = false
    }
}
