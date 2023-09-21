#!/bin/bash

flutter build ipa --release --export-method development

ideviceinstaller --uninstall com.tocandraw.tradeAgent
ideviceinstaller -i ./build/ios/ipa/trade_agent_v2.ipa
