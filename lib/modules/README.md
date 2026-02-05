# Modules Structure

Struktur folder modules mengikuti pattern **Clean Architecture** dengan pemisahan yang jelas antara bindings, controllers, dan views.

## Struktur Folder

```
modules/
├── splash/
│   ├── bindings/
│   │   └── splash_binding.dart
│   ├── controllers/
│   │   └── splash_controller.dart
│   └── views/
│       └── splash_view.dart
│
├── auth/
│   └── login/
│       ├── bindings/
│       │   └── login_binding.dart
│       ├── controllers/
│       │   └── login_controller.dart
│       └── views/
│           └── login_view.dart
│
├── employee/
│   └── dashboard/
│       ├── bindings/
│       │   └── employee_dashboard_binding.dart
│       ├── controllers/
│       │   └── employee_dashboard_controller.dart
│       └── views/
│           └── employee_dashboard_view.dart
│
└── admin/
    └── dashboard/
        ├── bindings/
        │   └── admin_dashboard_binding.dart
        ├── controllers/
        │   └── admin_dashboard_controller.dart
        └── views/
            └── admin_dashboard_view.dart
```

## Penjelasan Struktur

### 1. **Bindings/**
Folder ini berisi file binding yang digunakan untuk dependency injection dengan GetX.
- Menginisialisasi controller yang diperlukan
- Menggunakan `Get.put()` untuk eager loading atau `Get.lazyPut()` untuk lazy loading

### 2. **Controllers/**
Folder ini berisi business logic dan state management.
- Mengelola state aplikasi menggunakan GetX
- Berisi fungsi-fungsi yang memanipulasi data
- Berkomunikasi dengan services (API, Storage, dll)

### 3. **Views/**
Folder ini berisi UI/Widget yang ditampilkan ke user.
- Menggunakan `GetView<Controller>` untuk mengakses controller
- Hanya fokus pada tampilan, tidak ada logic bisnis
- Responsive dan reusable

## Keuntungan Struktur Ini

✅ **Separation of Concerns** - Setiap bagian memiliki tanggung jawab yang jelas
✅ **Maintainability** - Mudah untuk menemukan dan memperbaiki code
✅ **Scalability** - Mudah menambah fitur baru tanpa merusak yang sudah ada
✅ **Testability** - Mudah untuk melakukan unit testing
✅ **Readability** - Struktur yang jelas dan konsisten

## Cara Menambah Module Baru

1. Buat folder module baru di dalam `modules/`
2. Buat 3 subfolder: `bindings/`, `controllers/`, `views/`
3. Buat file binding, controller, dan view sesuai kebutuhan
4. Daftarkan route di `app_pages.dart`
5. Tambahkan route name di `app_routes.dart`

### Contoh:

```dart
// 1. Buat structure
modules/
  └── profile/
      ├── bindings/
      │   └── profile_binding.dart
      ├── controllers/
      │   └── profile_controller.dart
      └── views/
          └── profile_view.dart

// 2. Di app_routes.dart
static const profile = '/profile';

// 3. Di app_pages.dart
GetPage(
  name: AppRoutes.profile,
  page: () => const ProfileView(),
  binding: ProfileBinding(),
),
```

## Import Paths

Pastikan untuk menggunakan relative import yang benar:

```dart
// Dari view ke controller (dalam module yang sama)
import '../controllers/profile_controller.dart';

// Dari binding ke controller (dalam module yang sama)
import '../controllers/profile_controller.dart';

// Ke core/data/routes (dari module manapun)
import '../../../core/...';
import '../../../data/...';
import '../../../routes/...';
```

## Best Practices

1. **Satu module = satu fitur** - Jangan campur-campur fitur dalam satu module
2. **Konsisten dengan naming** - Gunakan pattern `feature_type.dart` (e.g., `login_controller.dart`)
3. **Keep it simple** - Jangan membuat struktur yang terlalu kompleks
4. **Document your code** - Tambahkan komentar untuk code yang kompleks
5. **Follow Dart/Flutter conventions** - Gunakan snake_case untuk file, PascalCase untuk class

---

**Last Updated:** February 5, 2026
**Maintainer:** Flutter Absensi GPS Team
