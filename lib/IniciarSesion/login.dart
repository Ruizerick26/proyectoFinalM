import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_final/IniciarSesion/registro.dart';
import 'package:proyecto_final/IniciarSesion/auxiliar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/map_op/mapa.dart';
import 'package:proyecto_final/Adminsitrador/AdmPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _estaUsuarioAutenticado();
  }

  void _estaUsuarioAutenticado() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("Usuario no autenticado");
      } else {
        print("Usuario autenticado");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Login());
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static bool _contrasenaVisible = false;
  static bool visible = false;
  static bool googleVisible = false;
  String? _selectedRole;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    visible = false;
    googleVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromRGBO(0, 121, 107, 1)!,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 120.0, bottom: 0.0),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 50.0),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Image.asset('auth.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.black45,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white54,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                    ),
                    labelText: 'Email',
                    hintText: 'Email',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 10.0,
                  bottom: 30.0,
                ),
                child: TextFormField(
                  controller: _contrasenaController,
                  obscureText: !_contrasenaVisible,
                  keyboardType: TextInputType.visiblePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white70,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _contrasenaVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _contrasenaVisible = !_contrasenaVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black45,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                      BorderSide(color: Colors.white, width: 0.5),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                      BorderSide(color: Colors.white, width: 2),
                    ),
                    labelText: 'Contraseña',
                    hintText: 'Contraseña',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 1.0),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.black45,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Rol',
                        ),
                        items: ['Administrador', 'Topografo'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_emailController.text.contains('@')) {
                      mostrarSnackBar('Email no correcto', context);
                    } else if (_contrasenaController.text.length < 6) {
                      mostrarSnackBar(
                        'La contraseña debe contener al menos 6 caracteres',
                        context,
                      );
                    } else {
                      setState(() {
                        _cambiarEstadoIndicadorProgreso();
                      });
                      acceder(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black45,
                    shadowColor: Colors.black45,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Colors.white70,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Acceder',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: visible,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    width: 320,
                    margin: const EdgeInsets.only(),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.blueGrey[800],
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: googleVisible,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    width: 320,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.blueGrey[800],
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const PaginaRegistro(),
                      ),
                    );
                  },
                  child: const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> acceder(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        UserCredential credencial = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _contrasenaController.text.trim(),
        );

        if (_selectedRole != null) {
          if (_selectedRole == 'Administrador') {
            if (_emailController.text.trim().toLowerCase() == "admin@gmail.com" &&
                _contrasenaController.text.trim() == "admin123*") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaginaAdmin()),
              );
            } else {
              mostrarSnackBar("Acceso denegado", context);
              setState(() {
                _cambiarEstadoIndicadorProgreso();
              });
            }
          } else if (_selectedRole == 'Topografo') {
            if (_emailController.text.trim().toLowerCase() == "admin@gmail.com") {
              mostrarSnackBar("Acceso denegado", context);
              setState(() {
                _cambiarEstadoIndicadorProgreso();
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => mapasV()),
              );
            }
          }
        } else {
          mostrarSnackBar("Rol no seleccionado", context);
        }

        setState(() {
          _cambiarEstadoIndicadorProgreso();
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          mostrarSnackBar("Usuario desconocido", context);
        } else if (e.code == "wrong-password") {
          mostrarSnackBar("Contraseña incorrecta", context);
        } else {
          mostrarSnackBar("Lo sentimos, hubo un error", context);
        }
        setState(() {
          _cambiarEstadoIndicadorProgreso();
        });
      }
    }
  }

  void _cambiarEstadoIndicadorProgreso() {
    visible = !visible;
  }

  void mostrarSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
