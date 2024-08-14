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
                                        
                window.fetch = function(resource, options) {
                    if (!options) {
                        options = {};
                    }

                    if (!options.headers) {
                        options.headers = {};
                    }

                    for (const header in window.additionalHeaders) {
                        options.headers[header] = window.additionalHeaders[header];
                    }

                    if (resource instanceof Request) {
                        options.headers = Object.assign(
                            {},
                            Object.fromEntries(resource.headers.entries()),
                            options.headers
                        );
                    }

                    console.log('patched window.fetch with', resource, options);

                    return originalFetch(resource, options);
                };
            })();
        """
        }
    }
}
