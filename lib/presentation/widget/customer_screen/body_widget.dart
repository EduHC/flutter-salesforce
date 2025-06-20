import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/customer.dart';

class CustomerScreenBodyWidget extends StatelessWidget {
  final List<Customer> customers;
  final bool databaseError;
  final String? databaseErrorMsg;

  const CustomerScreenBodyWidget({
    super.key,
    required this.customers,
    required this.databaseError,
    required this.databaseErrorMsg,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading:
                customer.pictureUrl != null
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(customer.pictureUrl!),
                    )
                    : CircleAvatar(
                      child: Text(
                        customer.firstName.isNotEmpty
                            ? customer.firstName[0].toUpperCase()
                            : '',
                      ),
                    ),
            title: Text('${customer.firstName} ${customer.lastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.email != null) Text(customer.email!),
                if (customer.cellphone != null) Text(customer.cellphone!),
                if (customer.city != null)
                  Text('${customer.city}, ${customer.state ?? ''}'),
              ],
            ),
            trailing: Icon(
              customer.isActive ? Icons.check_circle : Icons.cancel,
              color: customer.isActive ? Colors.green : Colors.red,
            ),
            onTap: () {
              // Handle row tap—e.g., open customer details
            },
          ),
        );
      },
    );
  }
}
