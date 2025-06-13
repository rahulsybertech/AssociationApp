import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newapp/controllers/DisputeController.dart';


class DisputeDetailsScreen extends StatelessWidget {
  const DisputeDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final DisputeController controller = Get.put(DisputeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        leading: BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(child: Icon(Icons.account_circle)),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer Dropdown
              Obx(() => DropdownButtonFormField<CustomerList>(
                value: controller.selectedCustomerlist.value,
                items: controller.customerList
                    .map(
                      (customer) => DropdownMenuItem<CustomerList>(
                    value: customer,
                    child: Text('${customer.accountName}'),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  controller.customerId.value = val!.id.toString(); // ✅ Correct

                  controller.selectedCustomer.value = val! as String;

                },
                decoration: InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null ? 'Select a customer' : null,
              )),

              const SizedBox(height: 12),

              // Supplier Dropdown
              Obx(() => DropdownButtonFormField<CustomerList>(
                value: controller.selectedSuplierlist.value,
                items: controller.supplierList
                    .map(
                      (customer) => DropdownMenuItem<CustomerList>(
                    value: customer,
                    child: Text('${customer.accountName}'),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  controller.supplierId.value = val!.id.toString();
                  controller.selectedCustomer.value = val! as String;
                },
                decoration: InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null ? 'Select a customer' : null,
              )),
              const SizedBox(height: 12),

              // Disputed Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Disputed Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => controller.disputedAmount.value = val,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter disputed amount' : null,
              ),
              const SizedBox(height: 12),

              // Settled Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Settled Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => controller.settledAmount.value = val,
                validator: (val) =>
                val == null || val.isEmpty ? 'Enter settled amount' : null,
              ),
              const SizedBox(height: 12),

              // Upload File
              Obx(() => GestureDetector(
                onTap: controller.uploadDocument,
                child: DottedBorderBox(
                  child: Column(
                    children: [
                      const Text('5.0 MB maximum file size'),
                      const SizedBox(height: 8),
                      const Icon(Icons.upload_file, size: 30),
                      Text(
                        controller.selectedFileName.isEmpty
                            ? 'Upload Document'
                            : controller.selectedFileName.value,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 12),
                ),
                onPressed: controller.saveDispute,
                child: const Text('SAVE'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Custom dotted box
class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red,
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
