# 齐鲁工业大学图书馆借证与选座 · iOS 原生客户端

本项目为 **齐鲁工大借证与选座系统** 的 iOS 原生 Swift 壳应用源码。

## 🌟 特性
- **原生沉浸**：去除 Safari 浏览器所有上下边框与地址栏，全屏沉浸式体验。
- **下拉刷新**：内置原生 `UIRefreshControl`，支持下拉秒级重载。
- **加载进度条**：顶部渐变式加载进度指示。
- **原生弹窗支持**：桥接支持网页内 `alert()` 与 `confirm()` 原生对话框。
- **Sideloadly 友好**：支持通过 Sideloadly 免越狱个人自签名安装。

## 🚀 如何自动打包 IPA (GitHub Actions)
1. 在 GitHub 上创建一个新仓库（如 `qlulibrary-ios`）。
2. 将本目录（`E:\Projects\qlu-lib-hub\ios\`）下的所有文件推送到该仓库。
3. GitHub Actions 会自动在免费的苹果云端服务器（`macos-14`）上调用 Xcode 执行编译。
4. 编译完成后（约 40 秒），在 GitHub 仓库的 **Actions ➔ 最近的构建记录 ➔ Artifacts** 中直接点击下载 `qlulibrary-unsigned-ipa.zip`，解压即可得到 `qlulibrary.ipa`。
5. 将 `qlulibrary.ipa` 拖入 **Sideloadly**，输入 Apple ID 完成自签安装！
