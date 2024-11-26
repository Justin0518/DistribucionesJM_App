const mongoose = require('mongoose');

// Función para conectar con MongoDB Atlas
async function connectDb(uri) {
  try {
    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Conexión exitosa a la base de datos');
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error);
    throw error;
  }
}

module.exports = connectDb;