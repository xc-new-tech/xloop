import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用户协议确认复选框组件
class TermsAgreementCheckbox extends StatelessWidget {
  const TermsAgreementCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: '我已阅读并同意'),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _showUserAgreement(context),
                      child: Text(
                        '《用户协议》',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '和'),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _showPrivacyPolicy(context),
                      child: Text(
                        '《隐私政策》',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 显示用户协议
  void _showUserAgreement(BuildContext context) {
    _showAgreementDialog(
      context: context,
      title: '用户协议',
      content: _getUserAgreementContent(),
    );
  }

  /// 显示隐私政策
  void _showPrivacyPolicy(BuildContext context) {
    _showAgreementDialog(
      context: context,
      title: '隐私政策',
      content: _getPrivacyPolicyContent(),
    );
  }

  /// 显示协议对话框
  void _showAgreementDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 获取用户协议内容
  String _getUserAgreementContent() {
    return '''
XLoop 用户协议

生效日期：2025年1月7日

欢迎使用XLoop知识智能平台！

1. 服务说明
XLoop是一个智能知识管理平台，为用户提供知识库管理、文件解析、智能问答等服务。

2. 用户账户
2.1 您需要创建账户才能使用我们的服务
2.2 您有责任保护账户信息的安全
2.3 您对账户下的所有活动负责

3. 使用规则
3.1 您同意遵守相关法律法规
3.2 不得上传违法、有害或侵权内容
3.3 不得恶意攻击或破坏系统

4. 知识产权
4.1 平台技术及服务的知识产权归XLoop所有
4.2 您上传的内容版权归您所有
4.3 您授权我们为提供服务而使用您的内容

5. 隐私保护
我们重视您的隐私，具体请参阅《隐私政策》。

6. 免责声明
6.1 服务按"现状"提供，不提供任何明示或暗示的保证
6.2 我们不对服务中断、数据丢失等承担责任

7. 协议变更
我们可能会更新本协议，更新后会通过适当方式通知您。

8. 争议解决
因本协议产生的争议应通过友好协商解决，协商不成的可向我们所在地法院起诉。

如有疑问，请联系我们：support@xloop.com

感谢您使用XLoop！
''';
  }

  /// 获取隐私政策内容
  String _getPrivacyPolicyContent() {
    return '''
XLoop 隐私政策

生效日期：2025年1月7日

我们深知个人信息对您的重要性，我们将按照相关法律法规要求，保护您的个人信息安全。

1. 信息收集
1.1 账户信息：用户名、邮箱、密码等注册信息
1.2 使用信息：操作日志、设备信息、IP地址等
1.3 内容信息：您上传的文档、创建的知识库等

2. 信息使用
2.1 提供和改进服务
2.2 用户身份验证和账户安全
2.3 数据分析和服务优化
2.4 法律法规要求的其他用途

3. 信息共享
3.1 我们不会向第三方出售您的个人信息
3.2 在获得您同意的情况下可能会共享信息
3.3 法律要求或政府强制命令下可能会披露信息

4. 信息安全
4.1 采用行业标准的安全技术保护您的信息
4.2 对员工进行数据保护培训
4.3 定期进行安全审计和更新

5. 信息保存
5.1 我们会根据业务需要和法律要求保存您的信息
5.2 您可以随时要求删除个人信息
5.3 账户注销后会安全删除相关信息

6. 您的权利
6.1 查询个人信息的权利
6.2 更正或删除个人信息的权利
6.3 撤回同意的权利
6.4 投诉举报的权利

7. Cookie使用
我们使用Cookie和类似技术来改善用户体验，您可以通过浏览器设置管理Cookie。

8. 第三方服务
我们的服务可能包含第三方链接，请注意这些第三方有自己的隐私政策。

9. 儿童隐私
我们不会故意收集13岁以下儿童的个人信息。

10. 政策更新
我们可能会更新本隐私政策，更新后会通过适当方式通知您。

如有疑问或投诉，请联系我们：
邮箱：privacy@xloop.com
地址：[公司地址]

感谢您对XLoop的信任！
''';
  }
} 