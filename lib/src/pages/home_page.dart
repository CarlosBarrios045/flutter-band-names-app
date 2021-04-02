import 'dart:io';
import 'package:band_names_app/src/providers/socket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Model
import 'package:band_names_app/src/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    super.initState();
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.on('active-bands', _handleActiveBand);
  }

  _handleActiveBand(payload) {
    this.bands = (payload as List).map((b) => Band.fromMap(b)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 20),
              child: socketProvider.serverStatus == ServerStatus.Online
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue[300],
                    )
                  : Icon(Icons.offline_bolt, color: Colors.red))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 10),
              height: 220,
              width: double.infinity,
              child: _showGraph()),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (_, int i) => _bandTile(bands[i])),
          ),
        ],
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    return Dismissible(
      onDismissed: (_) =>
          socketProvider.socket.emit("delete-band", {"id": band.id}),
      direction: DismissDirection.startToEnd,
      background: Container(
          padding: EdgeInsets.only(left: 8),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete band',
              style: TextStyle(color: Colors.white),
            ),
          )),
      key: Key(band.id),
      child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: TextStyle(fontSize: 20),
          ),
          onTap: () =>
              socketProvider.socket.emit('vote-band', {"id": band.id})),
    );
  }

  addNewBand() {
    final textFieldController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller: textFieldController,
                  decoration: InputDecoration(hintText: 'Example: Alex Campos'),
                ),
                actions: [
                  MaterialButton(
                    onPressed: () => addBandToList(textFieldController.text),
                    child: Text('Add'),
                    textColor: Colors.blue,
                    elevation: 5,
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Text('New band name:')),
              content: CupertinoTextField(
                controller: textFieldController,
                placeholder: 'Example: Alex Campos',
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => addBandToList(textFieldController.text),
                  child: Text('Add'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text('Dismiss'),
                )
              ],
            ));
  }

  void addBandToList(String name) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    if (name.length > 1) {
      socketProvider.socket.emit("add-band", {"name": name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return PieChart(
      dataMap: dataMap,
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: true,
        decimalPlaces: 1,
      ),
    );
  }
}
