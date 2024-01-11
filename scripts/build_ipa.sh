#!/bin/bash
set -e

dart ./scripts/gen_version.dart
flutter build ipa
open ./build/ios/archive/Runner.xcarchive
