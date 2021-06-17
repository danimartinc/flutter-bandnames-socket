
class Band {

  final String id;
  final String name;
  final int votes;

  //Constructor
  Band({
    required this.id, 
    required this.name, 
    required this.votes
  });

  //BackendServer emite como respuesta un map() mediante la implementación de comunicación por Sockets
  //Factory Constructor, constructor que recibe argumentos y devuelve una instancia de la Band
  //fromJson(), método que recibe un Map en formato JSON
  //Recibo un map llamando JSON mediante el cual asigno cada uno de los valores del mapa a cada una de las propiedades
  factory Band.fromMap( Map<String, dynamic> obj ) 
    => Band(
      //Validamos que las propiedades contegan información
      id   : obj.containsKey('id')    ? obj['id']    : 'no-id',
      name : obj.containsKey('name')  ? obj['name']  : 'no-name',
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes'
    );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'votes': votes,
    };
  }
}
