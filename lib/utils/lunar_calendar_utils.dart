// 农历日历工具类
class LunarCalendarUtils {
  // 农历数据 - 简化版，实际应用中可能需要更完整的农历库
  // 这里使用的是一种简化的方式来计算农历，实际生产环境可能需要引入专门的农历库
  
  // 计算给定日期的农历表示
  static String getLunarDate(DateTime date) {
    // 这里使用简化的方法计算农历，实际应用中建议使用专门的农历库
    // 例如 luanr, chinese_calendar 等
    
    // 以下是简化版实现，仅作为示例
    final year = date.year;
    final month = date.month;
    final day = date.day;
    
    // 计算农历年 (实际应用中需要更复杂的计算)
    final lunarYear = _getLunarYear(year);
    
    // 计算农历月 (实际应用中需要更复杂的计算)
    final lunarMonth = _getLunarMonth(year, month);
    
    // 计算农历日 (实际应用中需要更复杂的计算)
    final lunarDay = _getLunarDay(year, month, day);
    
    // 判断是否是闰月
    final isLeapMonth = _isLeapMonth(year, month);
    
    return '$lunarYear年${isLeapMonth ? '闰' : ''}$lunarMonth$lunarDay';
  }
  
  // 获取农历年的表示
  static String _getLunarYear(int year) {
    // 农历年份的天干地支表示
    final tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    final diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    final animals = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
    
    // 计算天干地支
    final tianGanIndex = (year - 4) % 10;
    final diZhiIndex = (year - 4) % 12;
    
    return '${tianGan[tianGanIndex]}${diZhi[diZhiIndex]}年(${animals[diZhiIndex]})';
  }
  
  // 获取农历月的表示
  static String _getLunarMonth(int year, int month) {
    // 农历月份的表示
    final lunarMonths = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];
    
    // 简化计算，实际应用中需要更复杂的计算
    final lunarMonthIndex = (month + 2) % 12;
    
    return '${lunarMonths[lunarMonthIndex]}月';
  }
  
  // 获取农历日的表示
  static String _getLunarDay(int year, int month, int day) {
    // 农历日期的表示
    final lunarDays = [
      '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
    ];
    
    // 简化计算，实际应用中需要更复杂的计算
    final lunarDayIndex = (day - 1) % 30;
    
    return lunarDays[lunarDayIndex];
  }
  
  // 判断是否是闰月
  static bool _isLeapMonth(int year, int month) {
    // 简化判断，实际应用中需要更复杂的计算
    // 这里只是示例，并不是真实的闰月计算
    final leapYears = [2020, 2023, 2025, 2028, 2031];
    final leapMonths = [4, 2, 6, 2, 3];
    
    for (int i = 0; i < leapYears.length; i++) {
      if (leapYears[i] == year && leapMonths[i] == month) {
        return true;
      }
    }
    
    return false;
  }
}