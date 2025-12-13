import 'package:equatable/equatable.dart';

abstract class MetaHighestBidEvent extends Equatable {
  const MetaHighestBidEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data with pagination
class LoadMetaHighestBidsRequested extends MetaHighestBidEvent {
  final String? organizerFilter;
  final int pageSize;

  const LoadMetaHighestBidsRequested({
    this.organizerFilter,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [organizerFilter, pageSize];
}

/// Load next page of data
class LoadMoreMetaHighestBidsRequested extends MetaHighestBidEvent {
  const LoadMoreMetaHighestBidsRequested();
}

/// Refresh all data (force re-fetch)
class RefreshMetaHighestBidsRequested extends MetaHighestBidEvent {
  const RefreshMetaHighestBidsRequested();
}

/// Update search query (debounced)
class SearchQueryChanged extends MetaHighestBidEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Update organizer filter
class OrganizerFilterChanged extends MetaHighestBidEvent {
  final String? organizer;

  const OrganizerFilterChanged(this.organizer);

  @override
  List<Object?> get props => [organizer];
}

/// Clear error message
class ClearMetaHighestBidError extends MetaHighestBidEvent {
  const ClearMetaHighestBidError();
}

/// Cancel ongoing requests
class CancelMetaHighestBidRequests extends MetaHighestBidEvent {
  const CancelMetaHighestBidRequests();
}
