//
// AVFaceTracker.swift
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

import AVFoundation

internal class AVFaceTracker: NSObject, FaceTracker {
    internal static var isSupported: Bool {
        return AVCaptureDevice.frontCamera != nil
    }
    
    internal weak var delegate: FaceTrackerDelegate?
    
    internal required override init() {
        super.init()
        
        if AVCaptureDevice.isAuthorizedForVideo {
            configurationQueue.async { self.configureSession() }
        }
    }
    
    internal func resume() {
        isTracking = false
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            guard let self = self else {
                return
            }
            
            if isGranted {
                self.configurationQueue.async {
                    if self.isSessionConfigured == false {
                        self.configureSession()
                    }
                    
                    self.observeAVFoundationNotifications()
                    self.session.startRunning()
                }
            } else {
                self.delegate?.tracker(self, didFailWithError: BarabaError.cameraUnauthorized)
            }
        }
    }
    
    internal func pause() {
        configurationQueue.async {
            self.session.stopRunning()
            self.removeObservers()
        }
    }
    
    private func configureSession() {
        guard let deviceInput = try? AVCaptureDevice.frontCamera.map(AVCaptureDeviceInput.init(device:)),
            session.canAddInput(deviceInput) else {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .low
        session.addInput(deviceInput)

        let metadataOutput = AVCaptureMetadataOutput()
        session.addOutput(metadataOutput)
        
        if metadataOutput.availableMetadataObjectTypes.contains(.face) {
            metadataOutput.metadataObjectTypes = [.face]
        }

        metadataOutput.setMetadataObjectsDelegate(self, queue: dataOutputQueue)
        session.commitConfiguration()
    }
    
    private func observeAVFoundationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    @objc
    internal func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? Error else {
            delegate?.tracker(self, didFailWithError: BarabaError.unknown)
            return
        }
        
        // .mediaServicesWereReset is a recoverable error
        if (error as NSError).code != AVError.Code.mediaServicesWereReset.rawValue {
            delegate?.tracker(self, didFailWithError: error)
        }
    }
    
    @objc
    internal func sessionWasInterrupted(notification: NSNotification) {
        delegate?.trackerWasInterrupted(self)
    }
    
    @objc
    internal func sessionInterruptionEnded(notification: NSNotification) {
        delegate?.trackerInterruptionEnded(self)
    }
    
    deinit {
        removeObservers()
    }
    
    private var isTracking: Bool = false
    
    private var isSessionConfigured: Bool {
        session.outputs.isEmpty == false
    }
    
    private let session = AVCaptureSession()
    
    private let configurationQueue = DispatchQueue(label: "\(Constant.bundleIdentifier).avsession.queue",
                                                   attributes: [],
                                                   autoreleaseFrequency: .workItem)
    
    private let dataOutputQueue = DispatchQueue(label: "\(Constant.bundleIdentifier).metadata.queue",
                                                qos: .userInteractive,
                                                attributes: [],
                                                autoreleaseFrequency: .workItem)
}

extension AVFaceTracker: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let isFaceDetected = metadataObjects.contains(where: { $0.type == .face })
        
        if isFaceDetected && isTracking == false {
            isTracking = true
            delegate?.trackerDidStartTrackingFace(self)
        } else if isFaceDetected == false && isTracking == true {
            isTracking = false
            delegate?.trackerDidEndTrackingFace(self)
        }
    }
}
