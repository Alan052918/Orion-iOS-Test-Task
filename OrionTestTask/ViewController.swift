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

    private var progressBar: UIProgressView!
    private var startButton: UIButton!

    private var webView: WKWebView!

    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!

    private var webViewEstimatedProgress: NSKeyValueObservation!
    private var webViewCanGoBack: NSKeyValueObservation!
    private var webViewCanGoForward: NSKeyValueObservation!

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupProgressBar()
        setupStartButton()
        setupWebView()
        setupBottomToolbar()
    }

    private func setupProgressBar() {
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.backgroundColor = .gray
        progressBar.tintColor = .blue
        progressBar.setProgress(0.0, animated: true)

        view.addSubview(progressBar)
        progressBar.isHidden = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
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
        webView.isHidden = false
        let url = URL(string: "https://www.kagi.com")!
        Task {
            await loadURL(url: url)
        }
    }

    @discardableResult
    private func loadURL(url: URL) async -> WKNavigation? {
        return webView.load(URLRequest(url: url))
    }

    private func setupBottomToolbar() {
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: webView,
                                     action: #selector(webView.goBack))
        backButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
        backButton.isEnabled = false
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"),
                                        style: .plain,
                                        target: webView,
                                        action: #selector(webView.goForward))
        forwardButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray],
                                             for: .disabled)
        forwardButton.isEnabled = false
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                        target: webView,
                                        action: #selector(webView.reload))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, backButton, spacer, forwardButton, spacer, refreshButton, spacer]

        navigationController?.navigationBar.isHidden = true
        navigationController?.isToolbarHidden = false
    }

    @objc func backButtonDidPress() {
        logger.info("back button pressed")
        webView.goBack()
    }

    @objc func forwardButtonDidPress() {
        logger.info("forward button pressed")
        webView.goForward()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.underPageBackgroundColor = .clear
        webView.allowsBackForwardNavigationGestures = true

        view.addSubview(webView)
        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
            webView.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1.0),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webViewEstimatedProgress = webView.observe(\.estimatedProgress) { [self] newWebView, _ in
            progressBar.setProgress(Float(newWebView.estimatedProgress), animated: true)
            if newWebView.estimatedProgress < 1 {
                progressBar.isHidden = false
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                progressBar.isHidden = true
            }
        }
        webViewCanGoBack = webView.observe(\.canGoBack) { [self] newWebView, _ in
            backButton.isEnabled = newWebView.canGoBack
        }
        webViewCanGoForward = webView.observe(\.canGoForward) { [self] newWebView, _ in
            forwardButton.isEnabled = newWebView.canGoForward
        }
    }

}

extension ViewController: WKUIDelegate {

}

extension ViewController: WKNavigationDelegate {

}
