const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// 1. CARPETA PÚBLICA PARA LAS IMÁGENES DE PROYECTO1/IMG
app.use('/img', express.static(path.join(__dirname, 'img')));

// 2. OBTENER PRODUCTOS (GET)
app.get('/app/productos', async (req, res) => {
  try {
    const [r] = await db.query('SELECT * FROM productos');
    res.json(r);
  } catch (e) { 
    res.status(500).json(e); 
  }
});

app.get('/app/productos/:id', async (req, res) => {
  try {
    const [r] = await db.query('SELECT * FROM productos WHERE id_producto = ?', [req.params.id]);
    if (!r.length) return res.status(404).json({ mensaje: 'No encontrado' });
    res.json(r[0]);
  } catch (e) { 
    res.status(500).json(e); 
  }
});

// 3. REGISTRO Y LOGIN DE USUARIOS
app.post('/app/usuarios', async (req, res) => {
  const { nombre, correo, password } = req.body;
  try {
    const [result] = await db.query(
      'INSERT INTO usuarios (nombre, correo, password) VALUES (?, ?, ?)',
      [nombre, correo || '', password || '']
    );
    res.status(201).json({ mensaje: 'Usuario registrado con éxito', id_usuario: result.insertId });
  } catch (e) {
    res.status(500).json({ error: 'Error al registrar usuario', detalle: e.message });
  }
});

// 4. REGISTRAR VENTAS
app.post('/app/ventas', async (req, res) => {
  const { id_cliente, id_empleado, productos } = req.body;
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const [resVenta] = await connection.query('INSERT INTO ventas (id_cliente, id_empleado) VALUES (?, ?)', [id_cliente || 1, id_empleado || 1]);
    const id_venta = resVenta.insertId;
    if (productos && productos.length) {
      for (const item of productos) {
        await connection.query('INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (?, ?, ?, ?)', [id_venta, item.id_producto, item.cantidad, item.precio_unitario]);
        await connection.query('UPDATE productos SET stock = stock - ? WHERE id_producto = ?', [item.cantidad, item.id_producto]);
      }
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

app.listen(3000, () => console.log(' Servidor listo en http://localhost:3000'));