# Clean Architecture Implementation for Update Feature

## Overview
This document explains the clean architecture implementation for the **Update Feature** in the StockEx application, following the same pattern as your existing Auth feature.

## Architecture Layers

### 1. **Domain Layer** (Business Logic)
Contains the core business rules and is independent of any framework or UI library.

#### Files:
- `lib/features/update/domain/entities/update_entity.dart`
  - **UpdateEntity**: Core business model representing user profile data
  - Properties: userId, fullName, email, phoneNumber, profilePicture, updatedAt
  - All properties are immutable (Equatable)

- `lib/features/update/domain/repository/update_repository.dart`
  - **IUpdateRepository**: Abstract interface defining contract for data operations
  - Methods:
    - `updateProfile(UpdateEntity)` - Update user profile
    - `uploadProfilePicture(String imagePath)` - Upload profile picture
    - `getUserProfile()` - Fetch user profile

- `lib/features/update/domain/usecase/update_profile_usecase.dart`
  - **UpdateProfileUsecase**: Business logic for updating profile
  - **UploadProfilePictureUsecase**: Business logic for uploading pictures
  - **GetUserProfileUsecase**: Business logic for fetching profile
  - Use Riverpod providers for dependency injection
  - Returns `Either<Failure, T>` for error handling

---

### 2. **Data Layer** (Data Management)
Implements the repository interface and handles data from different sources.

#### 2.1 Models
- `lib/features/update/data/model/update_api_model.dart`
  - Handles API responses using `@JsonSerializable()`
  - Methods:
    - `fromJson()` - Parse API responses
    - `toJson()` - Serialize to API format
    - `toEntity()` - Convert to domain entity
    - `fromEntity()` - Convert from domain entity

- `lib/features/update/data/model/update_hive_model.dart`
  - Handles local database storage using Hive
  - Extends `HiveObject` for database persistence
  - Type ID: 1 (defined in `HiveTableConstant`)
  - Methods:
    - `fromEntity()` - Convert from domain entity
    - `toEntity()` - Convert to domain entity

#### 2.2 Data Sources
**Abstract Interfaces** (`lib/features/update/data/datascources/update_datascource.dart`)
- `IUpdateLocalDatasource`: Local storage operations
- `IUpdateRemoteDatasource`: Remote API operations

**Remote Data Source** (`lib/features/update/data/datascources/remote/update_remote_datasource.dart`)
- Implements `IUpdateRemoteDatasource`
- Handles all API calls using `ApiClient` (Dio wrapper)
- Methods:
  - `updateProfile()` - PUT request to update profile
  - `uploadProfilePicture()` - POST with multipart form data
  - `getUserProfile()` - GET request to fetch profile
- Error handling with specific DioExceptions

**Local Data Source** (`lib/features/update/data/datascources/local/update_local_datasource.dart`)
- Implements `IUpdateLocalDatasource`
- Handles Hive database operations
- Methods:
  - `updateProfile()` - Save profile to Hive
  - `getUserProfile()` - Retrieve profile from Hive
  - `deleteProfile()` - Delete profile from Hive

#### 2.3 Repository Implementation
- `lib/features/update/data/repositories/update_repository.dart`
  - Implements `IUpdateRepository`
  - Implements strategy pattern: **Online first, fallback to offline**
  - Checks network connectivity before making API calls
  - Syncs local cache with remote data
  - Comprehensive error handling with specific failure types

---

### 3. **Presentation Layer** (UI & State Management)
Handles UI and state management using Riverpod.

#### 3.1 State Management
- `lib/features/update/presentation/state/update_state.dart`
  - **UpdateState**: Immutable state class
  - Status enum: `initial, loading, profileLoaded, updateSuccess, uploadSuccess, error`
  - Properties:
    - `status`: Current operation status
    - `errorMessage`: Error details
    - `profileEntity`: User profile data
    - `isLoading`: Loading indicator flag
  - `copyWith()` method for immutable state updates

#### 3.2 View Model
- `lib/features/update/presentation/view_model/update_view_model.dart`
  - **UpdateViewModel**: Notifier managing state and business logic
  - Uses Riverpod for dependency injection
  - Methods:
    - `updateProfile()` - Update user profile
    - `uploadProfilePicture()` - Upload profile picture
    - `getUserProfile()` - Fetch user profile
    - `resetState()` - Reset to initial state
  - Injects all use cases through providers
  - Handles error states and success states

#### 3.3 UI Screens
- `lib/screen/bottom_screen/profile_clean_architecture.dart`
  - Example refactored profile screen using clean architecture
  - Uses `ConsumerStatefulWidget` for Riverpod integration
  - Watchers state changes with `ref.watch(updateViewModelProvider)`
  - Calls view model methods with `ref.read(updateViewModelProvider.notifier)`
  - Displays loading states and error messages

---

## Data Flow

### Update Profile Flow:
```
UI Layer (ProfileScreen)
    ↓
ViewModel (updateProfile())
    ↓
Use Case (UpdateProfileUsecase)
    ↓
Repository (updateProfile())
    ├→ Check Network (NetworkInfo)
    ├→ Remote DS (API call) or Local DS (Hive)
    └→ Return Either<Failure, bool>
    ↓
State Updated (UpdateStatus)
    ↓
UI Rebuilt with new state
```

### Upload Picture Flow:
```
UI Layer (pick image from camera/gallery)
    ↓
ViewModel (uploadProfilePicture(imagePath))
    ↓
Use Case (UploadProfilePictureUsecase)
    ↓
Repository (uploadProfilePicture())
    ├→ Check Network
    ├→ Remote DS (MultipartFile upload)
    └→ Return Either<Failure, bool>
    ↓
State Updated (UpdateStatus.uploadSuccess)
    ↓
UI shows success/error
```

---

## Error Handling

### Failure Types:
1. **ServerFailure**: Network/API errors
   - DioException handling
   - HTTP status codes
   - Server error messages

2. **LocalDatabaseFailure**: Hive/Local storage errors
   - Hive errors
   - Storage access issues

### Implementation:
```dart
// In Repository
if (await _networkInfo.isConnected) {
  try {
    // API call
  } on DioException catch (e) {
    return Left(ServerFailure(...));
  }
} else {
  // Try local storage
  try {
    // Hive operation
  } on HiveError catch (e) {
    return Left(LocalDatabaseFailure(...));
  }
}
```

---

## Dependency Injection (Riverpod)

### Providers:
```dart
// Repository Provider
final updateRepositoryProvider = Provider<IUpdateRepository>((ref) {
  return UpdateRepository(...);
});

// Use Case Providers
final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(ref.watch(updateRepositoryProvider));
});

// View Model Provider
final updateViewModelProvider = NotifierProvider<UpdateViewModel, UpdateState>(
  () => UpdateViewModel(),
);
```

---

## API Endpoints

Added to `lib/core/api/api_endpoints.dart`:
```dart
// UPDATE ENDPOINTS
static const String updateProfile = "/update-profile";
static const String uploadProfilePicture = "/upload-profile-picture";
static const String getUserProfile = "/profile";
```

---

## Database (Hive)

### Type Registration:
```dart
// In lib/core/constants/hive_table_constant.dart
static const int updateTypeId = 1;
static const String updateTable = 'update_table';
```

### Usage:
- Generated files: `update_api_model.g.dart`, `update_hive_model.g.dart`
- Run: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Usage Example

### In Your UI:
```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile on init
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
                Text(updateState.profileEntity?.fullName ?? 'User'),
                ElevatedButton(
                  onPressed: () {
                    ref.read(updateViewModelProvider.notifier).updateProfile(
                      fullName: 'New Name',
                      email: 'new@email.com',
                      phoneNumber: '1234567890',
                      profilePicture: null,
                    );
                  },
                  child: const Text('Update Profile'),
                ),
              ],
            ),
    );
  }
}
```

---

## Key Benefits

✅ **Separation of Concerns**: Clear layer separation
✅ **Testability**: Each layer can be tested independently
✅ **Reusability**: Use cases and repositories can be reused
✅ **Maintainability**: Easy to understand and modify
✅ **Scalability**: Easy to add new features
✅ **Offline Support**: Local caching with Hive
✅ **Error Handling**: Comprehensive error management
✅ **Type Safety**: Dart type system with Either pattern

---

## Next Steps

1. **Generate Build Files**: `flutter pub run build_runner build --delete-conflicting-outputs`
2. **Implement HiveService methods**: Add the methods for local storage operations
3. **Create UI Screens**: Refactor existing screens to use the ViewModel
4. **Write Tests**: Create unit and widget tests for each layer
5. **Update API Endpoints**: Ensure backend endpoints match the defined routes

---

## File Structure Summary
```
lib/features/update/
├── domain/
│   ├── entities/
│   │   └── update_entity.dart
│   ├── repository/
│   │   └── update_repository.dart
│   └── usecase/
│       └── update_profile_usecase.dart
├── data/
│   ├── datascources/
│   │   ├── update_datascource.dart
│   │   ├── remote/
│   │   │   └── update_remote_datasource.dart
│   │   └── local/
│   │       └── update_local_datasource.dart
│   ├── model/
│   │   ├── update_api_model.dart
│   │   ├── update_api_model.g.dart
│   │   ├── update_hive_model.dart
│   │   └── update_hive_model.g.dart
│   └── repositories/
│       └── update_repository.dart
└── presentation/
    ├── state/
    │   └── update_state.dart
    └── view_model/
        └── update_view_model.dart
```

---

## Questions?
Refer to your existing auth feature for similar implementations and patterns!
