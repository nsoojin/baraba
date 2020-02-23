//
// BarabaError.swift
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
import ARKit

public enum BarabaError: Error {
    /**
     An error code that indicates the app doesn't have user permission to use the camera.
     
     When this error occurs, you may prompt the user to give your app permission to use the camera in Settings.
     */
    case cameraUnauthorized
    
    /**
     An error code that indicates the configuration you chose to create Baraba object is not supported on the device.
     
     Call `Baraba.isConfigurationSupported(_:)` to ensure it's supported before attempting to create and run it on the Baraba object with `resume()`.
     */
    case unsupportedConfiguration
    
    /**
     An error code that indicates the camera sensor has failed.
     
     Underlying error object is provided by either AVFoundation or ARKit.
    */
    case cameraFailed(Error)
    
    /**
     An error code that indicates an unknown error has occured.
    */
    case unknown
}
