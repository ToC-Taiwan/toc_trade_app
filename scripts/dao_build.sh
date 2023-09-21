#!/bin/bash

rm ./lib/database.g.dart
dart run build_runner build --delete-conflicting-outputs
