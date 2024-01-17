#!/bin/bash
set -e

dart ./scripts/gen_version.dart
flutter build apk --split-per-abi
