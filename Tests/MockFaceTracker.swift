//
// MockFaceTracker.swift
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

import Foundation
@testable import Baraba

typealias MockAction = (FaceTrackerDelegate) -> ()

class MockFaceTracker: FaceTracker {
    var isResumed: Bool = false
    var action: MockAction?
    var delegate: FaceTrackerDelegate?
    
    func resume() {
        isResumed = true
        workQueue.async { [weak self] in
            if let delegate = self?.delegate {
                self?.action?(delegate)
            }
        }
    }
    
    func pause() {
        isResumed = false
    }
    
    required init() {}
    
    private let workQueue = DispatchQueue(label: "com.nsoojin.tests.mock-tracker")
    static var isSupported: Bool = true
    static var isHardwareAuthorized: Bool = true
    static var isHardwareDenied: Bool = false
}

class UnsupportedMockFaceTracker: FaceTracker {
    static var isSupported: Bool = false
    static var isHardwareAuthorized: Bool = true
    
    var delegate: FaceTrackerDelegate?
    
    func resume() {}
    
    func pause() {}
    
    required init() {}
}

class HardwareDeniedFaceTracker: FaceTracker {
    static var isSupported: Bool = true
    static var isHardwareAuthorized: Bool = false
    
    var delegate: FaceTrackerDelegate?
    
    func resume() {}
    
    func pause() {}
    
    required init() {}
}
