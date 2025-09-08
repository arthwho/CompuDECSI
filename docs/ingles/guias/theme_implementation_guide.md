# Theme Implementation Guide for CompuDECSI

## Overview
This guide explains how to implement Flutter's built-in theme system for dark/light mode support in your existing app.

## What We've Created

### 1. **AppTheme Class** (`lib/utils/app_theme.dart`)
- **Light Theme**: Uses your existing color palette
- **Dark Theme**: Automatically generated dark variants
- **Material 3**: Modern design system support

### 2. **Theme Toggle Widget** (`lib/widgets/theme_toggle.dart`)
- Simple toggle button for switching themes
- Can be placed anywhere in your app

### 3. **Updated Main App** (`lib/main.dart`)
- Theme switching capability
- Automatic theme application

## How to Implement Throughout Your App

### **Step 1: Replace Hardcoded Colors**

Instead of using `AppColors.primary`, use theme-aware colors:

```dart
// OLD WAY (hardcoded)
color: AppColors.primary

// NEW WAY (theme-aware)
color: Theme.of(context).colorScheme.primary
```

### **Step 2: Use Theme Extensions**

Access custom theme colors using the extension:

```dart
// Access theme-aware colors
context.customPurple
context.customRed
context.customBlue
context.customGrey

// Check if dark mode is active
if (context.isDarkMode) {
  // Dark mode specific logic
}
```

### **Step 3: Common Color Replacements**

| Old Usage | New Usage |
|-----------|-----------|
| `AppColors.primary` | `Theme.of(context).colorScheme.primary` |
| `AppColors.white` | `Theme.of(context).colorScheme.surface` |
| `AppColors.black` | `Theme.of(context).colorScheme.onSurface` |
| `AppColors.border` | `context.customBorder` |
| `AppColors.grey` | `context.customGrey` |
| `Colors.white` | `Theme.of(context).colorScheme.surface` |
| `Colors.black` | `Theme.of(context).colorScheme.onSurface` |

### **Step 4: Background and Surface Colors**

```dart
// OLD WAY
backgroundColor: Colors.white

// NEW WAY
backgroundColor: Theme.of(context).colorScheme.background
// or
backgroundColor: Theme.of(context).scaffoldBackgroundColor
```

### **Step 5: Text Colors**

```dart
// OLD WAY
style: TextStyle(color: Colors.black)

// NEW WAY
style: TextStyle(color: Theme.of(context).colorScheme.onSurface)
```

## Adding Theme Toggle to Your App

### **Option 1: AppBar Theme Toggle**

```dart
AppBar(
  title: Text('CompuDECSI'),
  actions: [
    ThemeToggle(
      onToggle: () {
        // Your theme toggle logic
      },
      isDarkMode: context.isDarkMode,
    ),
  ],
)
```

### **Option 2: Settings Page**

```dart
ListTile(
  leading: Icon(Icons.brightness_6),
  title: Text('Alternar Tema'),
  subtitle: Text(context.isDarkMode ? 'Modo Escuro' : 'Modo Claro'),
  onTap: () {
    // Your theme toggle logic
  },
)
```

## Implementation Strategy

### **Phase 1: Core Components (Week 1)**
- Update main app structure
- Test theme switching
- Update common widgets

### **Phase 2: Major Pages (Week 2)**
- Home page
- Authentication pages
- Navigation components

### **Phase 3: Remaining Pages (Week 3)**
- Event pages
- Profile pages
- Settings pages

### **Phase 4: Polish (Week 4)**
- Test all themes
- Fix any color inconsistencies
- Add theme persistence

## Testing Your Themes

### **Light Mode Testing**
- Check contrast ratios
- Ensure readability
- Verify color harmony

### **Dark Mode Testing**
- Test in low-light conditions
- Check accessibility
- Verify brand consistency

## Pro Tips

1. **Start Small**: Begin with one page to test the system
2. **Use Theme.of(context)**: Always access colors through the theme
3. **Test Both Modes**: Regularly switch between themes during development
4. **Accessibility**: Ensure sufficient contrast in both modes
5. **Brand Consistency**: Maintain your purple brand color in both themes

## Common Pitfalls

- **Don't hardcode colors** - always use theme colors
- **Don't forget contrast** - test readability in both modes
- **Don't ignore system preferences** - consider respecting user's system theme
- **Don't rush** - implement systematically to avoid inconsistencies

## Additional Resources

- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [Material Design Color System](https://m2.material.io/design/color/the-color-system.html)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

## Benefits After Implementation

- **Automatic dark mode support**
- **Better user experience**
- **System theme integration**
- **Easier maintenance**
- **Professional appearance**
- **Accessibility improvements**