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

/**
 A configuration that defines behavior for a Baraba object.
*/
public struct BarabaConfiguration {
    internal let tracker: FaceTracker
    
    internal init(tracker: FaceTracker) {
        self.tracker = tracker
    }
    
    private init() {
        if ARFaceTracker.isSupported {
            self.tracker = ARFaceTracker()
        } else {
            self.tracker = AVFaceTracker()
        }
    }
}

extension BarabaConfiguration {
    /**
     An automatic configuration. Baraba determines which configuration to use based on hardware availability.
    
     If the device supports `ARFaceTrackingConfiguration`, then `BarabaConfiguration.ar` is used. Otherwise, `BarabaConfiguration.av` is used.
    */
    public static let automatic: BarabaConfiguration = BarabaConfiguration()
    
    /**
     A configuration that uses ARKit Face Tracking to detect faces.

     ARKit Face Tracking is available only on iOS devices with a front-facing TrueDepth camera. Call `Baraba.isConfigurationSupported(_:)` to determine whether this configuration is available on the current device.
     
     - important:
        If you use this configuration, your app must include a privacy policy describing to users how you intend to use face tracking and face data. See [link](https://github.com/nsoojin/baraba#%EF%B8%8F-important) for more details.
    */
    public static let ar: BarabaConfiguration = BarabaConfiguration(tracker: ARFaceTracker())
    
    /**
     A configuration that uses AVFoundation to track faces.
    */
    public static let av: BarabaConfiguration = BarabaConfiguration(tracker: AVFaceTracker())
    
}
