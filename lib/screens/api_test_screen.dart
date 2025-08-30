import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  String _testResult = '';
  bool _isLoading = false;
  bool _useMockAPI = false;

  Future<void> _toggleMockAPI() async {
    setState(() {
      _useMockAPI = !_useMockAPI;
      _testResult = 'Mock API mode: ${_useMockAPI ? "Enabled" : "Disabled"}\n' +
          'Note: This is for display only. To actually enable mock API, ' +
          'modify the _useMockAPI variable in api_service.dart';
    });
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing health check...';
    });

    try {
      // Test direct HTTP call first
      final directResponse = await http.get(
        Uri.parse('https://cuptup.com/api/health'),
        headers: {'Content-Type': 'application/json'},
      );

      String directResult = 'Direct HTTP Call:\n';
      directResult += 'Status Code: ${directResponse.statusCode}\n';
      directResult += 'Response: ${directResponse.body}\n\n';

      // Test through API service
      final apiResponse = await _apiService.healthCheck();
      directResult += 'API Service Result:\n${apiResponse.toString()}';

      setState(() {
        _testResult = directResult;
      });
    } catch (e) {
      setState(() {
        _testResult =
            'Health Check Error:\n$e\n\nStack trace: ${StackTrace.current}';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing registration...';
    });

    try {
      // Test direct HTTP call first
      final directResponse = await http.post(
        Uri.parse('https://cuptup.com/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': 'Test User ${DateTime.now().millisecondsSinceEpoch}',
          'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'password_confirmation': 'password123',
          'role': 'owner',
        }),
      );

      String directResult = 'Direct HTTP Registration:\n';
      directResult += 'Status Code: ${directResponse.statusCode}\n';
      directResult += 'Response: ${directResponse.body}\n\n';

      // Test through API service
      final apiResponse = await _apiService.register(
        username: 'Test User ${DateTime.now().millisecondsSinceEpoch}',
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
        role: 'owner',
      );
      directResult += 'API Service Result:\n${apiResponse.toString()}';

      setState(() {
        _testResult = directResult;
      });
    } catch (e) {
      setState(() {
        _testResult =
            'Registration Error:\n$e\n\nStack trace: ${StackTrace.current}';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testNetworkInfo() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Checking network information...';
    });

    try {
      String networkInfo = 'Network Information:\n';

      // Check internet connectivity
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          networkInfo += '✓ Internet connectivity: Available\n';
        }
      } catch (e) {
        networkInfo += '✗ Internet connectivity: Not available - $e\n';
      }

      // Check if API server is reachable
      try {
        final result = await InternetAddress.lookup('cuptup.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          networkInfo += '✓ API domain (cuptup.com): Reachable\n';
          networkInfo += 'IP Address: ${result[0].address}\n';
        }
      } catch (e) {
        networkInfo += '✗ API domain (cuptup.com): Not reachable - $e\n';
      }

      // Test simple HTTP request
      try {
        final client = http.Client();
        final response = await client
            .get(
              Uri.parse('https://httpbin.org/status/200'),
            )
            .timeout(Duration(seconds: 10));
        networkInfo +=
            '✓ HTTP client: Working (Status: ${response.statusCode})\n';
        client.close();
      } catch (e) {
        networkInfo += '✗ HTTP client: Error - $e\n';
      }

      // Test HTTPS connectivity
      try {
        final client = http.Client();
        final response = await client
            .get(
              Uri.parse('https://httpbin.org/status/200'),
            )
            .timeout(Duration(seconds: 10));
        networkInfo += '✓ HTTPS connectivity: Working\n';
        client.close();
      } catch (e) {
        networkInfo += '✗ HTTPS connectivity: Error - $e\n';
      }

      setState(() {
        _testResult = networkInfo;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Network Info Error:\n$e';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _comprehensiveNetworkTest() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Running comprehensive network diagnostics...';
    });

    String diagnostics = 'NETWORK DIAGNOSTICS REPORT\n';
    diagnostics += '========================\n\n';

    // 1. Test basic internet connectivity
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 10));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        diagnostics += '✓ Internet connectivity: WORKING\n';
      }
    } catch (e) {
      diagnostics += '✗ Internet connectivity: FAILED - $e\n';
    }

    // 2. Test DNS resolution for our API domain
    try {
      final result = await InternetAddress.lookup('cuptup.com')
          .timeout(Duration(seconds: 10));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        diagnostics +=
            '✓ DNS resolution (cuptup.com): WORKING - IP: ${result[0].address}\n';
      }
    } catch (e) {
      diagnostics += '✗ DNS resolution (cuptup.com): FAILED - $e\n';
    }

    // 3. Test HTTPS connectivity to a known working endpoint
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://httpbin.org/status/200'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));
      diagnostics +=
          '✓ HTTPS connectivity: WORKING (Status: ${response.statusCode})\n';
      client.close();
    } catch (e) {
      diagnostics += '✗ HTTPS connectivity: FAILED - $e\n';
    }

    // 4. Test the actual API endpoint with detailed error handling
    diagnostics += '\nAPI ENDPOINT TESTING:\n';
    diagnostics += '---------------------\n';

    try {
      final client = http.Client();

      // Test health endpoint first
      try {
        final healthResponse = await client.get(
          Uri.parse('https://cuptup.com/api/health'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'CupTup-Flutter-App/1.0'
          },
        ).timeout(Duration(seconds: 20));

        diagnostics +=
            '✓ Health endpoint: ACCESSIBLE (Status: ${healthResponse.statusCode})\n';
        diagnostics +=
            'Response: ${healthResponse.body.substring(0, math.min(200, healthResponse.body.length))}\n';
      } catch (e) {
        diagnostics += '✗ Health endpoint: FAILED - $e\n';
      }

      // Test registration endpoint
      try {
        final regResponse = await client
            .post(
              Uri.parse('https://cuptup.com/api/auth/register'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'User-Agent': 'CupTup-Flutter-App/1.0'
              },
              body: json.encode({
                'name': 'DiagnosticTest',
                'email': 'diagnostic@test.com',
                'password': 'test123',
                'password_confirmation': 'test123',
                'role': 'owner',
              }),
            )
            .timeout(Duration(seconds: 20));

        diagnostics +=
            '✓ Registration endpoint: ACCESSIBLE (Status: ${regResponse.statusCode})\n';
        diagnostics +=
            'Response: ${regResponse.body.substring(0, math.min(200, regResponse.body.length))}\n';
      } catch (e) {
        diagnostics += '✗ Registration endpoint: FAILED - $e\n';

        // Detailed error analysis
        if (e.toString().contains('Failed to fetch')) {
          diagnostics += '\nERROR ANALYSIS:\n';
          diagnostics += 'The "Failed to fetch" error typically indicates:\n';
          diagnostics += '1. CORS policy blocking the request (for web apps)\n';
          diagnostics += '2. SSL/TLS certificate verification issues\n';
          diagnostics += '3. Server not responding or unreachable\n';
          diagnostics += '4. Network firewall blocking the connection\n\n';

          diagnostics += 'RECOMMENDED SOLUTIONS:\n';
          diagnostics +=
              '1. Enable Mock API mode temporarily (already enabled)\n';
          diagnostics += '2. Check if the API server is running\n';
          diagnostics += '3. For web: Configure CORS on the server\n';
          diagnostics += '4. For SSL issues: Update certificates\n';
        }
      }

      client.close();
    } catch (e) {
      diagnostics += '✗ API client setup: FAILED - $e\n';
    }

    // 5. Platform-specific information
    diagnostics += '\nPLATFORM INFORMATION:\n';
    diagnostics += '---------------------\n';
    diagnostics += 'Platform: ${Platform.operatingSystem}\n';
    diagnostics += 'Is Web: ${GetPlatform.isWeb}\n';
    diagnostics += 'Is Mobile: ${GetPlatform.isMobile}\n';
    diagnostics += 'Is Desktop: ${GetPlatform.isDesktop}\n';

    // 6. Recommendations
    diagnostics += '\nRECOMMENDATIONS:\n';
    diagnostics += '----------------\n';
    diagnostics +=
        '1. Mock API is currently ENABLED - you can test app functionality\n';
    diagnostics += '2. Contact backend team to verify API server status\n';
    diagnostics += '3. Check API documentation for correct endpoints\n';
    diagnostics +=
        '4. For production: Ensure proper CORS and SSL configuration\n';

    setState(() {
      _testResult = diagnostics;
      _isLoading = false;
    });
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing login...';
    });

    try {
      // Test direct HTTP call first
      final directResponse = await http.post(
        Uri.parse('https://cuptup.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'admin@example.com',
          'password': 'password123',
        }),
      );

      String directResult = 'Direct HTTP Login:\n';
      directResult += 'Status Code: ${directResponse.statusCode}\n';
      directResult += 'Response: ${directResponse.body}\n\n';

      // Test through API service
      final apiResponse = await _apiService.login(
        email: 'admin@example.com',
        password: 'password123',
      );
      directResult += 'API Service Result:\n${apiResponse.toString()}';

      setState(() {
        _testResult = directResult;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Login Error:\n$e\n\nStack trace: ${StackTrace.current}';
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test the API connection with your backend',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testHealthCheck,
              child: Text('Test Health Check'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testRegistration,
              child: Text('Test Registration'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: Text('Test Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testNetworkInfo,
              child: Text('Check Network Info'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _comprehensiveNetworkTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('🔍 Full Network Diagnostics'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleMockAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: _useMockAPI ? Colors.green : Colors.grey,
              ),
              child: Text(_useMockAPI ? 'Mock API: ON' : 'Mock API: OFF'),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResult.isEmpty
                          ? 'Test results will appear here...'
                          : _testResult,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Note: Make sure to update the API base URL in api_service.dart to match your backend server.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
