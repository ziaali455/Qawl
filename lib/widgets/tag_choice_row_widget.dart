import 'package:flutter/material.dart';

class TagChoiceRow extends StatefulWidget {
  final Function(String) onStyleSelected; // Callback to pass the selected style

  const TagChoiceRow({super.key, required this.onStyleSelected});

  @override
  _TagChoiceRowState createState() => _TagChoiceRowState();
}

class _TagChoiceRowState extends State<TagChoiceRow> {
  final List<String> tags = [
    'Hafs ‘an Asim',
    'Shu’bah ‘an Asim',
    'Warsh ‘an Nafi’',
    'Qaloon ‘an Nafi’',
    'Duri ‘an Abu Amr',
    'Susi ‘an Abu Amr',
    'Bazzi ibn Kathir',
    'Qunbul ibn Kathir',
    'Duri an Kisaa’i',
    'Layth an Kisaa’i',
    'Hisham ‘an Ibn Amir',
    'Ibn Dakhwan/Amir',
    'Khalaf ‘an Hamzah',
    'Khallad ‘an Hamzah',
  ];

  String? selectedTag; // Holds the selected tag

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          final bool isSelected = selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(
                tag,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.green.shade800,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.green,
              backgroundColor: Colors.green.shade100,
              onSelected: (bool selected) {
                setState(() {
                  selectedTag = selected ? tag : null; // Update the selected tag
                  widget.onStyleSelected(selectedTag ?? 'Hafs \'an Asim'); // Pass to parent
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
