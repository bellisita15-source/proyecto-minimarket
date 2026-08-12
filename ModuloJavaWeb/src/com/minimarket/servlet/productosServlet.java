package com.minimarket.servlet;

import com.minimarket.dao.ProductoDAO;
import com.minimarket.modelo.Producto;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProductoServlet")
public class ProductoServlet extends HttpServlet {
    
    private ProductoDAO productoDAO = new ProductoDAO();

    // MÉTODOS GET: Consulta de datos desde la BD
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Obtener lista de productos desde MySQL
        List<Producto> listaProductos = productoDAO.listarProductos();
        
        // Enviar la lista a la vista JSP
        request.setAttribute("listaProductos", listaProductos);
        request.getRequestDispatcher("productos.jsp").forward(request, response);
    }

    // MÉTODOS POST: Recepción de datos del formulario HTML
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Capturar parámetros enviados por el formulario HTML
        String nombre = request.getParameter("nombre");
        double precio = Double.parseDouble(request.getParameter("precio"));
        int stock = Integer.parseInt(request.getParameter("stock"));

        // Instanciar modelo y guardar
        Producto nuevoProducto = new Producto();
        nuevoProducto.setNombre(nombre);
        nuevoProducto.setPrecio(precio);
        nuevoProducto.setStock(stock);

        productoDAO.insertarProducto(nuevoProducto);

        // Redireccionar mediante GET para refrescar la lista
        response.sendRedirect("ProductoServlet");
    }
}