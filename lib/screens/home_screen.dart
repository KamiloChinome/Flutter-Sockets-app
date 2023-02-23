import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band_model.dart';

class HomeScreen extends StatefulWidget {
  
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    Band(id: '1', name: 'Metalica', votes: 5),
    Band(id: '1', name: 'Queen', votes: 3),
    Band(id: '1', name: 'Starset', votes: 7),
    Band(id: '1', name: 'linkin Park', votes: 2),
    Band(id: '1', name: 'Gorillaz', votes: 10),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Band Names'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: bands.length,
        itemBuilder: (context, index) => bandTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon(Icons.add)),
    );
  }
  Widget bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        //TODO: LLAMAR BORRADO
      },
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
            onTap: () {},
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
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
    return;
  }else{
    showCupertinoDialog(
      context: context, 
      builder: (context) {
        return CupertinoAlertDialog(
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
        );
      },
    );
  }
}

  void addBandNameToList(String name){
    if(name.length > 1){
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}