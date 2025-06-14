require('dotenv').config();

const jwtConfig = {
  secret: process.env.JWT_SECRET || 'xloop-default-secret-key-change-in-production',
  refreshSecret: process.env.JWT_REFRESH_SECRET || 'xloop-refresh-secret-key-change-in-production',
  expiresIn: process.env.JWT_EXPIRES_IN || '15m',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  issuer: 'xloop-auth-service',
  audience: 'xloop-platform',
};

module.exports = jwtConfig; 