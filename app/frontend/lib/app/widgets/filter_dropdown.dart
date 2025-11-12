import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/products_provider.dart';

class FilterDropdown extends ConsumerWidget {
  const FilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(selectedProviderFilter);
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filtrar por fornecedor',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      borderRadius: BorderRadius.circular(12),
      value: currentFilter ?? 'Todos',
      items: const [
        'Todos',
        'brazilian',
        'european',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value == 'Todos' ? 'Todos os fornecedores' : value,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        ref.read(selectedProviderFilter.notifier).state = newValue;
      },
    );
  }
}