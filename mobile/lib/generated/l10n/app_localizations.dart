import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'XLoop知识智能平台'**
  String get appName;

  /// 欢迎文本
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get welcome;

  /// 登录按钮文本
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// 登出按钮文本
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get logout;

  /// 注册按钮文本
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get register;

  /// 邮箱输入框标签
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get email;

  /// 密码输入框标签
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// 确认密码输入框标签
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get confirmPassword;

  /// 用户名输入框标签
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// 提交按钮文本
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get submit;

  /// 取消按钮文本
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 确认按钮文本
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// 保存按钮文本
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// 删除按钮文本
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 编辑按钮文本
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 设置页面标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 个人资料页面标题
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get profile;

  /// 知识库页面标题
  ///
  /// In zh, this message translates to:
  /// **'知识库'**
  String get knowledgeBase;

  /// 聊天页面标题
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get chat;

  /// 搜索功能标签
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 加载状态文本
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// 网络错误提示
  ///
  /// In zh, this message translates to:
  /// **'网络连接错误'**
  String get networkError;

  /// 未知错误提示
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError;

  /// 重试按钮文本
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// 无数据状态文本
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// 下拉刷新文本
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新'**
  String get pullToRefresh;

  /// 释放刷新文本
  ///
  /// In zh, this message translates to:
  /// **'释放刷新'**
  String get releaseToRefresh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
