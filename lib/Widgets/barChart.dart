import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample8 extends StatefulWidget {
  BarChartSample8({super.key, required this.listLevelVoca});

  final Color barBackgroundColor = Colors.white;
  final Color barColor = Colors.red;

  final List<int> listLevelVoca;

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample8> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bar_chart),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Level Remember',
                  style: TextStyle(
                    color: widget.barColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Expanded(
              child: BarChart(
                randomData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColor(x){
      switch(x){
        case 0:
          return Colors.deepOrange;
          break;
        case 1:
          return Colors.yellow;
          break;
        case 2:
          return Colors.greenAccent;
          break;
        case 3:
          return Colors.green;
          break;
        case 4:
          return Colors.blue;
          break;
        case 5:
          return Colors.blueAccent;
          break;
        default:
          return Colors.red;
      }
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: getColor(x),
          borderRadius: BorderRadius.circular(5),
          borderDashArray: x >= 4 ? [4, 4] : null,
          width: 22,
          borderSide: BorderSide(color: widget.barColor, width: 0),
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    List<String> days = ['1', '2', '3', '4', '5', 'Remember'];

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      maxY: 200.0,
      barTouchData: BarTouchData(
        enabled: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: (value, titlemeta){
              TextStyle styte = TextStyle(fontSize: 10);
              switch (value.toInt()) {
                case 0:
                  return Text('${widget.listLevelVoca[1]} word', style: styte);
                case 1:
                  return Text('${widget.listLevelVoca[2]} word', style: styte);
                case 2:
                  return Text('${widget.listLevelVoca[3]} word', style: styte);
                case 3:
                  return Text('${widget.listLevelVoca[4]} word', style: styte);
                case 4:
                  return Text('${widget.listLevelVoca[5]} word', style: styte);
                case 5:
                  return Text('${widget.listLevelVoca[6]} word', style: styte);
                default:
                  return Text('${widget.listLevelVoca[7]} word', style: styte);
              }
            },
            showTitles: true,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: [makeGroupData(0, widget.listLevelVoca[1]*1.0+0.05), makeGroupData(1, widget.listLevelVoca[2]*1.0+0.05), makeGroupData(2, widget.listLevelVoca[3]*1.0+0.05), makeGroupData(3, widget.listLevelVoca[4]*1.0+0.05), makeGroupData(4, widget.listLevelVoca[5]*1.0+0.05), makeGroupData(5, widget.listLevelVoca[6]*1.0+0.05)],
      gridData: const FlGridData(show: false),
    );
  }
}