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
        sceneView = ARSCNView(frame: .one)
        sceneView.isHidden = true
        
        window = UIWindow(frame: .one)
        window.windowLevel = .normal - 999
        window.addSubview(sceneView)
        
        super.init()
        
        sceneView.session.delegate = self
        sceneView.session.delegateQueue = sessionQueue
        sceneView.delegate = self
    }

    internal func resume() {
        isTracking = false
        sceneView.session.run(ARFaceTrackingConfiguration(), options: [])
        
    }
    
    internal func pause() {
        sceneView.session.pause()
    }
    
    private var isTracking: Bool = false
    private let sceneView: ARSCNView
    private let window: UIWindow
    private let sessionQueue = DispatchQueue(label: "com.nsoojin.baraba.arsession.queue",
                                             qos: .userInteractive,
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
}

extension ARFaceTracker: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let faceAnchor = anchor as? ARFaceAnchor

        if faceAnchor?.isTracked == true && isTracking == false {
            isTracking = true
            delegate?.trackerDidStartTrackingFace(self)
        } else if faceAnchor?.isTracked == false && isTracking == true {
            isTracking = false
            delegate?.trackerDidEndTrackingFace(self)
        }
    }
}

extension ARFaceTracker: ARSessionDelegate {
    public func sessionWasInterrupted(_ session: ARSession) {
        delegate?.trackerWasInterrupted(self)
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        delegate?.trackerInterruptionEnded(self)
    }
}
