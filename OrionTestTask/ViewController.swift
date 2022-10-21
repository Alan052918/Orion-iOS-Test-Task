//
//  ViewController.swift
//  OrionTestTask
//
//  Created by Junda Ai on 10/16/22.
//

import Logging
import UIKit
import WebKit

// MARK: UIViewController
class ViewController: UIViewController {

    let logger = Logger(label: "com.jundaai.OrionTestTask.ViewController")

    let progressBar = UIProgressView()
    let startButton = UIButton()

    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var refreshButton: UIBarButtonItem!

    let leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    let rightEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()

    lazy var webView = WKWebView()
    private var webViewIsHidden: NSKeyValueObservation?
    private var webViewEstimatedProgress: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupProgressBar()
        setupStartButton()
        setupToolbar()
        setupGestureRecognizers()
        setupWebView()
    }

    func setupProgressBar() {
        progressBar.progressViewStyle = .default
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

    func setupStartButton() {
        startButton.configuration = .filled()
        startButton.configuration?.title = "start"
        startButton.addTarget(self, action: #selector(startButtonDidPress), for: .touchUpInside)

        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startButtonDidPress() {
        webView.isHidden = false
//        let url = URL(string: "https://www.kagi.com")!
//        let url = URL(string: "https://github1s.com/lynoapp/")!
        // swiftlint:disable:next line_length
        let url = URL(string: "https://stil.kurir.rs/moda/157971/ovo-su-najstilizovanije-zene-sveta-koja-je-po-vama-br-1-anketa")!
        Task {
            await loadURL(url: url)
        }
    }

    @discardableResult func loadURL(url: URL) async -> WKNavigation? {
        return webView.load(URLRequest(url: url))
    }

    func setupWebView() {
        webView.underPageBackgroundColor = .clear
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
            webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webViewIsHidden = webView.observe(\.isHidden) { [self] newWebView, _ in
            refreshButton.isEnabled = !newWebView.isHidden
            startButton.isHidden = !newWebView.isHidden
        }
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
    }

    func setupToolbar() {
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(backButtonDidPress))
        backButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
        backButton.isEnabled = false
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(forwardButtonDidPress))
        forwardButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray],
                                             for: .disabled)
        forwardButton.isEnabled = false
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                        target: self,
                                        action: #selector(refreshButtonDidPress))
        refreshButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray],
                                             for: .disabled)
        refreshButton.isEnabled = false
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [spacer, backButton, spacer, forwardButton, spacer, refreshButton, spacer]
    }

    @objc func backButtonDidPress() {
        logger.info("back button pressed")
        webViewGoBack()
    }

    @objc func forwardButtonDidPress() {
        logger.info("forward button pressed")
        webViewGoForward()
    }

    @objc func refreshButtonDidPress() {
        logger.info("refresh button pressed")
        progressBar.isHidden = false
        progressBar.setProgress(0.0, animated: true)
        webView.reload()
    }

    func setupGestureRecognizers() {
        leftEdgePanGestureRecognizer.addTarget(self, action: #selector(leftScreenEdgeDidSwipe))
        leftEdgePanGestureRecognizer.edges = .left
        leftEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(leftEdgePanGestureRecognizer)

        rightEdgePanGestureRecognizer.addTarget(self, action: #selector(rightScreenEdgeDidSwipe))
        rightEdgePanGestureRecognizer.edges = .right
        rightEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(rightEdgePanGestureRecognizer)
    }

    @objc func leftScreenEdgeDidSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        logger.info("left screen edge swiped")
        webViewGoBack()
    }

    @objc func rightScreenEdgeDidSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        logger.info("right screen edge swiped")
        webViewGoForward()
    }

    func webViewGoBack() {
        guard backButton != nil,
              forwardButton != nil else { return }
        if webView.canGoBack {
            webView.goBack()
        } else {
            webView.isHidden = true
            backButton.isEnabled = false
            forwardButton.isEnabled = true
        }
    }

    func webViewGoForward() {
        guard backButton != nil,
              forwardButton != nil else { return }
        if webView.isHidden {
            webView.isHidden = false
            backButton.isEnabled = true
            forwardButton.isEnabled = webView.canGoForward
        } else if webView.canGoForward {
            webView.goForward()
        }
    }

}

// MARK: WKUIDelegate
extension ViewController: WKUIDelegate {

}

// MARK: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.info("did finish loading \(webView.title!)")
        backButton.isEnabled = webView.canGoBack || !webView.isHidden
        forwardButton.isEnabled = webView.canGoForward || webView.isHidden
    }

}

extension ViewController: UIGestureRecognizerDelegate {

}
