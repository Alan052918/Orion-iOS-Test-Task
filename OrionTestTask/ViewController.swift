//
//  ViewController.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/16/22.
//

import Logging
import UIKit
import WebKit

public class ViewController: UIViewController {

    private let logger = Logger(label: "com.jundaai.OrionTestTask.ViewController")

    private var startButton: UIButton!

    private var webView: WKWebView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupStartButton()
        setupWebView()
    }

    private func setupStartButton() {
        startButton = UIButton()
        startButton.configuration = .filled()
        startButton.configuration?.title = "kagi.com"
        startButton.configuration?.baseBackgroundColor = .systemBlue
        startButton.addTarget(self, action: #selector(startButtonDidPress), for: .touchUpInside)

        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonDidPress() {
        logger.info("start button pressed")
        webView.isHidden = false
        let myURL = URL(string: "https://www.kagi.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        view.addSubview(webView)
        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
            webView.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1.0)
        ])
    }

}

extension ViewController: WKUIDelegate {

}

extension ViewController: WKNavigationDelegate {

}
