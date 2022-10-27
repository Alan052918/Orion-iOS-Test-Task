//
//  BrowserState.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/26/22.
//

import Foundation

struct BrowerState: Hashable, Codable {

    enum CoderKeys: String, CodingKey {
        case webViewInteractionState
        case fullWebViewVisibleState
    }

    var webViewInteractionState: Data
    var fullWebViewVisibleState: Bool

    init(webViewInteractionState: Data, fullWebViewVisibleState: Bool) {
        self.webViewInteractionState = webViewInteractionState
        self.fullWebViewVisibleState = fullWebViewVisibleState
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CoderKeys.self)
        webViewInteractionState = try values.decode(Data.self, forKey: .webViewInteractionState)
        fullWebViewVisibleState = try values.decode(Bool.self, forKey: .fullWebViewVisibleState)
    }

    func decodeBrowserState(from data: Data) -> BrowerState? {
        var browserState: BrowerState?
        let decoder = JSONDecoder()
        if let decodedBrowserState = try? decoder.decode(BrowerState.self, from: data) {
            browserState = decodedBrowserState
        }
        return browserState
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CoderKeys.self)
        try container.encode(webViewInteractionState, forKey: .webViewInteractionState)
        try container.encode(fullWebViewVisibleState, forKey: .fullWebViewVisibleState)
    }

}
