//
//  File
//  DreamsTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2021 Dreams AB.
//

import Foundation
@testable import Dreams

final class DreamsNetworkInteractingSpy: DreamsNetworkInteracting {

    var didLoadCount: Int = 0
    var useWebViews: [WebViewProtocol] = []
    var useDelegates: [DreamsDelegate] = []
    var navigateToLocations: [String] = []
    var useNavigations: [ViewControllerPresenting] = []
    var launchCredentials: [DreamsCredentials] = []
    var launchLocations: [String?] = []
    var completions: [((Result<Void, DreamsLaunchingError>) -> Void)] = []
    var launchLocales: [Locale] = []
    var updateLocales: [Locale] = []
    var launchHeaders: [[String: String]?] = []
    var updateHeaders: [[String: String]?] = []
    
    func didLoad() {
        didLoadCount += 1
    }
    
    func use(webView: WebViewProtocol) {
        useWebViews.append(webView)
    }
    
    func use(delegate: DreamsDelegate) {
        useDelegates.append(delegate)
    }
    
    public func launch(
        credentials: DreamsCredentials,
        location: String?,
        locale: Locale?,
        theme: String?,
        timezone: String?,
        headers: [String: String]? = nil,
        completion: ((Result<Void, DreamsLaunchingError>) -> Void)?
    ) {
        launchCredentials.append(credentials)
        if let location = location {
            launchLocations.append(location)
        }
        if let locale = locale {
            launchLocales.append(locale)
        }
        if let headers = headers {
            launchHeaders.append(headers)
        }
        if let completion = completion {
            completions.append(completion)
        }
    }
    
    func update(locale: Locale) {
        updateLocales.append(locale)
    }
    
    func update(headers: [String : String]?) {
        updateHeaders.append(headers)
    }

    func navigateTo(location: String) {
        navigateToLocations.append(location)
    }

    func use(navigation: ViewControllerPresenting) {
        useNavigations.append(navigation)
    }
}
