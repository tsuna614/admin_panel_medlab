import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_events.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_states.dart';
import 'package:admin_panel_medlab/services/voucher_service.dart';
import 'package:bloc/bloc.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherService voucherService;
  final int itemsPerPage = 10;

  VoucherBloc({required this.voucherService}) : super(VoucherInitial()) {
    on<FetchVouchersEvent>(_onFetchVouchers);
    on<CreateVoucherEvent>(_onAddVoucher);
    on<UpdateVoucherEvent>(_onUpdateVoucher);
    on<DeleteVoucherEvent>(_onDeleteVoucher);
  }

  Future<void> _onFetchVouchers(
    FetchVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());
    final response = await voucherService.fetchVouchers(
      event.page ?? 1,
      event.limit ?? itemsPerPage,
    );

    if (response.statusCode == 200 && response.data != null) {
      final voucherResponse = response.data!;

      emit(
        VouchersLoaded(
          vouchers: voucherResponse.vouchers,
          currentPage: voucherResponse.currentPage,
          totalVouchers: voucherResponse.total,
        ),
      );
    } else {
      emit(
        VoucherError(
          response.errorMessage ?? "Unknown error fetching vouchers.",
        ),
      );
    }
  }

  Future<void> _onAddVoucher(
    CreateVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    if (state is VouchersLoaded) {
      final currentState = state as VouchersLoaded;
      emit(VoucherLoading());
      final response = await voucherService.createVoucher(event.voucher);
      if (response.statusCode == 200) {
        add(
          FetchVouchersEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(VoucherError(response.errorMessage ?? "Error adding voucher."));
      }
    } else {
      emit(VoucherError("Cannot add voucher, vouchers not loaded."));
    }
  }

  Future<void> _onUpdateVoucher(
    UpdateVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    if (state is VouchersLoaded) {
      final currentState = state as VouchersLoaded;
      emit(VoucherLoading());
      final response = await voucherService.updateVoucher(event.voucher);
      if (response.statusCode == 200) {
        emit(VoucherOperationSuccess("Voucher updated successfully."));
        add(
          FetchVouchersEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(VoucherError(response.errorMessage ?? "Error updating voucher."));
      }
    } else {
      emit(VoucherError("Cannot update voucher, vouchers not loaded."));
    }
  }

  Future<void> _onDeleteVoucher(
    DeleteVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    if (state is VouchersLoaded) {
      final currentState = state as VouchersLoaded;
      final response = await voucherService.deleteVoucher(event.voucherId);
      if (response.statusCode == 200) {
        emit(VoucherOperationSuccess("Voucher deleted successfully."));
        add(
          FetchVouchersEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(VoucherError(response.errorMessage ?? "Error deleting voucher."));
      }
    } else {
      emit(VoucherError("Cannot delete voucher, vouchers not loaded."));
    }
  }
}
