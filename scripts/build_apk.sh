#!/bin/bash

dart ./scripts/gen_version.dart
flutter build apk --split-per-abi
