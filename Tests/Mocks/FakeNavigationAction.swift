//
//  FakeNavigationAction
//  DreamsTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2024 Dreams AB.
//

import Foundation
import WebKit

class FakeWKNavigationAction: WKNavigationAction {
    
    private let fakeRequest: URLRequest
    
    init(fakeRequest: URLRequest) {
        self.fakeRequest = fakeRequest
    }

    override var request: URLRequest {
        fakeRequest
    }
}
