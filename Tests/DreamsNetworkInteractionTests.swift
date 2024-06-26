//
//  DreamsViewControllerDelegateTests
//  DreamsTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import XCTest
import WebKit
@testable import Dreams

final class NavigationMock: ViewControllerPresenting {

    var presentViewControllers: [UIViewController] = []

    func present(viewController: UIViewController) {
        presentViewControllers.append(viewController)
    }
}

final class DreamsNetworkInteractionTests: XCTestCase {

    private var service: WebServiceSpy!
    private var webView: WebViewSpy!
    private var delegate: DreamsDelegateSpy!
    private var localeFormatter: LocaleFormatterMock!
    private var navigationMock: NavigationMock!

    private var subject: DreamsNetworkInteraction!

    override func setUpWithError() throws {
        let configuration = DreamsConfiguration(clientId: "clientId",
                                                baseURL: URL(string: "https://www.dreamstech.com")!)
        service = WebServiceSpy()
        localeFormatter = LocaleFormatterMock()
        subject = DreamsNetworkInteraction(configuration: configuration,
                                           webService: service,
                                           localeFormatter: localeFormatter)
        navigationMock = NavigationMock()
        subject.use(navigation: navigationMock)

        delegate = DreamsDelegateSpy()
        subject.use(delegate: delegate)

        webView = WebViewSpy(configuration: WKWebViewConfiguration())
        subject.use(webView: webView)
    }

    func test_didLoad_didSetDelegate() {
        subject.didLoad()

        XCTAssertNotNil(service.delegate)
    }

    func test_didLoad_addedHandlers() {
        subject.didLoad()

        XCTAssertEqual(webView.scriptMessageHandlers.count, 7)
    }

    func test_launch_didCallLocaleFormatter() {
        let localeId = "sv"
        let locale = Locale(identifier: localeId)

        subject.launch(credentials: DreamsCredentials(idToken: "idToken"), locale: locale)

        XCTAssertEqual(localeFormatter.formatsGiven.count, 1)
        XCTAssertEqual(localeFormatter.localesGiven.count, 1)
        XCTAssertEqual(localeFormatter.formatsGiven.first!, .bcp47)
        XCTAssertEqual(localeFormatter.localesGiven.first!, locale)
    }

    func test_launch_calledCorrectRequest() {
        localeFormatter.returnString = "sv"

        subject.launch(credentials: DreamsCredentials(idToken: "idToken"), locale: Locale(identifier: "sv"))

        let expectedBody: [String: Any] = ["token": "idToken", "locale": "sv", "client_id": "clientId"]
        let httpBody = service.load_bodys.first!
        XCTAssertEqual(service.load_urls.count, 1)
        XCTAssertEqual(service.load_bodys.count, 1)
        XCTAssertEqual(service.load_methods.count, 1)
        XCTAssertEqual(service.load_urls.first?.absoluteString, "https://www.dreamstech.com/users/verify_token")
        XCTAssertEqual(service.load_methods.first, "POST")
        XCTAssertEqual(NSDictionary(dictionary: expectedBody), NSDictionary(dictionary: httpBody))
    }

    func test_launchWithLocation_calledCorrectRequest() {
        localeFormatter.returnString = "sv"

        subject.launch(credentials: DreamsCredentials(idToken: "idToken"), locale: Locale(identifier: "sv"), location: "drybones", completion: nil)

        let expectedBody: [String: Any] = ["token": "idToken", "locale": "sv", "client_id": "clientId"]
        let httpBody = service.load_bodys.first!
        XCTAssertEqual(service.load_urls.count, 1)
        XCTAssertEqual(service.load_bodys.count, 1)
        XCTAssertEqual(service.load_methods.count, 1)
        XCTAssertEqual(service.load_urls.first?.absoluteString, "https://www.dreamstech.com/users/verify_token?location=drybones")
        XCTAssertEqual(service.load_methods.first, "POST")
        XCTAssertEqual(NSDictionary(dictionary: expectedBody), NSDictionary(dictionary: httpBody))
    }

    func test_launch_passedCompletionToWebService() {
        let completion: (Result<Void, DreamsLaunchingError>) -> Void = { result in

        }

        subject.launch(credentials: DreamsCredentials(idToken: "idToken"), locale: Locale(identifier: "sv_SE"), location: nil, completion: completion)

        XCTAssertEqual(service.completions.count, 1)
    }

    func test_launch_sucess_notified() {
        var called = false
        let completion: (Result<Void, DreamsLaunchingError>) -> Void = { result in
            called = true
        }

        subject.launch(credentials: DreamsCredentials(idToken: "idToken"), locale: Locale(identifier: "sv_SE"), location: nil, completion: completion)
        service.completions.first!(.success(()))

        XCTAssertTrue(called)
    }

    func test_webServiceDidPrepareRequest_requestedWebView() {
        let request = URLRequest(url: URL(string: "https://www.dreamstech.com")!)
        subject.webServiceDidPrepareRequest(service: service, urlRequest: request)

        XCTAssertEqual(webView.requests.count, 1)
        XCTAssertEqual(webView.requests.first, request)
    }

    func test_webServiceDidPrepareMessage() {
        let jsString = "jsString"
        subject.webServiceDidPrepareMessage(service: service, jsString: jsString)

        XCTAssertEqual(webView.javaScriptStrings.count, 1)
        XCTAssertEqual(webView.javaScriptStrings.first, jsString)
    }

    func test_webServiceDidReceiveMessage_onAccountProvisionRequested_calledDelegate() {
        let event = ResponseEvent.onAccountProvisionRequested

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: ["requestId": "request_id"])

        XCTAssertEqual(delegate.handleDreamsAccountProvisionInitiatedCompletions.count, 1)
    }

    func test_webServiceDidReceiveMessage_onExitRequested_calledDelegate() {
        let event = ResponseEvent.onExitRequested

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: nil)

        XCTAssertEqual(delegate.handleExitRequestCount, 1)
    }

    func test_webServiceDidReceiveMessage_onIdTokenDidExpire_calledDelegate() {
        let event = ResponseEvent.onIdTokenDidExpire

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject:  ["requestId": "request_id"])

        XCTAssertEqual(delegate.handleDreamsCredentialsExpiredCompletions.count, 1)
    }

    func test_webServiceDidReceiveMessage_onTelemetryEvent_calledDelegate() {
        let event = ResponseEvent.onTelemetryEvent
        let name = "name"

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject:  ["name": name, "payload": ["a":"b"]])

        XCTAssertEqual(delegate.handleDreamsTelemetryEventNames.count, 1)
        XCTAssertEqual(delegate.handleDreamsTelemetryEventNames.first, name)
        XCTAssertEqual(delegate.handleDreamsTelemetryEventPayloads.count, 1)
    }

    func test_webServiceDidReceiveMessage_onAccountProvisionRequested_delegatePerformedACall() {
        let event = ResponseEvent.onAccountProvisionRequested
        let jsonObject =  ["requestId": "request_id"]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: jsonObject)
        delegate.handleDreamsAccountProvisionInitiatedCompletions.first!()

        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .accountProvisionInitiated)
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: jsonObject))
    }

    func test_webServiceDidReceiveMessage_onIdTokenDidExpire_delegatePerformedACall() {
        let event = ResponseEvent.onIdTokenDidExpire
        let token = "bbb"
        let jsonObject =  ["requestId": "request_id"]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject:  jsonObject)
        delegate.handleDreamsCredentialsExpiredCompletions.first!(DreamsCredentials(idToken: token))

        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .updateIdToken)

        let expectedJsonObject =  ["requestId": "request_id", "idToken": token]
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: expectedJsonObject))
    }

    func test_webServiceDidReceiveMessage_share_navigation() {
        let event = ResponseEvent.share
        let jsonObject = ["text":"aaa", "url": "https://dreamstech.com"]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject:  jsonObject)

        XCTAssertEqual(navigationMock.presentViewControllers.count, 1)
        XCTAssertTrue(navigationMock.presentViewControllers.first is UIActivityViewController)
    }

    func test_webServiceDidReceiveMessage_onTransferConsentRequested_delegatePerformedACallSucceeded() {
        let event = ResponseEvent.onTransferConsentRequested
        let jsonObject =  ["requestId": "test request id", "consentId": "test consent id"]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: jsonObject)


        let jsonObjectReturned =  ["requestId": "test request id", "consentId": "test consent id", "consentRef": "test consent ref"]
        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .transferConsentSucceeded)
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: jsonObjectReturned))
    }

    func test_webServiceDidReceiveMessage_onTransferConsentRequested_delegatePerformedACallCancelled() {
        let event = ResponseEvent.onTransferConsentRequested
        let jsonObject =  ["requestId": "test request id", "consentId": "invalid fail me"]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: jsonObject)


        let jsonObjectReturned =  ["requestId": "test request id", "consentId": "invalid fail me"]
        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .transferConsentCancelled)
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: jsonObjectReturned))
    }

    func test_webServiceDidReceiveMessage_onAccountRequested_delegatePerformedACallSucceeded() {
        let event = ResponseEvent.onAccountRequested
            let jsonObject: [String: Any] =  [
            "requestId": "test request id",
            "dream": [
                "type": "dream",
                    "id": "uuid",
                    "name": "name",
                    "target_amount": [
                        "cents": 200,
                        "currency": "SEK"
                    ],
                    "target_date": "2029-01-01",
                    "user": [
                    "type": "user",
                    "id": "test-uuid",
                    "externalId": "test_extuuid",
                    ],
            ]
        ]
            
            
        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: jsonObject)

        let jsonObjectReturned =  ["requestId": "test request id"]
        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .accountRequestedSucceeded)
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: jsonObjectReturned))
    }

    func test_webServiceDidReceiveMessage_onAccountRequested_delegatePerformedACallCancelled() {
        let event = ResponseEvent.onAccountRequested
        let jsonObject: [String: Any] =  [
            "requestId": "invalid fail me",
            "dream": [
                "type": "dream",
                "id": "uuid",
                "name": "name",
            "target_amount": [
                "cents": 200,
                "currency": "SEK"
            ],
            "target_date": "2029-01-01",
            "user": [
                "type": "user",
                "id": "test-uuid",
                "externalId": "test_extuuid",
            ],
          ]
         ]

        subject.webServiceDidReceiveMessage(service: service, event: event, jsonObject: jsonObject)


        let jsonObjectReturned =  ["requestId": "invalid fail me"]
        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, .accountRequestedFailed)
        XCTAssertEqual(NSDictionary(dictionary: service.jsonObjects.first!), NSDictionary(dictionary: jsonObjectReturned))
    }

    func test_send_serviceReceivedEvents() {
        let event = Request.accountProvisionInitiated

        subject.send(event: event, with: nil)

        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, event)
    }

    func test_updateLocale_passedToService() {
        let event = Request.updateLocale

        subject.update(locale: Locale(identifier: "sv_SE"))

        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, event)
    }

    func test_navigateTo_passedToService() {
        let event = Request.navigateTo

        subject.navigateTo(location: "drop_coffee")

        XCTAssertEqual(service.events.count, 1)
        XCTAssertEqual(service.events.first, event)
        XCTAssertEqual(service.jsonObjects.count, 1)
        XCTAssertEqual((service.jsonObjects.first as? [String: String])?["location"], "drop_coffee")
    }
    
    func test_update_headers() {
        subject.update(headers: ["Custom-Header": "header-value"])
        XCTAssertEqual(service.headerObjects.count, 1)
        XCTAssertEqual(service.headerObjects.first, ["Custom-Header": "header-value"])
    }
}
