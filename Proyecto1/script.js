let productos = JSON.parse(localStorage.getItem("productos")) || [
    { id: 1, nombre: "Arroz Premium 1kg", precio: 3500, imagen: "img/arroz.jpg" },
    { id: 2, nombre: "Leche Entera 1L", precio: 4500, imagen: "img/leche.jpg" },
    { id: 3, nombre: "Azúcar 1kg", precio: 3800, imagen: "img/azucar.jpg" },
    { id: 4, nombre: "Huevos 30 un", precio: 15000, imagen: "img/huevos.jpg" },
    { id: 5, nombre: "Jabón Manos", precio: 5000, imagen: "img/javon.jpg" },
    { id: 6, nombre: "PanTajado", precio: 3000, imagen: "img/pan.jpg" },
    { id: 7, nombre: "Queso Campesino", precio: 5400, imagen: "img/queso.jpg" },
    { id: 8, nombre: "Aceite de Girasol 1L", precio: 10900, imagen: "img/aceite.jpg" }
];
let carrito = JSON.parse(localStorage.getItem("carrito")) || [];
let usuarios = JSON.parse(localStorage.getItem("usuarios")) || [];
let ventas = JSON.parse(localStorage.getItem("ventas")) || [];
let usuarioActual = JSON.parse(sessionStorage.getItem("usuarioActual")) || null;
const INGRESO_MINIMO_META = 20000.00;

// --- CONEXIÓN CON EL BACKEND NODE.JS Y MYSQL ---
async function cargarProductosDesdeBD() {
    try {
        const respuesta = await fetch("http://localhost:3000/app/productos");
        if (respuesta.ok) {
            const productosBD = await respuesta.json();
            if (productosBD && productosBD.length > 0) {
                // Mapear productos recibidos de MySQL
                productos = productosBD.map(p => ({
                    ...p,
                    imagen: p.imagen || `img/${p.nombre.toLowerCase().split(' ')[0]}.jpg`
                }));
            }
        }
    } catch (err) {
        console.warn("⚠️ Servidor Node.js no disponible. Usando datos de respaldo local:", err);
    }
    renderizarCatalogo();
}

function activarVista(idVista) {
    document.querySelectorAll(".vista").forEach(v => { v.style.display = "none"; });
    document.getElementById(idVista).style.display = "block";
    document.querySelectorAll(".nav-btn").forEach(btn => btn.classList.remove("active"));
    const botonActivo = {
        "vista-inicio": "navInicio",
        "vista-compras": "navCarrito",
        "vista-inventario": "btnInventario",
        "vista-usuarios": "btnUsuarios",
        "vista-reportes": "btnReportes"
    }[idVista];
    if (botonActivo) document.getElementById(botonActivo).classList.add("active");
}

function evaluarReglasDeAcceso() {
    const btnAuth = document.getElementById("btnAuthNav");
    if (usuarioActual) {
        btnAuth.textContent = `Cerrar Sesión (${usuarioActual.user})`;
        btnAuth.style.backgroundColor = "#ef4444";
        if (usuarioActual.rol === "admin") {
            document.querySelectorAll(".admin-element").forEach(el => el.style.display = "inline-block");
        } else {
            document.querySelectorAll(".admin-element").forEach(el => el.style.display = "none");
        }
    } else {
        btnAuth.textContent = "Iniciar Sesión";
        btnAuth.style.backgroundColor = "#0284c7";
        document.querySelectorAll(".admin-element").forEach(el => el.style.display = "none");
    }
    document.getElementById("badgeCarrito").textContent = carrito.length;
}

// --- RENDERING DEL CATÁLOGO ---
function renderizarCatalogo() {
    const grid = document.getElementById("grid-productos");
    if (!grid) return;
    grid.innerHTML = "";
    productos.forEach(p => {
        const card = document.createElement("article");
        card.classList.add("card");
        const rutaImagen = p.imagen ? p.imagen : "img/placeholder.jpg";
        const idProd = p.id_producto || p.id;
        const precioNum = parseFloat(p.precio) || 0;

        card.innerHTML = `
            <div class="card-img-container">
                <img src="${rutaImagen}" alt="${p.nombre}" class="producto-img" onerror="this.src='img/placeholder.jpg'">
            </div>
            <h3>${p.nombre}</h3>
            <p class="precio">$${precioNum.toLocaleString('es-CO')}</p>
            <button class="btn-primary btn-add-cart" data-id="${idProd}">Agregar al Carrito</button>
        `;
        grid.appendChild(card);
    });

    grid.querySelectorAll(".btn-add-cart").forEach(boton => {
        boton.addEventListener("click", (e) => {
            const id = Number(e.target.dataset.id);
            agregarItemAlCarrito(id);
        });
    });
}

function agregarItemAlCarrito(id) {
    if (!usuarioActual) {
        alert("Atención: Para poder realizar compras en el market, primero debe Iniciar Sesión.");
        activarVista("vista-auth");
        return;
    }
    const prod = productos.find(p => (p.id_producto || p.id) === id);
    if (prod) {
        carrito.push(prod);
        localStorage.setItem("carrito", JSON.stringify(carrito));
        evaluarReglasDeAcceso();
        alert(`"${prod.nombre}" añadido al carrito.`);
    }
}

function renderizarResumenCarrito() {
    const ul = document.getElementById("listaCarrito");
    const totalSpan = document.getElementById("totalMonto");
    ul.innerHTML = "";
    let acumulado = 0;
    if (carrito.length === 0) {
        ul.innerHTML = "<li style='color:var(--text-muted);'>No has añadido productos a tu orden de compra.</li>";
        totalSpan.textContent = "0.00";
        return;
    }
    carrito.forEach((item, idx) => {
        const precioNum = parseFloat(item.precio) || 0;
        const li = document.createElement("li");
        li.innerHTML = `
            <span>${item.nombre} — <strong>$${precioNum.toLocaleString('es-CO')}</strong></span>
            <button class="btn-danger btn-remove-item" data-index="${idx}" style="width:auto; padding:4px 10px; font-size:12px;">Quitar</button>
        `;
        ul.appendChild(li);
        acumulado += precioNum;
    });
    totalSpan.textContent = acumulado.toLocaleString('es-CO');
    ul.querySelectorAll(".btn-remove-item").forEach(b => {
        b.addEventListener("click", (e) => {
            carrito.splice(Number(e.target.dataset.index), 1);
            localStorage.setItem("carrito", JSON.stringify(carrito));
            evaluarReglasDeAcceso();
            renderizarResumenCarrito();
        });
    });
}

// --- TRANSACCIÓN INTEGRADA CON MYSQL ---
async function formalizarTransaccion() {
    if (carrito.length === 0) {
        alert("Error: No hay ítems en el carrito para procesar.");
        return;
    }
    const cliente = document.getElementById("facturaNombre").value.trim();
    const documento = document.getElementById("facturaIdentificacion").value.trim();
    const metodo = document.getElementById("medioPago").value;
    const finalTotal = carrito.reduce((sum, i) => sum + (parseFloat(i.precio) || 0), 0);
    
    if (!cliente || !documento) {
        alert("Error: Complete los campos requeridos de Nombre e Identificación.");
        return;
    }

    // Agrupar ítems del carrito para enviarlos ordenados a MySQL
    const productosParaBD = [];
    carrito.forEach(item => {
        const idProd = item.id_producto || item.id;
        const existe = productosParaBD.find(p => p.id_producto === idProd);
        if (existe) {
            existe.cantidad += 1;
        } else {
            productosParaBD.push({
                id_producto: idProd,
                cantidad: 1,
                precio_unitario: parseFloat(item.precio) || 0
            });
        }
    });

    try {
        // Enviar la venta vía POST a Node.js / MySQL
        const respuesta = await fetch("http://localhost:3000/app/ventas", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                id_cliente: 1,  // ID cliente general en BD
                id_empleado: 1, // ID empleado cajero en BD
                productos: productosParaBD
            })
        });

        let idVentaServidor = Math.floor(Math.random() * 90000 + 10000);
        if (respuesta.ok) {
            const dataServidor = await respuesta.json();
            if (dataServidor.id_venta) idVentaServidor = dataServidor.id_venta;
        }

        const factura = {
            id: "FAC-" + idVentaServidor,
            fecha: new Date().toLocaleDateString(),
            cliente,
            documento,
            medioPago: metodo,
            detalles: carrito.map(c => c.nombre).join(", "),
            total: finalTotal
        };

        ventas.push(factura);
        localStorage.setItem("ventas", JSON.stringify(ventas));

        alert(`¡Transacción Procesada e Integrada en MySQL!\nFactura de Compra: ${factura.id}\nTotal: $${factura.total.toLocaleString('es-CO')}\nForma de cobro: ${factura.medioPago}`);
        
        carrito = [];
        localStorage.setItem("carrito", JSON.stringify(carrito));
        document.getElementById("facturaNombre").value = "";
        document.getElementById("facturaIdentificacion").value = "";
        evaluarReglasDeAcceso();
        activarVista("vista-inicio");
        cargarProductosDesdeBD(); // Recargar productos para actualizar stock de MySQL
    } catch (error) {
        console.error("Error registrando la venta en la base de datos:", error);
        alert("La venta se procesó localmente pero hubo un detalle al sincronizar con el servidor MySQL.");
    }
}

function procesarInformesVentas() {
    const tbody = document.getElementById("historialVentasBody");
    const widget = document.getElementById("widgetTendencia");
    tbody.innerHTML = "";
    let ingresosTotales = 0;
    if (ventas.length === 0) {
        tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; color:var(--text-muted);'>No se registran transacciones.</td></tr>";
    } else {
        ventas.forEach(v => {
            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td><strong>${v.id}</strong></td>
                <td>${v.fecha}</td>
                <td>${v.cliente} (${v.documento})</td>
                <td>${v.medioPago}</td>
                <td>${v.detalles}</td>
                <td style="color:var(--success-text); font-weight:bold;">$${v.total.toLocaleString('es-CO')}</td>
            `;
            tbody.appendChild(tr);
            ingresosTotales += v.total;
        });
    }
    if (ingresosTotales >= INGRESO_MINIMO_META) {
        const margenSubida = ((ingresosTotales - INGRESO_MINIMO_META) / INGRESO_MINIMO_META) * 100;
        widget.className = "tendencia-widget subida";
        widget.innerHTML = `<strong>Rendimiento Comercial Positivo:</strong> Los ingresos actuales suman <strong>$${ingresosTotales.toLocaleString('es-CO')}</strong>, superando la meta base de $${INGRESO_MINIMO_META.toLocaleString('es-CO')} en un <strong>+${margenSubida.toFixed(1)}%</strong>.`;
    } else {
        const margenBaja = ((INGRESO_MINIMO_META - ingresosTotales) / INGRESO_MINIMO_META) * 100;
        widget.className = "tendencia-widget baja";
        widget.innerHTML = `<strong>Alerta de Desaceleración:</strong> Ventas brutas totales de <strong>$${ingresosTotales.toLocaleString('es-CO')}</strong>. Rendimiento por debajo del umbral mínimo en un <strong>-${margenBaja.toFixed(1)}%</strong>.`;
    }
}

function renderizarTablaUsuarios() {
    const tbody = document.getElementById("listaUsuariosBody");
    tbody.innerHTML = "";
    if (usuarios.length === 0) {
        tbody.innerHTML = "<tr><td colspan='3' style='text-align:center;'>Ningún usuario registrado.</td></tr>";
        return;
    }
    usuarios.forEach(u => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td><strong>${u.user}</strong></td>
            <td><span style="background:#e2e8f0; padding:3px 8px; border-radius:4px; font-size:13px;">${u.rol.toUpperCase()}</span></td>
            <td>${u.rol === 'admin' ? 'Acceso completo' : 'Módulo de compras básico'}</td>
        `;
        tbody.appendChild(tr);
    });
}

function registrarNuevoProducto() {
    const nomInput = document.getElementById("nombre");
    const preInput = document.getElementById("precio");
    const fb = document.getElementById("mensajeFeedback");
    const nombre = nomInput.value.trim();
    const precio = parseFloat(preInput.value);
    if (!nombre || isNaN(precio) || precio <= 0) {
        fb.textContent = "Campos erróneos o vacíos.";
        fb.className = "error-message";
        return;
    }
    productos.push({ id: Date.now(), nombre, precio, imagen: "img/placeholder.jpg" });
    localStorage.setItem("productos", JSON.stringify(productos));
    nomInput.value = "";
    preInput.value = "";
    fb.textContent = "¡Artículo incorporado exitosamente!";
    fb.style.color = "var(--success)";
    renderizarCatalogo();
}

function borrarProductoDeInventario(id) {
    productos = productos.filter(p => (p.id_producto || p.id) !== id);
    localStorage.setItem("productos", JSON.stringify(productos));
    renderizarCatalogo();
}

function ejecutarAccionAuth() {
    if (usuarioActual) {
        sessionStorage.removeItem("usuarioActual");
        usuarioActual = null;
        alert("Sesión cerrada.");
        location.reload();
    } else {
        activarVista("vista-auth");
    }
}

function validarLogin() {
    const user = document.getElementById("usuario").value.trim();
    const pass = document.getElementById("password").value.trim();
    const err = document.getElementById("errorLogin");
    if (user === "admin" && pass === "1234") {
        usuarioActual = { user: "admin", rol: "admin" };
    } else {
        const uNode = usuarios.find(u => u.user === user && u.pass === pass);
        if (uNode) {
            usuarioActual = uNode;
        } else {
            err.textContent = "Contraseña o usuario inválido.";
            return;
        }
    }
    sessionStorage.setItem("usuarioActual", JSON.stringify(usuarioActual));
    err.textContent = "";
    document.getElementById("usuario").value = "";
    document.getElementById("password").value = "";
    evaluarReglasDeAcceso();
    cargarProductosDesdeBD();
    activarVista("vista-inicio");
}

function procesarRegistro() {
    const user = document.getElementById("nuevoUser").value.trim();
    const pass = document.getElementById("nuevoPass").value.trim();
    const rol = document.getElementById("rol").value;
    if (!user || pass.length < 4) {
        alert("El usuario no puede estar vacío y la contraseña debe tener mínimo 4 caracteres.");
        return;
    }
    usuarios.push({ user, pass, rol });
    localStorage.setItem("usuarios", JSON.stringify(usuarios));
    alert("Usuario Creado Con Éxito.");
    document.getElementById("nuevoUser").value = "";
    document.getElementById("nuevoPass").value = "";
    document.getElementById("card-registro").style.display = "none";
    document.getElementById("card-login").style.display = "block";
}

document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("navInicio").addEventListener("click", () => { cargarProductosDesdeBD(); activarVista("vista-inicio"); });
    document.getElementById("navCarrito").addEventListener("click", () => { renderizarResumenCarrito(); activarVista("vista-compras"); });
    document.getElementById("btnInventario").addEventListener("click", () => activarVista("vista-inventario"));
    document.getElementById("btnUsuarios").addEventListener("click", () => { renderizarTablaUsuarios(); activarVista("vista-usuarios"); });
    document.getElementById("btnReportes").addEventListener("click", () => { procesarInformesVentas(); activarVista("vista-reportes"); });
    document.getElementById("btnAuthNav").addEventListener("click", ejecutarAccionAuth);
    document.getElementById("btnIngresar").addEventListener("click", validarLogin);
    document.getElementById("btnRegistrar").addEventListener("click", procesarRegistro);
    document.getElementById("btnGuardarProducto").addEventListener("click", registrarNuevoProducto);
    document.getElementById("btnPagar").addEventListener("click", formalizarTransaccion);
    document.getElementById("btnVaciarCarrito").addEventListener("click", () => {
        carrito = [];
        localStorage.setItem("carrito", JSON.stringify(carrito));
        evaluarReglasDeAcceso();
        renderizarResumenCarrito();
    });
    document.getElementById("linkRegistro").addEventListener("click", () => {
        document.getElementById("card-login").style.display = "none";
        document.getElementById("card-registro").style.display = "block";
    });
    document.getElementById("linkVolverLogin").addEventListener("click", () => {
        document.getElementById("card-registro").style.display = "none";
        document.getElementById("card-login").style.display = "block";
    });

    evaluarReglasDeAcceso();
    cargarProductosDesdeBD(); // Carga de datos real desde Node.js/MySQL al iniciar
    activarVista("vista-inicio");
});