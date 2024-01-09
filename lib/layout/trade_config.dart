import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trade_agent/constant/constant.dart';
import 'package:trade_agent/entity/entity.dart';
import 'package:trade_agent/generated/l10n.dart';

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
    futureConfig = fetchConfig();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          title: Text(S.of(context).trade_configuration),
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
                if (data.server == null) {
                  return Text(
                    S.of(context).no_data,
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
                    ListTile(title: const Text('Development'), trailing: Text(data.development.toString())),
                    _buildExpansionTile('History', data.history!.toMap()),
                    _buildExpansionTile('Quota', data.quota!.toMap()),
                    _buildExpansionTile('TargetStock', data.targetStock!.toMap()),
                    _buildExpansionTile('AnalyzeStock', data.analyzeStock!.toMap()),
                    _buildExpansionTile('TradeStock', data.tradeStock!.toMap()),
                    _buildExpansionTile('TradeFuture', data.tradeFuture!.toMap()),
                    _buildExpansionTile('Database', data.database!.toMap()),
                    _buildExpansionTile('Server', data.server!.toMap()),
                    _buildExpansionTile('Sinopac', data.sinopac!.toMap()),
                    _buildExpansionTile('Fugle', data.fugle!.toMap()),
                    _buildExpansionTile('RabbitMQ', data.rabbitMQ!.toMap()),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
      );
}

Future<Config> fetchConfig() async {
  try {
    final response = await http.get(Uri.parse('$tradeAgentURLPrefix/basic/config'));
    if (response.statusCode == 200) {
      return Config.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      return Config();
    }
  } on Exception {
    return Config();
  }
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
