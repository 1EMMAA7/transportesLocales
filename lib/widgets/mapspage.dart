import 'package:flutter/material.dart';
import 'package:transportes_locales/widgets/loginpage.dart';
import 'package:transportes_locales/models/usermodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapsPage extends StatelessWidget {
  final User user;

  const MapsPage({super.key, required this.user});

  // Paleta de colores fríos (consistente con las demás páginas)
  final Color _primaryColor = const Color(0xFF2C5F9B);
  final Color _secondaryColor = const Color(0xFF4A90A4);
  final Color _accentColor = const Color(0xFF6BB2B2);
  final Color _backgroundLight = const Color(0xFFF8FBFE);
  final Color _cardColor = const Color(0xFFE3F2FD);
  final Color _textPrimary = const Color(0xFF2C3E50);
  final Color _textSecondary = const Color(0xFF5D6D7E);
  final Color _successColor = const Color(0xFF27AE60);
  final Color _warningColor = const Color(0xFFE74C3C);
  final Color _gradientStart = const Color(0xFF667EEA);
  final Color _gradientEnd = const Color(0xFF764BA2);

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: _buildAppBar(context),
      body: const MapWebView(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Text(
        'Mapa de Transportes',
        style: TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        // Botón de ubicación
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              _showMessage(context, 'Buscando tu ubicación...', _accentColor);
            },
          ),
        ),
        
        // Menú de perfil
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: PopupMenuButton<String>(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            onSelected: (value) {
              _handleMenuSelection(context, value);
            },
            itemBuilder: (BuildContext context) => [
              // Header del menú con información del usuario
              PopupMenuItem<String>(
                enabled: false,
                height: 80,
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del usuario
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.person,
                              color: _primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
              
              // Opción Mi Perfil
              PopupMenuItem<String>(
                value: 'profile',
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: _primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mi Perfil',
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Separador
              const PopupMenuDivider(height: 1),
              
              // Opción Cerrar Sesión
              PopupMenuItem<String>(
                value: 'logout',
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: _warningColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: _warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 50),
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        _showComingSoonMessage(context, 'Mi Perfil');
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.logout, color: _warningColor, size: 30),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                '¿Estás seguro de que quieres cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: _textSecondary.withOpacity(0.3)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _warningColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _primaryColor,
        content: Row(
          children: [
            Icon(Icons.build_circle_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$feature - Próximamente',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class MapWebView extends StatefulWidget {
  const MapWebView({super.key});

  @override
  State<MapWebView> createState() => _MapWebViewState();
}

class _MapWebViewState extends State<MapWebView> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
        },
      ))
      ..loadRequest(Uri.parse('https://umap.openstreetmap.fr/es/map/trasnportes-locales-huajauapan_1298643#18/17.81052/-97.77547'));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading)
          Container(
            color: const Color(0xFFF8FBFE),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5F9B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5F9B)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando mapa...',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}