# TOC TRADE APP

[![Maintained](https://img.shields.io/badge/Maintained-yes-green?style=for-the-badge)](https://github.com/ToC-Taiwan/toc_trade_app)
[![Flutter](https://img.shields.io/badge/Flutter-3.13.5-blue?logo=flutter&logoColor=blue&style=for-the-badge)](https://docs.flutter.dev)
[![iOS](https://img.shields.io/badge/OS-iOS-orange?logo=ios&logoColor=orange&style=for-the-badge)](https://www.apple.com/ios)
[![Android](https://img.shields.io/badge/OS-Android-green?logo=android&logoColor=green&style=for-the-badge)](https://www.android.com)

[![RELEASE](https://img.shields.io/github/release/ToC-Taiwan/toc_trade_app?style=for-the-badge)](https://github.com/ToC-Taiwan/toc_trade_app/releases/latest)
[![LICENSE](https://img.shields.io/github/license/ToC-Taiwan/toc_trade_app?style=for-the-badge)](COPYING)

![Example](./assets/cover.png)

## Getting Started

- Activate protoc plugin

```sh
dart pub global activate protoc_plugin
```

## Generate android store key

```sh
cd /Applications/Android Studio.app/Contents/jre/Contents/Home/bin
./keytool -genkey -v -keystore /Users/timhsu/dev_projects/key/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias play_console_upload
```

## Authors

- [**Tim Hsu**](https://github.com/Chindada)
