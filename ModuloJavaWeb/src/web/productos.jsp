<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minimarket.modelo.Producto" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Minimarket Flash - Módulo Java Web (Servlets & JSP)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container my-5">
        <h1 class="text-primary text-center mb-4">Minimarket Flash - Módulo Java Web</h1>
        
        <!-- Formulario HTML con envío POST al Servlet -->
        <div class="card shadow-sm mb-5">
            <div class="card-header bg-primary text-white">
                <h5 class="card-title mb-0">Registrar Producto (Método POST)</h5>
            </div>
            <div class="card-body">
                <form action="ProductoServlet" method="POST" class="row g-3">
                    <div class="col-md-5">
                        <label for="nombre" class="form-label">Nombre del Producto:</label>
                        <input type="text" id="nombre" name="nombre" class="form-control" required placeholder="Ej. Arroz 1kg">
                    </div>
                    <div class="col-md-3">
                        <label for="precio" class="form-label">Precio ($):</label>
                        <input type="number" step="0.01" id="precio" name="precio" class="form-control" required placeholder="3500">
                    </div>
                    <div class="col-md-2">
                        <label for="stock" class="form-label">Stock:</label>
                        <input type="number" id="stock" name="stock" class="form-control" required placeholder="50">
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-success w-100">Guardar</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Renderizado con elementos JSP Scriptlets y expresiones -->
        <div class="card shadow-sm">
            <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Inventario en MySQL (Consulta GET)</h5>
                <a href="ProductoServlet" class="btn btn-sm btn-outline-light">Cargar/Actualizar (GET)</a>
            </div>
            <div class="card-body p-0">
                <table class="table table-striped table-hover mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Precio</th>
                            <th>Stock</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Producto> productos = (List<Producto>) request.getAttribute("listaProductos");
                            if (productos != null && !productos.isEmpty()) {
                                for (Producto p : productos) {
                        %>
                        <tr>
                            <td><%= p.getIdProducto() %></td>
                            <td><%= p.getNombre() %></td>
                            <td>$<%= String.format("%.2f", p.getPrecio()) %></td>
                            <td><%= p.getStock() %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" class="text-center text-muted">Presione "Cargar/Actualizar (GET)" para consultar MySQL.</td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>