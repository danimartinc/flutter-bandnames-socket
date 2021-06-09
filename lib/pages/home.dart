import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//Models
import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Definimos un listado de bandas
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 2 ),
    Band(id: '2', name: 'Bon Jovi', votes: 2 ),
    Band(id: '3', name: 'Queen', votes: 2 ),
    Band(id: '4', name: 'Héroes del Silencio', votes: 5 ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames', style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        //Indicamos la longitud del ListView
        itemCount: bands.length,
        itemBuilder: ( BuildContext context, int index ) => _bandTile( bands[ index ] ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: addNewBand,
       ),
    );
  }

  Widget _bandTile( Band band ) {
    return Dismissible(
      //ID único para el Widget, que obtenemos mediante el ID de la banda
      key: Key( band.id ),
      //Indicamos que solo se pueda deslicar en una dirección
      direction: DismissDirection.startToEnd,
      //Método que se dispara 
      onDismissed: ( direction ) {
        print('direccion: $direction');
         print('id: ${band.id}');
        //TODO: Llamada al borrado en el servidor
      },
      background: Container(
        padding: EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Eliminar banda', style: TextStyle( color: Colors.white )),
        )
      ),
      /*confirmDismiss: ( direction ) {
        return 
      } ,*/
      child: ListTile(
        leading: CircleAvatar(
          //Indicamos que se muestre las iniciales de la Band
          //Mediante .substring(0,2), obtenemos las dos primeras letras del name de la banda
          child: Text( band.name.substring(0,2) ),
          //Indicamos el blue de tipo translúcido
          backgroundColor: Colors.blue[100],
        ),
        title: Text( band.name ),
        trailing: Text( '${ band.votes }', style: TextStyle( fontSize: 20) ,),
        onTap: () {
          print( band.name );
        },
      ),
    );
  }

  /*
  Widget confirmDeleteBand( Band band, DismissDirection direction ) {

    return showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text('Eliminar banda'),
          content: Text('¿Desea eliminar la banda ${ band.name }'),
          actions: [
            MaterialButton(
              textColor: Colors.blue,
              onPressed: () => Navigator.pop( context, true ),
              child: Text("Aceptar"),
              elevation: 5,
            ),
            MaterialButton(
              textColor: Colors.red,
              onPressed: () => Navigator.pop( context, false ),
              child: Text("Cancelar"),
              elevation: 5,
            ),
          ],
        );
      }
    );
  }*/

  //Método que permite añadir una nueva banda al seleccionar el floatingActionButton
  addNewBand() {

    //TextEditingController(), que nos permite obtener la información que se escribe en el TextField
    final textController = new TextEditingController();

    //Para mostrar el Dialgo en IOs, comprobamos si el dispositivo es Android
    if( Platform.isAndroid ){
      //Mostramos un Dialog
      return showDialog(
        //Obtenemos el context desde el StatefulWidget global
        context: context,
        //Construye el popup del Dialog
        builder: ( context ) {
          //Retorna un Widget, AlertDialog()
          return AlertDialog(
            title: Text('Nueva banda'),
            //Input de texto
            content: TextField(
              //Implementamos el textController
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Añadir'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text )
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( BuildContext context ) {
        return CupertinoAlertDialog(
          title: Text('Nueva banda:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              //Permite que se dispare el action al pulsar el botón 
              isDefaultAction: true,
              child: Text('Añadir'),
              onPressed: () => addBandToList( textController.text,  )
            ),
            CupertinoDialogAction(
              //Permite que se dispare el action al pulsar el botón 
              isDestructiveAction: true,
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop( context )
            ),
          ],
        );
      }
    );
  }

  //Método que permite añadir una banda mediante el Dialog, inserta u nuevo elemento en la lista
  void addBandToList( String name ) {

    //Comprobar que hay contenido en el name, si es así realizamos la insercción de la nueva banda
    if( name.length > 1 ){
      setState(() {
        //Agragamos la nueva instancia al Map de Band
        this.bands.add( new Band( id: DateTime.now().toString(), name: name, votes : 0 ));   
      });
    }
    //Cerramos el Dialog
    Navigator.pop( context );
  }

}
