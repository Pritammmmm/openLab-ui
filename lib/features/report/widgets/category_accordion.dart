import 'package:flutter/material.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../models/parameter_model.dart';
import 'parameter_row.dart';

class CategoryAccordion extends StatelessWidget {
  final String category;
  final List<ParameterModel> parameters;
  final bool initiallyExpanded;
  final void Function(ParameterModel) onParameterTap;

  const CategoryAccordion({
    super.key,
    required this.category,
    required this.parameters,
    this.initiallyExpanded = false,
    required this.onParameterTap,
  });

  @override
  Widget build(BuildContext context) {
    final greenCount =
        parameters.where((p) => p.trafficLight == 'green').length;
    final yellowCount =
        parameters.where((p) => p.trafficLight == 'yellow').length;
    final redCount =
        parameters.where((p) => p.trafficLight == 'red').length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        title: Text(
          category,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (greenCount > 0)
                TrafficLightBadge(
                  status: 'green',
                  count: greenCount,
                  fontSize: 11,
                ),
              if (greenCount > 0 && (yellowCount > 0 || redCount > 0))
                const SizedBox(width: 4),
              if (yellowCount > 0)
                TrafficLightBadge(
                  status: 'yellow',
                  count: yellowCount,
                  fontSize: 11,
                ),
              if (yellowCount > 0 && redCount > 0)
                const SizedBox(width: 4),
              if (redCount > 0)
                TrafficLightBadge(
                  status: 'red',
                  count: redCount,
                  fontSize: 11,
                ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          ...parameters.map(
            (param) => ParameterRow(
              parameter: param,
              onTap: () => onParameterTap(param),
            ),
          ),
        ],
      ),
    );
  }
}
