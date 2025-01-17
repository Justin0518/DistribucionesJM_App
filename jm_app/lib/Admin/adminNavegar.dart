import 'package:flutter/material.dart';
import 'package:jm_app/Admin/inventarioAdmin.dart'; // Gestión de Inventario
import 'package:jm_app/Admin/pedidosAdmin.dart';    // Gestión de Pedidos
import 'package:jm_app/Admin/usuarios.dart';   // Gestión de Usuarios
import 'package:jm_app/Admin/informes.dart';   // Informes
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jm_app/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const String baseUrl = 'https://distribucionesjm-app.onrender.com';

class AdminNavegar extends StatefulWidget {
  @override
  _AdminNavegarState createState() => _AdminNavegarState();
}

class _AdminNavegarState extends State<AdminNavegar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // GlobalKey para controlar el Drawer

  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool hayNuevoPedido = false; // Variable para controlar la notificación de nuevos pedidos

  @override
  void initState() {
    super.initState();
    verificarNuevosPedidos(); // Llamar al backend para verificar si hay nuevos pedidos
  }

  Future<void> verificarNuevosPedidos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pedidos/recibido'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          hayNuevoPedido = data['hayNuevosPedidos']; // Basado en la respuesta del backend
        });
      } else {
        throw Exception('Error al verificar nuevos pedidos');
      }
    } catch (error) {
      print('Error al conectar con el backend: $error');
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) { // Si accede a la pantalla de pedidos
      marcarPedidosComoVistos(); // Llamar a la función que actualiza los pedidos en el backend
      setState(() {
        hayNuevoPedido = false; // Desactivar la notificación al acceder a pedidos
      });
    }
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
  void _cerrarSesion() {
    // Navegar de regreso a la pantalla de login para cerrar sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(), // Suponiendo que esta es la pantalla de login
      ),
    );
  }
  Future<void> marcarPedidosComoVistos() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pedidos/marcar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al marcar los pedidos como vistos');
      }
    } catch (error) {
      print('Error al conectar con el backend: $error');
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer(); // Abre el Drawer usando el scaffoldKey
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) => Scaffold(
        key: _scaffoldKey, // Asignamos la key al Scaffold
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 200.h,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff000000), Color(0xff434343)],
                          stops: [0, 1],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -85.h,
                      left: -112.w,
                      child: Container(
                        width: 280.w,
                        height: 170.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF2B109).withOpacity(0.89),
                              Color(0xFFE2590B).withOpacity(0.89),
                              Color(0xFFFF20909).withOpacity(0.89),
                            ],
                            stops: [0.5, 0.61, 0.81],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              ListTile(
                leading: Icon(Icons.inventory),
                title: Text('Inventario', style: TextStyle(fontSize: 12.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0);
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Pedidos', style: TextStyle(fontSize: 12.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: Icon(Icons.list_alt_rounded),
                title: Text('Informes', style: TextStyle(fontSize: 12.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(2);
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Clientes', style: TextStyle(fontSize: 12.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Cerrar sesión', style: TextStyle(fontSize: 12.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _cerrarSesion();
                },
              ),
            ],
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            InventarioAdmin(openDrawer: _openDrawer),
            PedidosAdmin(),
            Informes(),
            Clientes(),
          ],
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          height: 60.h,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.red,
            unselectedItemColor: Color(0xFF828282),
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontSize: 12.sp),
            unselectedLabelStyle: TextStyle(fontSize: 12.sp),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.inventory, size: 22.w), label: 'Inventario'),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.assignment, size: 22.w),
                    if (hayNuevoPedido)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded, size: 22.w), label: 'Informes'),
              BottomNavigationBarItem(icon: Icon(Icons.people, size: 22.w), label: 'Clientes'),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}