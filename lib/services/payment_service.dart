import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/api_constants.dart';

/// Service to handle iPaymu Sandbox payment integrations
class PaymentService {
  final Dio _dio;
  static PaymentService? _instance;

  PaymentService._({Dio? dio}) : _dio = dio ?? Dio();

  static PaymentService get instance {
    _instance ??= PaymentService._();
    return _instance!;
  }

  String get _va => dotenv.env[ApiConstants.ipaymuVaKey] ?? '';
  String get _apiKey => dotenv.env[ApiConstants.ipaymuApiKeyKey] ?? '';
  bool get _isSandbox =>
      dotenv.env[ApiConstants.ipaymuIsSandboxKey]?.toLowerCase() == 'true';

  String get _baseUrl => _isSandbox
      ? ApiConstants.ipaymuSandboxUrl
      : ApiConstants.ipaymuProductionUrl;

  /// Generate signature for iPaymu API v2
  /// HMAC-SHA256(HTTPMethod : VaNumber : Lowercase(SHA-256(RequestBody)) : ApiKey)
  String _generateSignature({
    required String method,
    required Map<String, dynamic> body,
  }) {
    // 1. Serialize request body to a compact JSON string (no spaces)
    final bodyString = jsonEncode(body);

    // 2. Compute SHA-256 hash of the JSON body
    final bodyBytes = utf8.encode(bodyString);
    final bodyHash = sha256.convert(bodyBytes).toString().toLowerCase();

    // 3. Create StringToSign
    final stringToSign = '${method.toUpperCase()}:$_va:$bodyHash:$_apiKey';

    // 4. Compute HMAC-SHA256 signature
    final keyBytes = utf8.encode(_apiKey);
    final dataBytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);

    return digest.toString();
  }

  /// Create a checkout session on iPaymu
  /// Returns the redirection checkout URL
  Future<String> createCheckoutSession({
    required String orderId,
    required int amount,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) async {
    const method = 'POST';

    // Standard payload for iPaymu Redirection Checkout v2
    final body = {
      'name': customerName.isEmpty ? 'Customer GOBAN' : customerName,
      'email': customerEmail.isEmpty ? 'customer@goban.my.id' : customerEmail,
      'phone': customerPhone.isEmpty ? '08123456789' : customerPhone,
      'amount': amount,
      'notifyUrl':
          'https://goban.my.id/api/payment/notify', // Webhook / callback
      'returnUrl': 'https://goban.my.id/payment/success', // Redirect on success
      'cancelUrl': 'https://goban.my.id/payment/cancel', // Redirect on cancel
      'referenceId': orderId,
    };

    final signature = _generateSignature(method: method, body: body);

    // Get timestamp formatted as YYYYMMDDhhmmss
    final now = DateTime.now().toUtc();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    try {
      final response = await _dio.post(
        _baseUrl,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'va': _va,
            'signature': signature,
            'timestamp': timestamp,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 200) {
          // Success: return checkout Url
          return data['data']['Url'] as String;
        } else {
          throw PaymentException(
            data['message'] ?? 'Gagal membuat transaksi pembayaran',
          );
        }
      }
      throw PaymentException(
        'Gagal menghubungi server iPaymu: HTTP ${response.statusCode}',
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw PaymentException('Gagal membuat transaksi: $errorMsg');
    }
  }
}

class PaymentException implements Exception {
  final String message;
  const PaymentException(this.message);

  @override
  String toString() => message;
}
