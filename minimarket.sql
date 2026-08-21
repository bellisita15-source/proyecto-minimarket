CREATE DATABASE IF NOT EXISTS minimarket DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE minimarket;

DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT
);

CREATE TABLE proveedores (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  direccion VARCHAR(150)
);

CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  direccion VARCHAR(150)
);

CREATE TABLE empleados (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  cargo VARCHAR(50),
  salario DECIMAL(10,2)
);

CREATE TABLE usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol VARCHAR(20) DEFAULT 'cliente'
);

CREATE TABLE productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  imagen_url VARCHAR(255) DEFAULT 'default.png',
  id_categoria INT,
  id_proveedor INT,
  FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE ventas (
  id_venta INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_cliente INT,
  id_empleado INT,
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
  FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE TABLE detalle_venta (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT,
  id_producto INT,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

INSERT INTO categorias (nombre, descripcion) VALUES
('Lácteos y Huevos', 'Derivados de la leche y huevos frescos'),
('Panadería y Galletas', 'Pan fresco, tostadas y galletas'),
('Abarrotes y Granos', 'Arroz, aceite, azúcar y granos'),
('Bebidas y Refrescos', 'Gaseosas, jugos y agua');

INSERT INTO proveedores (nombre, telefono, direccion) VALUES
('Alpina Alimenticios', '6012345678', 'Calle 100 # 15-20, Bogotá'),
('Grupo Nutresa', '6018765432', 'Carrera 68 # 20-40, Bogotá');

INSERT INTO clientes (nombre, telefono, direccion) VALUES
('Cliente General', '0000000000', 'Venta mostrador'),
('María López', '3209876543', 'Carrera 10 # 5-67');

INSERT INTO empleados (nombre, cargo, salario) VALUES
('Ana Martínez', 'Cajera', 1300000.00),
('Carlos Rodríguez', 'Administrador', 2100000.00);

INSERT INTO usuarios (nombre, correo, password, rol) VALUES
('Admin SENA', 'admin@minimarket.com', '123456', 'admin');

INSERT INTO productos (nombre, precio, stock, imagen_url, id_categoria, id_proveedor) VALUES
('Arroz Premium 1kg', 3500.00, 100, 'arroz.jpg', 3, 2),
('Leche Entera 1L', 4500.00, 80, 'leche.jpg', 1, 1),
('Azúcar 1kg', 3800.00, 90, 'azucar.jpg', 3, 2),
('Huevos 30 un', 15000.00, 40, 'huevos.jpg', 1, 1),
('Jabón Manos', 5000.00, 50, 'javon.jpg', 3, 2),
('PanTajado', 3000.00, 30, 'pan.jpg', 2, 2),
('Queso Campesino', 5400.00, 25, 'queso.jpg', 1, 1),
('Aceite de Girasol 1L', 10900.00, 60, 'aceite.jpg', 3, 2);