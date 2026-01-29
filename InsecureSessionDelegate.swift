//
//  InsecureSessionDelegate.swift
//  Liquid
//
//  Created by Giuseppe Pizzini on 15/12/25.
//


import Foundation

final class InsecureSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // DEV ONLY: accetta qualsiasi certificato
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

enum InsecureURLSession {
    static let shared: URLSession = {
        let delegate = InsecureSessionDelegate()
        return URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }()
}