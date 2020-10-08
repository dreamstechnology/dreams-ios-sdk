//
//  DreamsWebServiceDelegate
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import Foundation

/**
 The delegate for the `DreamsWebService`
 */
protocol DreamsWebServiceDelegate {

    /**
     Delegate callback as a result of calling `load(:url:method:body:)` function on the dreams web service object.
     - parameter service: The dreams web service object invoking the delegate method.
     - parameter urlRequest:The `URLRequest` to use when loading the web view.

     # Notes: #
     The urlRequest should be able to be passed directly to web views `load(_:)` function
     */
    func dreamsWebServiceDidPrepareRequest(service: DreamsWebServiceType, urlRequest: URLRequest)

    /**
     Delegate callback as a result of calling `prepareRequestMessage(event:jsonObject)` function on the dreams web service object.
     - parameter service: The dreams web service object invoking the delegate method.
     - parameter jsString: The javascript string to use when evaluating javascript.

     # Notes: #
     The `jsString` should be able to be passed directly to the web views `evaluateJavaScript(_:completionHandler:)`function.
     */
    func dreamsWebServiceDidPrepareMessage(service: DreamsWebServiceType, jsString: String)

    /**
     Delegate callback as a result of  the WKScriptHandlers `userContentController(_:didReceive:)` function.
     - parameter service: The dreams web service object invoking the delegate method.
     - parameter event: The received DreamsEvent.Response type.
     - parameter (optional) jsonObject: The received JSONObject.
     */
    func dreamsWebServiceDidReceiveMessage(service: DreamsWebServiceType, event: DreamsEvent.Response, jsonObject: JSONObject?)
}
