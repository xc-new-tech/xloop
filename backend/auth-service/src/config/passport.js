const passport = require('passport');
const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');
const jwtConfig = require('./jwt');
const { User } = require('../models');

/**
 * Passport JWT策略配置
 * 提供基于JWT的认证策略
 */

// JWT策略配置
const jwtOptions = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: jwtConfig.secret,
  issuer: jwtConfig.issuer,
  audience: jwtConfig.audience,
  passReqToCallback: true, // 传递req对象到回调函数
};

// JWT认证策略
passport.use('jwt', new JwtStrategy(jwtOptions, async (req, payload, done) => {
  try {
    // 验证令牌类型
    if (payload.type !== 'access') {
      return done(null, false, { message: '无效的令牌类型' });
    }

    // 查找用户
    const user = await User.findByPk(payload.userId, {
      attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'created_at']
    });

    if (!user) {
      return done(null, false, { message: '用户不存在' });
    }

    if (user.status !== 'active') {
      return done(null, false, { message: '账户已被禁用' });
    }

    // 验证成功，返回用户信息
    return done(null, user, { token: payload });

  } catch (error) {
    console.error('JWT策略认证失败:', error);
    return done(error, false, { message: '认证过程中发生错误' });
  }
}));

/**
 * 可选JWT策略（不强制要求认证）
 * 如果有令牌则验证，没有令牌则返回null但不报错
 */
passport.use('jwt-optional', new JwtStrategy({
  ...jwtOptions,
  passReqToCallback: true,
}, async (req, payload, done) => {
  try {
    // 验证令牌类型
    if (payload.type !== 'access') {
      return done(null, null); // 不报错，返回null
    }

    // 查找用户
    const user = await User.findByPk(payload.userId, {
      attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'created_at']
    });

    if (!user || user.status !== 'active') {
      return done(null, null); // 不报错，返回null
    }

    // 验证成功，返回用户信息
    return done(null, user, { token: payload });

  } catch (error) {
    console.error('可选JWT策略认证失败:', error);
    return done(null, null); // 不报错，返回null
  }
}));

// Passport中间件配置
const configurePassport = (app) => {
  // 初始化passport
  app.use(passport.initialize());
  
  // 序列化用户（会话管理，如果需要的话）
  passport.serializeUser((user, done) => {
    done(null, user.id);
  });

  // 反序列化用户
  passport.deserializeUser(async (id, done) => {
    try {
      const user = await User.findByPk(id, {
        attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'created_at']
      });
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  });
};

/**
 * Passport认证中间件
 * 使用Passport JWT策略进行认证
 */
const passportAuthenticate = passport.authenticate('jwt', { session: false });

/**
 * Passport可选认证中间件
 * 使用Passport JWT可选策略进行认证
 */
const passportOptionalAuthenticate = passport.authenticate('jwt-optional', { session: false });

/**
 * 自定义Passport认证中间件，提供更好的错误处理
 */
const passportAuthenticateWithErrorHandling = (req, res, next) => {
  passport.authenticate('jwt', { session: false }, (err, user, info) => {
    if (err) {
      console.error('Passport认证错误:', err);
      return res.status(500).json({
        success: false,
        error: 'AUTHENTICATION_ERROR',
        message: '认证过程中发生错误',
      });
    }

    if (!user) {
      const message = info?.message || '认证失败';
      return res.status(401).json({
        success: false,
        error: 'AUTHENTICATION_FAILED',
        message,
      });
    }

    // 将用户信息添加到请求对象
    req.user = user;
    if (info?.token) {
      req.token = info.token;
    }

    next();
  })(req, res, next);
};

/**
 * 基于角色的Passport中间件工厂
 * @param {string|Array} allowedRoles - 允许的角色
 */
const passportRequireRole = (allowedRoles) => {
  const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

  return (req, res, next) => {
    passportAuthenticateWithErrorHandling(req, res, (err) => {
      if (err) return next(err);

      if (!roles.includes(req.user.role)) {
        return res.status(403).json({
          success: false,
          error: 'INSUFFICIENT_PRIVILEGES',
          message: '权限不足',
          requiredRole: roles,
          userRole: req.user.role,
        });
      }

      next();
    });
  };
};

module.exports = {
  configurePassport,
  passportAuthenticate,
  passportOptionalAuthenticate,
  passportAuthenticateWithErrorHandling,
  passportRequireRole,
}; 