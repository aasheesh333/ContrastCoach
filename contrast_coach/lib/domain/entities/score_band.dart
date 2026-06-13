enum ScoreBand { low, moderate, strong }

extension ScoreBandLabel on ScoreBand {
  String get label => switch (this) {
        ScoreBand.low => 'Low',
        ScoreBand.moderate => 'Moderate',
        ScoreBand.strong => 'Strong',
      };
}
