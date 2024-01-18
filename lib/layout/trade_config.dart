import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/modules/api/api.dart';

class TradeConfigPage extends StatefulWidget {
  const TradeConfigPage({super.key});

  @override
  State<TradeConfigPage> createState() => _TradeConfigPageState();
}

class _TradeConfigPageState extends State<TradeConfigPage> {
  late Future<Config> futureConfig;

  @override
  void initState() {
    super.initState();
    futureConfig = API.fetchConfig();
  }

  ExpansionTile _buildExpansionTile(String title, Map<String, dynamic> data) {
    final children = <Widget>[];
    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        children.add(_buildExpansionTile(key, value));
        return;
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListTile(
            title: Text(key),
            trailing: Text(value.toString()),
          ),
        ),
      );
    });
    return ExpansionTile(
      leading: const Icon(Icons.computer, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.trade_configuration),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: FutureBuilder<Config>(
            future: futureConfig,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;
                if (data.simulation == null) {
                  return Text(
                    AppLocalizations.of(context)!.no_data,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ListTile(title: const Text('Simulation'), trailing: Text(data.simulation.toString())),
                    ListTile(title: const Text('ManualTrade'), trailing: Text(data.manualTrade.toString())),
                    _buildExpansionTile('History', data.history!.toJson()),
                    _buildExpansionTile('Quota', data.quota!.toJson()),
                    _buildExpansionTile('TargetStock', data.targetStock!.toJson()),
                    _buildExpansionTile('AnalyzeStock', data.analyzeStock!.toJson()),
                    _buildExpansionTile('TradeStock', data.tradeStock!.toJson()),
                    _buildExpansionTile('TradeFuture', data.tradeFuture!.toJson()),
                  ],
                );
              }
              return const Center(
                child: SpinKitWave(color: Colors.blueGrey, size: 35.0),
              );
            },
          ),
        ),
      );
}
