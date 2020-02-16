//
// BarabaConfiguration.swift
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

public struct BarabaConfiguration {
    public var isSupported: Bool {
        trackerType.isSupported
    }
    
    public var pauseDuration: TimeInterval
    
    internal let trackerType: FaceTracker.Type
    
    private init(trackerType: FaceTracker.Type, pauseDuration: TimeInterval = 2.0) {
        self.trackerType = trackerType
        self.pauseDuration = pauseDuration
    }
    
    private init() {
        if ARFaceTracker.isSupported {
            self.trackerType = ARFaceTracker.self
        } else {
            self.trackerType = AVFaceTracker.self
        }
        
        pauseDuration = 2.0
    }
}

extension BarabaConfiguration {
    
    public static let `default`: BarabaConfiguration = BarabaConfiguration()
    
    public static let ar: BarabaConfiguration = BarabaConfiguration(trackerType: ARFaceTracker.self)
    
    public static let av: BarabaConfiguration = BarabaConfiguration(trackerType: AVFaceTracker.self)
    
}
