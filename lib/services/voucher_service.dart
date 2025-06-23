import 'package:admin_panel_medlab/models/voucher_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

class FetchVoucherResponse {
  final int total;
  final int totalPages;
  final int currentPage;
  final List<Voucher> vouchers;

  FetchVoucherResponse.fromJson(Map<String, dynamic> json)
    : total = json['total'],
      totalPages = json['totalPages'],
      currentPage = json['currentPage'],
      vouchers = (json['vouchers'] as List)
          .map((p) => Voucher.fromJson(p))
          .toList();
}

abstract class VoucherService {
  final ApiClient apiClient;

  VoucherService(this.apiClient);

  Future<ApiResponse<FetchVoucherResponse>> fetchVouchers(
    int? page,
    int? limit,
  );

  Future<ApiResponse<Voucher>> fetchVoucherById(String voucherId);

  Future<ApiResponse<void>> createVoucher(Voucher voucher);

  Future<ApiResponse<void>> updateVoucher(Voucher voucher);

  Future<ApiResponse<void>> deleteVoucher(String voucherId);
}

class VoucherServiceImpl extends VoucherService {
  VoucherServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<FetchVoucherResponse>> fetchVouchers(
    int? page,
    int? limit,
  ) {
    return apiClient.get<FetchVoucherResponse>(
      endpoint: '/vouchers/withPagination',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => FetchVoucherResponse.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<Voucher>> fetchVoucherById(String voucherId) {
    return apiClient.get<Voucher>(
      endpoint: '/vouchers/$voucherId',
      fromJson: (data) => Voucher.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<void>> createVoucher(Voucher voucher) {
    print("Creating voucher: ${voucher.toJson()}");
    return apiClient.post<void>(endpoint: '/vouchers', data: voucher.toJson());
  }

  @override
  Future<ApiResponse<void>> updateVoucher(Voucher voucher) {
    return apiClient.put<void>(
      endpoint: '/vouchers/${voucher.id}',
      data: voucher.toJson(),
    );
  }

  @override
  Future<ApiResponse<void>> deleteVoucher(String voucherId) {
    return apiClient.delete<void>(endpoint: '/vouchers/$voucherId');
  }
}
