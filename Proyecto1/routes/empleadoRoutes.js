const express = require('express');
const router = express.Router();
const db = require('../db'); // Ajusta la ruta según tu archivo de conexión

// OBTENER USUARIO POR ID
router.get('/:id', (req, res) => {
    const { id } = req.params;
    const query = 'SELECT id_usuario, nombre, correo, rol FROM usuarios WHERE id_usuario = ?';

    db.query(query, [id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Error interno del servidor' });
        if (results.length === 0) return res.status(404).json({ mensaje: 'Usuario no encontrado' });

        return res.status(200).json({ usuario: results[0] });
    });
});

// CREAR USUARIO (COMPATIBLE CON APP WEB Y APP MÓVIL)
router.post('/', (req, res) => {
    const { nombre, password, rol, correo } = req.body;

    if (!nombre || !password) {
        return res.status(400).json({ error: 'El nombre y la contraseña son requeridos' });
    }

    // Si la web no envía correo, se genera uno por defecto para cumplir la restricción de la DB
    const correoFinal = correo || `${nombre.toLowerCase().replace(/\s+/g, '')}@minimarket.com`;
    const rolFinal = rol || 'cliente';

    const query = 'INSERT INTO usuarios (nombre, correo, password, rol) VALUES (?, ?, ?, ?)';

    db.query(query, [nombre, correoFinal, password, rolFinal], (err, result) => {
        if (err) {
            console.error('Error al insertar usuario:', err);
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'El nombre de usuario o correo ya existe' });
            }
            return res.status(500).json({ error: 'Error al registrar en la base de datos' });
        }

        return res.status(201).json({
            mensaje: 'Usuario registrado con éxito',
            id_usuario: result.insertId
        });
    });
});

module.exports = router;