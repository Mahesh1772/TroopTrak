import 'package:prototype_1/util/charts/bar_graph/individual_bar_graph.dart';

class BarData {
  final List<double> conductParticipationList;

  BarData({
    required this.conductParticipationList,
  });

  List<IndividualBar> barData = [];

  //initialize bar data
  void initializeBarData() {
    for (int i = 0; i < conductParticipationList.length; i += 1) {
      barData
          .add(IndividualBar(x: i, y: conductParticipationList[i].toDouble()));
    }
  }
}
