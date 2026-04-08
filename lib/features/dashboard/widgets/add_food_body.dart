import 'package:flutter/material.dart';
import 'package:nutrient_tracker/features/dashboard/add_food_screen.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/food_result_widgets.dart';
import 'package:nutrient_tracker/models/food_model.dart';

/// AddFoodScreen의 검색바 + 결과 목록 바디 위젯
class AddFoodBody extends StatelessWidget {
  final TextEditingController searchCtrl;
  final AddFoodMode mode;
  final bool loading;
  final String status;
  final List<FoodModel> results;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<FoodModel> onFoodTap;

  const AddFoodBody({
    super.key,
    required this.searchCtrl,
    required this.mode,
    required this.loading,
    required this.status,
    required this.results,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
    required this.onFoodTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            controller: searchCtrl,
            hintText: mode == AddFoodMode.food
                ? '음식명 검색 (한글·영문 가능)'
                : '음료·보충제 검색 (예: 콜라, 시리얼, 프로틴)',
            leading: const Icon(Icons.search),
            trailing: [
              if (searchCtrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
            ],
            onSubmitted: onSubmitted,
            onChanged: onChanged,
          ),
        ),
        if (loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (status.isNotEmpty)
          Expanded(
            child: Center(
              child: Text(status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else if (results.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    mode == AddFoodMode.food
                        ? '음식명을 검색해보세요'
                        : '음료나 보충제를 검색해보세요',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode == AddFoodMode.food
                        ? '예) 닭가슴살, chicken breast, 삼겹살'
                        : '예) 콜라, 에너지드링크, 프로틴 쉐이크',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (ctx, i) => FoodResultItem(
                food: results[i],
                onTap: () => onFoodTap(results[i]),
              ),
            ),
          ),
      ],
    );
  }
}
