const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  req.db.query('SELECT * FROM producto', (err, results) => {
    if (err) return res.status(500).json({ error: 'Error BD', detalle: err });
    res.status(200).json(results);
  });
});

router.get('/:id', (req, res) => {
  const { id } = req.params;
  req.db.query('SELECT * FROM producto WHERE id_producto = ?', [id], (err, results) => {
    if (err) return res.status(500).json({ error: 'Error BD', detalle: err });
    if (!results || results.length === 0) return res.status(404).json({ mensaje: 'Producto no encontrado' });
    res.status(200).json(results[0]);
  });
});

module.exports = router;
