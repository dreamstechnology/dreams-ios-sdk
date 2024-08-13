//
//  WebServiceJS
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2024 Dreams Technology AB.
//

import Foundation

enum WebServiceJS: String {
    case additionalHTTPHeaders
    
    var jsString: String {
        switch self {
        case .additionalHTTPHeaders:
            """
            (function() {
                window.additionalHeaders = {};
                window.setAdditionalHeaders = function(headers) {
                    try {
                        window.additionalHeaders = JSON.parse(headers);
                    } catch (e) {
                        console.error('Failed to parse headers:', e);
                    }
                };
                                        
                const originalFetch = window.fetch;
                                        
                window.fetch = function(input, init) {
                    if (!init) {
                        init = {};
                    }

                    if (!init.headers) {
                        init.headers = {};
                    }
                    for (const header in window.additionalHeaders) {
                        init.headers[header] = window.additionalHeaders[header];
                    }
                    return originalFetch(input, init);
                };
            })();
        """
        }
    }
}
