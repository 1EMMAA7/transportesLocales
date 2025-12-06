import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:transportes_locales/widgets/loginpage.dart';
import 'package:transportes_locales/models/usermodel.dart';

class MapsPage extends StatefulWidget {
  final User user;

  const MapsPage({super.key, required this.user});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // Paleta de colores fríos
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

  final MapController _mapController = MapController();
  List<MapPoint> _allPoints = [];
  List<MapPoint> _filteredPoints = [];
  String _currentFilter = 'all';
  bool _isLoading = true;
  bool _locationLoading = false;
  LatLng? _userLocation;
  double _searchRadius = 2.0; // Radio en kilómetros

  // Coordenadas de Huajuapan de León (fallback)
  final LatLng _initialCenter = const LatLng(17.81052, -97.77547);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Primero cargar los puntos
    _loadMapPoints();
    
    // Luego obtener la ubicación
    await _getCurrentLocation();
  }

  void _loadMapPoints() {
    // Puntos de ejemplo para transporte en Huajuapan
    final List<MapPoint> points = [
      MapPoint(
        id: '1',
        name: 'Terminal Central',
        position: const LatLng(17.8076, -97.7732),
        isFavorite: true,
        lastVisited: DateTime.now(),
        type: 'terminal',
        description: 'Terminal principal de autobuses',
        distance: 0.0,
      ),
      MapPoint(
        id: '2',
        name: 'Parada Mercado',
        position: const LatLng(17.8068, -97.7759),
        isFavorite: false,
        lastVisited: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'parada',
        description: 'Parada frente al mercado central',
        distance: 0.0,
      ),
      MapPoint(
        id: '3',
        name: 'Estación Universidad',
        position: const LatLng(17.8123, -97.7781),
        isFavorite: true,
        lastVisited: DateTime.now().subtract(const Duration(days: 1)),
        type: 'terminal',
        description: 'Parada universitaria',
        distance: 0.0,
      ),
      MapPoint(
        id: '4',
        name: 'Parada Hospital',
        position: const LatLng(17.8089, -97.7704),
        isFavorite: false,
        lastVisited: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'parada',
        description: 'Parada cerca del hospital regional',
        distance: 0.0,
      ),
      MapPoint(
        id: '5',
        name: 'Terminal Sur',
        position: const LatLng(17.8034, -97.7768),
        isFavorite: false,
        lastVisited: DateTime.now().subtract(const Duration(days: 2)),
        type: 'terminal',
        description: 'Terminal sur de la ciudad',
        distance: 0.0,
      ),
      // Puntos más lejanos para demostración
      MapPoint(
        id: '6',
        name: 'Terminal Norte',
        position: const LatLng(17.8200, -97.7800),
        isFavorite: false,
        lastVisited: DateTime.now().subtract(const Duration(days: 3)),
        type: 'terminal',
        description: 'Terminal norte de la ciudad',
        distance: 0.0,
      ),
      MapPoint(
        id: '7',
        name: 'Parada Estadio',
        position: const LatLng(17.8150, -97.7850),
        isFavorite: false,
        lastVisited: DateTime.now().subtract(const Duration(days: 1)),
        type: 'parada',
        description: 'Parada cerca del estadio',
        distance: 0.0,
      ),
    ];

    setState(() {
      _allPoints = points;
      _filteredPoints = _allPoints;
    });
  }

  // Función para calcular distancia entre dos coordenadas
  double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end) / 1000; // Convertir a kilómetros
  }

  // Función para obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationLoading = true;
    });

    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Los permisos de ubicación fueron denegados', _warningColor);
          _finishLoading();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage('Los permisos de ubicación están denegados permanentemente. Active los permisos en configuración.', _warningColor);
        _finishLoading();
        return;
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final userLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _userLocation = userLocation;
      });

      // Calcular distancias para todos los puntos
      _updatePointsDistance(userLocation);
      
      // Aplicar filtro de cercanía por defecto
      _applyFilter('nearby');
      
      // Mover mapa a la ubicación del usuario
      _mapController.move(userLocation, 15.0);
      
      _showMessage('Ubicación detectada. Mostrando puntos cercanos', _successColor);

    } catch (e) {
      _showMessage('Error obteniendo ubicación: $e', _warningColor);
      // Usar ubicación por defecto
      setState(() {
        _userLocation = _initialCenter;
      });
      _updatePointsDistance(_initialCenter);
    } finally {
      _finishLoading();
    }
  }

  void _updatePointsDistance(LatLng userLocation) {
    for (var point in _allPoints) {
      point.distance = _calculateDistance(userLocation, point.position);
    }
  }

  void _finishLoading() {
    setState(() {
      _isLoading = false;
      _locationLoading = false;
    });
  }

  void _applyFilter(String filterType) {
    setState(() {
      _currentFilter = filterType;

      switch (filterType) {
        case 'nearby':
          if (_userLocation != null) {
            _filteredPoints = _allPoints.where((point) => 
              point.distance <= _searchRadius).toList();
            // Ordenar por distancia
            _filteredPoints.sort((a, b) => a.distance.compareTo(b.distance));
          } else {
            _filteredPoints = _allPoints;
          }
          break;
        case 'favorites':
          _filteredPoints = _allPoints.where((point) => point.isFavorite).toList();
          break;
        case 'recent':
          final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
          _filteredPoints = _allPoints.where((point) => 
            point.lastVisited.isAfter(oneDayAgo)).toList();
          break;
        case 'terminals':
          _filteredPoints = _allPoints.where((point) => point.type == 'terminal').toList();
          break;
        case 'stops':
          _filteredPoints = _allPoints.where((point) => point.type == 'parada').toList();
          break;
        default:
          _filteredPoints = _allPoints;
      }
    });
  }

  void _toggleFavorite(String pointId) {
    setState(() {
      final point = _allPoints.firstWhere((p) => p.id == pointId);
      point.isFavorite = !point.isFavorite;
      _applyFilter(_currentFilter);
    });
    _showMessage(
        '${_allPoints.firstWhere((p) => p.id == pointId).isFavorite ? 'Agregado a' : 'Eliminado de'} favoritos', 
        _successColor
    );
  }

  void _goToCurrentLocation() async {
    setState(() {
      _locationLoading = true;
    });

    await _getCurrentLocation();
    
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    }
  }

  void _showRadiusSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Radio de búsqueda',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mostrar puntos dentro de:',
                  style: TextStyle(color: _textSecondary),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_searchRadius.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _searchRadius,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  label: '${_searchRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                  activeColor: _primaryColor,
                  inactiveColor: _cardColor,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.5 km', style: TextStyle(color: _textSecondary)),
                    Text('10 km', style: TextStyle(color: _textSecondary)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: _textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilter('nearby');
                  _showMessage('Radio actualizado a ${_searchRadius.toStringAsFixed(1)} km', _primaryColor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPointDetails(MapPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header del punto
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: point.type == 'terminal' 
                            ? _primaryColor.withOpacity(0.1) 
                            : _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        point.type == 'terminal' ? Icons.directions_bus : Icons.place,
                        color: point.type == 'terminal' ? _primaryColor : _accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            point.type == 'terminal' ? 'Terminal' : 'Parada',
                            style: TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        point.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: point.isFavorite ? _warningColor : _textSecondary,
                        size: 28,
                      ),
                      onPressed: () => _toggleFavorite(point.id),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Distancia (si tenemos ubicación)
                if (_userLocation != null) ...[
                  Row(
                    children: [
                      Icon(Icons.place, color: _textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Distancia: ${point.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Descripción
                if (point.description.isNotEmpty) ...[
                  Text(
                    point.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Última visita
                Row(
                  children: [
                    Icon(Icons.access_time, color: _textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Última visita: ${_formatDate(point.lastVisited)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: _textSecondary.withOpacity(0.3)),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _mapController.move(point.position, 16.0);
                          Navigator.pop(context);
                          _showMessage('Navegando a ${point.name}', _primaryColor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ir aquí'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message, Color color) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: _buildAppBar(context),
      body: _isLoading ? _buildLoadingIndicator() : _buildMapContent(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón de radio de búsqueda
          if (_userLocation != null) ...[
            FloatingActionButton.small(
              onPressed: _showRadiusSettings,
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.tune),
            ),
            const SizedBox(height: 8),
          ],
          // Botón de ubicación
          FloatingActionButton(
            onPressed: _goToCurrentLocation,
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            child: _locationLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa de Transportes',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (_userLocation != null) ...[
            Text(
              'Radio: ${_searchRadius.toStringAsFixed(1)} km',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
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
              child: const Icon(
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
                                  widget.user.fullName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.user.email,
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

  Widget _buildMapContent() {
    return Column(
      children: [
        // Barra de filtros
        _buildFilterBar(),
        // Mapa
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _userLocation ?? _initialCenter,
              zoom: 14.0,
              maxZoom: 18.0,
              minZoom: 10.0,
            ),
            children: [
              // Capa de tiles (mapa)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.transporteslocales.app',
              ),
              // Marcador de ubicación del usuario
              if (_userLocation != null) ...[
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40.0,
                      height: 40.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _successColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
              // Capa de marcadores de puntos
              MarkerLayer(
                markers: _filteredPoints.map((point) {
                  return Marker(
                    point: point.position,
                    width: 60.0,
                    height: 60.0,
                    child: GestureDetector(
                      onTap: () => _showPointDetails(point),
                      child: _buildCustomMarker(point),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            'Filtrar puntos:',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Cercanos', 'nearby', Icons.near_me),
                _buildFilterChip('Todos', 'all', Icons.map),
                _buildFilterChip('Favoritos', 'favorites', Icons.favorite),
                _buildFilterChip('Recientes', 'recent', Icons.access_time),
                _buildFilterChip('Terminales', 'terminals', Icons.directions_bus),
                _buildFilterChip('Paradas', 'stops', Icons.place),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _currentFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : _primaryColor,
        ),
        selected: isSelected,
        onSelected: (_) => _applyFilter(value),
        checkmarkColor: Colors.white,
        selectedColor: _primaryColor,
        backgroundColor: _cardColor,
      ),
    );
  }

  Widget _buildCustomMarker(MapPoint point) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: point.type == 'terminal' ? _primaryColor : _accentColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Icon(
            point.type == 'terminal' ? Icons.directions_bus : Icons.place,
            color: Colors.white,
            size: 20,
          ),
        ),
        if (point.isFavorite)
          Icon(Icons.favorite, color: _warningColor, size: 16),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Obteniendo ubicación...',
            style: TextStyle(
              fontSize: 16,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La app necesita acceso a tu ubicación\npara mostrar puntos cercanos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
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

class MapPoint {
  final String id;
  final String name;
  final LatLng position;
  bool isFavorite;
  final DateTime lastVisited;
  final String type; // 'terminal' o 'parada'
  final String description;
  double distance;

  MapPoint({
    required this.id,
    required this.name,
    required this.position,
    required this.isFavorite,
    required this.lastVisited,
    required this.type,
    required this.description,
    required this.distance,
  });
}