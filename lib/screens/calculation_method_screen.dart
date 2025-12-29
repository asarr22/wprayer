import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/providers/prayer_provider.dart';
import 'package:wprayer/utils/constants/sizes.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';

class CalculationMethodScreen extends ConsumerWidget {
  const CalculationMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    // We need to know which one is currently selected by the USER preference
    // We can get this from a Future, but better if we let the logic handle it.
    // For now, listing methods. To highlight selected, we might need to expose user preference in state.
    // Assuming we'll just tap to set and pop.

    final methods = [
      {'name': loc.auto, 'value': 'AUTO'},
      {'name': 'Muslim World League', 'value': 'MWL'},
      {'name': 'Egyptian', 'value': 'EGYPTIAN'},
      {'name': 'Karachi', 'value': 'KARACHI'},
      {'name': 'Umm Al-Qura', 'value': 'UMM_AL_QURA'},
      {'name': 'Dubai', 'value': 'DUBAI'},
      {'name': 'Kuwait', 'value': 'KUWAIT'},
      {'name': 'Qatar', 'value': 'QATAR'},
      {'name': 'Singapore', 'value': 'SINGAPORE'},
      {'name': 'North America (ISNA)', 'value': 'NORTH_AMERICA'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.calculationMethod),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(WSizes.padding),
        itemCount: methods.length,
        itemBuilder: (context, index) {
          final method = methods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: WSizes.spaceBetweenItems),
            child: InkWell(
              onTap: () {
                final value = method['value'] as String;
                ref
                    .read(prayerProvider.notifier)
                    .updateCalculationMethod(value == 'AUTO' ? null : value);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(WSizes.borderRadius),
              child: Container(
                padding: const EdgeInsets.all(WSizes.padding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(WSizes.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      method['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
