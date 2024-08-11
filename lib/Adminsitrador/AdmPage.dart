import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_final/map_op/mapa.dart';
import 'package:proyecto_final/map_op/mapa2.dart';

class PaginaAdmin extends StatefulWidget {
  @override
  _PaginaAdminState createState() => _PaginaAdminState();
}

class _PaginaAdminState extends State<PaginaAdmin> {
  final _nameController = TextEditingController(); // Controlador para el nombre
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Indicador de carga

  Future<void> signUpWithEmailAndPassword(String nombre, String email, String password) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': nombre, // Guardar el nombre en la base de datos
        'email': email,
        'activo': true,
        'lat': null,
        'long': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario creado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  Future<void> toggleUserActiveStatus(String uid, bool isActive) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'activo': isActive,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado de usuario actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado de usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración de Usuarios'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agregar Usuario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          signUpWithEmailAndPassword(
                            _nameController.text,
                            _emailController.text,
                            _passwordController.text,
                          );
                          _nameController.clear();
                          _emailController.clear();
                          _passwordController.clear();
                        },
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Agregar',
                          style: TextStyle(color: Colors.white), // Color de texto blanco
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Activar/Inhabilitar o eliminar un usuario',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final nombre = doc.get('nombre');
                        final email = doc.get('email');
                        final activo = doc.get('activo');

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(nombre), // Mostrar el nombre en lugar del correo
                            subtitle: Text(email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: activo ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Icon(
                                  activo ? Icons.check_circle : Icons.cancel,
                                  color: activo ? Colors.green : Colors.red,
                                ),
                                SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(activo ? Icons.toggle_on : Icons.toggle_off),
                                  onPressed: () => toggleUserActiveStatus(doc.id, !activo),
                                  color: Colors.deepPurple,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => deleteUser(doc.id),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SizedBox(height: 32),
              Text(
                'Ubicación de los Usuarios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Posiciones').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>?;

                        final nombre = data != null && data.containsKey('nombre') ? data['nombre'] : 'Nombre desconocido';
                        final lat = data != null && data.containsKey('lat') ? data['lat'] : 'Latitud no disponible';
                        final long = data != null && data.containsKey('log') ? data['log'] : 'Longitud no disponible';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(nombre), 
                            subtitle: Text('Lat: $lat, Long: $long'), 
                          ),
                        );
                      }).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SizedBox(height: 16),
              Container(
                height: 400, 
                child: mapasV2(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
