import 'package:admin_panel_medlab/models/voucher_model.dart';
import 'package:equatable/equatable.dart';
// Import your Voucher and ApiResponse models

abstract class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

class VoucherLoading extends VoucherState {}

class VouchersLoaded extends VoucherState {
  final List<Voucher> vouchers;
  final int currentPage;
  final int totalVouchers;

  const VouchersLoaded({
    required this.vouchers,
    this.currentPage = 1,
    this.totalVouchers = 0,
  });

  VouchersLoaded copyWith({
    List<Voucher>? vouchers,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return VouchersLoaded(
      vouchers: vouchers ?? this.vouchers,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [vouchers, currentPage];
}

class VoucherOperationSuccess extends VoucherState {
  final String message;
  const VoucherOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class VoucherError extends VoucherState {
  final String message;
  const VoucherError(this.message);

  @override
  List<Object> get props => [message];
}
