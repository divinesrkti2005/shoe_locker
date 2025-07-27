import 'package:flutter/material.dart';
import 'package:shoe_locker/app/shared_pref/shared_pref_service.dart';
import 'package:shoe_locker/features/auth/data/data_source/auth_remote_datasource.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final token = await SharedPrefService.getToken();
    final userId = await SharedPrefService.getUserId();
    if (token == null || userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Not logged in.';
      });
      return;
    }
    final dataSource = AuthRemoteDataSource();
    final profile = await dataSource.getCustomerProfile(token, userId);
    if (profile == null) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to fetch profile.';
      });
    } else {
      setState(() {
        _profileData = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final profile = _profileData;
    if (profile == null) {
      return const Center(child: Text('No profile data.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: (profile['image'] != null && profile['image'].toString().isNotEmpty)
                  ? NetworkImage(profile['image'].toString().startsWith('http')
                      ? profile['image']
                      : 'http://10.0.2.2:3000/public/uploads/${profile['image']}')
                  : null,
              child: (profile['image'] == null || profile['image'].toString().isEmpty)
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Text('First Name: ${profile['fname'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Last Name: ${profile['lname'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Email: ${profile['email'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Phone: ${profile['phone'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Role: ${profile['role'] ?? ''}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
          // TODO: Add edit profile functionality
        ],
      ),
    );
  }
} 