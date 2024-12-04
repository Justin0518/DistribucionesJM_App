import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Necesario para el formato de fechas
import 'package:flutter_screenutil/flutter_screenutil.dart'; 


const String baseUrl = 'https://distribucionesjm-app.onrender.com';


class Informes extends StatefulWidget {
  
  @override
  _InformesState createState() => _InformesState();
}

class _InformesState extends State<Informes> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  Widget build(BuildContext context) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (context, child) => Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Informes',
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
      body: Column(
        children: [
          _buildDateRangePicker(),

          Flexible(
            child: _buildInformeCard(
              title: 'Ventas Totales',
              description: 'Ver el detalle completo de las ventas.',
              icon: Icons.attach_money,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformeVentasTotales(
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin,
                    ),
                  ),
                );
              },
            ),
          ),

          Flexible(
            child: _buildInformeCard(
              title: 'Productos Más Vendidos',
              description: 'Conoce los productos con más ventas.',
              icon: Icons.shopping_bag,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformeProductosMasVendidos(
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin,
                    ),
                  ),
                );
              },
            ),
          ),

          Flexible(
            child: _buildInformeCard(
              title: 'Clientes Activos',
              description: 'Detalles sobre los clientes más activos.',
              icon: Icons.people,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformeClientesActivos(
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
    );
  }

  // Widget para el rango de fechas
  Widget _buildDateRangePicker() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fechaInicio != null && fechaFin != null
                ? 'Desde: ${DateFormat('dd/MM/yyyy').format(fechaInicio!)}\nHasta: ${DateFormat('dd/MM/yyyy').format(fechaFin!)}'
                : 'Seleccione un rango de fechas',
            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
          ),
          ElevatedButton(
            onPressed: _selectDateRange,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Seleccionar Fecha',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
// Función para abrir el selector de rango de fechas con color personalizado
Future<void> _selectDateRange() async {
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    initialDateRange: fechaInicio != null && fechaFin != null
        ? DateTimeRange(start: fechaInicio!, end: fechaFin!)
        : null,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.red, // Color principal del DatePicker
            onPrimary: Colors.white, // Color del texto sobre el color primario
            onSurface: Colors.black54, // Color del texto y los iconos en la superficie
            secondary: Color(0xFFFFCDD2), // Rojo claro para las fechas seleccionadas
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary, // Texto en los botones
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      fechaInicio = picked.start;
      fechaFin = picked.end;
    });
  }
}


Widget _buildInformeCard({
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h), // Espaciado responsivo entre las tarjetas
      child: SizedBox(
        width: 0.85.sw, // Ancho responsivo de las tarjetas
        height: 100.h, // Altura responsiva
        child: Card(
          elevation: 3, // Sombra para la tarjeta
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r), // Esquinas redondeadas responsivas
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Padding interno responsivo
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(icon, color: Colors.white, size: 24.w), // Ícono responsivo
                    radius: 25.w, // Radio responsivo
                  ),
                  SizedBox(width: 16.w), // Espaciado responsivo entre el ícono y los textos
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp, // Fuente responsiva
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h), // Espaciado responsivo entre los textos
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp, // Fuente responsiva
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}



class InformeVentasTotales extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  InformeVentasTotales({required this.fechaInicio, required this.fechaFin});

  @override
  _InformeVentasTotalesState createState() => _InformeVentasTotalesState();
}

class _InformeVentasTotalesState extends State<InformeVentasTotales> {
  int totalVentas = 0;
  bool isLoading = true;
  List<dynamic> historialVentas = [];
    String formatPrice(dynamic price) {
    final formatter = NumberFormat('#,###', 'es');
    return formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    fetchVentasTotales();
  }

  Future<void> fetchVentasTotales() async {
    try {
      final fechaInicio = widget.fechaInicio != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaInicio!)
          : '2024-01-01'; // Fecha predeterminada si no se selecciona
      final fechaFin = widget.fechaFin != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaFin!)
          : '2024-12-31'; // Fecha predeterminada si no se selecciona

      final response = await http.get(
        Uri.parse('$baseUrl/informes/ventas-totales?fechaInicio=$fechaInicio&fechaFin=$fechaFin'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalVentas = (data['totalVentas'] ?? 0).toInt();
          print(totalVentas);
          historialVentas = data['historialVentas'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener las ventas totales');
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF828282)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Ventas Totales',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de Ventas:',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '\$${formatPrice(totalVentas)}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Historial de ventas',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: historialVentas.length,
                      itemBuilder: (context, index) {
                        final venta = historialVentas[index];
                        final fechaVenta = venta['fechaCompra']; // Asegúrate de que el backend envíe este campo
                        final totalVenta = venta['total']; // Asegúrate de que el backend envíe este campo

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w), // Espaciado responsivo
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w), // Padding interno responsivo
                            tileColor: Colors.grey[100], // Color de fondo para mayor legibilidad
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r), // Bordes redondeados responsivos
                            ),
                            title: Text(
                              'Venta #${index + 1}',
                              style: TextStyle(
                                fontSize: 14.sp, // Fuente responsiva
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Fecha: $fechaVenta',
                              style: TextStyle(
                                fontSize: 12.sp, // Fuente responsiva
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              '\$${formatPrice(totalVenta)}',
                              style: TextStyle(
                                fontSize: 14.sp, // Fuente responsiva
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                ],
              ),
      ),
    ),
    );
  }
}
// Para formatear las fechas

class InformeProductosMasVendidos extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  InformeProductosMasVendidos({this.fechaInicio, this.fechaFin});

  @override
  _InformeProductosMasVendidosState createState() => _InformeProductosMasVendidosState();
}

class _InformeProductosMasVendidosState extends State<InformeProductosMasVendidos> {
  List<dynamic> productosMasVendidos = [];
  bool isLoading = true;
    String formatPrice(dynamic price) {
    final formatter = NumberFormat('#,###', 'es');
    return formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    fetchProductosMasVendidos();
  }

  Future<void> fetchProductosMasVendidos() async {
    try {
      final fechaInicio = widget.fechaInicio != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaInicio!)
          : '2024-01-01';
      final fechaFin = widget.fechaFin != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaFin!)
          : '2024-12-31';

      final response = await http.get(
        Uri.parse(
          '$baseUrl/informes/productos-mas-vendidos?fechaInicio=$fechaInicio&fechaFin=$fechaFin',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productosMasVendidos = data; // Captura la lista de productos
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener productos más vendidos');
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF828282)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Productos Más Vendidos',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w), // Padding responsivo
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3.w, // Hacer el indicador de carga responsivo
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking de Productos',
                    style: TextStyle(
                      fontSize: 16.sp, // Fuente responsiva
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 20.h), // Espaciado responsivo
                  Expanded(
                    child: productosMasVendidos.isEmpty
                        ? Text(
                            'No se encontraron productos más vendidos.',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey), // Fuente responsiva
                          )
                        : ListView.builder(
                            itemCount: productosMasVendidos.length,
                            itemBuilder: (context, index) {
                              final producto = productosMasVendidos[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h), // Espaciado entre tarjetas
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r), // Bordes redondeados responsivos
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      producto['nombreProducto'],
                                      style: TextStyle(fontSize: 14.sp), // Fuente responsiva
                                    ),
                                    subtitle: Text(
                                      '${formatPrice(producto['totalVendido'])} unidades vendidas',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), // Fuente responsiva
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
          ),
          ),
        );
        }
      }
// Para formatear las fechas

class InformeClientesActivos extends StatefulWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  InformeClientesActivos({this.fechaInicio, this.fechaFin});

  @override
  _InformeClientesActivosState createState() => _InformeClientesActivosState();
}

class _InformeClientesActivosState extends State<InformeClientesActivos> {
  int clientesActivos = 0;
  int totalClientes = 0;
  bool isLoading = true;
  List<dynamic> listaClientes = [];

  @override
  void initState() {
    super.initState();
    fetchClientesActivos();
  }

  Future<void> fetchClientesActivos() async {
    try {
      final fechaInicio = widget.fechaInicio != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaInicio!)
          : '2024-01-01';
      final fechaFin = widget.fechaFin != null
          ? DateFormat('yyyy-MM-dd').format(widget.fechaFin!)
          : '2024-12-31';

      final response = await http.get(
        Uri.parse(
          '$baseUrl/informes/clientes-activos?fechaInicio=$fechaInicio&fechaFin=$fechaFin',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          clientesActivos = data['clientesActivos'] ?? 0;
          totalClientes = data['totalClientes'] ?? 0;
          listaClientes = data['detallesClientesActivos'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener los clientes activos');
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF828282)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Clientes Activos',
          style: TextStyle(
            color: Color(0xFFEC2020),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: Color(0xFFDFDDDD),
            height: 1.h,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clientes Totales:',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '$totalClientes',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Clientes Activos:',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '$clientesActivos',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lista de Clientes Activos',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  
            Expanded(
              child: ListView.builder(
                itemCount: listaClientes.length,
                itemBuilder: (context, index) {
                  final cliente = listaClientes[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h), // Espaciado entre elementos
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w), // Padding interno responsivo
                      title: Text(
                        cliente['nombres'] ?? 'Cliente sin nombre',
                        style: TextStyle(fontSize: 14.sp), // Fuente responsiva
                      ),
                      subtitle: Text(
                        'Email: ${cliente['email'] ?? 'Sin email'}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), // Fuente responsiva
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20.w, // Ícono responsivo
                      ),
                    ),
                  );
                },
              ),
            ),
                ],
              ),
      ),
    ),
    );
  }
}
