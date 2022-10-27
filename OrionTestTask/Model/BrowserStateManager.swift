//
//  DataModel.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/26/22.
//

import Logging
import UIKit

class BrowserStateManager {

    static let sharedInstance: BrowserStateManager = {
        let instance = BrowserStateManager()
        instance.loadBrowserState()
        return instance
    }()

    let logger = Logger(label: "com.jundaai.OrionTestTask.BrowserStateManager")

    var browserState: BrowerState!

    private let dataFileName = "BrowserState"

    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func browserStateModelURL() -> URL {
        let docURL = documentsDirectory()
        return docURL.appendingPathExtension(dataFileName)
    }

    func saveBrowserState() {
        logger.info("save browser state")

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(browserState) {
            do {
                try encoded.write(to: browserStateModelURL())
            } catch {
                logger.error("Couldn't write to save file: \(error.localizedDescription)")
            }
        }
    }

    func loadBrowserState() {
        logger.info("load browser state")

        let decoder = JSONDecoder()
        if let codedData = try? Data(contentsOf: browserStateModelURL()) {
            do {
                let decoded = try decoder.decode(BrowerState.self, from: codedData)
                browserState = decoded
            } catch {
                logger.error("Couldn't load from file: \(error.localizedDescription)")
            }
        }
    }

}
