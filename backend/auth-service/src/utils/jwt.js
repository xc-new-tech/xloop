const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const jwtConfig = require('../config/jwt');
const { UserSession } = require('../models');

/**
 * JWT工具类
 * 提供令牌生成、验证、刷新等功能
 */
class JWTUtils {
  /**
   * 生成访问令牌 (Access Token)
   * @param {Object} payload - 令牌载荷数据
   * @param {string} payload.userId - 用户ID
   * @param {string} payload.email - 用户邮箱
   * @param {string} payload.role - 用户角色
   * @param {Object} options - JWT选项
   * @returns {string} JWT令牌
   */
  static generateAccessToken(payload, options = {}) {
    const defaultOptions = {
      expiresIn: jwtConfig.expiresIn,
      issuer: jwtConfig.issuer,
      audience: jwtConfig.audience,
    };

    const mergedOptions = { ...defaultOptions, ...options };
    const tokenPayload = {
      ...payload,
      type: 'access',
      jti: crypto.randomUUID(), // JWT ID，唯一标识符
    };

    return jwt.sign(tokenPayload, jwtConfig.secret, mergedOptions);
  }

  /**
   * 生成刷新令牌 (Refresh Token)
   * @param {Object} payload - 令牌载荷数据
   * @param {Object} options - JWT选项
   * @returns {string} JWT刷新令牌
   */
  static generateRefreshToken(payload, options = {}) {
    const defaultOptions = {
      expiresIn: jwtConfig.refreshExpiresIn,
      issuer: jwtConfig.issuer,
      audience: jwtConfig.audience,
    };

    const mergedOptions = { ...defaultOptions, ...options };
    const tokenPayload = {
      ...payload,
      type: 'refresh',
      jti: crypto.randomUUID(),
    };

    return jwt.sign(tokenPayload, jwtConfig.refreshSecret, mergedOptions);
  }

  /**
   * 验证访问令牌
   * @param {string} token - 要验证的令牌
   * @param {Object} options - 验证选项
   * @returns {Object} 解码后的载荷
   * @throws {Error} 验证失败时抛出错误
   */
  static verifyAccessToken(token, options = {}) {
    const defaultOptions = {
      issuer: jwtConfig.issuer,
      audience: jwtConfig.audience,
    };

    const mergedOptions = { ...defaultOptions, ...options };

    try {
      const decoded = jwt.verify(token, jwtConfig.secret, mergedOptions);
      
      if (decoded.type !== 'access') {
        throw new Error('无效的令牌类型');
      }

      return decoded;
    } catch (error) {
      throw new Error(`访问令牌验证失败: ${error.message}`);
    }
  }

  /**
   * 验证刷新令牌
   * @param {string} token - 要验证的刷新令牌
   * @param {Object} options - 验证选项
   * @returns {Object} 解码后的载荷
   * @throws {Error} 验证失败时抛出错误
   */
  static verifyRefreshToken(token, options = {}) {
    const defaultOptions = {
      issuer: jwtConfig.issuer,
      audience: jwtConfig.audience,
    };

    const mergedOptions = { ...defaultOptions, ...options };

    try {
      const decoded = jwt.verify(token, jwtConfig.refreshSecret, mergedOptions);
      
      if (decoded.type !== 'refresh') {
        throw new Error('无效的令牌类型');
      }

      return decoded;
    } catch (error) {
      throw new Error(`刷新令牌验证失败: ${error.message}`);
    }
  }

  /**
   * 生成令牌对（访问令牌 + 刷新令牌）
   * @param {Object} user - 用户对象
   * @param {Object} sessionInfo - 会话信息
   * @returns {Object} 包含访问令牌和刷新令牌的对象
   */
  static async generateTokenPair(user, sessionInfo = {}) {
    const payload = {
      userId: user.id,
      email: user.email,
      role: user.role,
      username: user.username,
    };

    // 生成访问令牌
    const accessToken = this.generateAccessToken(payload);

    // 生成刷新令牌
    const refreshToken = this.generateRefreshToken({
      userId: user.id,
    });

    // 生成令牌族ID（用于令牌轮换安全机制）
    const tokenFamily = crypto.randomUUID();

    // 对刷新令牌进行哈希处理
    const refreshTokenHash = await bcrypt.hash(refreshToken, 10);

    // 计算刷新令牌过期时间
    const refreshExpiresAt = new Date();
    const expiresInMs = this.parseExpiresIn(jwtConfig.refreshExpiresIn);
    refreshExpiresAt.setTime(refreshExpiresAt.getTime() + expiresInMs);

    // 保存会话信息到数据库
    try {
      await UserSession.create({
        user_id: user.id,
        refresh_token_hash: refreshTokenHash,
        token_family: tokenFamily,
        expires_at: refreshExpiresAt,
        ip_address: sessionInfo.ipAddress,
        user_agent: sessionInfo.userAgent,
        device_info: sessionInfo.deviceInfo || {},
        location_info: sessionInfo.locationInfo || {},
      });
    } catch (error) {
      console.error('保存用户会话失败:', error);
      throw new Error('创建用户会话失败');
    }

    return {
      accessToken,
      refreshToken,
      expiresIn: this.parseExpiresIn(jwtConfig.expiresIn) / 1000, // 转换为秒
      tokenType: 'Bearer',
    };
  }

  /**
   * 刷新访问令牌
   * @param {string} refreshToken - 刷新令牌
   * @param {Object} sessionInfo - 会话信息
   * @returns {Object} 新的令牌对
   * @throws {Error} 刷新失败时抛出错误
   */
  static async refreshAccessToken(refreshToken, sessionInfo = {}) {
    try {
      // 验证刷新令牌
      const decoded = this.verifyRefreshToken(refreshToken);

      // 查找所有活跃会话并验证刷新令牌
      const sessions = await UserSession.findAll({
        where: {
          user_id: decoded.userId,
          status: 'active',
        },
        include: [{ 
          model: require('../models').User, 
          as: 'user',
          attributes: ['id', 'email', 'role', 'username', 'status', 'email_verified']
        }]
      });

      let validSession = null;
      for (const session of sessions) {
        // 验证刷新令牌哈希
        const isValid = await bcrypt.compare(refreshToken, session.refresh_token_hash);
        if (isValid) {
          validSession = session;
          break;
        }
      }

      if (!validSession || !validSession.isValid()) {
        throw new Error('无效或过期的刷新令牌');
      }

      if (!validSession.user || validSession.user.status !== 'active') {
        throw new Error('用户账户已禁用');
      }

      // 撤销旧的刷新令牌
      await validSession.revoke('refresh_token_used');

      // 更新会话活动时间
      if (sessionInfo.ipAddress) {
        validSession.ip_address = sessionInfo.ipAddress;
      }
      if (sessionInfo.userAgent) {
        validSession.user_agent = sessionInfo.userAgent;
      }
      await validSession.updateActivity();

      // 生成新的令牌对
      return await this.generateTokenPair(validSession.user, sessionInfo);

    } catch (error) {
      throw new Error(`令牌刷新失败: ${error.message}`);
    }
  }

  /**
   * 撤销刷新令牌（登出）
   * @param {string} refreshToken - 要撤销的刷新令牌
   * @param {string} reason - 撤销原因
   * @returns {boolean} 撤销是否成功
   */
  static async revokeRefreshToken(refreshToken, reason = 'logout') {
    try {
      // 首先验证刷新令牌以获取用户ID
      const decoded = this.verifyRefreshToken(refreshToken);
      
      // 查找所有活跃会话并验证刷新令牌
      const sessions = await UserSession.findAll({
        where: {
          user_id: decoded.userId,
          status: 'active',
        }
      });

      for (const session of sessions) {
        // 验证刷新令牌哈希
        const isValid = await bcrypt.compare(refreshToken, session.refresh_token_hash);
        if (isValid) {
          await session.revoke(reason);
          return true;
        }
      }

      return false;
    } catch (error) {
      console.error('撤销令牌失败:', error);
      return false;
    }
  }

  /**
   * 撤销用户的所有刷新令牌（全部登出）
   * @param {string} userId - 用户ID
   * @param {string} reason - 撤销原因
   * @returns {number} 撤销的令牌数量
   */
  static async revokeAllUserTokens(userId, reason = 'logout_all') {
    try {
      const result = await UserSession.revokeAllUserSessions(userId, reason);
      return Array.isArray(result) ? result.length : result[0] || 0;
    } catch (error) {
      console.error('撤销用户所有令牌失败:', error);
      throw new Error('撤销令牌失败');
    }
  }

  /**
   * 解析过期时间字符串为毫秒数
   * @param {string|number} expiresIn - 过期时间（如 '15m', '7d', 3600）
   * @returns {number} 毫秒数
   */
  static parseExpiresIn(expiresIn) {
    if (typeof expiresIn === 'number') {
      return expiresIn * 1000; // 假设输入是秒，转换为毫秒
    }

    if (typeof expiresIn !== 'string') {
      throw new Error('无效的过期时间格式');
    }

    const timeUnits = {
      s: 1000,
      m: 60 * 1000,
      h: 60 * 60 * 1000,
      d: 24 * 60 * 60 * 1000,
    };

    const match = expiresIn.match(/^(\d+)([smhd])$/);
    if (!match) {
      throw new Error('无效的过期时间格式');
    }

    const [, value, unit] = match;
    return parseInt(value) * timeUnits[unit];
  }

  /**
   * 从请求头中提取Bearer令牌
   * @param {string} authHeader - Authorization头部值
   * @returns {string|null} 提取的令牌，如果没有则返回null
   */
  static extractBearerToken(authHeader) {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    return authHeader.substring(7); // 移除 'Bearer ' 前缀
  }

  /**
   * 清理过期的会话记录
   * @returns {number} 清理的记录数量
   */
  static async cleanupExpiredSessions() {
    try {
      return await UserSession.cleanupExpiredSessions();
    } catch (error) {
      console.error('清理过期会话失败:', error);
      return 0;
    }
  }
}

module.exports = JWTUtils; 