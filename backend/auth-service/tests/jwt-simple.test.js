const JWTUtils = require('../src/utils/jwt');

describe('JWT工具类核心功能测试', () => {
  const mockUser = {
    id: 'test-user-id',
    email: 'test@example.com',
    role: 'user',
    username: 'testuser'
  };

  describe('令牌生成和验证', () => {
    test('应该能生成和验证访问令牌', () => {
      const payload = {
        userId: mockUser.id,
        email: mockUser.email,
        role: mockUser.role,
      };

      const token = JWTUtils.generateAccessToken(payload);
      expect(token).toBeTruthy();
      expect(typeof token).toBe('string');

      const decoded = JWTUtils.verifyAccessToken(token);
      expect(decoded).toBeTruthy();
      expect(decoded.userId).toBe(mockUser.id);
      expect(decoded.email).toBe(mockUser.email);
      expect(decoded.type).toBe('access');
    });

    test('应该能生成和验证刷新令牌', () => {
      const payload = { userId: mockUser.id };
      const token = JWTUtils.generateRefreshToken(payload);
      
      expect(token).toBeTruthy();
      expect(typeof token).toBe('string');

      const decoded = JWTUtils.verifyRefreshToken(token);
      expect(decoded).toBeTruthy();
      expect(decoded.userId).toBe(mockUser.id);
      expect(decoded.type).toBe('refresh');
      expect(decoded.jti).toBeTruthy(); // JWT ID应该存在
    });

    test('无效访问令牌应该抛出错误', () => {
      expect(() => {
        JWTUtils.verifyAccessToken('invalid-token');
      }).toThrow();
    });

    test('无效刷新令牌应该抛出错误', () => {
      expect(() => {
        JWTUtils.verifyRefreshToken('invalid-token');
      }).toThrow();
    });

    test('刷新令牌不应该被当作访问令牌验证', () => {
      const refreshToken = JWTUtils.generateRefreshToken({ userId: mockUser.id });
      
      expect(() => {
        JWTUtils.verifyAccessToken(refreshToken);
      }).toThrow('访问令牌验证失败');
    });

    test('访问令牌不应该被当作刷新令牌验证', () => {
      const accessToken = JWTUtils.generateAccessToken({ userId: mockUser.id });
      
      expect(() => {
        JWTUtils.verifyRefreshToken(accessToken);
      }).toThrow('刷新令牌验证失败');
    });
  });

  describe('工具函数测试', () => {
    test('应该能正确解析过期时间字符串', () => {
      expect(JWTUtils.parseExpiresIn('15m')).toBe(15 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn('1h')).toBe(60 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn('7d')).toBe(7 * 24 * 60 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn('30s')).toBe(30 * 1000);
      expect(JWTUtils.parseExpiresIn(3600)).toBe(3600 * 1000);
    });

    test('无效过期时间格式应该抛出错误', () => {
      expect(() => JWTUtils.parseExpiresIn('invalid')).toThrow();
      expect(() => JWTUtils.parseExpiresIn('15x')).toThrow();
      expect(() => JWTUtils.parseExpiresIn('')).toThrow();
      expect(() => JWTUtils.parseExpiresIn(null)).toThrow();
    });

    test('应该能正确提取Bearer令牌', () => {
      const token = 'test-token-123';
      const authHeader = `Bearer ${token}`;
      
      const extracted = JWTUtils.extractBearerToken(authHeader);
      expect(extracted).toBe(token);
    });

    test('无效授权头应该返回null', () => {
      expect(JWTUtils.extractBearerToken('Invalid header')).toBeNull();
      expect(JWTUtils.extractBearerToken('Basic dXNlcjpwYXNz')).toBeNull();
      expect(JWTUtils.extractBearerToken('')).toBeNull();
      expect(JWTUtils.extractBearerToken(null)).toBeNull();
      expect(JWTUtils.extractBearerToken(undefined)).toBeNull();
    });

    test('Bearer后缺少令牌应该返回空字符串', () => {
      expect(JWTUtils.extractBearerToken('Bearer ')).toBe('');
      expect(JWTUtils.extractBearerToken('Bearer')).toBeNull();
    });
  });

  describe('令牌选项和配置', () => {
    test('应该能使用自定义过期时间', () => {
      const payload = { userId: mockUser.id };
      const customOptions = { expiresIn: '5m' };
      
      const token = JWTUtils.generateAccessToken(payload, customOptions);
      const decoded = JWTUtils.verifyAccessToken(token);
      
      expect(decoded).toBeTruthy();
      expect(decoded.userId).toBe(mockUser.id);
      
      // 验证过期时间约为5分钟后
      const expiresIn = decoded.exp - decoded.iat;
      expect(expiresIn).toBe(5 * 60); // 5分钟 = 300秒
    });

    test('应该包含正确的issuer和audience', () => {
      const payload = { userId: mockUser.id };
      const token = JWTUtils.generateAccessToken(payload);
      const decoded = JWTUtils.verifyAccessToken(token);
      
      expect(decoded.iss).toBe('xloop-auth-service');
      expect(decoded.aud).toBe('xloop-platform');
    });

    test('错误的issuer应该验证失败', () => {
      const payload = { userId: mockUser.id };
      const token = JWTUtils.generateAccessToken(payload);
      
      expect(() => {
        JWTUtils.verifyAccessToken(token, { issuer: 'wrong-issuer' });
      }).toThrow();
    });

    test('错误的audience应该验证失败', () => {
      const payload = { userId: mockUser.id };
      const token = JWTUtils.generateAccessToken(payload);
      
      expect(() => {
        JWTUtils.verifyAccessToken(token, { audience: 'wrong-audience' });
      }).toThrow();
    });
  });
}); 