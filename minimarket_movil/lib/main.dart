import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MinimarketFlashApp());

class MinimarketFlashApp extends StatelessWidget {
  const MinimarketFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minimarket Flash!',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF5C1305),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// FORMATO DE MONEDA EN PESOS COLOMBIANOS ($3.500)
String formatearPrecioCOP(dynamic precio) {
  double val = double.tryParse(precio.toString()) ?? 0.0;
  int entero = val.toInt();
  String str = entero.toString();
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String resultado = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  return '\$$resultado';
}

// 1. PANTALLA DE LOGIN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  void _iniciarSesion() {
    if (_usuarioController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese usuario y contraseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Minimarket ',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF5C1305)),
                      children: [
                        TextSpan(text: 'Flash!', style: TextStyle(color: Color(0xFFE0612B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Iniciar Sesión en el Sistema', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario / Correo',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF5C1305)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF5C1305)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0082C8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _iniciarSesion,
                    child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C1305),
                      minimumSize: const Size.fromHeight(45),
                      side: const BorderSide(color: Color(0xFF5C1305)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistroScreen()),
                      );
                    },
                    child: const Text('Crear una cuenta (Registrarse)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. REGISTRO (SINCRONIZADO CON WEB)
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _rolSeleccionado = 'cliente';

  String get apiUserUrl => kIsWeb ? 'http://localhost:3000/app/usuarios' : 'http://10.0.2.2:3000/app/usuarios';

  Future<void> _registrarUsuario() async {
    if (_nombreCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor complete todos los campos')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUserUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': _nombreCtrl.text,
          'password': _passCtrl.text,
          'rol': _rolSeleccionado,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión')));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al registrar usuario')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C1305),
        title: const Text('Crear Cuenta', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre de Usuario', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña Segura', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _rolSeleccionado,
              decoration: const InputDecoration(labelText: 'Tipo de Perfil', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'cliente', child: Text('Cliente (Comprador)')),
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
              ],
              onChanged: (val) => setState(() => _rolSeleccionado = val!),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0612B),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _registrarUsuario,
              child: const Text('Finalizar Registro', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. NAVEGACIÓN PRINCIPAL
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> carrito = [];

  void agregarAlCarrito(Map producto) {
    setState(() {
      int index = carrito.indexWhere((item) => item['id_producto'] == producto['id_producto']);
      if (index != -1) {
        carrito[index]['cantidad'] += 1;
      } else {
        carrito.add({
          'id_producto': producto['id_producto'],
          'nombre': producto['nombre'],
          'precio': double.tryParse(producto['precio'].toString()) ?? 0.0,
          'imagen_url': producto['imagen_url'],
          'cantidad': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['nombre']} agregado al carrito'), duration: const Duration(seconds: 1)),
    );
  }

  void eliminarDelCarrito(int index) {
    setState(() => carrito.removeAt(index));
  }

  void vaciarCarrito() {
    setState(() => carrito.clear());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      TiendaScreen(onAgregarAlCarrito: agregarAlCarrito),
      CarritoScreen(carrito: carrito, onEliminar: eliminarDelCarrito, onVaciar: vaciarCarrito),
      const InventarioScreen(),
      const UsuariosScreen(),
      const PanelVentasScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C1305),
        title: RichText(
          text: const TextSpan(
            text: 'Minimarket ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            children: [TextSpan(text: 'Flash!', style: TextStyle(color: Color(0xFFE0612B)))],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          )
        ],
      ),
      body: paginas[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFE0612B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tienda'),
          BottomNavigationBarItem(
            icon: Badge(label: Text('${carrito.length}'), child: const Icon(Icons.shopping_cart)),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventario'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Ventas'),
        ],
      ),
    );
  }
}

// MÓDULO 1: TIENDA
class TiendaScreen extends StatefulWidget {
  final Function(Map) onAgregarAlCarrito;
  const TiendaScreen({super.key, required this.onAgregarAlCarrito});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  List productos = [];
  bool isLoading = true;

  String get baseUrl => kIsWeb ? 'http://localhost:3000/app/productos' : 'http://10.0.2.2:3000/app/productos';

  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Future<void> fetchProductos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          productos = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _cargarImagenProducto(String? imgName) {
    if (imgName == null || imgName.isEmpty) {
      return const Icon(Icons.shopping_bag, size: 50, color: Color(0xFF5C1305));
    }

    String baseName = imgName.contains('.') ? imgName.split('.').first : imgName;
    List<String> extensiones = ['.png', '.jpg', '.jpeg', '.webp'];

    return _probarExtensiones(baseName, extensiones, 0);
  }

  Widget _probarExtensiones(String baseName, List<String> exts, int index) {
    if (index >= exts.length) {
      return const Icon(Icons.shopping_bag, size: 50, color: Color(0xFF5C1305));
    }

    String assetPath = 'assets/img/$baseName${exts[index]}';

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _probarExtensiones(baseName, exts, index + 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          width: double.infinity,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catálogo de Productos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C1305))),
              Text('Explora nuestras ofertas disponibles en tiempo real.', style: TextStyle(color: Color(0xFFA86200))),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C1305)))
              : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final item = productos[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _cargarImagenProducto(item['imagen_url']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C1305)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFD1F2D9), borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          formatearPrecioCOP(item['precio']),
                          style: const TextStyle(color: Color(0xFF0082C8), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0612B),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => widget.onAgregarAlCarrito(item),
                        child: const Text('Agregar al Carrito', style: TextStyle(fontSize: 12)),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// MÓDULO 2: CARRITO DE COMPRAS
class CarritoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> carrito;
  final Function(int) onEliminar;
  final VoidCallback onVaciar;

  const CarritoScreen({super.key, required this.carrito, required this.onEliminar, required this.onVaciar});

  double get total => carrito.fold(0, (sum, item) => sum + (item['precio'] * item['cantidad']));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Carrito de Compras', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5C1305))),
              if (carrito.isNotEmpty)
                TextButton.icon(
                  onPressed: onVaciar,
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  label: const Text('Vaciar', style: TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
        Expanded(
          child: carrito.isEmpty
              ? const Center(child: Text('El carrito está vacío.'))
              : ListView.builder(
            itemCount: carrito.length,
            itemBuilder: (context, index) {
              final item = carrito[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF5C1305),
                    child: Icon(Icons.shopping_basket, color: Colors.white),
                  ),
                  title: Text(item['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Cantidad: ${item['cantidad']} | Subtotal: ${formatearPrecioCOP(item['precio'] * item['cantidad'])}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onEliminar(index),
                  ),
                ),
              );
            },
          ),
        ),
        if (carrito.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(formatearPrecioCOP(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0082C8))),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0082C8),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () {
                    onVaciar();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Compra realizada con éxito!')));
                  },
                  child: const Text('Finalizar Compra'),
                )
              ],
            ),
          )
      ],
    );
  }
}

// MÓDULO 3: INVENTARIO
class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List productos = [];
  bool isLoading = true;

  String get baseUrl => kIsWeb ? 'http://localhost:3000/app/productos' : 'http://10.0.2.2:3000/app/productos';

  @override
  void initState() {
    super.initState();
    fetchProductos();
  }

  Future<void> fetchProductos() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          productos = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) fetchProductos();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final item = productos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(item['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Precio: ${formatearPrecioCOP(item['precio'])} | Stock: ${item['stock']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => eliminarProducto(item['id_producto']),
              ),
            ),
          );
        },
      ),
    );
  }
}

// MÓDULO 4: USUARIOS
class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Módulo de Gestión de Usuarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5C1305))),
    );
  }
}

// MÓDULO 5: PANEL VENTAS
class PanelVentasScreen extends StatelessWidget {
  const PanelVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Panel de Reportes y Ventas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5C1305))),
    );
  }
}