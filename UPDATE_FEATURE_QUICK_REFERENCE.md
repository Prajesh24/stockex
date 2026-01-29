# Update Feature - Clean Architecture Quick Reference

## 📋 What Was Created

### Domain Layer (Business Logic)
✅ **update_entity.dart** - Core business model for user profile updates
✅ **update_repository.dart** - Abstract interface for data operations
✅ **update_profile_usecase.dart** - Three use cases:
   - UpdateProfileUsecase
   - UploadProfilePictureUsecase
   - GetUserProfileUsecase

### Data Layer (Data Management)
✅ **update_api_model.dart** - API response/request model with JSON serialization
✅ **update_hive_model.dart** - Local database model for Hive storage
✅ **update_datascource.dart** - Abstract interfaces for data sources
✅ **update_remote_datasource.dart** - Remote API operations
✅ **update_local_datasource.dart** - Local Hive database operations
✅ **update_repository.dart** - Repository implementation with network checking

### Presentation Layer (UI & State)
✅ **update_state.dart** - Immutable state class with status enum
✅ **update_view_model.dart** - Riverpod ViewModel for state management
✅ **profile_clean_architecture.dart** - Example refactored UI screen

### Configuration Updates
✅ **api_endpoints.dart** - Added 3 new endpoints
✅ **hive_table_constant.dart** - Added update table configuration
✅ **CLEAN_ARCHITECTURE_GUIDE.md** - Comprehensive documentation

---

## 🚀 How to Use

### 1. In Your UI (Profile Screen)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/update/presentation/view_model/update_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    Future.microtask(() {
      ref.read(updateViewModelProvider.notifier).getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateViewModelProvider);

    return Scaffold(
      body: updateState.isLoading
          ? const CircularProgressIndicator()
          : Column(
              children: [
                // Display profile info
                Text(updateState.profileEntity?.fullName ?? 'User'),
                Text(updateState.profileEntity?.email ?? 'email'),
                
                // Show error if any
                if (updateState.status == UpdateStatus.error)
                  Text('Error: ${updateState.errorMessage}'),
              ],
            ),
    );
  }
}
```

### 2. Update Profile
```dart
ref.read(updateViewModelProvider.notifier).updateProfile(
  fullName: 'John Doe',
  email: 'john@example.com',
  phoneNumber: '1234567890',
  profilePicture: null,
);
```

### 3. Upload Profile Picture
```dart
ref.read(updateViewModelProvider.notifier).uploadProfilePicture(
  imagePath: imageFile.path,
);
```

### 4. Get User Profile
```dart
ref.read(updateViewModelProvider.notifier).getUserProfile();
```

---

## 📝 Important: Next Steps

### 1. **Generate Build Files** (REQUIRED)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
This generates:
- `update_api_model.g.dart`
- `update_hive_model.g.dart`

### 2. **Implement HiveService Methods**
Add these methods to your `HiveService` class:
```dart
// In lib/core/services/hive/hive_service.dart

Future<void> saveUpdateProfile(UpdateHiveModel profile) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  await box.put('profile_key', profile);
}

Future<UpdateHiveModel?> getUpdateProfile(String userId) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  return box.get('profile_key');
}

Future<void> deleteUpdateProfile(String userId) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  await box.delete('profile_key');
}
```

### 3. **Register Hive Types**
In your app initialization (usually `main.dart`):
```dart
Hive.registerAdapter(UpdateHiveModelAdapter());
```

### 4. **Update Your Backend API**
Ensure your backend has these endpoints:
- `PUT /api/auth/update-profile` - Update profile data
- `POST /api/auth/upload-profile-picture` - Upload image (multipart)
- `GET /api/auth/profile` - Get user profile

### 5. **Update EditProfileScreen** (Optional)
Refactor your `edit_profile_screen.dart` to use the ViewModel:
```dart
ref.read(updateViewModelProvider.notifier).updateProfile(
  fullName: fullNameController.text,
  email: emailController.text,
  phoneNumber: phoneController.text,
  profilePicture: null,
);
```

---

## 🔍 State Status Values

Monitor these in your UI:
- `UpdateStatus.initial` - Initial state
- `UpdateStatus.loading` - Operation in progress
- `UpdateStatus.profileLoaded` - Profile successfully loaded
- `UpdateStatus.updateSuccess` - Profile successfully updated
- `UpdateStatus.uploadSuccess` - Picture successfully uploaded
- `UpdateStatus.error` - Operation failed

---

## 📊 Data Flow Diagram

```
┌─────────────────┐
│   UI Layer      │
│  (ProfileScreen)│
└────────┬────────┘
         │ watches state
         │ calls methods
         ↓
┌─────────────────────────┐
│   Presentation Layer    │
│  (UpdateViewModel)      │
└────────┬────────────────┘
         │ calls use cases
         ↓
┌─────────────────────────┐
│   Domain Layer          │
│  (UpdateProfileUsecase) │
└────────┬────────────────┘
         │ calls repository
         ↓
┌─────────────────────────────┐
│     Data Layer              │
│  (UpdateRepository)         │
└────────┬────────────────────┘
         │ checks network
         ├─ if online → Remote DS
         └─ if offline → Local DS
         ↓
┌──────────────────────┐
│  Remote/Local DS     │
│  (API/Hive)          │
└──────────────────────┘
```

---

## 🎯 Best Practices Followed

✅ **Dependency Injection** - Riverpod providers for dependency management
✅ **Separation of Concerns** - Clear layer separation (Domain, Data, Presentation)
✅ **Either Pattern** - Error handling with `Either<Failure, T>`
✅ **Immutability** - Equatable and copyWith for state
✅ **Offline Support** - Hive local caching
✅ **Network Aware** - Checks connectivity before API calls
✅ **Type Safety** - Strong typing throughout
✅ **Error Handling** - Specific failure types for different errors

---

## 📂 File Locations Summary

```
lib/features/update/
├── domain/
│   ├── entities/update_entity.dart
│   ├── repository/update_repository.dart
│   └── usecase/update_profile_usecase.dart
├── data/
│   ├── datascources/
│   │   ├── update_datascource.dart
│   │   ├── remote/update_remote_datasource.dart
│   │   └── local/update_local_datasource.dart
│   ├── model/
│   │   ├── update_api_model.dart
│   │   ├── update_hive_model.dart
│   │   └── *.g.dart (generated files)
│   └── repositories/update_repository.dart
└── presentation/
    ├── state/update_state.dart
    ├── view_model/update_view_model.dart
    └── pages/ (create your screens here)

lib/screen/bottom_screen/
├── profile.dart (original)
└── profile_clean_architecture.dart (refactored example)

Core Updates:
├── lib/core/api/api_endpoints.dart (updated)
└── lib/core/constants/hive_table_constant.dart (updated)

Documentation:
├── CLEAN_ARCHITECTURE_GUIDE.md (comprehensive)
└── UPDATE_FEATURE_QUICK_REFERENCE.md (this file)
```

---

## 🔗 Related Files Reference

**Auth Feature** (Your existing pattern):
- `lib/features/auth/domain/entities/auth_entity.dart` - Compare structure
- `lib/features/auth/domain/usecase/login_usecase.dart` - Compare pattern
- `lib/features/auth/presentation/view_model/auth_view_model.dart` - Compare VM

---

## ❓ Common Questions

**Q: Where do I call `updateProfile()`?**
A: Call it from your UI: `ref.read(updateViewModelProvider.notifier).updateProfile(...)`

**Q: How do I know when an operation is done?**
A: Watch the state: `final updateState = ref.watch(updateViewModelProvider);`
Check `updateState.status` for completion.

**Q: Can I use this offline?**
A: Yes! The repository checks network and falls back to Hive caching.

**Q: Do I need to manually handle Hive?**
A: No! The repository handles it automatically.

**Q: How do I show loading state?**
A: Use `updateState.isLoading` or `updateState.status == UpdateStatus.loading`

---

## 🚨 Troubleshooting

**Build Files Not Generated?**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Hive Adapter Not Found?**
- Make sure you ran build_runner
- Register adapter in main.dart: `Hive.registerAdapter(UpdateHiveModelAdapter());`

**API Calls Failing?**
- Check API endpoints are correct in `api_endpoints.dart`
- Verify backend is running
- Check network connectivity

**State Not Updating?**
- Make sure you're using `ConsumerStatefulWidget` or `ConsumerWidget`
- Use `ref.watch()` to listen to state changes
- Use `ref.read().notifier` to call methods

---

## 📞 Support

For questions, refer to:
1. CLEAN_ARCHITECTURE_GUIDE.md (detailed documentation)
2. Your existing auth feature (reference implementation)
3. Profile_clean_architecture.dart (UI example)

Happy coding! 🎉
