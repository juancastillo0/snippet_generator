import 'package:meta/meta.dart';
import 'package:snippet_generator/models/serializer.dart';
import 'package:test/test.dart';

class WorkingHoursModel implements Serializable<WorkingHoursModel> {
  final int dayId;
  final bool startHourId;

  const WorkingHoursModel({
    @required this.dayId,
    @required this.startHourId,
  });

  static WorkingHoursModel fromJson(Map<String, dynamic> map) {
    return WorkingHoursModel(
      dayId: map['dayId'] as int,
      startHourId: map['startHourId'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'dayId': dayId,
      'startHourId': startHourId,
    };
  }

  static final serializerFunc = SerializerFunc(fromJson: fromJson);
}

void main() {
  group('Serializer', () {
    test('simple', () {
      final _ = WorkingHoursModel.serializerFunc;
      final result = Serializers.fromJson<WorkingHoursModel>(
          {"dayId": 1, "startHourId": true});

      expect(result.dayId, 1);

      // final result2 = Serializers.fromJson<Map<String, WorkingHoursModel>>({
      //   "s": {"dayId": 1, "startHourId": true}
      // });

      // expect(result2["s"].dayId, 1);
    });
  });
}
