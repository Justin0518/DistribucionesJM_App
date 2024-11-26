require('dotenv').config();
const app = require('./app');
const connectDb = require('./db/mongodb');
const { appConfig, dbConfig } = require('./config');

// Función para inicializar la aplicación
async function initApp(appConfig, dbConfig) {
  try {
    // Conexión a MongoDB Atlas
    await connectDb(dbConfig.uri);
    // Inicio del servidor
    app.listen(appConfig.port, () =>
      console.log(`Servidor escuchando en el puerto ${appConfig.port}`)
    );
  } catch (error) {
    console.error('Error al iniciar la aplicación:', error);
    process.exit(1);
  }
}

initApp(appConfig, dbConfig);
