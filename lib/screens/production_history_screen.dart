// production_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductionHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productionRecords;
  final Function(List<Map<String, dynamic>>) onProductionRecordsUpdated;

  const ProductionHistoryScreen({
    super.key,
    required this.productionRecords,
    required this.onProductionRecordsUpdated,
  });

  @override
  State<ProductionHistoryScreen> createState() => _ProductionHistoryScreenState();
}

class _ProductionHistoryScreenState extends State<ProductionHistoryScreen> {
  // Controller untuk edit dialog
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _viscosityController = TextEditingController();
  final TextEditingController _smokeController = TextEditingController();
  final TextEditingController _fireStatusController = TextEditingController();
  final TextEditingController _rpmController = TextEditingController();
  final TextEditingController _productionAmountController = TextEditingController();
  final TextEditingController _productionDateController = TextEditingController();

  @override
  void dispose() {
    _durationController.dispose();
    _temperatureController.dispose();
    _viscosityController.dispose();
    _smokeController.dispose();
    _fireStatusController.dispose();
    _rpmController.dispose();
    _productionAmountController.dispose();
    _productionDateController.dispose();
    super.dispose();
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Helper untuk select date
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _productionDateController.text = _formatDate(dateTime);
        return;
      }
      _productionDateController.text = _formatDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter hanya cooking records
    final cookingRecords = widget.productionRecords.where((record) => record['type'] == 'cooking_session').toList();

    // Group cooking records by date
    Map<String, List<Map<String, dynamic>>> groupedCookingRecords = {};
    
    for (var record in cookingRecords) {
      final date = DateFormat('yyyy-MM-dd').format(record['date'] as DateTime);
      if (!groupedCookingRecords.containsKey(date)) {
        groupedCookingRecords[date] = [];
      }
      groupedCookingRecords[date]!.add(record);
    }

    final sortedCookingDates = groupedCookingRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFF7E4C27),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            color: const Color(0xFF7E4C27),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Histori Sesi Memasak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                Text(
                  '${cookingRecords.length} sesi',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
              
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: cookingRecords.isEmpty
                  ? _buildEmptyState()
                  : _buildCookingHistoryList(sortedCookingDates, groupedCookingRecords),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_food_beverage,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada sesi memasak',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selesaikan sesi memasak di halaman beranda\nuntuk melihat histori di sini',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCookingHistoryList(List<String> sortedDates, Map<String, List<Map<String, dynamic>>> groupedRecords) {
    return Column(
      children: [
        // Summary Card untuk Cooking
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDC8542).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Sesi', _getCookingSessionCount().toString()),
              _buildSummaryItem('Rata-rata', _getAverageCookingTime()),
              _buildSummaryItem('Terlama', _getLongestCookingTime()),
              _buildSummaryItem('Total Ikat', _getTotalProductionAmount().toString()),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final records = groupedRecords[date]!;
              final dateTime = DateTime.parse(date);
              
              return _buildCookingDateGroup(dateTime, records);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC8542),
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCookingDateGroup(DateTime date, List<Map<String, dynamic>> records) {
    final totalAmount = records.fold<int>(0, (sum, record) {
    final amount = record['production_amount'];
    return sum + (amount is int ? amount : (int.tryParse(amount?.toString() ?? '0') ?? 0));
  });
    
    return ExpansionTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDC8542).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.emoji_food_beverage,
          color: const Color(0xFFDC8542),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('dd MMMM yyyy').format(date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFFDC8542),
              ),
            ),
          ),
          if (totalAmount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7E4C27),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalAmount ikat',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${records.length} sesi memasak',
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey,
        ),
      ),
      children: records.map((record) => _buildCookingRecordItem(record)).toList(),
    );
  }

  Widget _buildCookingRecordItem(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final duration = Duration(seconds: (record['duration'] as int? ?? 0));
    final productionAmount = record['production_amount'] ?? 0;
    
    return Dismissible(
      key: Key('cooking-${record['date']}-${record.hashCode}'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(Icons.edit, 'Edit', Colors.blue, Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(Icons.delete, 'Hapus', Colors.red, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(record);
        } else if (direction == DismissDirection.startToEnd) {
          _showEditDialog(record);
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteCookingRecord(record);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDC8542).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer,
              color: const Color(0xFFDC8542),
              size: 18,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Durasi: ${_formatDuration(duration)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC8542),
                ),
              ),
              if (productionAmount > 0)
                Text(
                  'Produksi: $productionAmount ikat',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7E4C27),
                  ),
                ),
              const SizedBox(height: 2),
              
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Suhu: ${(record['final_temperature'] as double? ?? 0.0).toStringAsFixed(1)}°C • '
                'Kekentalan: ${(record['final_viscosity'] as double? ?? 0.0).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
              Text(
                'Asap: ${(record['final_smoke'] as int? ?? 0) == 0 ? 'Padam' : 'Terdeteksi'} • '
                'API: ${record['final_fire_status'] ?? 0} • '
                'RPM: ${record['final_rpm'] ?? 0}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
              Text(
                'Tanggal: ${_formatDate(date)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('HH:mm').format(date),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC8542),
                ),
              ),
              Text(
                DateFormat('dd/MM').format(date),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, String text, Color color, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: alignment == Alignment.centerLeft 
                ? MainAxisAlignment.start 
                : MainAxisAlignment.end,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Map<String, dynamic> record) async {
    final duration = Duration(seconds: (record['duration'] as int? ?? 0));
    final productionAmount = record['production_amount'] ?? 0;
    
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Hapus Data?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah Anda yakin ingin menghapus data sesi memasak ini?'),
              const SizedBox(height: 12),
              Text('⏱️ Durasi: ${_formatDuration(duration)}'),
              Text('🌡️ Suhu: ${(record['final_temperature'] as double? ?? 0.0).toStringAsFixed(1)}°C'),
              if (productionAmount > 0) Text('📦 Produksi: $productionAmount ikat'),
              Text('📅 Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(record['date'] as DateTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showEditDialog(Map<String, dynamic> record) {
    // Isi controller dengan data existing
    _durationController.text = (record['duration'] as int? ?? 0).toString();
    _temperatureController.text = (record['final_temperature'] as double? ?? 0.0).toString();
    _viscosityController.text = (record['final_viscosity'] as double? ?? 0.0).toStringAsFixed(0);
    _smokeController.text = (record['final_smoke'] as int? ?? 0).toString();
    _fireStatusController.text = (record['final_fire_status'] as int? ?? 0).toString();
    _rpmController.text = (record['final_rpm'] as int? ?? 0).toString();
    _productionAmountController.text = (record['production_amount'] as int? ?? 0).toString();
    _productionDateController.text = _formatDate(record['date'] as DateTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit Data Memasak'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit semua data sesi memasak:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                
                // Durasi
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi (detik)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                    helperText: 'Total detik proses memasak',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Suhu
                TextFormField(
                  controller: _temperatureController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Suhu Akhir (°C)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.thermostat),
                    helperText: 'Suhu akhir proses memasak',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Kekentalan
                TextFormField(
                  controller: _viscosityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kekentalan Akhir (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.science),
                    helperText: 'Persentase kekentalan akhir',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Asap
                TextFormField(
                  controller: _smokeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Status Asap (0=Padam, 1=Terdeteksi)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.smoke_free),
                    helperText: '0 untuk padam, 1 untuk terdeteksi',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Status Api
                TextFormField(
                  controller: _fireStatusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Status Api',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                    helperText: 'Status api dari sensor',
                  ),
                ),
                const SizedBox(height: 12),
                
                // RPM
                TextFormField(
                  controller: _rpmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RPM Akhir',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                    helperText: 'Kecepatan putaran akhir',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Jumlah Produksi
                TextFormField(
                  controller: _productionAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Produksi (ikat)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2),
                    helperText: 'Jumlah ikat gula aren yang dihasilkan',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tanggal dan Waktu
                TextFormField(
                  controller: _productionDateController,
                  readOnly: true,
                  onTap: () => _selectDateTime(context),
                  decoration: const InputDecoration(
                    labelText: 'Tanggal & Waktu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.access_time),
                    helperText: 'Tap untuk mengubah tanggal dan waktu',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC8542),
              ),
              onPressed: () {
                _updateCookingRecord(record);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCookingRecord(Map<String, dynamic> record) async {
    setState(() {
      widget.productionRecords.remove(record);
    });
    await widget.onProductionRecordsUpdated(List.from(widget.productionRecords));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data sesi memasak berhasil dihapus'),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateCookingRecord(Map<String, dynamic> record) async {
    try {
      // Parse semua nilai baru
      final int duration = int.tryParse(_durationController.text) ?? (record['duration'] as int? ?? 0);
      final double temperature = double.tryParse(_temperatureController.text) ?? (record['final_temperature'] as double? ?? 0.0);
      final double viscosity = double.tryParse(_viscosityController.text) ?? (record['final_viscosity'] as double? ?? 0.0);
      final int smoke = int.tryParse(_smokeController.text) ?? (record['final_smoke'] as int? ?? 0);
      final int fireStatus = int.tryParse(_fireStatusController.text) ?? (record['final_fire_status'] as int? ?? 0);
      final int rpm = int.tryParse(_rpmController.text) ?? (record['final_rpm'] as int? ?? 0);
      final int productionAmount = int.tryParse(_productionAmountController.text) ?? (record['production_amount'] as int? ?? 0);
      
      // Parse tanggal baru
      DateTime newDate;
      try {
        newDate = DateFormat('dd/MM/yyyy HH:mm').parse(_productionDateController.text);
      } catch (e) {
        newDate = record['date'] as DateTime; // fallback ke tanggal lama
      }

      setState(() {
        // Update semua field
        record['duration'] = duration;
        record['final_temperature'] = temperature;
        record['final_viscosity'] = viscosity;
        record['final_smoke'] = smoke;
        record['final_fire_status'] = fireStatus;
        record['final_rpm'] = rpm;
        record['production_amount'] = productionAmount;
        record['date'] = newDate;
        
        // Update parent dan simpan ke storage
        widget.onProductionRecordsUpdated(List.from(widget.productionRecords));
      });

      // Clear controllers
      _durationController.clear();
      _temperatureController.clear();
      _viscosityController.clear();
      _smokeController.clear();
      _fireStatusController.clear();
      _rpmController.clear();
      _productionAmountController.clear();
      _productionDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua data sesi memasak berhasil diperbarui'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error update data: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Helper methods
  int _getCookingSessionCount() {
    return widget.productionRecords
        .where((record) => record['type'] == 'cooking_session')
        .length;
  }

  int _getTotalProductionAmount() {
    return widget.productionRecords
        .where((record) => record['type'] == 'cooking_session')
        .fold(0, (sum, record) => sum + (record['production_amount'] as int? ?? 0));
  }

  String _getAverageCookingTime() {
    final cookingRecords = widget.productionRecords
        .where((record) => record['type'] == 'cooking_session')
        .toList();
    
    if (cookingRecords.isEmpty) return "0:00";
    
    final totalSeconds = cookingRecords.fold(0, (sum, record) => sum + ((record['duration'] as int?) ?? 0));
    final averageSeconds = totalSeconds ~/ cookingRecords.length;
    final averageDuration = Duration(seconds: averageSeconds);
    
    return _formatDuration(averageDuration);
  }

  String _getLongestCookingTime() {
    final cookingRecords = widget.productionRecords
        .where((record) => record['type'] == 'cooking_session')
        .toList();
    
    if (cookingRecords.isEmpty) return "0:00";
    
    int longestSeconds = 0;
    for (var record in cookingRecords) {
      final duration = (record['duration'] as int?) ?? 0;
      if (duration > longestSeconds) {
        longestSeconds = duration;
      }
    }
    
    return _formatDuration(Duration(seconds: longestSeconds));
  }
}