// maps_page.dart
import 'package:flutter/material.dart';
import 'package:transportes_locales/widgets/loginpage.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mapa',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      // Drawer es el menú lateral
      drawer: _buildDrawer(context),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Pantalla de Mapa',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Aquí irá tu mapa integrado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir el menú lateral
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado del drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[50],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar/Imagen de perfil
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      "https://img3.pillowfort.social/posts/44a1658f1e2f47597c2a.gif",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre de usuario
                const Text(
                  'Usuario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  'usuario@ejemplo.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Opción 1: Favoritos
          _buildDrawerItem(
            icon: Icons.favorite_border,
            title: 'Favoritos',
            onTap: () {
              // Cierra el drawer primero
              Navigator.pop(context);
              // Aquí puedes navegar a la pantalla de Favoritos
              _showComingSoonMessage(context, 'Favoritos');
            },
          ),
          
          // Opción 2: Filtrar
          _buildDrawerItem(
            icon: Icons.filter_list,
            title: 'Filtrar',
            onTap: () {
              Navigator.pop(context);
              // Muestra opciones de filtro
              _showFilterOptions(context);
            },
          ),
          
          // Divisor
          const Divider(color: Colors.grey, height: 1),
          
          // Opción 3: Mi Cuenta
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Mi Cuenta',
            onTap: () {
              Navigator.pop(context);
              _showComingSoonMessage(context, 'Mi Cuenta');
            },
          ),
          
          // Opción 4: Cerrar Sesión
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              // Cierra el drawer
              Navigator.pop(context);
              // Muestra diálogo de confirmación
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para items del menú
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black87,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  // Método para mostrar opciones de filtro
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opción de filtro: Rutas
              _buildFilterOption(
                title: 'Rutas',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage(context, 'Filtro: Rutas');
                },
              ),
              
              // Opción de filtro: Paradas
              _buildFilterOption(
                title: 'Paradas',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage(context, 'Filtro: Paradas');
                },
              ),
              
              // Opción de filtro: Horarios
              _buildFilterOption(
                title: 'Horarios',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage(context, 'Filtro: Horarios');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para opciones de filtro
  Widget _buildFilterOption({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.check_box_outline_blank,
          color: Colors.grey[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  // Diálogo para cerrar sesión
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              // Navega al LoginPage reemplazando toda la pila de navegación
              Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false, // Esto limpia toda la pila de navegación
            ); // Regresa al login
              // Aquí también puedes limpiar datos de sesión
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar mensajes de "próximamente"
  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        content: Text('$feature - Próximamente'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}