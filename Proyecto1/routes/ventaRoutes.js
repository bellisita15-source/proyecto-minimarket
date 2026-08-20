const express = require('express');
const router = express.Router();
router.post('/', (req, res) => {
    const { id_cliente, id_empleado } = req.body;
    const sql = 'INSERT INTO venta (fecha_venta, total_venta, id_cliente, id_empleado) VALUES (NOW(), 0, ?, ?)';
    req.db.query(sql, [id_cliente || 1, id_empleado || 1], (err, result) => {
        if (err) return res.status(500).json({ error: "Error al registrar la venta" });
        res.status(201).json({ mensaje: "Venta registrada exitosamente", id_venta: result.insertId });
    });
});

module.exports = router;
