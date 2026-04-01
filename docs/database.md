# DB 스키마 (Firestore)

## 컬렉션 구조

### users/{userId}
```
{
  name: string,
  age: number,
  gender: "male" | "female" | "other",
  height_cm: number,
  weight_kg: number,
  goal: "diet" | "muscle" | "health" | "medical",
  daily_calorie_target: number,
  daily_protein_target: number,
  has_kidney_disease: boolean,
  has_liver_disease: boolean,
  medications: string[],
  created_at: timestamp
}
```

### users/{userId}/daily_logs/{date}
```
{
  date: string,           // "2026-03-31"
  total_calories: number,
  total_carbs_g: number,
  total_protein_g: number,
  total_fat_g: number,
  total_sugar_g: number,
  total_fiber_g: number,
  total_sodium_mg: number,
  total_caffeine_mg: number,
  total_alcohol_g: number,
  total_water_ml: number,
  updated_at: timestamp
}
```

### users/{userId}/daily_logs/{date}/entries/{entryId}
```
{
  food_id: string,        // foods 컬렉션 참조
  food_name: string,
  amount_g: number,
  calories: number,
  carbs_g: number,
  protein_g: number,
  fat_g: number,
  sugar_g: number,
  sodium_mg: number,
  caffeine_mg: number,
  logged_at: timestamp,
  meal_type: "breakfast" | "lunch" | "dinner" | "snack"
}
```

### foods/{foodId}
```
{
  name: string,
  name_en: string,
  source: "kr_mfds" | "usda" | "barcode" | "custom",
  barcode: string | null,
  per_100g: {
    calories: number,
    carbs_g: number,
    protein_g: number,
    fat_g: number,
    sugar_g: number,
    fiber_g: number,
    sodium_mg: number,
    potassium_mg: number,
    phosphorus_mg: number,
    caffeine_mg: number,
    alcohol_g: number,
    saturated_fat_g: number,
    fructose_g: number
  },
  created_at: timestamp
}
```
