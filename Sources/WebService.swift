//
//  WebService
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import Foundation
import WebKit

typealias JSONObject = [String: Any]

final class WebService: NSObject, WebServiceType {

    private enum Constants {
        static let jsonMimetype = "application/json"
        static let headerContentType = "Content-Type"
    }

    var delegate: WebServiceDelegate?
    
    private var completion: ((Result<Void, DreamsLaunchingError>) -> Void)?
    private var isRunning: Bool = false
    private var headers: [String: String]? = nil
    
    func set(headers: [String : String]?) {
        self.headers = headers
    }

    func load(url: URL, method: String, body: JSONObject? = nil, completion: ((Result<Void, DreamsLaunchingError>) -> Void)?) {
        guard !isRunning else {
            completion?(.failure(.alreadyLaunched))
            return
        }
        isRunning = true
        self.completion = completion
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.addValue(Constants.jsonMimetype, forHTTPHeaderField: Constants.headerContentType)
        
        if let httpBody = body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: httpBody)
        }
        
        delegate?.webServiceDidPrepareRequest(service: self, urlRequest: urlRequest)
    }

    func prepareRequestMessage(event: Request, with jsonObject: JSONObject?) {
        guard let jsString = encode(event: event, with: jsonObject) else { return }
        delegate?.webServiceDidPrepareMessage(service: self, jsString: jsString)
    }

    func handleResponseMessage(name: String, body: Any?) {
        let (optionalEvent, jsonObject) = transformResponseMessage(name: name, body: body)
        guard let event = optionalEvent else { return }
        delegate?.webServiceDidReceiveMessage(service: self, event: event, jsonObject: jsonObject)
    }
}

private extension WebService {

    func encode(event: Request, with jsonObject: JSONObject?) -> String? {
        guard
            let jsonObject = jsonObject,
            let data = try? JSONSerialization.data(withJSONObject: jsonObject),
            let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        let message = "\(event.rawValue)('\(jsonString)')"
        return message
    }

    func transformResponseMessage(name: String, body: Any?) -> (ResponseEvent?, JSONObject?) {
        let event = ResponseEvent(rawValue: name)
        let jsonObject = body as? JSONObject
        return (event, jsonObject)
    }
}

extension WebService {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handleResponseMessage(name: message.name, body: message.body)
    }
}

// MARK: WKNavigationDelegate

extension WebService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor
                 navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.allow)
            return
        }
        switch response.statusCode {
        case 200...299:
            handleSuccess()
        case 422:
            handleError(.invalidCredentials)
        default:
            handleError(.httpErrorStatus(response.statusCode))
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(.requestFailure(error as NSError))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let headers = headers else {
            decisionHandler(.allow)
            return
        }
        
        let existingHeaders = navigationAction.request.allHTTPHeaderFields ?? [:]
        let hasRequiredHeaders = headers.allSatisfy { key, value in
            existingHeaders[key] == value
        }
        
        guard !hasRequiredHeaders else {
            decisionHandler(.allow)
            return
        }

        var modifiedRequest = navigationAction.request
        
        for (key, value) in headers {
            modifiedRequest.addValue(value, forHTTPHeaderField: key)
        }
        delegate?.webServiceDidPrepareRequest(service: self, urlRequest: modifiedRequest)
        decisionHandler(.cancel)
    }
    
    private func handleError(_ error: DreamsLaunchingError) {
        completion?(.failure(error))
        completion = nil
        isRunning = false
    }
    
    private func handleSuccess() {
        completion?(.success(()))
        completion = nil
        isRunning = false
    }
}
