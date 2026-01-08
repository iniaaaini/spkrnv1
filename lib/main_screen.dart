// main_screen.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/production_history_screen.dart';
import '../services/storage_service.dart'; // Tambahkan import ini

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _productionRecords = []; // Ubah dari final ke var
  late List<Widget> _screens;
  final StorageService _storageService = StorageService(); // Tambahkan ini
  
  // Animation controller untuk transisi halus
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Load data dari storage terlebih dahulu
    _loadStoredData();
    
    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize screens dengan data yang sudah di-load
    _initializeScreens();
    
    // Start animation
    _animationController.forward();
  }

  // Method untuk load data dari storage
  Future<void> _loadStoredData() async {
    try {
      final records = await _storageService.loadProductionRecords();
      if (mounted) {
        setState(() {
          _productionRecords = records;
          print('📂 Loaded ${_productionRecords.length} records from storage');
        });
        // Update screens setelah data loaded
        _initializeScreens();
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    }
  }

  // Method untuk initialize screens
  void _initializeScreens() {
    _screens = [
      HomeScreen(
        productionRecords: _productionRecords,
        onProductionRecordsUpdated: _updateAndSaveProductionRecords,
      ),
      ProductionHistoryScreen(
        productionRecords: _productionRecords,
        onProductionRecordsUpdated: _updateAndSaveProductionRecords,
      ),
    ];
  }

  // Method untuk update dan simpan data ke storage
  Future<void> _updateAndSaveProductionRecords(List<Map<String, dynamic>> records) async {
    setState(() {
      _productionRecords = List.from(records);
    });
    
    // Simpan ke SharedPreferences
    await _storageService.saveProductionRecords(_productionRecords);
    print('💾 Saved ${_productionRecords.length} records to storage');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        // Reset animation untuk transisi halus
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: const Color(0xFF7E4C27),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: const Color(0xFFFDF7EF),
          selectedItemColor: const Color(0xFF7E4C27),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey[600],
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _currentIndex == 0 
                      ? const Color(0xFF7E4C27).withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.home,
                  size: 24,
                  color: _currentIndex == 0 
                      ? const Color(0xFF7E4C27) 
                      : Colors.grey[600],
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E4C27).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.home,
                  size: 24,
                  color: Color(0xFF7E4C27),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _currentIndex == 1 
                      ? const Color(0xFF7E4C27).withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history,
                  size: 24,
                  color: _currentIndex == 1 
                      ? const Color(0xFF7E4C27) 
                      : Colors.grey[600],
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E4C27).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history,
                  size: 24,
                  color: Color(0xFF7E4C27),
                ),
              ),
              label: 'Histori',
            ),
          ],
        ),
      ),
    );
  }
}