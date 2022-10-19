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
public class ViewController: UIViewController {

    private let logger = Logger(label: "com.jundaai.OrionTestTask.ViewController")

    private var progressBar: UIProgressView!
    private var startButton: UIButton!

    private var webView: WKWebView!
    private var webViewIsHidden: NSKeyValueObservation!
    private var webViewEstimatedProgress: NSKeyValueObservation!

    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var refreshButton: UIBarButtonItem!

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
        setupWebView()
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
            // FIXME: set webView.bottomAnchor to toolbar.topAnchor
            webView.bottomAnchor.constraint(equalToSystemSpacingBelow: safeArea.bottomAnchor, multiplier: 1.0),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        webViewIsHidden = webView.observe(\.isHidden) { [self] newWebView, _ in
            refreshButton.isEnabled = !newWebView.isHidden
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

    private func setupBottomToolbar() {
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

        navigationController?.navigationBar.isHidden = true
        navigationController?.isToolbarHidden = false
    }

    @objc func backButtonDidPress() {
        logger.info("back button pressed")
        if webView.canGoBack {
            webView.goBack()
        } else {
            webView.isHidden = true
            backButton.isEnabled = false
            forwardButton.isEnabled = true
        }
    }

    @objc func forwardButtonDidPress() {
        logger.info("forward button pressed")
        if webView.isHidden {
            webView.isHidden = false
            backButton.isEnabled = true
            forwardButton.isEnabled = webView.canGoForward
        } else if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func refreshButtonDidPress() {
        logger.info("refresh button pressed")
        progressBar.isHidden = false
        progressBar.setProgress(0.0, animated: true)
        webView.reload()
    }

}

// MARK: WKUIDelegate
extension ViewController: WKUIDelegate {

}

// MARK: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.info("did finish loading \(webView.title!)")
        backButton.isEnabled = webView.canGoBack || !webView.isHidden
        forwardButton.isEnabled = webView.canGoForward || webView.isHidden
    }

}
