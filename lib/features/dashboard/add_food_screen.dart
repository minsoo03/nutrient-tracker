import 'package:flutter/material.dart';
import 'package:nutrient_tracker/core/constants/app_colors.dart';
import 'package:nutrient_tracker/features/auth/services/auth_service.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/add_food_body.dart';
import 'package:nutrient_tracker/features/dashboard/widgets/food_result_widgets.dart';
import 'package:nutrient_tracker/models/food_entry_model.dart';
import 'package:nutrient_tracker/models/food_model.dart';
import 'package:nutrient_tracker/services/food_search_service.dart';
import 'package:nutrient_tracker/services/nutrition_service.dart';
import 'package:nutrient_tracker/utils/food_grouper.dart';
import 'package:nutrient_tracker/utils/portion_helper.dart';

enum AddFoodMode { food, drink }

class AddFoodScreen extends StatefulWidget {
  final AddFoodMode mode;

  const AddFoodScreen({super.key, this.mode = AddFoodMode.food});

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
    setState(() {
      _loading = true;
      _results = [];
      _status = '';
    });

    final raw = await _searchService.searchFoods(query);
    final filtered = raw.where(_matchesMode).toList();
    final results = FoodGrouper.groupAndAverage(filtered);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _results = results;
      _status = results.isEmpty
          ? '검색 결과가 없습니다.\n한글은 식품명 전체 또는 띄어쓰기 없이 입력해보세요.'
          : '';
    });
  }

  bool _matchesMode(FoodModel food) {
    final profile = PortionHelper.inputProfileFor(food.name);
    return switch (widget.mode) {
      AddFoodMode.food =>
        profile.category == FoodUiCategory.generalFood ||
            profile.category == FoodUiCategory.koreanMeal,
      AddFoodMode.drink =>
        profile.category == FoodUiCategory.beverage ||
            profile.category == FoodUiCategory.caffeinatedDrink ||
            profile.category == FoodUiCategory.alcoholicDrink ||
            profile.category == FoodUiCategory.proteinSupplement,
    };
  }

  Future<void> _addFood(FoodModel food) async {
    final dialogResult = await showAmountDialog(context, food);
    if (dialogResult == null || !mounted) return;

    final (
      amountG,
      mealType,
      extraNutrition,
      companionLabel,
      caffeineOverrideMg,
      sugarOverrideG,
      isZeroDrink,
    ) = dialogResult;

    final uid = _authService.currentUser?.id ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 정보가 없어 저장할 수 없습니다. 다시 로그인해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scaledBase = food.per100g.scaled(amountG);
    final adjustedSugarG = sugarOverrideG ?? scaledBase.sugarG;
    final sugarDelta = adjustedSugarG - scaledBase.sugarG;
    final adjustedCarbsG = (scaledBase.carbsG + sugarDelta).clamp(
      0.0,
      double.infinity,
    );
    final adjustedCalories = (scaledBase.calories + sugarDelta * 4).clamp(
      0.0,
      double.infinity,
    );
    final finalCaffeineMg =
        (caffeineOverrideMg ?? scaledBase.caffeineMg) +
        extraNutrition.caffeineMg;
    final scaled = FoodNutrition(
      calories: adjustedCalories + extraNutrition.calories,
      carbsG: adjustedCarbsG + extraNutrition.carbsG,
      proteinG: scaledBase.proteinG + extraNutrition.proteinG,
      fatG: scaledBase.fatG + extraNutrition.fatG,
      sugarG: adjustedSugarG + extraNutrition.sugarG,
      fiberG: scaledBase.fiberG + extraNutrition.fiberG,
      sodiumMg: scaledBase.sodiumMg + extraNutrition.sodiumMg,
      caffeineMg: finalCaffeineMg,
      alcoholG: scaledBase.alcoholG + extraNutrition.alcoholG,
    );

    final inputProfile = PortionHelper.inputProfileFor(food.name);
    final usesMl = inputProfile.usesMilliliters;
    final usesPiece = PortionHelper.usesPieceCount(food.name);
    final amountValue = usesPiece
        ? amountG / PortionHelper.gramsPerPiece(food.name)
        : amountG;
    final amountUnit = usesPiece ? 'piece' : (usesMl ? 'ml' : 'g');
    final entryType = switch (inputProfile.category) {
      FoodUiCategory.alcoholicDrink => 'alcohol',
      FoodUiCategory.proteinSupplement => 'supplement',
      FoodUiCategory.beverage || FoodUiCategory.caffeinatedDrink => 'drink',
      _ => 'food',
    };
    final parts = <String>[if (isZeroDrink) '제로'];
    if (companionLabel != null) {
      parts.add(companionLabel);
    }
    final suffix = parts.join(' · ');
    final entry = FoodEntryModel(
      foodId: food.id,
      foodName: suffix.isEmpty ? food.name : '${food.name} · $suffix',
      amountG: amountG,
      amountValue: amountValue,
      amountUnit: amountUnit,
      entryType: entryType,
      calories: scaled.calories,
      carbsG: scaled.carbsG,
      proteinG: scaled.proteinG,
      fatG: scaled.fatG,
      sugarG: scaled.sugarG,
      fiberG: scaled.fiberG,
      sodiumMg: scaled.sodiumMg,
      caffeineMg: finalCaffeineMg,
      alcoholG: scaled.alcoholG,
      loggedAt: DateTime.now(),
      mealType: mealType,
    );

    try {
      await _nutritionService.addFoodEntry(uid, _todayDate, entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.name} 추가됨 (${entry.displayAmountText})'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ 음식 추가 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == AddFoodMode.food ? '음식 추가' : '음료/보충제 추가'),
        centerTitle: true,
      ),
      body: AddFoodBody(
        searchCtrl: _searchCtrl,
        mode: widget.mode,
        loading: _loading,
        status: _status,
        results: _results,
        onSubmitted: _search,
        onChanged: (v) => setState(() {}),
        onClear: () {
          _searchCtrl.clear();
          setState(() {
            _results = [];
            _status = '';
          });
        },
        onFoodTap: _addFood,
      ),
    );
  }
}
