// Modern Minimal – Step 2 (Thông tin giao hàng) trong checkout customer.
//
// Mobile: Stacked (saved addresses trên, form dưới).
// Desktop: 2 cột – form trái + saved addresses phải.

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../config/spacing.dart';
import 'delivery_info_form.dart';
import 'saved_addresses_list.dart';

class DeliveryInfoStep extends StatefulWidget {
  final Function(String fullName, String phone, String address, String? notes)
      onNext;

  const DeliveryInfoStep({super.key, required this.onNext});

  @override
  State<DeliveryInfoStep> createState() => _DeliveryInfoStepState();
}

class _DeliveryInfoStepState extends State<DeliveryInfoStep> {
  final GlobalKey<DeliveryInfoFormState> _formKey =
      GlobalKey<DeliveryInfoFormState>();

  void _onAddressSelected(String id) {
    _formKey.currentState?.loadAddress(id);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    final form = DeliveryInfoForm(key: _formKey, onNext: widget.onNext);
    final saved =
        SavedAddressesList(onAddressSelected: _onAddressSelected);

    if (isMobile) {
      return Column(
        children: [
          saved,
          AppSpacing.gapLg,
          form,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: form),
        AppSpacing.gapLg,
        Expanded(child: saved),
      ],
    );
  }
}
