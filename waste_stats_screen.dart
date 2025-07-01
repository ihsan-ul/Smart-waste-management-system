import 'package:flutter/material.dart';
import 'package:smart_waste_management/db.dart';
import 'package:fl_chart/fl_chart.dart'; 

class WasteStatsScreen extends StatelessWidget {
  final int userId;

  WasteStatsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Statistics'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, int>>(
            future: DatabaseHelper.instance.getWasteCounts(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                final counts = snapshot.data!;
                final total = counts.values.reduce((a, b) => a + b);
                final mostProducedWaste = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

                String advice;
                switch (mostProducedWaste.key) {
                  case 'recyclable':
                    advice = 'Try to separate recyclables and make use of recycling centers.';
                    break;
                  case 'organic':
                    advice = 'Consider composting organic waste to reduce landfill impact.';
                    break;
                  case 'general':
                    advice = 'Minimize general waste by reusing items and reducing single-use products.';
                    break;
                  default:
                    advice = 'Keep up the good work in managing your waste!';
                }

                // Data for pie chart
                final pieData = [
                  PieChartSectionData(
                    value: (counts['recyclable'] ?? 0).toDouble(),
                    color: Colors.blue,
                    title: '${((counts['recyclable'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: (counts['organic'] ?? 0).toDouble(),
                    color: Colors.green,
                    title: '${((counts['organic'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: (counts['general'] ?? 0).toDouble(),
                    color: Colors.orange,
                    title: '${((counts['general'] ?? 0) / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pie Chart Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Your Waste Distribution',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 220,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sections: pieData,
                                        centerSpaceRadius: 50,
                                        sectionsSpace: 2,
                                        startDegreeOffset: -90,
                                        borderData: FlBorderData(show: false),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          total.toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegend(Colors.blue, 'Recyclable'),
                                  SizedBox(width: 15),
                                  _buildLegend(Colors.green, 'Organic'),
                                  SizedBox(width: 15),
                                  _buildLegend(Colors.orange, 'General'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Detailed Statistics Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detailed Statistics',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              SizedBox(height: 15),
                              _buildStatRow('Recyclable', counts['recyclable'] ?? 0, Colors.blue),
                              _buildStatRow('Organic', counts['organic'] ?? 0, Colors.green),
                              _buildStatRow('General', counts['general'] ?? 0, Colors.orange),
                              Divider(thickness: 1, color: Colors.grey.shade300),
                              _buildStatRow('Total Waste Items', total, Colors.purple),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Advice Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalized Advice',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.yellow.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline,
                                        color: Colors.orange, size: 30),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        advice,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
