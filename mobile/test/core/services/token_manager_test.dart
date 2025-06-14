import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/token_manager.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TokenManager Tests', () {
    setUp(() async {
      await TestHelpers.setupTestEnvironment();
    });

    tearDown(() async {
      await TestHelpers.tearDownTestEnvironment();
    });

    group('TokenInfo', () {
      test('should parse valid JWT token', () {
        // Using a pre-generated valid JWT token for testing
        const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
            'eyJzdWIiOiJ0ZXN0X3VzZXIiLCJpc3MiOiJ4bG9vcF90ZXN0IiwiZXhwIjoyMDA5NDQwMDAwLCJpYXQiOjE3MDQ0NDAwMDB9.'
            'test_signature';
        
        final tokenInfo = TokenInfo.fromJwt(testToken);
        
        expect(tokenInfo.token, equals(testToken));
        expect(tokenInfo.subject, equals('test_user'));
        expect(tokenInfo.issuer, equals('xloop_test'));
      });

      test('should detect expired token correctly', () {
        // Using a pre-generated expired JWT token
        const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
            'eyJzdWIiOiJ0ZXN0X3VzZXIiLCJpc3MiOiJ4bG9vcF90ZXN0IiwiZXhwIjoxNjA0NDQwMDAwLCJpYXQiOjE2MDQ0MzkwMDB9.'
            'test_signature';
        
        final tokenInfo = TokenInfo.fromJwt(expiredToken);
        
        expect(tokenInfo.isExpired, isTrue);
      });

      test('should throw exception for invalid JWT', () {
        expect(
          () => TokenInfo.fromJwt('invalid_jwt_token'),
          throwsA(isA<TokenParseException>()),
        );
      });
    });
  });
}

 