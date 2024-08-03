import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_final/schema/ubicacion.dart';

Future<void> subir(usuario usser) async{
  FirebaseFirestore ref2 = FirebaseFirestore.instance;
  await ref2.collection("Usuarios").add({
    "nombre": usser.nombre,
    "lat": usser.lat,
    "log": usser.log
  });
  // DatabaseReference ref = FirebaseDatabase.instance.ref("Usuarios");
  // await ref.set(usser);
  print("subido");
}
Future<void> actualizar(usuario usser) async{
  DatabaseReference ref = FirebaseDatabase.instance.ref("Usuarios");
  await ref.update({
    "nombre": usser.nombre,
    "lat": usser.lat,
    "log": usser.log
  });
}