import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';

class DateTimeCurrencyPage extends StatefulWidget {
  const DateTimeCurrencyPage({super.key});

  @override
  State<DateTimeCurrencyPage> createState() => _DateTimeCurrencyPageState();
}

class _DateTimeCurrencyPageState extends State<DateTimeCurrencyPage> {
  static const _currencySymbols = [
    '€',
    '£',
    r'$',
    '¥',
    '₹',
    '₦',
    '₺',
    '₩',
    '₽',
    '₫',
    'R',
    'CHF',
    'kr',
    'zł',
    'د.إ',
  ];

  late String _currencySymbol;
  late String _dateFormat;
  late String _timeFormat;

  @override
  void initState() {
    super.initState();
    final settings = AppSettingsStore.instance.getSettings();
    _currencySymbol = settings.currencySymbol;
    _dateFormat = settings.dateFormat;
    _timeFormat = settings.timeFormat;
  }

  Future<void> _save() async {
    await AppSettingsStore.instance.saveSettings(
      AppSettings(
        currencySymbol: _currencySymbol,
        dateFormat: _dateFormat,
        timeFormat: _timeFormat,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date, time and currency settings saved')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final previewSettings = AppSettings(
      currencySymbol: _currencySymbol,
      dateFormat: _dateFormat,
      timeFormat: _timeFormat,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date-Time and Currency'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Date and Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The app uses the device system clock automatically.',
                  ),
                  const SizedBox(height: 12),
                  Text('Current device time: ${now.toLocal()}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _dateFormat,
            decoration: const InputDecoration(
              labelText: 'Date Format',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'dd/mm/yyyy', child: Text('DD/MM/YYYY')),
              DropdownMenuItem(value: 'mm/dd/yyyy', child: Text('MM/DD/YYYY')),
              DropdownMenuItem(value: 'yyyy-mm-dd', child: Text('YYYY-MM-DD')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _dateFormat = value);
            },
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '24-hour', label: Text('24-hour')),
              ButtonSegment(value: '12-hour', label: Text('12-hour')),
            ],
            selected: {_timeFormat},
            onSelectionChanged: (selection) {
              setState(() => _timeFormat = selection.first);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Currency Symbol',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _currencySymbols.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final symbol = _currencySymbols[index];
                return ChoiceChip(
                  label: Text(symbol),
                  selected: _currencySymbol == symbol,
                  onSelected: (_) {
                    setState(() => _currencySymbol = symbol);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${previewSettings.currencySymbol}12.50',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_formatPreviewDateTime(now, previewSettings)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  String _formatPreviewDateTime(DateTime value, AppSettings settings) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final date = switch (settings.dateFormat) {
      'mm/dd/yyyy' => '$month/$day/$year',
      'yyyy-mm-dd' => '$year-$month-$day',
      _ => '$day/$month/$year',
    };
    final minute = value.minute.toString().padLeft(2, '0');
    final time = settings.timeFormat == '12-hour'
        ? '${(value.hour % 12 == 0 ? 12 : value.hour % 12).toString().padLeft(2, '0')}:$minute ${value.hour >= 12 ? 'PM' : 'AM'}'
        : '${value.hour.toString().padLeft(2, '0')}:$minute';
    return '$date $time';
  }
}
