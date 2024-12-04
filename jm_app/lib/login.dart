import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jm_app/Admin/adminNavegar.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jm_app/Cliente/navegar.dart';

const String baseUrl = 'https://distribucionesjm-app.onrender.com';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isClienteSelected = false;
  bool isAdministradorSelected = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // Indicador de carga

  // Función para autenticar cliente
  Future<void> autenticarCliente() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('$baseUrl/clientes/login'); // URL del backend para autenticar cliente

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": emailController.text,
          "contraseña": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');

        // Si las credenciales son correctas
        final data = json.decode(response.body);
        final clienteId = data['_id'];


        // Navega a la pantalla "Navegar"
        bool esTemporal = data['isPasswordTemporary'] ?? false;
        print(data['isPasswordTemporary']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Navegar(clienteId: clienteId, esTemporal: esTemporal, email: emailController.text),
          ),
        );

      } else if (response.statusCode == 404) {
        _mostrarMensajeError('Cliente no registrado');
      } else if (response.statusCode == 401) {
        _mostrarMensajeError('Contraseña incorrecta');
      }
    } catch (error) {
      _mostrarMensajeError('Error al conectar con el servidor');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> autenticarAdmin() async {
  setState(() {
    isLoading = true;
  });
  
  final url = Uri.parse('$baseUrl/admin/login'); // Endpoint para administradores

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": emailController.text,
        "contraseña": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Si las credenciales son correctas
      final data = json.decode(response.body);


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminNavegar(), // Cambiar a la pantalla de admin
        ),
      );
    } else if (response.statusCode == 404) {
      _mostrarMensajeError('Administrador no encontrado');
    } else if (response.statusCode == 401) {
      _mostrarMensajeError('Contraseña incorrecta');
    }
  } catch (error) {
    _mostrarMensajeError('Error al conectar con el servidor');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  // Función para mostrar mensaje de error
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              // Fondo
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/fondo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                color: Color.fromARGB(33, 70, 69, 69).withOpacity(0.64),
              ),
              Column(
                children: [
                  const Spacer(flex: 3),
                  Image.asset(
                    'assets/images/loguito.png',
                    width: 300.w,
                    fit: BoxFit.fill,
                  ),
                  const Spacer(flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isClienteSelected = true;
                            isAdministradorSelected = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isClienteSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFE33914), Color(0xFFF20909)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            border: isClienteSelected ? null : Border.all(color: Colors.white),
                          ),
                          child: Text(
                            'Cliente',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isClienteSelected = false;
                            isAdministradorSelected = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isAdministradorSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFE33914), Color(0xFFF20909)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            border: isAdministradorSelected ? null : Border.all(color: Colors.white),
                          ),
                          child: Text(
                            'Administrador',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.white, size: 40.sp),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'Usuario',
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        Row(
                          children: [
                            Icon(Icons.lock, color: Colors.white, size: 40.sp),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: TextField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  hintText: 'Contraseña',
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                obscureText: true,
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 60.h),
                        GestureDetector(
                          onTap: () {
                            if (!isClienteSelected && !isAdministradorSelected) {
                              _mostrarMensajeError('Debes elegir una opción: Cliente o Administrador');
                            } else if (isClienteSelected) {
                              autenticarCliente();
                            } else if (isAdministradorSelected) {
                              autenticarAdmin();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE33914), Color(0xFFF20909)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Text(
                              'Ingresar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                        if (isLoading) CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 150.h),
                  painter: CurvePainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF2B109),
          Color(0xFFE2590B),
          Color(0xFFE33914),
        ],
        stops: [0.05, 0.5, 1.0], // Ajusta los porcentajes aquí para suavizar la transición
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 4, 90, size.width / 2, 105)
      ..quadraticBezierTo(size.width * 0.75, 117, size.width, 80)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
