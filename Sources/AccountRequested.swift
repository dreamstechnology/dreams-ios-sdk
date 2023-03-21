//
//  AccountRequested
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2023 Dreams Technology AB.
//

import Foundation

public struct AccountRequestedError: Error {
    public init(requestId: String, reason: String) {
        self.requestId = requestId
        self.reason = reason
    }

    let requestId: String
    let reason: String
}

public struct AccountRequestedSuccess {
    public init(requestId: String) {
        self.requestId = requestId
    }

    let requestId: String
}
