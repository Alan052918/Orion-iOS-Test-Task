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

    let webView = WKWebView()
    var webViewEstimatedProgress: NSKeyValueObservation?
    var fullWebViewIsVisible = false {
        didSet {
            startButton.isHidden = fullWebViewIsVisible
            backButton.isEnabled = fullWebViewIsVisible
            refreshButton.isEnabled = fullWebViewIsVisible
        }
    }

    var restoredWebViewInteractionState: Any!
    var restoredFullWebViewVisibleState: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.restorationIdentifier = "baseView"

        setupProgressBar()
        setupStartButton()
        setupToolbar()
        setupGestureRecognizers()
        setupWebView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if restoredWebViewInteractionState != nil {
            webView.interactionState = restoredWebViewInteractionState
        }
        if restoredFullWebViewVisibleState != nil {
            fullWebViewIsVisible = restoredFullWebViewVisibleState
        }

        updateUserActivity()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.window?.windowScene?.userActivity = nil
    }

    func setupProgressBar() {
        progressBar.progressViewStyle = .default
        progressBar.restorationIdentifier = "progressBar"
        progressBar.setProgress(0.0, animated: false)

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
        startButton.layer.cornerRadius = 8
        startButton.layer.cornerCurve = .continuous
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.setTitle("start", for: .normal)
        startButton.restorationIdentifier = "startButton"
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
        webView.load(URLRequest(url: url))

        fullWebViewIsVisible = true
    }

    func setupWebView() {
        webView.restorationIdentifier = "webView"
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

        webViewEstimatedProgress = webView.observe(\.estimatedProgress) { [self] (updatedWebView, _) in
            progressBar.setProgress(Float(updatedWebView.estimatedProgress), animated: true)
        }
    }

    func setupToolbar() {
        backButton = ToolbarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonDidPress))
        forwardButton = ToolbarButtonItem(image: UIImage(systemName: "chevron.forward"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(forwardButtonDidPress))
        refreshButton = ToolbarButtonItem(barButtonSystemItem: .refresh,
                                          target: self,
                                          action: #selector(refreshButtonDidPress))
        let spacer = ToolbarButtonItem.spacer()
        toolbarItems = [spacer, backButton, spacer, forwardButton, spacer, refreshButton, spacer]
    }

    @objc func backButtonDidPress() {
        logger.info("back button pressed")
        guard backButton != nil,
              forwardButton != nil else { return }
        if webView.canGoBack {
            webView.goBack()
        } else {
            webView.isHidden = true
            fullWebViewIsVisible = false
        }
    }

    @objc func forwardButtonDidPress() {
        logger.info("forward button pressed")
        guard backButton != nil,
              forwardButton != nil else { return }
        if webView.isHidden {
            webView.isHidden = false
            fullWebViewIsVisible = true
        } else if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func refreshButtonDidPress() {
        logger.info("refresh button pressed")
        webView.reload()
    }

    func setupGestureRecognizers() {
        leftEdgePanGestureRecognizer.addTarget(self, action: #selector(leftScreenEdgeDidSwipe(_:)))
        leftEdgePanGestureRecognizer.edges = .left
        leftEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(leftEdgePanGestureRecognizer)

        rightEdgePanGestureRecognizer.addTarget(self, action: #selector(rightScreenEdgeDidSwipe(_:)))
        rightEdgePanGestureRecognizer.edges = .right
        rightEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(rightEdgePanGestureRecognizer)
    }

    @objc func leftScreenEdgeDidSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        logger.info("LEFT screen edge swiped")
        if fullWebViewIsVisible {
            popWebView(gestureRecognizer: gestureRecognizer)
        }
    }

    @objc func rightScreenEdgeDidSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        logger.info("RIGHT screen edge swiped")
        if !fullWebViewIsVisible {
            pushWebView(gestureRecognizer: gestureRecognizer)
        }
    }

    func popWebView(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let webViewTranslation = gestureRecognizer.translation(in: view)
        switch gestureRecognizer.state {
        case .began:
            logger.info("LEFT screen edge pan gesture BEGAN")
            startButton.isHidden = false
        case .changed:
            logger.info("LEFT screen edge pan gesture CHANGED: translation.x: \(webViewTranslation.x)")
            UIView.animate(withDuration: 0, delay: 0) { [self] in
                webView.transform = CGAffineTransform(translationX: webViewTranslation.x, y: 0)
            }
        case .ended:
            let popShouldComplete = webViewTranslation.x > view.frame.width / 2
            logger.info("LEFT screen edge pan gesture ENDED: \(popShouldComplete ? "completed" : "cancelled")")
            if popShouldComplete {
                // completed: pop webView out of screen
                UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
                    webView.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
                }, completion: { [self] _ in
                    webView.isHidden = true
                    webView.transform = .identity
                    fullWebViewIsVisible = false
                })
            } else {
                // cancelled: reset webView to full screen position
                UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
                    webView.transform = .identity
                }, completion: { [self] _ in
                    fullWebViewIsVisible = true
                })
            }
        default:
            break
        }
    }

    func pushWebView(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let webViewTranslation = gestureRecognizer.translation(in: view)
        switch gestureRecognizer.state {
        case .began:
            logger.info("RIGHT screen edge pan gesture BEGAN: translation.x: \(webViewTranslation.x)")
            webView.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
            webView.isHidden = false
        case .changed:
            logger.info("RIGHT screen edge pan gesture CHANGED: translation.x: \(webViewTranslation.x)")
            UIView.animate(withDuration: 0, delay: 0) { [self] in
                webView.transform = CGAffineTransform(translationX: view.frame.width + webViewTranslation.x, y: 0)
            }
        case .ended:
            let pushShouldComplete = -webViewTranslation.x > view.frame.width / 2
            logger.info("RIGHT screen edge pan gesture ENDED: \(pushShouldComplete ? "completed" : "cancelled")")
            if pushShouldComplete {
                // completed: push webView to full screen position
                UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
                    webView.transform = .identity
                }, completion: { [self] _ in
                    fullWebViewIsVisible = true
                })
            } else {
                // cancelled: pop webView out of screen
                UIView.animate(withDuration: 0.2, delay: 0, animations: { [self] in
                    webView.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
                }, completion: { [self] _ in
                    webView.isHidden = true
                    webView.transform = .identity
                    fullWebViewIsVisible = false
                })
            }
        default:
            break
        }
    }

}

// MARK: WKUIDelegate
extension ViewController: WKUIDelegate {

}

// MARK: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        logger.info("did commit loading \(webView.title!)")

        progressBar.setProgress(0.0, animated: false)
        progressBar.isHidden = false
        progressBar.alpha = 1
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.info("did finish loading \(webView.title!)")

        forwardButton.isEnabled = webView.canGoForward || !fullWebViewIsVisible

        UIView.animate(withDuration: 0.2, delay: 0.2, animations: { [self] in
            progressBar.alpha = 0
        }, completion: { [self] _ in
            progressBar.isHidden = true
        })
    }

}

// MARK: UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {

}

// MARK: UIStateRestoring
extension ViewController {

    static let restoreWebViewInteractionStateKey = "webViewInteractionState"
    static let restoreFullWebViewVisibleStateKey = "fullWebViewVisibleState"

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        coder.encode(webView.interactionState, forKey: ViewController.restoreWebViewInteractionStateKey)
        coder.encode(fullWebViewIsVisible, forKey: ViewController.restoreFullWebViewVisibleStateKey)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)

        restoredWebViewInteractionState = coder.decodeObject(forKey: ViewController.restoreWebViewInteractionStateKey)
        restoredFullWebViewVisibleState = coder.decodeBool(forKey: ViewController.restoreFullWebViewVisibleStateKey)
    }

    func restore(from activity: NSUserActivity) {
        guard activity.activityType == SceneDelegate.MainSceneActivityType(),
              let userInfo = activity.userInfo else { return }

        if let webViewInteractionState = userInfo[SceneDelegate.webViewInteractionStateKey] {
            restoredWebViewInteractionState = webViewInteractionState
        }
        if let fullWebViewVisibleState = userInfo[SceneDelegate.fullWebViewVisibleStateKey] as? Bool {
            restoredFullWebViewVisibleState = fullWebViewVisibleState
        }
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)

        let entries = [
            SceneDelegate.webViewInteractionStateKey: webView.interactionState,
            SceneDelegate.fullWebViewVisibleStateKey: fullWebViewIsVisible
        ]
        activity.addUserInfoEntries(from: entries as [AnyHashable: Any])
    }

    func updateUserActivity() {
        let currentUserActivity = view.window?.windowScene?.userActivity ??
            NSUserActivity(activityType: SceneDelegate.MainSceneActivityType())

        let entries = [
            SceneDelegate.webViewInteractionStateKey: webView.interactionState,
            SceneDelegate.fullWebViewVisibleStateKey: fullWebViewIsVisible
        ]
        currentUserActivity.addUserInfoEntries(from: entries as [AnyHashable: Any])

        view.window?.windowScene?.userActivity = currentUserActivity
    }

}

// MARK: UIViewControllerRestoration
extension ViewController: UIViewControllerRestoration {

    static func viewController(withRestorationIdentifierPath identifierComponents: [String],
                               coder: NSCoder) -> UIViewController? {
        let viewController = ViewController(nibName: nil, bundle: nil)

        if let restoredWebViewInteractionState =
            coder.decodeObject(forKey: ViewController.restoreWebViewInteractionStateKey) {
            viewController.webView.interactionState = restoredWebViewInteractionState
        }
        viewController.fullWebViewIsVisible = coder.decodeBool(forKey: ViewController.restoreFullWebViewVisibleStateKey)
        return viewController
    }

}
