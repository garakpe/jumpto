import 'fitness_factor.dart';

/// 각 체력요인별 평가종목 클래스
class Event {
  final String koreanName;
  final FitnessFactor fitnessFactor;
  
  const Event(this.koreanName, this.fitnessFactor);
  
  @override
  String toString() => koreanName;
  
  @override
  bool operator ==(Object other) => 
    identical(this, other) || 
    (other is Event && 
     koreanName == other.koreanName && 
     fitnessFactor == other.fitnessFactor);
  
  @override
  int get hashCode => koreanName.hashCode ^ fitnessFactor.hashCode;
  
  /// 평가종목 목록을 생성
  static List<Event> createEventList() {
    final List<Event> events = [];
    
    // 심폐지구력 종목
    events.add(Event('왕복오래달리기', FitnessFactor.cardioEndurance));
    events.add(Event('오래달리기걷기', FitnessFactor.cardioEndurance));
    events.add(Event('스텝검사', FitnessFactor.cardioEndurance));
    
    // 유연성 종목
    events.add(Event('앉아윗몸앞으로굽히기', FitnessFactor.flexibility));
    events.add(Event('종합유연성', FitnessFactor.flexibility));
    
    // 근력근지구력 종목
    events.add(Event('윗몸말아올리기', FitnessFactor.muscularStrength));
    events.add(Event('악력', FitnessFactor.muscularStrength));
    events.add(Event('(무릎대고)팔굽혀펴기', FitnessFactor.muscularStrength));
    
    // 순발력 종목
    events.add(Event('50m달리기', FitnessFactor.power));
    events.add(Event('제자리멀리뛰기', FitnessFactor.power));
    
    // 비만 종목
    events.add(Event('체질량지수', FitnessFactor.bmi));
    
    return events;
  }
  
  /// 체력요인으로 해당 종목 목록 찾기
  static List<Event> findByFitnessFactor(FitnessFactor factor) {
    return createEventList().where((event) => event.fitnessFactor == factor).toList();
  }
  
  /// 종목명으로 Event 객체 찾기
  static Event findByName(String name) {
    return createEventList().firstWhere(
      (event) => event.koreanName == name,
      orElse: () => throw ArgumentError('유효하지 않은 평가종목입니다: $name'),
    );
  }
}
