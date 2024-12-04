import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


const String baseUrl = 'https://distribucionesjm-app.onrender.com';


class Clientes extends StatefulWidget {
  @override
  _ClientesState createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> clientesFiltrados = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchClientes(); // Llamar para obtener clientes del backend
  }

  // Función para manejar el retorno al agregar un cliente
  Future<void> _agregarCliente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgregarCliente()),
    );

    // Si el resultado es 'refresh', recargar la lista de clientes
    if (result == 'refresh') {
      fetchClientes();
    }
  }

  // Función para obtener clientes del backend
  Future<void> fetchClientes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clientes/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          clientes = data.map((cliente) {
            return {
              "_id": cliente["_id"],
              "nombre": "${cliente['nombres']} ${cliente['apellidos']}",
              "email": cliente["email"],
              "telefono": cliente["telefono"],
              "activo": cliente["estado"] == "activo"
            };
          }).toList();
          clientesFiltrados = List.from(clientes);
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al conectar con el backend: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para filtrar clientes según la búsqueda
  void _filtrarClientes(String query) {
    setState(() {
      searchQuery = query;
      clientesFiltrados = clientes.where((cliente) {
        final nombreCompleto = cliente['nombre'].toLowerCase();
        final emailCliente = cliente['email'].toLowerCase();
        final queryLower = query.toLowerCase();

        return nombreCompleto.contains(queryLower) || emailCliente.contains(queryLower);
      }).toList();
    });
  }

  // Función para eliminar cliente del backend
  Future<void> eliminarCliente(String clienteId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/clientes/$clienteId'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cliente eliminado correctamente'),
          backgroundColor: Colors.green,
        ));

        // Actualizar la lista de clientes después de la eliminación
        fetchClientes();
      } else {
        print('Error al eliminar cliente: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al eliminar cliente: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (context, child) => Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Clientes',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20.h), // Espaciado responsivo
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r), // Bordes redondeados responsivos
                      border: Border.all(color: const Color(0xFFE4E4E4)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        _filtrarClientes(value);
                      },
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente',
                        hintStyle: TextStyle(color: const Color(0xFFB0B0B0), fontSize: 12.sp), // Fuente responsiva
                        suffixIcon: Icon(Icons.search, color: const Color(0xFF828282), size: 20.w), // Ícono responsivo
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 25.w), // Padding interno responsivo
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h), // Espaciado responsivo

                  // Lista de clientes filtrados
                  Expanded(
                    child: ListView.builder(
                      itemCount: clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesFiltrados[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h), // Espaciado responsivo entre tarjetas
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r), // Bordes redondeados responsivos
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 20.w), // Padding interno responsivo
                              leading: CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 20.r, // Tamaño responsivo
                                child: Icon(Icons.person, color: Colors.white, size: 20.sp), // Ícono responsivo
                              ),
                              title: Text(
                                cliente['nombre'],
                                style: TextStyle(
                                  fontSize: 14.sp, // Fuente responsiva
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                cliente['email'],
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey), // Fuente responsiva
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20.w), // Ícono responsivo
                                onPressed: () {
                                  eliminarCliente(cliente['_id']);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleCliente(clienteId: cliente['_id']),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCliente,
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white, size: 20.w), // Ícono responsivo
      ),

    ),
    );
  }
}




class DetalleCliente extends StatefulWidget {
  final String clienteId;

  DetalleCliente({required this.clienteId});

  @override
  _DetalleClienteState createState() => _DetalleClienteState();
}

class _DetalleClienteState extends State<DetalleCliente> {
  Map<String, dynamic> cliente = {};
  List<dynamic> historialCompras = [];
  bool isLoading = true;
  String formatPrice(dynamic price) {
    final formatter = NumberFormat('#,###', 'es');
    return formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    fetchDetalleCliente();
  }

  Future<void> fetchDetalleCliente() async {
    final clienteId = widget.clienteId;
    try {
      final response = await http.get(Uri.parse('$baseUrl/clientes/$clienteId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cliente = data['cliente'];
          historialCompras = data['historialCompras'];
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener los detalles del cliente: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al conectar con el backend: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (context, child) => Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF828282)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Detalle del Cliente',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
body: isLoading
    ? Center(child: CircularProgressIndicator())
    : Padding(
        padding: EdgeInsets.all(40.w), // Espaciado responsivo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Datos del cliente
            Text(
              'Nombre: ${cliente['nombres']} ${cliente['apellidos']}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold), // Fuente responsiva
            ),
            SizedBox(height: 10.h), // Espaciado responsivo
            Text(
              'Email: ${cliente['email']}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]), // Fuente responsiva
            ),
            SizedBox(height: 10.h),
            Text(
              'Teléfono: ${cliente['telefono']}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]), // Fuente responsiva
            ),
            SizedBox(height: 20.h),

            // Historial de compras
            Text(
              'Historial de Compras',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red), // Fuente responsiva
            ),
            SizedBox(height: 10.h),

            Expanded(
              child: historialCompras.isNotEmpty
                  ? ListView.builder(
                      itemCount: historialCompras.length,
                      itemBuilder: (context, index) {
                        final compra = historialCompras[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r), // Bordes redondeados responsivos
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Fecha de compra: ${compra['fechaCompra'].substring(0, 10)}',
                              style: TextStyle(
                                fontSize: 14.sp, // Fuente responsiva
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(), // Evitar conflicto de scrolls
                                itemCount: compra['productos'].length,
                                itemBuilder: (context, prodIndex) {
                                  final producto = compra['productos'][prodIndex];
                                  return ListTile(
                                    title: Text(
                                      producto['nombre'],
                                      style: TextStyle(fontSize: 14.sp), // Fuente responsiva
                                    ),
                                    subtitle: Text(
                                      'Cantidad: ${producto['cantidad']}',
                                      style: TextStyle(fontSize: 12.sp), // Fuente responsiva
                                    ),
                                    trailing: Text(
                                      '\$${formatPrice(producto['subtotal'])}',
                                      style: TextStyle(
                                        fontSize: 14.sp, // Fuente responsiva
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),
                              Padding(
                                padding: EdgeInsets.all(8.w), // Espaciado responsivo
                                child: Text(
                                  'Total: \$${formatPrice(compra['total'])}',
                                  style: TextStyle(
                                    fontSize: 14.sp, // Fuente responsiva
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No hay historial de compras',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey), // Fuente responsiva
                      ),
                    ),
            ),
          ],
        ),
      ),

    ),
    );
  }
}





class AgregarCliente extends StatefulWidget {
  @override
  _AgregarClienteState createState() => _AgregarClienteState();
}

class _AgregarClienteState extends State<AgregarCliente> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmarEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmarPasswordController = TextEditingController();

  // Expresión regular para validar el formato de un correo electrónico
  final RegExp emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[cC][oO][mM]$");

  // Función para enviar los datos al backend y agregar el cliente
  Future<void> agregarCliente() async {
    final url = Uri.parse('$baseUrl/clientes/agregar'); // Reemplaza con tu URL del backend

    final body = json.encode({
      "_id": "C${DateTime.now().millisecondsSinceEpoch}", // Generar un ID temporal único
      "nombres": nombreController.text,
      "apellidos": apellidoController.text,
      "telefono": telefonoController.text,
      "email": emailController.text,
      "contraseña": passwordController.text, // Añadimos la contraseña
      "estado": "activo"
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        // Si la solicitud fue exitosa
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar todos los campos
        nombreController.clear();
        apellidoController.clear();
        telefonoController.clear();
        emailController.clear();
        confirmarEmailController.clear();
        passwordController.clear();
        confirmarPasswordController.clear();
        Navigator.pop(context, 'refresh');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar el cliente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (context, child) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF828282)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Agregar Cliente',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.w), // Espaciado responsivo
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Nombres
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombres',
                  labelStyle: TextStyle(fontSize: 14.sp), // Fuente responsiva
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r), // Bordes redondeados responsivos
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w), // Borde responsivo
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h), // Espaciado responsivo

              // Campo: Apellidos
              TextFormField(
                controller: apellidoController,
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Campo: Teléfono
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(
                  labelText: 'Número de Teléfono',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (value.length != 10) {
                    return 'El número debe tener 10 dígitos';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'El número solo debe contener dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Campo: Correo Electrónico
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (!emailRegExp.hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Campo: Confirmar Correo Electrónico
              TextFormField(
                controller: confirmarEmailController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Correo Electrónico',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != emailController.text) {
                    return 'Los correos electrónicos no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Campo: Contraseña
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  } else if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Campo: Confirmar Contraseña
              TextFormField(
                controller: confirmarPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.w),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),

              // Botón: Agregar Cliente
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      agregarCliente(); // Llamar a la función para agregar el cliente
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r), // Bordes redondeados responsivos
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h, // Padding vertical responsivo
                      horizontal: 40.w, // Padding horizontal responsivo
                    ),
                  ),
                  child: Text(
                    'Agregar Cliente',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp), // Fuente responsiva
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    ),
    );
  }
}
