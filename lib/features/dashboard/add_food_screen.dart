import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/food_result_widgets.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/services/food_search_service.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';
import 'package:nutrient_tracker/utils/food_grouper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchCtrl = TextEditingController();
  final _searchService = FoodSearchService();
  final _nutritionService = NutritionService();
  final _authService = AuthService();

  List<FoodModel> _results = [];
  bool _loading = false;
  String _status = '';
  late String _todayDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _loading = true; _results = []; _status = ''; });

    final raw = await _searchService.searchFoods(query);
    final results = FoodGrouper.groupAndAverage(raw);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _results = results;
      _status = results.isEmpty ? '검색 결과가 없습니다.\n영문으로 검색하거나 식품명을 다시 확인해주세요.' : '';
    });
  }

  Future<void> _addFood(FoodModel food) async {
    final dialogResult = await showAmountDialog(context, food);
    if (dialogResult == null || !mounted) return;

    final (amountG, mealType) = dialogResult;
    final uid = _authService.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final scaled = food.per100g.scaled(amountG);
    final entry = FoodEntryModel(
      foodId: food.id,
      foodName: food.name,
      amountG: amountG,
      calories: scaled.calories,
      carbsG: scaled.carbsG,
      proteinG: scaled.proteinG,
      fatG: scaled.fatG,
      sugarG: scaled.sugarG,
      fiberG: scaled.fiberG,
      sodiumMg: scaled.sodiumMg,
      caffeineMg: scaled.caffeineMg,
      loggedAt: DateTime.now(),
      mealType: mealType,
    );

    try {
      await _nutritionService.addFoodEntry(uid, _todayDate, entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.name} 추가됨 (${amountG.toStringAsFixed(0)}g)'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음식 추가'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: '음식명 검색 (한글·영문 가능)',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() { _results = []; _status = ''; });
                    },
                  ),
              ],
              onSubmitted: _search,
              onChanged: (v) => setState(() {}),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_status.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(_status,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500])),
              ),
            )
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('음식명을 검색해보세요',
                        style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Text('예) 닭가슴살, chicken breast, 삼겹살',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, i) => FoodResultItem(
                  food: _results[i],
                  onTap: () => _addFood(_results[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
