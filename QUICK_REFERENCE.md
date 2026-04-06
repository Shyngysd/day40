# 🧪 Краткий Справочник Тестирования

## Быстрый Старт

### 1. Запустить тесты
```bash
flutter test test/widget_test.dart
```

### 2. Запустить приложение
```bash
flutter run
```

---

## 📋 Что Протестировано

### ✅ Экран Списка (4 теста)
```
Пустой список          → Показать: "No todos yet..."
Загрузка               → Показать: CircularProgressIndicator  
Загруженные элементы   → Показать: ListView с элементами
Переходы между ними    → Корректная последовательность
```

### ✅ Кнопка Добавления (3 теста)
```
Ввод + тап             → Элемент появился в списке
Пустой ввод            → Ошибка: "Title cannot be empty"
Несколько добавлений   → Все элементы видны
```

### ✅ Обработка Ошибок (3 теста)
```
Ошибка при добавлении  → Красный SnackBar
Стиль ошибки           → Colors.red фон
Ошибка загрузки        → Текст ошибки в центре
```

### ✅ Keys Всех Виджетов (1 тест)
```
todo_input_field       ✓
add_todo_button        ✓
todos_list             ✓
empty_state_text       ✓
loading_indicator      ✓
success_snackbar       ✓
error_snackbar         ✓
detail_title           ✓
detail_id              ✓
```

### ✅ Навигация (4 теста)
```
Тап → Деталь           → TodoDetailScreen открывается
Информация деталей     → Все поля заполнены корректно
Кнопка назад           → Возврат на список
Множество навигаций    → Можно ходить туда-сюда
```

### ✅ Интеграция (1 тест)
```
Пусто → Добавить → Детали → Назад → Удалить → Пусто
Полный цикл работы приложения
```

---

## 🔧 Ключевые Функции για Тестирования

### Repository
```dart
repository.getTodos()          // Получить элементы
repository.addTodo("title")    // Добавить элемент
repository.deleteTodo(id)      // Удалить элемент
repository.setError(true)      // Включить ошибку
repository.clear()             // Очистить состояние
```

### Состояние Экрана
```dart
state = tester.state<TodoListScreenState>(
  find.byType(TodoListScreen),
);
state.refreshTodos()           // Обновить список
```

---

## 🔍 Поиск в Тестах (Finders)

### По Key
```dart
find.byKey(const Key('todo_input_field'))
find.byKey(const Key('add_todo_button'))
```

### По Тексту
```dart
find.text('No todos yet. Add one to get started!')
find.text('Complete Flutter course')
```

### По Типу
```dart
find.byType(TodoListScreen)
find.byType(CircularProgressIndicator)
find.byIcon(Icons.delete)
find.byIcon(Icons.arrow_back)
```

---

## ⚙️ Основные Операции в Тестах

### Вводить Текст
```dart
await tester.enterText(
  find.byKey(const Key('todo_input_field')),
  'My Todo Title',
);
```

### Нажимать Кнопку
```dart
await tester.tap(find.byKey(const Key('add_todo_button')));
await tester.pumpAndSettle();  // Ждать завершения
```

### Проверить Наличие
```dart
expect(find.text('My Todo Title'), findsOneWidget);
expect(find.byKey(const Key('success_snackbar')), findsOneWidget);
```

### Проверить Отсутствие
```dart
expect(find.text('Deleted Item'), findsNothing);
expect(find.byKey(const Key('loading_indicator')), findsNothing);
```

---

## 📊 Структура Теста

```dart
testWidgets('Описание теста', (WidgetTester tester) async {
  // ПОДГОТОВКА - Setup
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // ДЕЙСТВИЕ - Act
  await tester.enterText(
    find.byKey(const Key('todo_input_field')),
    'Test Todo',
  );
  await tester.tap(find.byKey(const Key('add_todo_button')));
  await tester.pumpAndSettle();
  
  // ПРОВЕРКА - Assert
  expect(find.text('Test Todo'), findsOneWidget);
  expect(find.byKey(const Key('success_snackbar')), findsOneWidget);
});
```

---

## 🛠️ Отладка Тестов

### Если тест не находит элемент:
1. Проверить Key в коде
2. Проверить `pumpAndSettle()`
3. Использовать `find.byType()` вместо `find.byKey()`

### Если SnackBar не видимых:
1. Проверить `mounted` перед `ScaffoldMessenger`
2. Дождаться `pumpAndSettle()`

### Если тест зависает:
1. Добавить `--timeout=180s` флаг
2. Проверить async операции завершены

---

## 📂 Файловая Структура

```
lib/
├── main.dart                    # Приложение + компоненты
│   ├── TodoItem               # Модель
│   ├── TodoRepository         # Хранилище (Singleton)
│   ├── TodoListScreen         # Главный экран
│   ├── TodoListScreenState    # (публичный для тестов)
│   ├── TodoTile               # Элемент списка
│   └── TodoDetailScreen       # Экран деталей

test/
└── widget_test.dart            # 16+ комплексных тестов
```

---

## ✅ Чеклист Перед Коммитом

- [ ] Все 16+ тестов проходят
- [ ] `flutter test` выполняется без ошибок
- [ ] Нет ошибок анализа: `flutter analyze`
- [ ] Код отформатирован: `dart format lib/ test/`
- [ ] Приложение запускается: `flutter run`

---

## 🚀 Команды

```bash
# Запустить все тесты
flutter test

# Запустить конкретный файл
flutter test test/widget_test.dart

# Запустить тесты по имени
flutter test -k "empty state"
flutter test -k "navigation"

# Запустить с покрытием
flutter test --coverage

# Анализ кода
flutter analyze

# Форматирование
dart format lib/ test/

# Запустить приложение
flutter run

# Запустить в release
flutter run --release
```

---

## 📚 Полезные Ссылки

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Widget Tester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [Finder Documentation](https://api.flutter.dev/flutter/flutter_test/Finder-class.html)

---

## 🎯 Итого

✅ **Полная реализация** всех требований для тестирования  
✅ **16+ тестов** покрывают все сценарии  
✅ **Keys для всех** важных виджетов  
✅ **Готово к использованию** и расширению  

Тесты полностью функциональны и могут запуститься в любой момент! 🎉
