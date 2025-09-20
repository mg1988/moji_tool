class RegexRule {
  final String name;
  final String pattern;
  final String description;

  const RegexRule({
    required this.name,
    required this.pattern,
    required this.description,
  });
}

final List<RegexRule> regexRules = [
  const RegexRule(
    name: '邮箱',
    pattern: r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    description: '匹配标准邮箱格式',
  ),
  const RegexRule(
    name: '手机号码',
    pattern: r'^1[3-9]\d{9}$',
    description: '匹配中国大陆手机号码',
  ),
  const RegexRule(
    name: '身份证号',
    pattern: r'^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dX]$',
    description: '匹配中国大陆18位身份证号码',
  ),
  const RegexRule(
    name: 'URL',
    pattern: r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    description: '匹配网址URL',
  ),
  const RegexRule(
    name: 'IP地址',
    pattern: r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    description: '匹配IPv4地址',
  ),
  const RegexRule(
    name: '日期',
    pattern: r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
    description: '匹配YYYY-MM-DD格式日期',
  ),
  const RegexRule(
    name: '时间',
    pattern: r'^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$',
    description: '匹配HH:mm:ss格式时间',
  ),
  const RegexRule(
    name: '中文字符',
    pattern: r'^[\u4e00-\u9fa5]+$',
    description: '匹配中文字符',
  ),
  const RegexRule(
    name: '用户名',
    pattern: r'^[a-zA-Z]\w{5,17}$',
    description: '字母开头，6-18位字母、数字或下划线',
  ),
  const RegexRule(
    name: '强密码',
    pattern: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    description: '至少8位，包含大小写字母、数字和特殊字符',
  ),
const RegexRule(
    name: '正整数',
    pattern: r'^\d+$',
    description: '匹配正整数',
  ),
  const RegexRule(
    name: '浮点数',
    pattern: r'^\d*\.\d+$',
    description: '匹配浮点数',
  ),
  const RegexRule(
    name: '十六进制颜色',
    pattern: r'^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$',
    description: '匹配CSS十六进制颜色值',
  ),
  const RegexRule(
    name: '邮政编码',
    pattern: r'^\d{6}$',
    description: '匹配中国大陆邮政编码',
  ),
  const RegexRule(
    name: 'QQ号',
    pattern: r'^[1-9][0-9]{4,10}$',
    description: '匹配QQ号(5-11位)',
  ),
  // 继续添加更多常用正则规则...
];
