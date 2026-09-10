import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!

    private let targetURLString = "https://qlulibrary.khero.online"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        setupProgressView()
        setupSplashView()
        loadTargetURL()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func setupUI() {
        view.backgroundColor = .white
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isOpaque = true
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        if #available(iOS 15.0, *) {
            webView.underPageBackgroundColor = .white
        }
        webView.scrollView.contentInsetAdjustmentBehavior = .always

        // 下拉刷新 (Apple 经典浅蓝小菊花，纯白背景)
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = UIColor(red: 37/255.0, green: 99/255.0, blue: 235/255.0, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        view.addSubview(webView)

        // 监听加载进度
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 37/255.0, green: 99/255.0, blue: 235/255.0, alpha: 1.0)
        progressView.trackTintColor = .clear
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.5)
        ])
    }

    private func loadTargetURL() {
        guard let url = URL(string: targetURLString) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        webView.load(request)
    }

    @objc private func handleRefresh() {
        webView.reload()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)

            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        }
    }

    // MARK: - 微信级原生开屏过渡动画 (0 秒直出，平滑淡出)
    private var splashView: UIView!
    private var splashSpinner: UIActivityIndicatorView!
    private var isSplashDismissed = false
    private let splashMinDisplayTime: TimeInterval = 0.85
    private var splashStartTime: Date = Date()

    private func setupSplashView() {
        splashView = UIView()
        splashView.translatesAutoresizingMaskIntoConstraints = false
        splashView.backgroundColor = .white
        view.addSubview(splashView)

        NSLayoutConstraint.activate([
            splashView.topAnchor.constraint(equalTo: view.topAnchor),
            splashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            splashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splashView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let centerBox = UIStackView()
        centerBox.axis = .vertical
        centerBox.alignment = .center
        centerBox.spacing = 12
        centerBox.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(centerBox)

        // 品牌徽标容器 (带柔和微质感与呼吸动效)
        let logoContainer = UIView()
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.backgroundColor = UIColor(red: 239/255.0, green: 246/255.0, blue: 255/255.0, alpha: 1.0)
        logoContainer.layer.cornerRadius = 24
        logoContainer.layer.borderWidth = 1
        logoContainer.layer.borderColor = UIColor(red: 191/255.0, green: 219/255.0, blue: 254/255.0, alpha: 0.9).cgColor
        logoContainer.layer.shadowColor = UIColor(red: 37/255.0, green: 99/255.0, blue: 235/255.0, alpha: 0.22).cgColor
        logoContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        logoContainer.layer.shadowRadius = 16
        logoContainer.layer.shadowOpacity = 1

        NSLayoutConstraint.activate([
            logoContainer.widthAnchor.constraint(equalToConstant: 80),
            logoContainer.heightAnchor.constraint(equalToConstant: 80)
        ])

        let logoEmoji = UILabel()
        logoEmoji.text = "🏛️"
        logoEmoji.font = UIFont.systemFont(ofSize: 40)
        logoEmoji.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(logoEmoji)

        NSLayoutConstraint.activate([
            logoEmoji.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoEmoji.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor)
        ])

        // 校名与系统主标题
        let titleLabel = UILabel()
        titleLabel.text = "齐鲁工业大学"
        titleLabel.font = UIFont.systemFont(ofSize: 23, weight: .heavy)
        titleLabel.textColor = UIColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 1.0)

        let subLabel = UILabel()
        subLabel.text = "随身借证 · 智能选座系统"
        subLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subLabel.textColor = UIColor(red: 100/255.0, green: 116/255.0, blue: 139/255.0, alpha: 1.0)

        // 正在连接服务提示胶囊
        let loadingBox = UIStackView()
        loadingBox.axis = .horizontal
        loadingBox.alignment = .center
        loadingBox.spacing = 8
        loadingBox.layoutMargins = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        loadingBox.isLayoutMarginsRelativeArrangement = true
        loadingBox.backgroundColor = UIColor(red: 248/255.0, green: 250/255.0, blue: 252/255.0, alpha: 1.0)
        loadingBox.layer.cornerRadius = 16
        loadingBox.layer.borderWidth = 1
        loadingBox.layer.borderColor = UIColor(red: 226/255.0, green: 232/255.0, blue: 240/255.0, alpha: 1.0).cgColor

        splashSpinner = UIActivityIndicatorView(style: .medium)
        splashSpinner.color = UIColor(red: 37/255.0, green: 99/255.0, blue: 235/255.0, alpha: 1.0)
        splashSpinner.startAnimating()

        let tipLabel = UILabel()
        tipLabel.text = "正在同步图书馆服务..."
        tipLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        tipLabel.textColor = UIColor(red: 148/255.0, green: 163/255.0, blue: 184/255.0, alpha: 1.0)

        loadingBox.addArrangedSubview(splashSpinner)
        loadingBox.addArrangedSubview(tipLabel)

        centerBox.addArrangedSubview(logoContainer)
        centerBox.addArrangedSubview(titleLabel)
        centerBox.addArrangedSubview(subLabel)
        centerBox.setCustomSpacing(24, after: subLabel)
        centerBox.addArrangedSubview(loadingBox)

        NSLayoutConstraint.activate([
            centerBox.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            centerBox.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -25)
        ])

        // 微信级底部标语
        let footerLabel = UILabel()
        footerLabel.text = "齐鲁工业大学图书馆 × 智能移动门户"
        footerLabel.font = UIFont.systemFont(ofSize: 11.5, weight: .medium)
        footerLabel.textColor = UIColor(red: 203/255.0, green: 213/255.0, blue: 225/255.0, alpha: 1.0)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            footerLabel.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: splashView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // 柔和呼吸起伏动效
        UIView.animate(withDuration: 1.2, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
            logoContainer.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: nil)

        splashStartTime = Date()

        // 兜底 5 秒淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.dismissSplash()
        }
    }

    private func dismissSplash() {
        guard !isSplashDismissed, splashView != nil else { return }
        isSplashDismissed = true

        let elapsed = Date().timeIntervalSince(splashStartTime)
        let remaining = max(0, splashMinDisplayTime - elapsed)

        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
            guard let self = self, let splash = self.splashView else { return }
            UIView.animate(withDuration: 0.45, delay: 0, options: [.curveEaseInOut], animations: {
                splash.alpha = 0
                splash.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }) { _ in
                self.splashSpinner?.stopAnimating()
                splash.removeFromSuperview()
                self.splashView = nil
            }
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        dismissSplash()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        dismissSplash()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        dismissSplash()
    }

    // MARK: - WKUIDelegate (让 JS 中的 alert() 和 confirm() 正常弹出原生对话框)
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "齐鲁工大借证与选座", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in completionHandler() }))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "选座确认", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in completionHandler(false) }))
        alert.addAction(UIAlertAction(title: "确定预约", style: .default, handler: { _ in completionHandler(true) }))
        present(alert, animated: true)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}
