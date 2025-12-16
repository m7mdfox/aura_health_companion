import 'package:flutter/material.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  final List<WearableDevice> _devices = [
    WearableDevice(
      id: '1',
      name: 'Apple Watch Series 8',
      brand: 'Apple',
      icon: Icons.watch,
      isConnected: true,
      batteryLevel: 75,
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      features: ['Heart Rate', 'Steps', 'Sleep', 'Calories'],
    ),
    WearableDevice(
      id: '2',
      name: 'Xiaomi Mi Band 7',
      brand: 'Xiaomi',
      icon: Icons.watch,
      isConnected: false,
      batteryLevel: 0,
      lastSync: null,
      features: ['Heart Rate', 'Steps', 'Sleep'],
    ),
    WearableDevice(
      id: '3',
      name: 'Samsung Galaxy Watch 5',
      brand: 'Samsung',
      icon: Icons.watch,
      isConnected: false,
      batteryLevel: 0,
      lastSync: null,
      features: ['Heart Rate', 'Steps', 'Sleep', 'Blood Oxygen', 'ECG'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1120) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Connected Devices'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF1A1D2E), const Color(0xFF0F1120)]
                : [const Color(0xFF00177E), const Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(isDark),
          const SizedBox(height: 20),
          Text(
            'Available Devices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ..._devices.map((device) => _buildDeviceCard(device, isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanForDevices,
        backgroundColor: const Color(0xFF00177E),
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text('Scan Devices', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00177E).withOpacity(0.8),
            const Color(0xFF0F1120).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00177E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.watch,
            size: 50,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 15),
          const Text(
            'Connect Your Smartwatch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sync your health data automatically and track your progress 24/7',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(WearableDevice device, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: device.isConnected 
          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
          : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: device.isConnected 
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    device.icon,
                    color: device.isConnected ? const Color(0xFF4CAF50) : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: device.isConnected 
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: device.isConnected ? const Color(0xFF4CAF50) : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  device.isConnected ? 'Connected' : 'Not Connected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: device.isConnected ? const Color(0xFF4CAF50) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: device.isConnected,
                  onChanged: (value) => _toggleConnection(device),
                  activeThumbColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
            if (device.isConnected) ...[
              const SizedBox(height: 15),
              Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildDeviceInfo(
                      icon: Icons.battery_charging_full,
                      label: 'Battery',
                      value: '${device.batteryLevel}%',
                      color: _getBatteryColor(device.batteryLevel),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDeviceInfo(
                      icon: Icons.sync,
                      label: 'Last Sync',
                      value: _getLastSyncText(device.lastSync),
                      color: const Color(0xFF2196F3),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: device.features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1120) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1120) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return const Color(0xFF4CAF50);
    if (level > 20) return const Color(0xFFFF9800);
    return const Color(0xFFE91E63);
  }

  String _getLastSyncText(DateTime? lastSync) {
    if (lastSync == null) return 'Never';
    final diff = DateTime.now().difference(lastSync);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _toggleConnection(WearableDevice device) {
    setState(() {
      device.isConnected = !device.isConnected;
      if (device.isConnected) {
        device.batteryLevel = 85;
        device.lastSync = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} connected successfully'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      } else {
        device.batteryLevel = 0;
        device.lastSync = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} disconnected'),
          ),
        );
      }
    });
  }

  void _scanForDevices() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scan complete. No new devices found.'),
            ),
          );
        });
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Scanning for devices...'),
            ],
          ),
        );
      },
    );
  }
}

class WearableDevice {
  final String id;
  final String name;
  final String brand;
  final IconData icon;
  bool isConnected;
  int batteryLevel;
  DateTime? lastSync;
  final List<String> features;

  WearableDevice({
    required this.id,
    required this.name,
    required this.brand,
    required this.icon,
    required this.isConnected,
    required this.batteryLevel,
    required this.lastSync,
    required this.features,
  });
}