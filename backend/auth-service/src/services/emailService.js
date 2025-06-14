const { createTransporter, emailTemplates } = require('../config/email');
const crypto = require('crypto');

/**
 * 邮件服务类
 * 处理邮件发送功能
 */
class EmailService {
  constructor() {
    this.transporter = createTransporter();
  }

  /**
   * 发送邮件验证链接
   * @param {string} email - 用户邮箱
   * @param {string} username - 用户名
   * @param {string} verificationToken - 验证令牌
   */
  async sendVerificationEmail(email, username, verificationToken) {
    try {
      const baseUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
      const verificationLink = `${baseUrl}/auth/verify-email?token=${verificationToken}`;

      const mailOptions = {
        from: {
          name: 'XLoop平台',
          address: process.env.SMTP_FROM || process.env.SMTP_USER,
        },
        to: email,
        subject: emailTemplates.verification.subject,
        html: emailTemplates.verification.getHtml(verificationLink, username),
      };

      const result = await this.transporter.sendMail(mailOptions);
      console.log('验证邮件发送成功:', result.messageId);
      return result;

    } catch (error) {
      console.error('发送验证邮件失败:', error);
      throw new Error('邮件发送失败');
    }
  }

  /**
   * 发送密码重置邮件
   * @param {string} email - 用户邮箱
   * @param {string} username - 用户名
   * @param {string} resetToken - 重置令牌
   */
  async sendPasswordResetEmail(email, username, resetToken) {
    try {
      const baseUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
      const resetLink = `${baseUrl}/auth/reset-password?token=${resetToken}`;

      const mailOptions = {
        from: {
          name: 'XLoop平台',
          address: process.env.SMTP_FROM || process.env.SMTP_USER,
        },
        to: email,
        subject: '密码重置请求 - XLoop平台',
        html: this.generatePasswordResetHtml(resetLink, username),
      };

      const result = await this.transporter.sendMail(mailOptions);
      console.log('密码重置邮件发送成功:', result.messageId);
      return result;

    } catch (error) {
      console.error('发送密码重置邮件失败:', error);
      throw new Error('邮件发送失败');
    }
  }

  /**
   * 生成密码重置邮件HTML内容
   * @param {string} resetLink - 重置链接
   * @param {string} username - 用户名
   * @returns {string} HTML内容
   */
  generatePasswordResetHtml(resetLink, username) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>密码重置 - XLoop平台</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #007bff; color: white; padding: 20px; text-align: center; }
          .content { padding: 30px; background: #f8f9fa; }
          .button { 
            display: inline-block; 
            padding: 12px 24px; 
            background: #007bff; 
            color: white; 
            text-decoration: none; 
            border-radius: 4px; 
            margin: 20px 0;
          }
          .warning { 
            background: #fff3cd; 
            border: 1px solid #ffeaa7; 
            color: #856404; 
            padding: 15px; 
            border-radius: 4px; 
            margin: 20px 0;
          }
          .footer { 
            background: #6c757d; 
            color: white; 
            padding: 20px; 
            text-align: center; 
            font-size: 14px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>XLoop 知识智能平台</h1>
            <h2>密码重置请求</h2>
          </div>
          
          <div class="content">
            <h3>您好，${username}！</h3>
            
            <p>我们收到了您的密码重置请求。如果这是您本人的操作，请点击下面的按钮重置您的密码：</p>
            
            <div style="text-align: center;">
              <a href="${resetLink}" class="button">重置我的密码</a>
            </div>
            
            <p>或者复制以下链接到浏览器地址栏：</p>
            <p style="word-break: break-all; background: #e9ecef; padding: 10px; border-radius: 4px;">
              ${resetLink}
            </p>
            
            <div class="warning">
              <strong>⚠️ 重要提醒：</strong>
              <ul>
                <li>此链接将在 <strong>1小时</strong> 后失效</li>
                <li>为了您的账户安全，此链接只能使用一次</li>
                <li>如果您没有申请密码重置，请忽略此邮件</li>
                <li>重置密码后，您需要重新登录所有设备</li>
              </ul>
            </div>
            
            <p>如果您遇到任何问题，请联系我们的技术支持团队。</p>
            
            <p>祝您使用愉快！<br>XLoop 团队</p>
          </div>
          
          <div class="footer">
            <p>此邮件由系统自动发送，请勿直接回复。</p>
            <p>© 2025 XLoop 知识智能平台. 保留所有权利。</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * 发送密码重置成功通知邮件
   * @param {string} email - 用户邮箱
   * @param {string} username - 用户名
   */
  async sendPasswordResetConfirmation(email, username) {
    try {
      const mailOptions = {
        from: {
          name: 'XLoop平台',
          address: process.env.SMTP_FROM || process.env.SMTP_USER,
        },
        to: email,
        subject: '密码重置成功 - XLoop平台',
        html: this.generatePasswordResetConfirmationHtml(username),
      };

      const result = await this.transporter.sendMail(mailOptions);
      console.log('密码重置确认邮件发送成功:', result.messageId);
      return result;

    } catch (error) {
      console.error('发送密码重置确认邮件失败:', error);
      throw new Error('邮件发送失败');
    }
  }

  /**
   * 生成密码重置成功确认邮件HTML内容
   * @param {string} username - 用户名
   * @returns {string} HTML内容
   */
  generatePasswordResetConfirmationHtml(username) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>密码重置成功 - XLoop平台</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #28a745; color: white; padding: 20px; text-align: center; }
          .content { padding: 30px; background: #f8f9fa; }
          .success { 
            background: #d4edda; 
            border: 1px solid #c3e6cb; 
            color: #155724; 
            padding: 15px; 
            border-radius: 4px; 
            margin: 20px 0;
          }
          .footer { 
            background: #6c757d; 
            color: white; 
            padding: 20px; 
            text-align: center; 
            font-size: 14px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>XLoop 知识智能平台</h1>
            <h2>密码重置成功</h2>
          </div>
          
          <div class="content">
            <h3>您好，${username}！</h3>
            
            <div class="success">
              <strong>✅ 密码重置成功！</strong>
              <p>您的账户密码已经成功重置。为了确保您的账户安全，所有设备上的登录会话已被清除，您需要使用新密码重新登录。</p>
            </div>
            
            <p><strong>安全提醒：</strong></p>
            <ul>
              <li>请使用新密码登录您的账户</li>
              <li>建议定期更换密码以保护账户安全</li>
              <li>如发现任何异常活动，请立即联系我们</li>
            </ul>
            
            <p>感谢您使用 XLoop 知识智能平台！</p>
            
            <p>祝您使用愉快！<br>XLoop 团队</p>
          </div>
          
          <div class="footer">
            <p>此邮件由系统自动发送，请勿直接回复。</p>
            <p>© 2025 XLoop 知识智能平台. 保留所有权利。</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * 验证邮件服务配置
   * @returns {boolean} 验证结果
   */
  async verifyEmailConfig() {
    try {
      await this.transporter.verify();
      console.log('邮件服务配置验证成功');
      return true;
    } catch (error) {
      console.error('邮件服务配置验证失败:', error);
      return false;
    }
  }
}

module.exports = EmailService; 