import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'weekly'; // weekly, monthly

  // Weekly data
  List<double> weeklyStudyHours = [2.0, 2.5, 1.8, 3.0, 2.2, 1.5, 2.8];
  List<double> weeklyScreenTime = [5.2, 6.0, 5.8, 7.2, 6.5, 8.0, 6.8];
  List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Monthly data (simulated weeks)
  List<double> monthlyStudyHours = [8.5, 9.2, 7.8, 10.5];
  List<double> monthlyScreenTime = [24.5, 26.3, 25.8, 28.0];
  List<String> weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'weekly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'weekly'
                              ? const Color(0xFF6366F1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Weekly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedPeriod == 'weekly'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = 'monthly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedPeriod == 'monthly'
                              ? const Color(0xFF6366F1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Monthly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedPeriod == 'monthly'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Summary
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Study',
                      _selectedPeriod == 'weekly'
                          ? '${weeklyStudyHours.reduce((a, b) => a + b).toStringAsFixed(1)}h'
                          : '${monthlyStudyHours.reduce((a, b) => a + b).toStringAsFixed(1)}h',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Screen Time',
                      _selectedPeriod == 'weekly'
                          ? '${weeklyScreenTime.reduce((a, b) => a + b).toStringAsFixed(1)}h'
                          : '${monthlyScreenTime.reduce((a, b) => a + b).toStringAsFixed(1)}h',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Comparison Chart
              const Text(
                'Study vs Screen Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 250,
                  child: _selectedPeriod == 'weekly'
                      ? BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < weekdays.length) {
                                      return Text(weekdays[index],
                                          style: const TextStyle(fontSize: 11));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(
                              weeklyStudyHours.length,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: weeklyStudyHours[index],
                                    color: const Color(0xFF10B981),
                                    width: 8,
                                  ),
                                  BarChartRodData(
                                    toY: weeklyScreenTime[index],
                                    color: const Color(0xFFF59E0B),
                                    width: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < weeks.length) {
                                      return Text(weeks[index],
                                          style: const TextStyle(fontSize: 11));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(
                              monthlyStudyHours.length,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthlyStudyHours[index],
                                    color: const Color(0xFF10B981),
                                    width: 8,
                                  ),
                                  BarChartRodData(
                                    toY: monthlyScreenTime[index],
                                    color: const Color(0xFFF59E0B),
                                    width: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Legend
              Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Study Hours', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Screen Time', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Performance Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Summary',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '✓ Great week! You\'ve maintained a good balance between study and screen time.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✓ Average study hours: 2.3h per day',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✓ Peak productivity: Thursday with 3.0 study hours',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
