import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:io';
import 'hive_service.dart';

// Uncomment this class if you encounter SSL certificate issues
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class ApiService {
  static const String _baseUrl = 'https://cuptup.com/api';
  static const bool _useMockAPI =
      true; // Set to true for testing without backend - TEMPORARILY ENABLED FOR DEBUGGING

  // Create a custom HTTP client with proper configuration
  static http.Client? _httpClient;

  static http.Client get httpClient {
    if (_httpClient == null) {
      _httpClient = http.Client();
      // For debugging SSL issues, temporarily disable certificate verification
      HttpOverrides.global =
          MyHttpOverrides(); // TEMPORARILY ENABLED FOR DEBUGGING
    }
    return _httpClient!;
  }

  static void disposeClient() {
    _httpClient?.close();
    _httpClient = null;
  }

  // IMPORTANT: Backend API Configuration:
  // 1. Production URL: https://cuptup.com/api
  // 2. Local development: http://localhost:8000/api
  // 3. Set _useMockAPI = true for offline testing

  // Mock data for testing
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'username': 'admin',
      'email': 'admin@example.com',
      'password': 'password123',
      'role': 'owner'
    },
    {
      'id': 2,
      'username': 'employee1',
      'email': 'employee@example.com',
      'password': 'password123',
      'role': 'employee'
    },
  ];

  Future<Map<String, dynamic>> healthCheck() async {
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Mock API is healthy',
        'status': 'ok'
      };
    }

    return _handleRequest(() => httpClient.get(
          Uri.parse('$_baseUrl/health'),
          headers: {'Content-Type': 'application/json'},
        ));
  }

  Future<Map<String, dynamic>> _handleRequest(
      Future<http.Response> Function() request) async {
    try {
      print('Making API request...');
      final response = await request().timeout(Duration(seconds: 30));
      print('Response received: Status ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        if (response.statusCode == 401) {
          // Unauthorized, token might be expired
          HiveService.userBox.clear();
          Get.offAllNamed('/login');
        }
        // Handle API errors
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'An unknown error occurred';
        final errors = responseData['errors'];
        String detailedError = '';
        if (errors != null && errors is Map) {
          detailedError = errors.entries
              .map((e) => '${e.key}: ${e.value.join(', ')}')
              .join('\n');
        }
        print('API Error: $errorMessage');
        if (detailedError.isNotEmpty) {
          print('Detailed errors: $detailedError');
        }
        Get.snackbar(
          'Error',
          '$errorMessage\n$detailedError',
          snackPosition: SnackPosition.BOTTOM,
        );
        return {'success': false, 'message': errorMessage};
      }
    } on http.ClientException catch (e) {
      print('HTTP Client Exception: $e');
      print('Exception details: ${e.toString()}');
      print('Request URL was: $_baseUrl');

      // Check if this is a CORS or network connectivity issue
      String userMessage = 'Network connectivity issue detected.';
      if (e.toString().contains('Failed to fetch')) {
        userMessage += '\n\nPossible causes:';
        userMessage += '\n• No internet connection';
        userMessage += '\n• Server is down or unreachable';
        userMessage += '\n• CORS policy blocking request (web)';
        userMessage += '\n• SSL certificate issues';
        userMessage += '\n\nTrying mock API mode temporarily...';
      }

      Get.snackbar(
        'Network Error',
        userMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      return {'success': false, 'message': 'Network error: $e'};
    } on FormatException catch (e) {
      print('JSON Format Exception: $e');
      Get.snackbar(
        'Server Error',
        'Invalid response from server.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {'success': false, 'message': 'Invalid server response: $e'};
    } catch (e) {
      print('General Exception: $e');
      print('Exception type: ${e.runtimeType}');
      Get.snackbar(
        'Network Error',
        'Failed to connect to the server. Please check your network connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    if (_useMockAPI) {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));

      // Check if user already exists
      final existingUser = _mockUsers.firstWhere(
        (user) => user['email'] == email || user['username'] == username,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'User with this email or username already exists'
        };
      }

      // Add new user to mock database
      _mockUsers.add({
        'id': _mockUsers.length + 1,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      });

      return {'success': true, 'message': 'Registration successful'};
    }

    return _handleRequest(() => httpClient.post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': username, // Backend expects 'name' not 'username'
            'email': email,
            'password': password,
            'password_confirmation':
                password, // Backend requires password confirmation
            'role': role, // Added role field as per updated API
          }),
        ));
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (_useMockAPI) {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));

      // Find user in mock database
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Generate mock token
      final token =
          'mock_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'token': token,
        'role': user['role'],
        'user': user,
      };
    }

    return _handleRequest(() => httpClient.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        ));
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    // Note: Forgot password endpoint not available in current backend
    return {
      'success': false,
      'message':
          'Forgot password feature is not currently available. Please contact support.'
    };

    /* Commented out until backend implements this endpoint
    if (_useMockAPI) {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      // Check if user exists
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );
      
      if (user.isEmpty) {
        return {
          'success': false,
          'message': 'No account found with this email address'
        };
      }
      
      // In a real app, you would send an email here
      // For testing, we'll just return success
      return {
        'success': true,
        'message': 'Password reset link sent to your email'
      };
    }
    
    return _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/api/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email}),
        ));
    */
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Note: Reset password endpoint not available in current backend
    return {
      'success': false,
      'message':
          'Reset password feature is not currently available. Please contact support.'
    };

    /* Commented out until backend implements this endpoint
    if (_useMockAPI) {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));
      
      // For mock API, we'll accept any token that looks like "reset_token"
      if (!token.toLowerCase().contains('reset') && token != 'test123') {
        return {
          'success': false,
          'message': 'Invalid or expired reset token'
        };
      }
      
      // In a real app, you would update the user's password in the database
      return {
        'success': true,
        'message': 'Password reset successfully'
      };
    }
    
    return _handleRequest(() => http.post(
          Uri.parse('$_baseUrl/api/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'reset_token': token,
            'new_password': newPassword,
          }),
        ));
    */
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = HiveService.userBox.get('token');
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'data': {
          'user': {
            'id': 1,
            'name': 'Mock User',
            'email': 'mock@example.com',
            'role': HiveService.userBox.get('role'),
          }
        }
      };
    }

    return _handleRequest(() => httpClient.get(
          Uri.parse('$_baseUrl/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = HiveService.userBox.get('token');
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'data': {
          'user': {
            'id': 1,
            'name': 'Mock User',
            'email': 'mock@example.com',
          }
        }
      };
    }

    return _handleRequest(() => httpClient.get(
          Uri.parse('$_baseUrl/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final token = HiveService.userBox.get('token');
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'data': {
          'user': {
            'id': 1,
            'name': name,
            'email': email,
          }
        }
      };
    }

    return _handleRequest(() => httpClient.put(
          Uri.parse('$_baseUrl/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'name': name,
            'email': email,
          }),
        ));
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = HiveService.userBox.get('token');
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {'success': true, 'message': 'Password changed successfully'};
    }

    return _handleRequest(() => httpClient.post(
          Uri.parse('$_baseUrl/auth/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'current_password': currentPassword,
            'new_password': newPassword,
            'new_password_confirmation': newPassword,
          }),
        ));
  }

  Future<Map<String, dynamic>> logout() async {
    final token = HiveService.userBox.get('token');
    if (_useMockAPI) {
      await Future.delayed(Duration(seconds: 1));
      return {'success': true, 'message': 'Logged out successfully'};
    }

    return _handleRequest(() => httpClient.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }
}
