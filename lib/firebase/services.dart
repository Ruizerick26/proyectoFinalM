import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_final/schema/ubicacion.dart';

Future<void> subir(usuario usser, String uid) async{
  FirebaseFirestore ref2 = FirebaseFirestore.instance;
  await ref2.collection("Posiciones").doc(uid).set({
    "nombre": usser.nombre,
    "lat": usser.lat,
    "log": usser.log
  });
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