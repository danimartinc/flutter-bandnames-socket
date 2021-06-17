import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
//Models
import 'package:band_names/models/band.dart';
//Providers
import 'package:band_names/providers/socket_service.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Definimos un listado de bandas
  List<Band> bands = [];

  @override
  void initState() {
    //listen: false, indico que no es necesario volver a renderizar el componente
    final socketService = Provider.of<SocketService>( context, listen: false );

    //Primer argumento, evento que deseamos escuchar, en este caso active-bands
    socketService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }
  
  //Método que contiene el payload del evento active-bands
  _handleActiveBands( dynamic payload ) {
    //Asigno el tipo List al array de Bands mediante un cast
    this.bands = (payload as List)
        //map(), transforma cada uno de los valores internos del listado
        .map( (band) => Band.fromMap(band) )
        //Transformo en una lista
        .toList();

    setState(() {});
  }

  //Evitamos escuchar información cuando ya no es necesaria
  @override
  void dispose() {
    //listen: false, indico que no es necesario volver a renderizar el componente
    final socketService = Provider.of<SocketService>(context, listen: false );
    //Primer argumento, evento que deseamos escuchar
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text( 'BandNames', style: TextStyle(color: Colors.black87) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only( right: 10 ),
            //Comprobamos que si el serverStatus tiene estado online
            child: ( socketService.serverStatus == ServerStatus.Online )
                    //Icono que se muestra cuando se realiza la conexión mediante el Server
                    ? Icon( Icons.check_circle, color: Colors.blue[300] )
                    //Icono que se muestra cuando no hay conexión con el servidor
                    : Icon( Icons.offline_bolt, color: Colors.red ),
          )
        ],
      ),
      body: Column(
        children: [
          if( bands.isNotEmpty )
          _showGraph(),
          //Expanded, nos permite indicar al LisView que ocupe todo el espacio disponible en la columna
          Expanded(
            child: ListView.builder(
            //Indicamos la longitud del ListView
            itemCount: bands.length,
            itemBuilder: ( BuildContext context, int index ) => _bandTile( bands[ index ] ),
        ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: addNewBand,
       ),
    );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>( context, listen: false );

    return Dismissible(
      //ID único para el Widget, que obtenemos mediante el ID de la banda
      key: Key( band.id ),
      //Indicamos que solo se pueda deslicar en una dirección
      direction: DismissDirection.startToEnd,
      //Método que se dispara al realizar la acción de eliminar el evento
      //Se emite el evento delete-band
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', { 'id': band.id } ),
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
        //Se emite el evento vote-band
        //Envio el id mediante un map en el payload
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id } ),
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
        builder: ( _ ) {
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

      //Información del socketService
      final socketService = Provider.of<SocketService>(context, listen: false );
      //Se emite el evento add-band, mediante el payload enviamos un map con el name
      socketService.emit( 'add-band', { 'name': name });

     /* setState(() {
        //Agragamos la nueva instancia al Map de Band
        this.bands.add( new Band( id: DateTime.now().toString(), name: name, votes : 0 ));   
      });*/
    }
    //Cerramos el Dialog
    Navigator.pop( context );
  }

  //Mostrar gráfica
  Widget _showGraph() {
  
    Map<String, double> dataMap = new Map();
    // dataMap.putIfAbsent('Flutter', () => 5);
    bands.forEach( (band) {
      //band.name, key para recorrer el array mediante forEach()
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble() );
    });

    List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ];

  //Devolvemos la gráfica con el contenido
  return Container(
    padding: EdgeInsets.only( top: 10 ),
    //Necesario indicar un tamaño al PieChart para poder desplegarse
      width: double.infinity,
      height: 180,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
        ),
    )
    );
   

  }

}
