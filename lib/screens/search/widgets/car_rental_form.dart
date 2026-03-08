import 'package:flutter/material.dart';

class CarRentalForm extends StatefulWidget {
  const CarRentalForm({super.key});
  @override
  State<CarRentalForm> createState() => _CarRentalFormState();
}

class _CarRentalFormState extends State<CarRentalForm> {
  bool returnSameLocation = true;
  final TextEditingController locationCtrl = TextEditingController();
  DateTimeRange? range;
  int driverAge = 30;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: returnSameLocation,
          onChanged: (v) => setState(() => returnSameLocation = v),
          title: const Text('Return to same location'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: locationCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.directions_car),
            labelText: 'Pick-up location',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
              helpText: 'Select pick-up and drop-off',
            );
            if (picked != null) {
              setState(() => range = picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              range == null
                  ? 'Any dates'
                  : '${range!.start.toLocal()} - ${range!.end.toLocal()}'
                      .split('.')
                      .first,
            ),
          ),
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
            labelText: "Driver's age",
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$driverAge'),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => driverAge = (driverAge - 1).clamp(18, 99)),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => driverAge = (driverAge + 1).clamp(18, 99)),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Searching cars...')),
            );
          },
          child: const Text('Search'),
        ),
        const SizedBox(height: 16),
        Text('Popular car hire brands',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: const [
            Chip(label: Text('Alamo')),
            Chip(label: Text('AVIS')),
            Chip(label: Text('Budget')),
            Chip(label: Text('Hertz')),
            Chip(label: Text('Enterprise')),
          ],
        ),
      ],
    );
  }
}

