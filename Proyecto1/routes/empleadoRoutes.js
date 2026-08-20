const express = require('express');
const router = express.Router();

router.get('/:id', (req, res) => {
    const { id } = req.params;
    res.status(200).json({
        mensaje: `Detalles del empleado ${id} obtenidos.`,
        empleado: {
            idEmpleado: parseInt(id),
            nombre: "Ana",
            rol: "Cajero Principal",
            usuario: "anaP",
            password: "ana123"
        }
    });
});

module.exports = router;