import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//Permite manejar los status del Server, y conocer el estado de los Sockets
enum ServerStatus {
  Online,
  Offline,
  Connecting
}

//Nos permite expandir la comunicación con el Servidor en cualquier punto de la app
//ChangeNotifier, permite indicar al Provider cuando tiene que refrescar la interfaz o volver a renderizar un componente, si se produce algún cambio o se quiere notificar a los clientes
class SocketService with ChangeNotifier {

  //Propiedad para controlar el Status en el acceso, por defecto establecemos que se encuentra en Connecting
  //En la primera conexión, no sabemos si el usuario está offline/online
  ServerStatus _serverStatus = ServerStatus.Connecting;
  //Al definir la propiedad privada nos permite controlar como mostramos el socket al resto de la app
  late IO.Socket _socket;

  //Get para utilizar la propiedad privada de serverStatus
  ServerStatus get serverStatus => this._serverStatus;
  //Nos permite exponer el Socket
  IO.Socket get socket => this._socket;
  //Función que permite emitir un Socket
  Function get emit    => this._socket.emit;

  //Constructor
  SocketService(){
    this._initConfig();
  }

  //Método
  void _initConfig() {

    //Realiza la conexión Cliente-Server
    this._socket = IO.io('http://192.168.1.36:3000', {      
      //Indicamos al Server que tipo de comunicacion realizamos
      'transports' : ['websocket'],
      //Indicamos que realice la conexión de manera automática
      'autoConnect': true
    });

    //Estado conectado
    this._socket.onConnect( (_) {
      //Indicamos el Status del Servidor
      this._serverStatus = ServerStatus.Online;
      print('Conectado por Socket');
      notifyListeners();
    });

    // Estado Desconectado
    this._socket.onDisconnect( (_) {
      //Indicamos el Status del Servidor
      this._serverStatus = ServerStatus.Offline;
      print('Desconectado del Socket Server');
      notifyListeners();
    });
    
    /*
    //Permite escuchar el evento personalizado, para un nuevo mensaje
    //callback(), de tipo dynamic Function, que recibe un payload de tipo Map
    socket.on( 'new-message', ( payload ) {
      print( 'new-message: ' );
      //TODO: Ternario para comprobar si viene información
      print( 'nombre:' +  payload['name'] );
      print( 'mensaje:' + payload['message'] );
      //Comprobamos si se envían todas las propiedades mediante containsKey comprueba si el payload contiene esa propiedad
      print( payload.containsKey('message2') ? payload['message2'] : 'No hay información' );
    });
    */
  }

}