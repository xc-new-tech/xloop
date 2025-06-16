import 'dart:convert';

import '../models/email_template_model.dart';
import '../../domain/entities/email_template.dart';

/// 邮件模板服务
class EmailTemplateService {
  /// 默认邮件模板
  static final Map<String, EmailTemplateModel> _defaultTemplates = {
    'account_creation': EmailTemplateModel(
      id: 'account_creation',
      name: '账户创建邮件',
      type: EmailTemplateType.accountCreation,
      subject: '欢迎加入XLoop知识智能平台 - 您的账户已创建成功',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>欢迎加入XLoop</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        .credentials { background: #e8f4fd; padding: 20px; border-radius: 6px; margin: 20px 0; }
        .feature-list { list-style: none; padding: 0; }
        .feature-list li { padding: 8px 0; }
        .feature-list li:before { content: "✓"; color: #667eea; font-weight: bold; margin-right: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>欢迎加入XLoop！</h1>
            <p>您的智能知识管理之旅即将开始</p>
        </div>
        <div class="content">
            <h2>您好，{{username}}！</h2>
            <p>恭喜您成功注册XLoop知识智能平台！我们很高兴您选择我们的平台来管理和优化您的知识资产。</p>
            
            <div class="credentials">
                <h3>您的登录信息：</h3>
                <p><strong>用户名：</strong> {{username}}</p>
                <p><strong>初始密码：</strong> {{password}}</p>
                <p style="color: #e74c3c; font-size: 14px;">⚠️ 为了您的账户安全，请在首次登录后立即修改密码</p>
            </div>
            
            <a href="{{loginUrl}}" class="button">立即登录</a>
            
            <h3>XLoop平台核心功能：</h3>
            <ul class="feature-list">
                <li>智能知识库管理 - 轻松组织和检索您的知识资产</li>
                <li>语义搜索引擎 - 基于AI的智能搜索体验</li>
                <li>FAQ自动生成 - 从文档自动提取常见问题</li>
                <li>对话式交互 - 与您的知识库进行自然对话</li>
                <li>数据分析洞察 - 深入了解知识使用情况</li>
                <li>权限管理系统 - 灵活的团队协作控制</li>
            </ul>
            
            <h3>快速开始指南：</h3>
            <ol>
                <li>使用上述凭据登录平台</li>
                <li>完善您的个人资料信息</li>
                <li>创建您的第一个知识库</li>
                <li>上传文档并开始体验智能搜索</li>
            </ol>
            
            <p>如果您在使用过程中遇到任何问题，请随时联系我们的技术支持团队。</p>
        </div>
        <div class="footer">
            <p>此邮件由XLoop知识智能平台自动发送，请勿直接回复。</p>
            <p>如需帮助，请访问 <a href="{{supportUrl}}">帮助中心</a> 或联系客服。</p>
        </div>
    </div>
</body>
</html>
      ''',
      textContent: '''
欢迎加入XLoop知识智能平台！

您好，{{username}}！

恭喜您成功注册XLoop知识智能平台！

您的登录信息：
用户名：{{username}}
初始密码：{{password}}

⚠️ 为了您的账户安全，请在首次登录后立即修改密码

立即登录：{{loginUrl}}

XLoop平台核心功能：
✓ 智能知识库管理
✓ 语义搜索引擎  
✓ FAQ自动生成
✓ 对话式交互
✓ 数据分析洞察
✓ 权限管理系统

快速开始指南：
1. 使用上述凭据登录平台
2. 完善您的个人资料信息
3. 创建您的第一个知识库
4. 上传文档并开始体验智能搜索

如需帮助，请访问帮助中心：{{supportUrl}}

此邮件由XLoop知识智能平台自动发送，请勿直接回复。
      ''',
      variables: {
        'username': '用户名',
        'password': '初始密码',
        'loginUrl': '登录链接',
        'supportUrl': '帮助中心链接',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    
    'password_reset': EmailTemplateModel(
      id: 'password_reset',
      name: '密码重置邮件',
      type: EmailTemplateType.passwordReset,
      subject: 'XLoop平台密码重置请求',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>密码重置</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #e74c3c; color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background: #e74c3c; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 6px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>密码重置请求</h1>
        </div>
        <div class="content">
            <h2>您好，{{username}}！</h2>
            <p>我们收到了您的密码重置请求。如果这是您本人的操作，请点击下方按钮重置密码：</p>
            
            <a href="{{resetUrl}}" class="button">重置密码</a>
            
            <div class="warning">
                <p><strong>重要提醒：</strong></p>
                <ul>
                    <li>此链接将在 {{expireTime}} 后失效</li>
                    <li>如果您没有请求重置密码，请忽略此邮件</li>
                    <li>为了您的账户安全，请不要将此链接分享给他人</li>
                </ul>
            </div>
            
            <p>如果按钮无法点击，请复制以下链接到浏览器地址栏：</p>
            <p style="word-break: break-all; background: #f1f1f1; padding: 10px; border-radius: 4px;">{{resetUrl}}</p>
            
            <p>如果您没有请求重置密码，或者有任何疑问，请立即联系我们的技术支持团队。</p>
        </div>
        <div class="footer">
            <p>此邮件由XLoop知识智能平台自动发送，请勿直接回复。</p>
            <p>如需帮助，请访问 <a href="{{supportUrl}}">帮助中心</a> 或联系客服。</p>
        </div>
    </div>
</body>
</html>
      ''',
      textContent: '''
XLoop平台密码重置请求

您好，{{username}}！

我们收到了您的密码重置请求。如果这是您本人的操作，请访问以下链接重置密码：

{{resetUrl}}

重要提醒：
- 此链接将在 {{expireTime}} 后失效
- 如果您没有请求重置密码，请忽略此邮件
- 为了您的账户安全，请不要将此链接分享给他人

如果您没有请求重置密码，或者有任何疑问，请立即联系我们的技术支持团队。

如需帮助，请访问帮助中心：{{supportUrl}}

此邮件由XLoop知识智能平台自动发送，请勿直接回复。
      ''',
      variables: {
        'username': '用户名',
        'resetUrl': '重置链接',
        'expireTime': '过期时间',
        'supportUrl': '帮助中心链接',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  };

  /// 获取所有默认模板
  List<EmailTemplateModel> getDefaultTemplates() {
    return _defaultTemplates.values.toList();
  }

  /// 根据ID获取模板
  EmailTemplateModel? getTemplateById(String id) {
    return _defaultTemplates[id];
  }

  /// 根据类型获取模板
  List<EmailTemplateModel> getTemplatesByType(EmailTemplateType type) {
    return _defaultTemplates.values
        .where((template) => template.type == type)
        .toList();
  }

  /// 渲染模板内容
  String renderTemplate(String template, Map<String, dynamic> variables) {
    String result = template;
    
    variables.forEach((key, value) {
      final placeholder = '{{$key}}';
      result = result.replaceAll(placeholder, value.toString());
    });
    
    return result;
  }

  /// 验证模板变量
  List<String> validateTemplateVariables(
    String template,
    Map<String, dynamic> variables,
  ) {
    final List<String> missingVariables = [];
    final RegExp variablePattern = RegExp(r'\{\{(\w+)\}\}');
    final Iterable<RegExpMatch> matches = variablePattern.allMatches(template);
    
    for (final match in matches) {
      final variableName = match.group(1)!;
      if (!variables.containsKey(variableName)) {
        missingVariables.add(variableName);
      }
    }
    
    return missingVariables;
  }

  /// 预览模板
  String previewTemplate(
    EmailTemplateModel template,
    Map<String, dynamic> variables,
  ) {
    // 使用示例数据填充缺失的变量
    final Map<String, dynamic> previewVariables = Map.from(variables);
    
    template.variables.forEach((key, description) {
      if (!previewVariables.containsKey(key)) {
        previewVariables[key] = '[示例$description]';
      }
    });
    
    return renderTemplate(template.htmlContent, previewVariables);
  }

  /// 创建自定义模板
  EmailTemplateModel createCustomTemplate({
    required String id,
    required String name,
    required EmailTemplateType type,
    required String subject,
    required String htmlContent,
    required String textContent,
    required Map<String, String> variables,
    String language = 'zh-CN',
  }) {
    return EmailTemplateModel(
      id: id,
      name: name,
      type: type,
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
      variables: variables,
      language: language,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 导出模板为JSON
  String exportTemplate(EmailTemplateModel template) {
    return jsonEncode(template.toJson());
  }

  /// 从JSON导入模板
  EmailTemplateModel? importTemplate(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return EmailTemplateModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }
} 