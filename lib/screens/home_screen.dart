import 'dart:io';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band_model.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();
      setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Band Names'),
        backgroundColor: Colors.lightBlue,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
            ? const Icon(Icons.check_circle, color: Colors.amber,)
            : Icon(Icons.offline_bolt, color: Colors.red[300],)
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: bands.length,
              itemBuilder: (context, index) => bandTile(bands[index])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon(Icons.add)),
    );
  }
  Widget bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        color: Colors.red[100],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(band.name.substring(0, 2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: const TextStyle(fontSize: 19),),
            onTap: () => socketService.socket.emit('vote-band', {'id': band.id }),
          ),
          const Divider()
        ],
      ),
    );
  }
  addNewBand(){
    final textController = TextEditingController();
    if(Platform.isAndroid){
      showDialog(
      context: context, 
      builder: (_) => AlertDialog(
          title: const Text('Nombre de la nueva banda'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              textColor: Colors.lightBlue,
              child: const Text('add'),
              onPressed: () => addBandNameToList(textController.text),
            )
          ],
        ),
      );
      return;
  }else{
    showCupertinoDialog(
      context: context, 
      builder: (_) => CupertinoAlertDialog(
          title: const Text('Nombre de la nueva banda'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Agregar'),
              onPressed: () => addBandNameToList(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context)
            ),
          ],
        ),
    );
  }
}

  void addBandNameToList(String name){
    if(name.length > 1){
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    },);
  return Container(
    width: double.infinity,
    height: 200,
    child: PieChart(dataMap: dataMap),
  );
  }
}