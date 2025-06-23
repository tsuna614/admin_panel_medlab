import 'package:admin_panel_medlab/models/voucher_model.dart';
import 'package:equatable/equatable.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();

  @override
  List<Object?> get props => [];
}

class FetchVouchersEvent extends VoucherEvent {
  final int? page;
  final int? limit;

  const FetchVouchersEvent({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class CreateVoucherEvent extends VoucherEvent {
  final Voucher voucher;

  const CreateVoucherEvent({required this.voucher});

  @override
  List<Object?> get props => [voucher];
}

class UpdateVoucherEvent extends VoucherEvent {
  final Voucher voucher;

  const UpdateVoucherEvent({required this.voucher});

  @override
  List<Object?> get props => [voucher];
}

class DeleteVoucherEvent extends VoucherEvent {
  final String voucherId;

  const DeleteVoucherEvent({required this.voucherId});

  @override
  List<Object?> get props => [voucherId];
}
