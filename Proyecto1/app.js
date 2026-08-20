const express = require('express');
const cors = require('cors');
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// 1. Obtener todos los productos
app.get('/app/productos', async (req, res) => {
  try {
    const [r] = await db.query('SELECT * FROM productos');
    res.json(r);
  } catch (e) {
    res.status(500).json(e);
  }
});

// 2. Buscar producto por ID
app.get('/app/productos/:id', async (req, res) => {
  try {
    const [r] = await db.query('SELECT * FROM productos WHERE id_producto = ?', [req.params.id]);
    if (!r.length) return res.status(404).json({ mensaje: 'Producto no encontrado' });
    res.json(r[0]);
  } catch (e) {
    res.status(500).json(e);
  }
});

const PORT = 3000;
app.listen(PORT, () => console.log('🚀 Servidor ejecutándose en http://localhost:' + PORT));