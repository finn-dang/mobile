// Modern Minimal – Danh sách địa chỉ đã lưu cho checkout customer.
//
// Card bao bọc 1px border, header có icon + count, empty state có icon
// container 64px theo phong cách Modern Minimal.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/address_model.dart';
import '../../../../services/address_service.dart';
import 'saved_address_card.dart';

class SavedAddressesList extends StatelessWidget {
  final Function(String)? onAddressSelected;

  const SavedAddressesList({
    super.key,
    this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService();

    return StreamBuilder<List<AddressModel>>(
      stream: addressService.getAddresses(),
      builder: (context, snapshot) {
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final addresses = snapshot.data ?? const <AddressModel>[];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(color: AppColors.adminBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(count: addresses.length),
              AppSpacing.gapLg,
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl2),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                )
              else if (snapshot.hasError)
                _ErrorBox(message: 'Lỗi: ${snapshot.error}')
              else if (addresses.isEmpty)
                const _EmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => AppSpacing.gapSm,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return SavedAddressCard(
                      address: address,
                      onSelect: () {
                        if (onAddressSelected != null) {
                          onAddressSelected!(address.id);
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.bookmark_outline,
            size: 18,
            color: AppColors.primary600,
          ),
        ),
        AppSpacing.gapMd,
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Địa chỉ đã lưu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Chọn địa chỉ có sẵn hoặc nhập địa chỉ mới',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 24,
              color: AppColors.neutral400,
            ),
          ),
          AppSpacing.gapMd,
          const Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lưu địa chỉ trong form để dùng cho lần sau',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.errorLight),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.errorDark,
          ),
          AppSpacing.gapSm,
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.errorDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
