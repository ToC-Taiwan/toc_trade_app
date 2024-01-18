import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:trade_agent/constant/ad_id.dart';
import 'package:trade_agent/daos/database.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/layout/component/app_bar/app_bar.dart';
import 'package:trade_agent/layout/orders.dart';
import 'package:trade_agent/modules/api/api.dart';
import 'package:trade_agent/utils/utils.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  static const _insets = 16.0;
  BannerAd? _inlineAdaptiveAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  late Orientation _currentOrientation;

  double get _adWidth => MediaQuery.of(context).size.width - (4 * _insets);

  late Future<Balance> futureBalance;

  @override
  void initState() {
    super.initState();
    futureBalance = API.fetchBalance();
    BasicDao.getBasicByKey('remove_ad_status').then((value) {
      if (value != null) {
        alreadyRemovedAd = value.value == 'true';
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  Future<void> _loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });

    // Get an inline adaptive size for the current orientation.
    final AdSize size = AdSize.getInlineAdaptiveBannerAdSize(_adWidth.truncate(), 60);
    _inlineAdaptiveAd = BannerAd(
      adUnitId: bannerAdUnitID,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          // After the ad is loaded, get the platform ad size and use it to
          // update the height of the container. This is necessary because the
          // height can change after the ad is loaded.
          final bannerAd = ad as BannerAd;
          final size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  /// Gets a widget containing the ad, if one is loaded.
  /// Returns an empty container if no ad is loaded, or the orientation
  /// has changed. Also loads a new ad if the orientation changes.
  Widget _getAdWidget() => OrientationBuilder(
        builder: (context, orientation) {
          if (_currentOrientation == orientation && _inlineAdaptiveAd != null && _isLoaded && _adSize != null) {
            return Align(
              child: SizedBox(
                width: _adWidth,
                height: _adSize!.height.toDouble(),
                child: AdWidget(
                  ad: _inlineAdaptiveAd!,
                ),
              ),
            );
          }
          // Reload the ad if the orientation changes.
          if (_currentOrientation != orientation) {
            _currentOrientation = orientation;
            _loadAd();
          }
          return Container();
        },
      );

  @override
  void dispose() {
    super.dispose();
    _inlineAdaptiveAd?.dispose();
  }

  bool alreadyRemovedAd = false;
  Widget _buildAd() {
    if (alreadyRemovedAd) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _getAdWidget(),
    );
  }

  MaterialColor _balanceColors(num value) {
    if (value > 0) {
      return Colors.red;
    } else if (value < 0) {
      return Colors.green;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // backgroundColor: Colors.white,
        appBar: trAppbar(
          context,
          AppLocalizations.of(context)!.balance,
        ),
        body: FutureBuilder<Balance>(
          future: futureBalance,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.future == null && snapshot.data!.stock == null) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.no_data,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                );
              }
              final data = snapshot.data!;
              num total = 0;
              num lastTotal = 0;
              var stockArr = <BalanceDetail>[];
              var futureArr = <BalanceDetail>[];
              if (data.future != null) {
                data.future!.asMap().forEach((i, value) {
                  total += value.total!;
                  if (i == data.future!.length - 1) {
                    lastTotal += value.total!;
                  }
                });
                futureArr = data.future!.reversed.toList();
              }
              if (data.stock != null) {
                data.stock!.asMap().forEach((i, value) {
                  total += value.total!;
                  if (i == data.stock!.length - 1) {
                    lastTotal += value.total!;
                  }
                });
                stockArr = data.stock!.reversed.toList();
              }

              return Column(
                children: [
                  Expanded(
                    flex: 23,
                    child: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          elevation: 5,
                          flexibleSpace: TabBar(
                            labelStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.only(top: 5),
                            tabs: [
                              Tab(text: AppLocalizations.of(context)!.future),
                              Tab(text: AppLocalizations.of(context)!.stock),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            ListView.separated(
                              separatorBuilder: (context, index) => const Divider(
                                height: 0,
                                color: Colors.grey,
                              ),
                              itemCount: futureArr.length,
                              itemBuilder: (context, index) => ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderPage(
                                        date: futureArr[index].tradeDay!.substring(0, 10),
                                      ),
                                    ),
                                  );
                                },
                                leading: Icon(Icons.account_balance_wallet, color: _balanceColors(futureArr[index].total!)),
                                title: Text(futureArr[index].tradeDay!.substring(0, 10)),
                                subtitle: Text('${AppLocalizations.of(context)!.trade_count}: ${futureArr[index].tradeCount}'),
                                trailing: Text(
                                  commaNumber(futureArr[index].total.toString()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _balanceColors(futureArr[index].total!),
                                  ),
                                ),
                              ),
                            ),
                            ListView.separated(
                              separatorBuilder: (context, index) => const Divider(
                                height: 0,
                                color: Colors.grey,
                              ),
                              itemCount: stockArr.length,
                              itemBuilder: (context, index) => ListTile(
                                leading: Icon(Icons.account_balance_wallet, color: _balanceColors(stockArr[index].total!)),
                                title: Text(stockArr[index].tradeDay!.substring(0, 10)),
                                subtitle: Text('${AppLocalizations.of(context)!.trade_count}: ${stockArr[index].tradeCount}'),
                                trailing: Text(
                                  commaNumber(stockArr[index].total.toString()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _balanceColors(stockArr[index].total!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _buildAd(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.latest,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: SizedBox(
                              child: Text(
                                commaNumber(lastTotal.toString()),
                                style: TextStyle(fontSize: 22, color: _balanceColors(lastTotal)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: ListTile(
                            title: Text(
                              AppLocalizations.of(context)!.total,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: SizedBox(
                              child: Text(
                                commaNumber(total.toString()),
                                style: TextStyle(fontSize: 22, color: _balanceColors(total)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 26),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  futureBalance = API.fetchBalance();
                                });
                              },
                              icon: const Icon(
                                Icons.refresh,
                                size: 28,
                              ),
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: SpinKitWave(color: Colors.blueGrey, size: 35.0),
            );
          },
        ),
      );
}

Widget generateBalanceRow(BalanceDetail balance) {
  Color tmp;
  if (balance.total! > 0) {
    tmp = Colors.red;
  } else {
    tmp = Colors.green;
  }
  return Padding(
    padding: const EdgeInsets.only(top: 18, left: 20),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            balance.tradeDay!.substring(0, 10),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            balance.tradeCount!.toString(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            balance.originalBalance!.toString(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            balance.discount!.toString(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            balance.total!.toString(),
            style: TextStyle(color: tmp),
          ),
        ),
      ],
    ),
  );
}
