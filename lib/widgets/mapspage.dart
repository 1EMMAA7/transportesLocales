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
  final double _searchRadius = 2.0; // Radio en kilómetros
  final TextEditingController _searchController = TextEditingController();
  List<RouteOption> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  final FocusNode _searchFocusNode = FocusNode();

  // Coordenadas de Huajuapan de León (fallback)
  //final LatLng _initialCenter = const LatLng(17.81052, -97.77547);

  final Map<String, List<RouteOption>> _staticRoutes = {
    // Terminal Fovissste
    '1': [
      RouteOption(
        id: 'route_1_1',
        name: 'Fovissste - San Gabriel',
        startPoint: 'Terminal Fovissste',
        endPoint: 'San Jerónimo',
        routeType: 'Ruta Directa',
        frequency: 'Cada 15 min',
        duration: '25 min',
        price: '\$8.00',
        stops: ['Tecnologico', 'CFE', 'CBTA', 'Fovissste'],
        isCircular: false,
        horarios: ['6:00 AM', '7:30 AM', '9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM', '6:00 PM'],
      ),
      RouteOption(
        id: 'route_1_2',
        name: 'Fovissste - Periférico',
        startPoint: 'Terminal Fovissste',
        endPoint: 'Periférico',
        routeType: 'Ruta Expresa',
        frequency: 'Cada 20 min',
        duration: '30 min',
        price: '\$8.00',
        stops: ['El tejuan', 'Caseta', 'El boqueron','Fovissste'],
        isCircular: false,
        horarios: ['6:30 AM', '8:00 AM', '10:00 AM', '12:00 PM', '3:00 PM', '5:00 PM', '7:00 PM'],
      ),
    ],

    // Terminal del ORO
    '2': [
      RouteOption(
        id: 'route_2_1',
        name: 'Acatlán - Puebla',
        startPoint: 'Terminal ORO',
        endPoint: 'Puebla',
        routeType: 'Ruta Foránea',
        frequency: 'Horarios fijos',
        duration: '5 horas',
        price: '\$150.00',
        stops: ['Acatlán Centro', 'Carretera Federal', 'Puebla CAPU'],
        isCircular: false,
        horarios: ['1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '9:00 PM'],
      ),
      RouteOption(
        id: 'route_2_2',
        name: 'Acatlán - Huajuapan',
        startPoint: 'Terminal ORO',
        endPoint: 'Huajuapan',
        routeType: 'Ruta Regional',
        frequency: 'Horarios fijos',
        duration: '2 horas',
        price: '\$60.00',
        stops: ['Acatlán Centro', 'Chila', 'Petlalcingo', 'Huajuapan'],
        isCircular: false,
        horarios: ['8:00 AM', '9:00 AM', '10:00 AM', '4:00 PM', '5:00 PM', '6:00 PM'],
      ),
    ],

    // Terminal del SUR
    '3': [
      RouteOption(
        id: 'route_3_1',
        name: 'Huajuapan - Oaxaca',
        startPoint: 'Terminal SUR',
        endPoint: 'Oaxaca',
        routeType: 'Ruta Foránea',
        frequency: 'Horarios fijos',
        duration: '3 horas',
        price: '\$120.00',
        stops: ['Huajuapan', 'Nochixtlán', 'Huitzo', 'Oaxaca'],
        isCircular: false,
        horarios: ['7:00 AM', '10:00 AM', '1:00 PM', '4:00 PM', '7:00 PM'],
      ),
      RouteOption(
        id: 'route_3_2',
        name: 'Huajuapan - Tlaxiaco',
        startPoint: 'Terminal SUR',
        endPoint: 'Tlaxiaco',
        routeType: 'Ruta Regional',
        frequency: 'Cada hora',
        duration: '1.5 horas',
        price: '\$50.00',
        stops: ['Huajuapan', 'San Juan Mixtepec', 'Chalcatongo', 'Tlaxiaco'],
        isCircular: false,
        horarios: ['6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', 
                  '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
                  '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM'],
      ),
    ],

    // Combis Blancas
    '4': [
      RouteOption(
        id: 'route_4_1',
        name: 'Centro - Periférico',
        startPoint: 'Combis Blancas',
        endPoint: 'Periférico',
        routeType: 'Ruta Urbana',
        frequency: 'Cada 10 min',
        duration: '20 min',
        price: '\$8.00',
        stops: ['Zócalo', 'Mercado', 'Hospital', 'Periférico'],
        isCircular: false,
        horarios: ['5:30 AM', '6:30 AM', '7:30 AM', '8:30 AM', '9:30 AM', 
                  '10:30 AM', '11:30 AM', '12:30 PM', '1:30 PM', '2:30 PM',
                  '3:30 PM', '4:30 PM', '5:30 PM', '6:30 PM', '7:30 PM'],
      ),
    ]
  };

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    
  
    // Escuchar cambios en el campo de búsqueda
    _searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    _loadMapPoints();
    await _getCurrentLocation();
  }

  void _loadMapPoints() {
    final List<MapPoint> points = [
      MapPoint(
        id: '1',
        name: 'Combis de Fovissste',
        position: const LatLng(18.201017, -98.048083),
        isFavorite: true,
        lastVisited: DateTime.now(),
        type: 'terminal',
        description: 'Terminal principal de transporte urbano.',
        distance: 0.0,
      ),
      MapPoint(
        id: '2',
        name: 'Terminal del ORO',
        position: const LatLng(18.200390, -98.048650),
        isFavorite: true,
        lastVisited: DateTime.now(),
        type: 'terminal',
        description: 'Terminal de transporte foráneo a Puebla y Huajuapan.',
        distance: 0.0,
      ),
      MapPoint(
        id: '3',
        name: 'Terminal del SUR',
        position: const LatLng(18.200760, -98.048709),
        isFavorite: true,
        lastVisited: DateTime.now(),
        type: 'terminal',
        description: 'Terminal de transporte a Oaxaca y Tlaxiaco.',
        distance: 0.0,
      ),
      MapPoint(
        id: '4',
        name: 'Combis Blancas',
        position: const LatLng(18.201683, -98.046980),
        isFavorite: true,
        lastVisited: DateTime.now(),
        type: 'terminal',
        description: 'Transporte urbano local.',
        distance: 0.0,
      )
    ];

    // Asignar rutas estáticas al punto
    for (var point in points) {
      point.routes = _staticRoutes[point.id] ?? [];
    }

    setState(() {
      _allPoints = points;
      _filteredPoints = _allPoints;
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance(start, end) / 1000;
  }

  Future<void> _getCurrentLocation() async {
  setState(() {
    _locationLoading = true;
  });

  try {
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
      _showMessage('Los permisos de ubicación están denegados permanentemente.', _warningColor);
      _finishLoading();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final userLocation = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _userLocation = userLocation;
    });

    _updatePointsDistance(userLocation);
    
    // SOLUCIÓN: Llamar move() directamente - flutter_map maneja el estado interno
    _mapController.move(userLocation, 15.0);
    
    _showMessage('Ubicación detectada', _successColor);

  } catch (e) {
    _showMessage('Error obteniendo ubicación', _warningColor);
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
        case 'all':
          _filteredPoints = _allPoints;
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

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _showSearchResults = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final List<RouteOption> results = [];
    
    for (var point in _allPoints) {
      for (var route in point.routes) {
        final searchText = query.toLowerCase();
        final routeName = route.name.toLowerCase();
        final startPoint = route.startPoint.toLowerCase();
        final endPoint = route.endPoint.toLowerCase();
        final routeType = route.routeType.toLowerCase();
        
        if (routeName.contains(searchText) ||
            startPoint.contains(searchText) ||
            endPoint.contains(searchText) ||
            routeType.contains(searchText)) {
          results.add(route);
        } else {
          for (var stop in route.stops) {
            if (stop.toLowerCase().contains(searchText)) {
              results.add(route);
              break;
            }
          }
        }
      }
    }

    setState(() {
      _searchResults = results;
      _showSearchResults = true;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchResults = false;
      _searchResults.clear();
    });
  }

  void _showPointDetails(MapPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header del drawer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
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
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleFavorite(point.id);
                      },
                    ),
                  ],
                ),
              ),
              
              // Distancia (si tenemos ubicación)
              if (_userLocation != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
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
                ),
              ],
              
              // Descripción
              if (point.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    point.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ),
              ],
              
              // Separador
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: _textSecondary.withOpacity(0.3)),
              ),
              
              // Título de rutas
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.route, color: _primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Rutas disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${point.routes.length}',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de rutas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: point.routes.length,
                  itemBuilder: (context, index) {
                    final route = point.routes[index];
                    return _buildRouteCard(route, index);
                  },
                ),
              ),
              
              // Botón de cerrar solamente
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: _textSecondary.withOpacity(0.1)),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteCard(RouteOption route, int index) {
    final colors = [
      _primaryColor,
      _secondaryColor,
      _accentColor,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRouteDetails(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la ruta
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        route.isCircular ? Icons.refresh : Icons.arrow_forward,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            route.routeType,
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Información de la ruta
                Row(
                  children: [
                    _buildRouteInfo(Icons.access_time, route.duration, color),
                    const SizedBox(width: 16),
                    _buildRouteInfo(Icons.timelapse, route.frequency, color),
                    const SizedBox(width: 16),
                    _buildRouteInfo(Icons.attach_money, route.price, color),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Horarios (si existen)
                if (route.horarios != null && route.horarios!.isNotEmpty) ...[
                  Text(
                    'Horarios disponibles:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: route.horarios!.map((horario) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          horario,
                          style: TextStyle(
                            color: _successColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Paradas
                if (route.stops.isNotEmpty) ...[
                  Text(
                    'Paradas principales:',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: route.stops.take(3).map((stop) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stop,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRouteDetails(RouteOption route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la ruta
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      route.isCircular ? Icons.refresh : Icons.route,
                      color: _primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        Text(
                          route.routeType,
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Información detallada
              Column(
                children: [
                  _buildDetailRow('Origen:', route.startPoint, Icons.place),
                  const SizedBox(height: 12),
                  _buildDetailRow('Destino:', route.endPoint, Icons.flag),
                  const SizedBox(height: 12),
                  _buildDetailRow('Duración:', route.duration, Icons.access_time),
                  const SizedBox(height: 12),
                  _buildDetailRow('Frecuencia:', route.frequency, Icons.timelapse),
                  const SizedBox(height: 12),
                  _buildDetailRow('Precio:', route.price, Icons.attach_money),
                  const SizedBox(height: 12),
                  _buildDetailRow('Tipo:', route.routeType, Icons.directions_bus),
                ],
              ),
              const SizedBox(height: 24),
              
              // Horarios (si existen)
              if (route.horarios != null && route.horarios!.isNotEmpty) ...[
                Text(
                  'Horarios disponibles:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: route.horarios!.map((horario) {
                    return Chip(
                      label: Text(horario),
                      backgroundColor: _successColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Paradas
              Text(
                'Paradas principales:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: route.stops.map((stop) {
                  return Chip(
                    label: Text(stop),
                    backgroundColor: _primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: _primaryColor),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Botón de cerrar solamente
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: _primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _showSearchResults ? _primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  color: _showSearchResults ? _primaryColor : _textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar rutas...',
                      hintStyle: TextStyle(color: _textSecondary),
                      border: InputBorder.none,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: _textSecondary,
                                size: 18,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                    ),
                    onTap: () {
                      setState(() {
                        _showSearchResults = _searchController.text.isNotEmpty;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buscando rutas...',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_showSearchResults || _searchResults.isEmpty) {
      return Container();
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Resultados de búsqueda',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_searchResults.length}',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: _textSecondary,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron rutas',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final route = _searchResults[index];
                      return _buildSearchResultItem(route);
                    },
                  ),
          ),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _textSecondary.withOpacity(0.1)),
              ),
            ),
            child: OutlinedButton(
              onPressed: _clearSearch,
              style: OutlinedButton.styleFrom(
                foregroundColor: _textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: _textSecondary.withOpacity(0.3)),
              ),
              child: const Text('Cerrar búsqueda'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(RouteOption route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showRouteDetails(route);
            _clearSearch();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.route,
                    color: _primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${route.startPoint} → ${route.endPoint}',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: _textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            route.duration,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.attach_money, size: 12, color: _textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            route.price,
                            style: TextStyle(
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: _textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: _textPrimary,
          ),
          onPressed: () {
            _searchFocusNode.requestFocus();
          },
        ),
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
              PopupMenuItem<String>(
                enabled: false,
                height: 80,
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              
              const PopupMenuDivider(height: 1),
              
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
        _buildSearchBar(),
        
        if (_showSearchResults && _searchResults.isNotEmpty)
          _buildSearchResults(),
        
        if (!_showSearchResults)
          _buildFilterBar(),
        
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  zoom: 14.0,
                  maxZoom: 18.0,
                  minZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.transporteslocales.app',
                  ),
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
            'La app necesita acceso a tu ubicación\npara mostrar tu posición en el mapa',
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
  final String type;
  final String description;
  double distance;
  List<RouteOption> routes = [];

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

class RouteOption {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final String routeType;
  final String frequency;
  final String duration;
  final String price;
  final List<String> stops;
  final bool isCircular;
  final List<String>? horarios; // Nuevo campo para horarios específicos

  RouteOption({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.routeType,
    required this.frequency,
    required this.duration,
    required this.price,
    required this.stops,
    required this.isCircular,
    this.horarios, // Ahora es opcional
  });
}