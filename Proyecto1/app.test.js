const request = require('supertest');
const express = require('express');

// Módulos de prueba simulados
const app = express();
app.use(express.json());

// Endpoint de prueba de validación de registro
app.post('/app/validar-usuario', (req, res) => {
    const { user, pass } = req.body;
    if (!user || !pass || pass.length < 4) {
        return res.status(400).json({ error: "Datos inválidos o contraseña corta" });
    }
    return res.status(200).json({ mensaje: "Usuario válido" });
});

describe('Pruebas del Módulo de Usuario y Productos (Jest + Supertest)', () => {

    test('1. Validación Rechazada: Contraseña corta o campos vacíos', async () => {
        const respuesta = await request(app)
            .post('/app/validar-usuario')
            .send({ user: 'admin', pass: '123' });
        
        expect(respuesta.statusCode).toBe(400);
        expect(respuesta.body.error).toBe('Datos inválidos o contraseña corta');
    });

    test('2. Validación Exitosa: Usuario y contraseña correcta', async () => {
        const respuesta = await request(app)
            .post('/app/validar-usuario')
            .send({ user: 'admin', pass: '1234' });
        
        expect(respuesta.statusCode).toBe(200);
        expect(respuesta.body.mensaje).toBe('Usuario válido');
    });
});