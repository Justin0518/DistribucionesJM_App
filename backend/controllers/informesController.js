const Compra = require('../models/Compra');
const Cliente = require('../models/Clientes');


exports.obtenerVentasTotales = async (req, res) => {
  try {
    const { fechaInicio, fechaFin } = req.query;

    // Convertir fechaFin para incluir todo el día
    const fechaInicioDate = new Date(fechaInicio);
    const fechaFinDate = new Date(fechaFin);
    fechaFinDate.setUTCHours(23, 59, 59, 999); // Establecer hora final del día

    const ventasTotales = await Compra.aggregate([
      {
        $match: {
          fechaCompra: {
            $gte: new Date(fechaInicioDate),
            $lte: new Date(fechaFinDate)
          }
        }
      },
      {
        $group: {
          _id: null,
          totalVentas: { $sum: "$total" },
          totalCompras: { $sum: 1 }
        }
      }
    ]);

    // Obtener el historial de ventas
    const historialVentas = await Compra.find({
      fechaCompra: {
        $gte: new Date(fechaInicioDate),
        $lte: new Date(fechaFinDate)
      }
    }).select('fechaCompra total'); // Aquí puedes seleccionar los campos que necesites

    res.status(200).json({
      totalVentas: ventasTotales[0]?.totalVentas || 0,
      totalCompras: ventasTotales[0]?.totalCompras || 0,
      historialVentas
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener las ventas totales', error });
  }
};

// Obtener productos más vendidos
exports.obtenerProductosMasVendidos = async (req, res) => {
  try {
    const { fechaInicio, fechaFin } = req.query;
    // Convertir fechaFin para incluir todo el día
    const fechaInicioDate = new Date(fechaInicio);
    const fechaFinDate = new Date(fechaFin);
    fechaFinDate.setUTCHours(23, 59, 59, 999); 

    const productosMasVendidos = await Compra.aggregate([
      {
        $match: {
          fechaCompra: {
            $gte: new Date(fechaInicioDate),
            $lte: new Date(fechaFinDate)
          }
        }
      },
      { $unwind: "$productos" }, // Descomponer el array de productos
      {
        $group: {
          _id: "$productos._id",  // Agrupar por productoId
          nombreProducto: { $first: "$productos.nombre" },
          totalVendido: { $sum: "$productos.cantidad" }
        }
      },
      { $sort: { totalVendido: -1 } },  // Ordenar por la cantidad más alta
      { $limit: 5 } 
    ]);

    res.status(200).json(productosMasVendidos);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener los productos más vendidos', error });
  }
};



// Obtener clientes activos (que han hecho compras) y total de clientes
exports.obtenerClientesActivos = async (req, res) => {
  try {
    const { fechaInicio, fechaFin } = req.query;
    // Convertir fechaFin para incluir todo el día
    const fechaInicioDate = new Date(fechaInicio);
    const fechaFinDate = new Date(fechaFin);
    fechaFinDate.setUTCHours(23, 59, 59, 999); 

    // Obtener el número total de clientes
    const totalClientes = await Cliente.countDocuments();

    // Obtener los clientes que han hecho compras en el rango de fechas
    const clientesActivos = await Compra.aggregate([
      {
        $match: {
          fechaCompra: {
            $gte: new Date(fechaInicioDate),
            $lte: new Date(fechaFinDate)
          }
        }
      },
      {
        $group: {
          _id: "$clienteId", // Agrupar por clienteId
        }
      },
      {
        $lookup: {
          from: "clientes", // Nombre de la colección de clientes
          localField: "_id",
          foreignField: "_id",
          as: "detallesCliente"
        }
      },
      {
        $unwind: "$detallesCliente" // Descomponer el array de detalles de cliente
      },
      {
        $project: {
          _id: 0,
          nombres: { $concat: ["$detallesCliente.nombres", " ", "$detallesCliente.apellidos"] },
          email: "$detallesCliente.email"
        }
      }
    ]);

    res.status(200).json({
      totalClientes,
      clientesActivos: clientesActivos.length, // Cantidad de clientes activos
      detallesClientesActivos: clientesActivos // Lista de clientes activos con sus detalles
    });
  } catch (error) {
    console.error('Error al obtener los clientes activos:', error);
    res.status(500).json({ message: 'Error al obtener los clientes activos', error });
  }
};

