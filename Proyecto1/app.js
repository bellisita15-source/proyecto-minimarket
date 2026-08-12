const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// Ruta 1: Consultar productos de la BD
app.get('/app/productos', async (req, res) => {
  try {
    const [productos] = await db.query('SELECT * FROM productos');
    res.json(productos);
  } catch (error) {
    console.error("Error en BD:", error);
    res.status(500).json({ error: 'Error consultando la base de datos' });
  }
});

// Ruta 2: Registrar una venta en la BD
app.post('/app/ventas', async (req, res) => {
  const { id_cliente, id_empleado, productos } = req.body;
  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const [resVenta] = await connection.query(
      'INSERT INTO ventas (id_cliente, id_empleado) VALUES (?, ?)',
      [id_cliente || 1, id_empleado || 1]
    );
    const id_venta = resVenta.insertId;

    for (const item of productos) {
      await connection.query(
        'INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (?, ?, ?, ?)',
        [id_venta, item.id_producto, item.cantidad, item.precio_unitario]
      );

      await connection.query(
        'UPDATE productos SET stock = stock - ? WHERE id_producto = ?',
        [item.cantidad, item.id_producto]
      );
    }

    await connection.commit();
    res.status(201).json({ mensaje: 'Venta registrada con éxito', id_venta });
  } catch (error) {
    await connection.rollback();
    res.status(500).json({ error: 'Error al registrar la venta', detalle: error.message });
  } finally {
    connection.release();
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor ejecutándose en http://localhost:${PORT}`);
});