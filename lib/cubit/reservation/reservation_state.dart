part of 'reservation_cubit.dart';

@immutable
sealed class ReservationState {}

final class ReservationInitial extends ReservationState {}

final class ReservationLoading extends ReservationState {}

final class ReservationSuccess extends ReservationState {
  final dynamic response;

  ReservationSuccess(this.response);
}

final class ReservationCancelling extends ReservationState {
  final int carId;

  ReservationCancelling(this.carId);
}
final class ReservationCancellingSuccess extends ReservationState {}

final class ReservationError extends ReservationState {
  final String message;

  ReservationError(this.message);
}
