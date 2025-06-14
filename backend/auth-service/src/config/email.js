const nodemailer = require('nodemailer');
require('dotenv').config();

// 创建邮件传输器
const createTransporter = () => {
  return nodemailer.createTransporter({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: process.env.SMTP_PORT || 587,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
};

// 邮件模板配置
const emailTemplates = {
  verification: {
    subject: '激活您的XLoop账户',
    getHtml: (verificationLink, username) => `
      <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
        <h2>欢迎加入XLoop知识智能平台！</h2>
        <p>亲爱的 ${username}，</p>
        <p>感谢您注册XLoop平台。请点击下方链接激活您的账户：</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationLink}" 
             style="background-color: #007bff; color: white; padding: 12px 24px; 
                    text-decoration: none; border-radius: 5px; display: inline-block;">
            激活账户
          </a>
        </div>
        <p>如果按钮无法点击，请复制以下链接到浏览器地址栏：</p>
        <p style="word-break: break-all; color: #666;">${verificationLink}</p>
        <p>此链接将在24小时后过期。</p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
        <p style="color: #666; font-size: 12px;">
          如果您没有注册XLoop账户，请忽略此邮件。<br>
          XLoop团队
        </p>
      </div>
    `,
  },
  resetPassword: {
    subject: '重置您的XLoop密码',
    getHtml: (resetLink, username) => `
      <div style="max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;">
        <h2>重置密码请求</h2>
        <p>亲爱的 ${username}，</p>
        <p>我们收到了您重置密码的请求。请点击下方链接重置您的密码：</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetLink}" 
             style="background-color: #dc3545; color: white; padding: 12px 24px; 
                    text-decoration: none; border-radius: 5px; display: inline-block;">
            重置密码
          </a>
        </div>
        <p>如果按钮无法点击，请复制以下链接到浏览器地址栏：</p>
        <p style="word-break: break-all; color: #666;">${resetLink}</p>
        <p>此链接将在1小时后过期。</p>
        <p style="color: #e74c3c; font-weight: bold;">
          如果您没有申请重置密码，请立即联系我们的客服团队。
        </p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
        <p style="color: #666; font-size: 12px;">
          XLoop团队
        </p>
      </div>
    `,
  },
};

module.exports = {
  createTransporter,
  emailTemplates,
}; 