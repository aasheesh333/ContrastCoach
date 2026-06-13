class HrvTrend {
  const HrvTrend({required this.average, required this.trendPercent});
  final double average;
  final double trendPercent;
}

HrvTrend computeHrvTrend(List<double> samplesLast14Days) {
  if (samplesLast14Days.isEmpty) {
    return const HrvTrend(average: 0, trendPercent: 0);
  }
  final recent = samplesLast14Days.length >= 7
      ? samplesLast14Days.sublist(samplesLast14Days.length - 7)
      : samplesLast14Days;
  final prior = samplesLast14Days.length >= 14
      ? samplesLast14Days.sublist(samplesLast14Days.length - 14, samplesLast14Days.length - 7)
      : <double>[];

  final avg = recent.reduce((a, b) => a + b) / recent.length;
  if (prior.isEmpty) return HrvTrend(average: avg, trendPercent: 0);
  final priorAvg = prior.reduce((a, b) => a + b) / prior.length;
  if (priorAvg == 0) return HrvTrend(average: avg, trendPercent: 0);
  final trend = ((avg - priorAvg) / priorAvg) * 100;
  return HrvTrend(average: avg, trendPercent: trend);
}
