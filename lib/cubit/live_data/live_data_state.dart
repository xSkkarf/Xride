part of 'live_data_cubit.dart';

@immutable
sealed class LiveDataState {}

final class LiveDataInitial extends LiveDataState {}

final class LiveDataLoaded extends LiveDataState {
  final LiveDataModel liveData;
  final Set<Marker> carMarkers;

  LiveDataLoaded({required this.liveData, required this.carMarkers});
}
