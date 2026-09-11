enum ReportFilter {
  lastWeek,
  lastMonth,
  allHistory,
}

extension ReportFilterExtension on ReportFilter {
  String get label {
    switch (this) {
      case ReportFilter.lastWeek:
        return 'Last Week';
      case ReportFilter.lastMonth:
        return 'Last Month';
      case ReportFilter.allHistory:
        return 'All History';
    }
  }

  String get shortLabel {
    switch (this) {
      case ReportFilter.lastWeek:
        return '7 Days';
      case ReportFilter.lastMonth:
        return '30 Days';
      case ReportFilter.allHistory:
        return 'All Time';
    }
  }

  String get description {
    switch (this) {
      case ReportFilter.lastWeek:
        return 'Last 7 Days';
      case ReportFilter.lastMonth:
        return 'Last 30 Days';
      case ReportFilter.allHistory:
        return 'Complete History';
    }
  }
}
