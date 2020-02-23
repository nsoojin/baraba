//
// Log.swift
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

import os

internal struct Log {
    internal static func `default`(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: Log.oslog, type: .default, args)
    }
    
    internal static func info(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: Log.oslog, type: .info, args)
    }
    
    internal static func error(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: Log.oslog, type: .error, args)
    }
    
    internal static func debug(_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: Log.oslog, type: .debug, args)
    }
    
    private static let oslog = OSLog(subsystem: Constant.bundleIdentifier, category: "Baraba")
}
