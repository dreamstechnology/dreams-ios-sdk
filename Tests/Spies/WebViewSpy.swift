//
//  WebViewSpy
//  DreamsTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2021 Dreams AB.
//

import Foundation
import WebKit
@testable import Dreams

final class WebViewSpy: WebViewProtocol {
    
    var navigationDelegate: WKNavigationDelegate?
    
    var configuration: WKWebViewConfiguration
    
    var scriptMessageHandlers: [WKScriptMessageHandler] = []
    var names: [String] = []
    var requests: [URLRequest] = []
    var javaScriptStrings: [String] = []
    
    init(configuration: WKWebViewConfiguration) {
        self.configuration = configuration
    }
    
    func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
        scriptMessageHandlers.append(scriptMessageHandler)
        names.append(name)
    }
    
    func load(_ request: URLRequest) -> WKNavigation? {
        requests.append(request)
        
        return nil
    }
    
#if compiler(>=6)
    func evaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)?) {
        javaScriptStrings.append(javaScriptString)
    }
#else
    func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?) {
        javaScriptStrings.append(javaScriptString)
    }
#endif
}
