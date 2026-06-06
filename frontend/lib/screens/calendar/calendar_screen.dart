import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<EventProvider>().loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<EventProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Calendar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEvent(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: ep.loading
          ? const Center(child: CircularProgressIndicator())
          : ep.events.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No upcoming events', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => _showAddEvent(context),
                      child: const Text('Plan Your First Event'),
                    ),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ep.events.length,
                  itemBuilder: (_, i) => _EventCard(event: ep.events[i]),
                ),
    );
  }

  void _showAddEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddEventSheet(),
    );
  }
}

class _EventCard extends StatelessWidget {
  final AppEvent event;
  const _EventCard({required this.event});

  String get _emoji {
    switch (event.eventType.toLowerCase()) {
      case 'interview': return '💼';
      case 'wedding': return '💒';
      case 'party': return '🎉';
      case 'vacation': return '✈️';
      case 'date': return '❤️';
      case 'presentation': return '📊';
      default: return '📅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.read<EventProvider>();
    final daysUntil = event.eventDate.difference(DateTime.now()).inDays;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(_emoji),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('MMM d, y • h:mm a').format(event.eventDate)),
          if (event.location.isNotEmpty) Text(event.location, style: const TextStyle(fontSize: 12)),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(daysUntil == 0 ? 'Today' : daysUntil == 1 ? 'Tomorrow' : '$daysUntil days',
              style: TextStyle(
                  color: daysUntil <= 1 ? Colors.red : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          if (!event.outfitGenerated)
            TextButton(
              style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 6)),
              onPressed: () async {
                final result = await ep.generateEventOutfit(event.id);
                if (!context.mounted) return;
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['explanation']['summary'] ?? 'Outfit generated!')),
                  );
                  ep.loadEvents();
                }
              },
              child: const Text('Get Outfit', style: TextStyle(fontSize: 11)),
            )
          else
            const Text('✅ Outfit ready', style: TextStyle(fontSize: 10, color: Colors.green)),
        ]),
      ),
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet();
  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  String _type = 'casual';
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _title.dispose(); _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<EventProvider>().createEvent({
      'title': _title.text.trim(),
      'event_type': _type,
      'event_date': _date.toIso8601String(),
      'location': _location.text.trim(),
    });
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Event Title *'),
            validator: (v) => v!.isNotEmpty ? null : 'Required',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Event Type'),
            items: AppConstants.eventTypes.map((t) =>
              DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))
            ).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date: ${DateFormat('MMM d, y').format(_date)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          TextFormField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Location (optional)'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Create Event')),
        ]),
      ),
    );
  }
}
