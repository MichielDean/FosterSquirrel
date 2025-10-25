import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../repositories/drift/weight_repository.dart';
import '../common/optimized_images.dart';

/// A widget that displays a line chart showing weight progress over time for a squirrel.
///
/// This chart uses fl_chart to display weight measurements with proper date formatting
/// and responsive design for mobile screens.
class WeightProgressChart extends StatefulWidget {
  final String squirrelId;
  final double? height;
  final bool showTitle;

  const WeightProgressChart({
    super.key,
    required this.squirrelId,
    this.height,
    this.showTitle = true,
  });

  @override
  State<WeightProgressChart> createState() => _WeightProgressChartState();
}

class _WeightProgressChartState extends State<WeightProgressChart> {
  List<WeightDataPoint> _weightData = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Precomputed chart data to avoid expensive operations during build
  List<FlSpot> _chartSpots = [];
  double _minWeight = 0;
  double _maxWeight = 0;
  double _weightRange = 0;
  double _padding = 0;
  List<WeightDataPoint> _sortedData = [];

  // Cache expensive formatters to avoid recreation in build methods
  static final _shortDateFormat = DateFormat('M/d');
  static final _longDateFormat = DateFormat('M/d/yy');
  static final _tooltipDateFormat = DateFormat('M/d/yyyy h:mm a');

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  Future<void> _loadWeightData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final repository = Provider.of<WeightRepository>(context, listen: false);
      final data = await repository.getWeightTrendData(widget.squirrelId);

      // Precompute all expensive operations here, NOT in build method
      _precomputeChartData(data);

      setState(() {
        _weightData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weight data: $e';
        _isLoading = false;
      });
    }
  }

  /// Precompute all expensive chart calculations to avoid doing them during build
  void _precomputeChartData(List<WeightDataPoint> data) {
    if (data.isEmpty) {
      _chartSpots = [];
      _sortedData = [];
      return;
    }

    // Sort data points by date - done once here, not in build
    _sortedData = List<WeightDataPoint>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Convert to FlSpot for fl_chart - done once here, not in build
    _chartSpots = [];
    for (int i = 0; i < _sortedData.length; i++) {
      _chartSpots.add(FlSpot(i.toDouble(), _sortedData[i].weight));
    }

    // Calculate min/max for better chart scaling - done once here, not in build
    final weights = _sortedData.map((d) => d.weight).toList();
    _minWeight = weights.reduce((a, b) => a < b ? a : b);
    _maxWeight = weights.reduce((a, b) => a > b ? a : b);
    _weightRange = _maxWeight - _minWeight;
    _padding = _weightRange * 0.1; // Add 10% padding
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Weight Progress',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        Container(
          height: widget.height ?? 300,
          padding: const EdgeInsets.all(16.0),
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OptimizedAssetImage(
              path: 'assets/images/error_squirrel.png',
              width: 48,
              height: 48,
              color: Theme.of(context).colorScheme.error,
              colorBlendMode: BlendMode.srcIn,
              fallbackIcon: Icons.error_outline,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWeightData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weightData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No weight records yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add weight measurements to see progress over time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildLineChart();
  }

  Widget _buildLineChart() {
    // Use precomputed data - NO expensive operations during build!
    if (_chartSpots.isEmpty) {
      return Center(
        child: Text(
          'No weight data available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateHorizontalInterval(
            _minWeight,
            _maxWeight,
          ),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}g',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
            axisNameWidget: Text(
              'Weight (grams)',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateDateInterval(_sortedData.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _sortedData.length) {
                  final date = _sortedData[index].date;
                  final formatter = _sortedData.length > 10
                      ? _shortDateFormat
                      : _longDateFormat;
                  return Text(
                    formatter.format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
            axisNameWidget: Text(
              'Date',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            bottom: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
        ),
        minX: 0,
        maxX: (_sortedData.length - 1).toDouble(),
        minY: _minWeight - _padding,
        maxY: _maxWeight + _padding,
        lineBarsData: [
          LineChartBarData(
            spots: _chartSpots, // Use precomputed spots
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index >= 0 && index < _sortedData.length) {
                  final dataPoint = _sortedData[index];

                  return LineTooltipItem(
                    '${dataPoint.weight.toStringAsFixed(1)}g\n${_tooltipDateFormat.format(dataPoint.date)}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
            tooltipBorder: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            tooltipPadding: const EdgeInsets.all(8),
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  double _calculateHorizontalInterval(double min, double max) {
    final range = max - min;
    if (range < 10) return 2;
    if (range < 50) return 10;
    if (range < 100) return 20;
    return 50;
  }

  double _calculateDateInterval(int dataPointCount) {
    if (dataPointCount <= 5) return 1;
    if (dataPointCount <= 10) return 2;
    if (dataPointCount <= 20) return 3;
    return (dataPointCount / 5).ceil().toDouble();
  }
}
