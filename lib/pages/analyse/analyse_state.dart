class AnalyseState {
  //当前选中的日期范围，默认为今天起一周
  late List<DateTime> dateRange;

  //统计范围内的心情列表
  late List<double> moodList;

  //统计范围内的日期列表
  late List<DateTime> dateList;

  //天气
  late List<String> weatherList;

  //统计范围内日记的心情出现的次数
  late Map<double, int> moodMap;

  late Map<String, int> weatherMap;

  //加载状态，检查数据是否获取完成
  late bool finished;

  late String reply;

  //新增：关键词相关
  List<String> keywords = [];
  Map<String, int> keywordFrequency = {};

  AnalyseState() {
    final now = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    reply = '';
    finished = false;
    dateRange = [now.subtract(const Duration(days: 30)), now];
    moodList = [];
    dateList = [];
    weatherList = [];
    moodMap = {};
    weatherMap = {};
    keywords = [];
    keywordFrequency = {};
  }
}
