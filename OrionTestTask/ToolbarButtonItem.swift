//
//  ToolbarButtonItem.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/21/22.
//

import UIKit

class ToolbarButtonItem: UIBarButtonItem {

    static let spacerItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()

    override init() {
        super.init()
        isEnabled = false
        setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func spacer() -> UIBarButtonItem {
        return spacerItem
    }

}
