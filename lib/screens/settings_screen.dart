import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentVersion = '1.0.0';
  bool _isLoading = true;

  // LwenaTech Color Scheme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Download URLs - Automatically built releases from GitHub Actions
  static const String _windowsDownloadUrl =
      'https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Windows-v1.0.0.zip';
  static const String _androidDownloadUrl =
      'https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-v1.0.0.apk';
  static const String _macosDownloadUrl =
      'https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-macOS-v1.0.0.zip';
  static const String _linuxDownloadUrl =
      'https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Linux-v1.0.0.tar.gz';
  static const String _webDownloadUrl =
      'https://github.com/LWENA27/Mem_technology/releases/download/v1.0.0/LwenaTech-Web-v1.0.0.zip';
  static const String _releasesPageUrl =
      'https://github.com/LWENA27/Mem_technology/releases';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open download link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings & Downloads',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppInfoSection(),
                  const SizedBox(height: 24),
                  _buildDownloadSection(),
                  const SizedBox(height: 24),
                  _buildSystemInfoSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Application Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('App Name', 'InventoryMaster SaaS'),
            _buildInfoRow('Version', _currentVersion),
            _buildInfoRow('Platform', _getPlatformName()),
            _buildInfoRow('Build Mode', kDebugMode ? 'Debug' : 'Release'),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Download for Other Platforms',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Get InventoryMaster SaaS on your preferred platform',
              style: TextStyle(
                fontSize: 14,
                color: lightGray,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildDownloadCard(
              'Windows Desktop',
              'Windows 10/11 (64-bit)',
              Icons.desktop_windows,
              Colors.blue,
              _windowsDownloadUrl,
              '~50 MB',
            ),
            const SizedBox(height: 12),
            _buildDownloadCard(
              'Android Mobile',
              'Android 5.0+ (API 21+)',
              Icons.android,
              Colors.green,
              _androidDownloadUrl,
              '~25 MB',
            ),
            const SizedBox(height: 12),
            _buildDownloadCard(
              'macOS Desktop',
              'macOS 10.14+',
              Icons.laptop_mac,
              Colors.grey[700]!,
              _macosDownloadUrl,
              '~60 MB',
            ),
            const SizedBox(height: 12),
            _buildDownloadCard(
              'Linux Desktop',
              'Ubuntu 18.04+, Debian 10+',
              Icons.computer,
              Colors.orange,
              _linuxDownloadUrl,
              '~45 MB',
            ),
            const SizedBox(height: 12),
            _buildDownloadCard(
              'Web Application',
              'Static hosting package',
              Icons.web,
              Colors.purple,
              _webDownloadUrl,
              '~15 MB',
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Installation Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Each download includes installation instructions\n'
                    '• Windows: Run install.bat as Administrator\n'
                    '• Android: Enable "Install from Unknown Sources"\n'
                    '• macOS: Drag to Applications folder\n'
                    '• Linux: Run install.sh script\n'
                    '• Web: Deploy to any static hosting service',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(_releasesPageUrl),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('View All Releases'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.memory, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text(
                  'System Requirements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequirementItem(
                'Windows', 'Windows 10/11, 4GB RAM, 1GB Storage'),
            _buildRequirementItem(
                'Android', 'Android 5.0+, 2GB RAM, 100MB Storage'),
            _buildRequirementItem(
                'macOS', 'macOS 10.14+, 4GB RAM, 1GB Storage'),
            _buildRequirementItem(
                'Linux', 'Ubuntu 18.04+, 4GB RAM, 1GB Storage'),
            _buildRequirementItem('Web', 'Modern browser, Internet connection'),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text(
                  'About MEM Technology',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'InventoryMaster SaaS is a comprehensive multi-tenant inventory management system designed for modern businesses. Built with Flutter and Supabase for seamless cross-platform experience.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _launchUrl('https://github.com/LWENA27/Mem_technology'),
                    icon: const Icon(Icons.code, size: 18),
                    label: const Text('Source Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl('mailto:support@lwenatech.com'),
                    icon: const Icon(Icons.support, size: 18),
                    label: const Text('Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: lightGray,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    String downloadUrl,
    String fileSize,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 2),
            Text(
              'File size: $fileSize',
              style: const TextStyle(
                fontSize: 12,
                color: lightGray,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _launchUrl(downloadUrl),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String platform, String requirements) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              platform,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: darkGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              requirements,
              style: const TextStyle(
                color: lightGray,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}
