import 'package:flutter/material.dart';
import '../../hotels/hotels_page.dart';

class StaysTab extends StatefulWidget {
  const StaysTab({super.key});
  @override
  State<StaysTab> createState() => _StaysTabState();
}

class _StaysTabState extends State<StaysTab> {
  String _locationDraft = '';
  String _submittedLocation = '';
  DateTimeRange? _rangeDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF003B95),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: _SearchCard(
            onPickLocation: (v) => setState(() => _locationDraft = v),
            onPickDates: (r) => setState(() => _rangeDraft = r),
            onSearch: () {
              setState(() {
                _submittedLocation = _locationDraft;
              });
            },
            range: _rangeDraft,
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: HotelsPage(
            showHeader: false,
            query: _submittedLocation,
            locationFilter: _submittedLocation,
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  final ValueChanged<String> onPickLocation;
  final ValueChanged<DateTimeRange?> onPickDates;
  final VoidCallback onSearch;
  final DateTimeRange? range;
  const _SearchCard({
    required this.onPickLocation,
    required this.onPickDates,
    required this.onSearch,
    required this.range,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Where are you going?',
                border: OutlineInputBorder(),
              ),
              onChanged: onPickLocation,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  helpText: 'Select your stay dates',
                );
                onPickDates(picked);
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
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search stays'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
