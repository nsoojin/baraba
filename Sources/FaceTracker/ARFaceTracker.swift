//
// ARFaceTracker.swift
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

import ARKit

internal class ARFaceTracker: NSObject, FaceTracker {
    internal static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }

    internal weak var delegate: FaceTrackerDelegate?

    internal required override init() {
        session = ARSession()
        
        super.init()
        
        session.delegate = self
        session.delegateQueue = sessionQueue
    }

    internal func resume() {
        isTracking = false
        session.run(ARFaceTrackingConfiguration(), options: [])
    }
    
    internal func pause() {
        session.pause()
    }
    
    private var isTracking: Bool = false
    private let session: ARSession
    private let sessionQueue = DispatchQueue(label: "\(Constant.bundleIdentifier).arsession.queue",
                                             qos: .userInteractive,
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
}

extension ARFaceTracker: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let faceAnchor = anchors.first as? ARFaceAnchor

        if faceAnchor?.isTracked == true && isTracking == false {
            isTracking = true
            delegate?.trackerDidStartTrackingFace(self)
        } else if faceAnchor?.isTracked == false && isTracking == true {
            isTracking = false
            delegate?.trackerDidEndTrackingFace(self)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        delegate?.trackerWasInterrupted(self)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        delegate?.trackerInterruptionEnded(self)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        delegate?.tracker(self, didFailWithError: error)
    }
}
