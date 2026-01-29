# Update Feature - Architecture Overview

## 🏗️ Clean Architecture Pattern

Your Update Feature follows the **Clean Architecture** pattern with 3 distinct layers:

```
┌─────────────────────────────────────────┐
│      PRESENTATION LAYER (UI)            │
│  • ProfileScreen (ConsumerStatefulWidget)
│  • UpdateViewModel (Riverpod Notifier)   │
│  • UpdateState (Immutable State)         │
└────────────────┬────────────────────────┘
                 │
                 ↓ depends on
                 
┌─────────────────────────────────────────┐
│       DOMAIN LAYER (Business Logic)     │
│  • UpdateEntity (Business Model)         │
│  • IUpdateRepository (Interface)         │
│  • UpdateProfileUsecase                  │
│  • UploadProfilePictureUsecase          │
│  • GetUserProfileUsecase                 │
└────────────────┬────────────────────────┘
                 │
                 ↓ implements interface
                 
┌─────────────────────────────────────────┐
│       DATA LAYER (Data Sources)         │
│  • UpdateRepository (Implementation)     │
│  • UpdateRemoteDatasource (API)         │
│  • UpdateLocalDatasource (Hive)         │
│  • UpdateApiModel (JSON)                 │
│  • UpdateHiveModel (Database)            │
└─────────────────────────────────────────┘
```

---

## 📂 File Organization

```
features/update/
│
├── domain/                          ← Business Rules
│   ├── entities/
│   │   └── update_entity.dart       ← Core business model
│   ├── repository/
│   │   └── update_repository.dart   ← Abstract interface (what we need)
│   └── usecase/
│       └── update_profile_usecase.dart  ← Business logic workflows
│
├── data/                            ← Data Management
│   ├── datascources/
│   │   ├── update_datascource.dart  ← Abstract datasource interfaces
│   │   ├── remote/
│   │   │   └── update_remote_datasource.dart  ← API calls
│   │   └── local/
│   │       └── update_local_datasource.dart   ← Hive database
│   ├── model/
│   │   ├── update_api_model.dart    ← API response structure
│   │   └── update_hive_model.dart   ← Database model
│   └── repositories/
│       └── update_repository.dart   ← Implements domain interface
│
└── presentation/                    ← UI & State Management
    ├── state/
    │   └── update_state.dart        ← Immutable state class
    └── view_model/
        └── update_view_model.dart   ← State management & logic
```

---

## 🔄 Data Flow

### When User Updates Profile:

```
Step 1: User taps "Update Profile" button
           ↓
Step 2: UI calls ViewModel method
        ref.read(updateViewModelProvider.notifier).updateProfile(...)
           ↓
Step 3: ViewModel creates params and calls Use Case
        _updateProfileUsecase.call(UpdateProfileUsecaseParams(...))
           ↓
Step 4: Use Case converts params to Entity and calls Repository
        _updateRepository.updateProfile(entity)
           ↓
Step 5: Repository checks network
        if (await _networkInfo.isConnected)
           ├─ YES → Call Remote Datasource (API)
           │        └─ Save result to Local Datasource (Hive)
           └─ NO → Call Local Datasource (Hive)
           ↓
Step 6: Datasource returns result
        Either<Failure, bool>
           ↓
Step 7: Repository returns to Use Case
        Either<Failure, bool>
           ↓
Step 8: Use Case returns to ViewModel
        Either<Failure, bool>
           ↓
Step 9: ViewModel updates state
        state = state.copyWith(
          status: success ? UpdateStatus.updateSuccess : UpdateStatus.error
        )
           ↓
Step 10: UI rebuilds with new state
         Shows success/error message to user
```

---

## 🧩 Component Responsibilities

### Domain Layer (Business Logic)

**UpdateEntity**
- Pure business model
- No dependencies
- What data exists in the system

**IUpdateRepository**
- What operations are available
- No implementation details
- Defined by business needs

**Use Cases**
- Orchestrate business logic
- Use repository to get data
- Convert between formats
- Return Either<Failure, T>

### Data Layer (Data Management)

**UpdateRemoteDatasource**
- Makes API calls
- Parses API responses
- Handles network errors

**UpdateLocalDatasource**
- Manages local Hive storage
- Saves data offline
- Retrieves cached data

**UpdateRepository** (Implementation)
- Decides which datasource to use
- Checks network connectivity
- Converts between models and entities
- Implements business logic for data management

### Presentation Layer (UI & State)

**UpdateState**
- Holds current UI state
- Status, error messages, data
- Immutable (uses copyWith)

**UpdateViewModel**
- Manages state changes
- Calls use cases
- Transforms results into state updates

**UI Screens**
- Displays state
- Captures user input
- Calls ViewModel methods

---

## 🔌 Dependency Injection

All dependencies are managed by Riverpod providers:

```dart
// UI Layer depends on
updateViewModelProvider
  ↓
// ViewModel depends on
updateProfileUsecaseProvider
  ↓
// Use Case depends on
updateRepositoryProvider
  ↓
// Repository depends on
updateRemoteDatasourceProvider    +    updateLocalDatasourceProvider
↓                                      ↓
apiClientProvider                      hiveServiceProvider
tokenServiceProvider                   
networkInfoProvider                    
```

---

## 💾 Data Models

### Three Representations of User Profile:

1. **UpdateEntity** (Domain)
   - Used in business logic
   - Framework independent
   - Most abstract

2. **UpdateApiModel** (Data - API)
   - Represents API response
   - JSON serializable
   - For network communication

3. **UpdateHiveModel** (Data - Database)
   - Represents local storage
   - Hive persistent
   - For offline support

Conversions:
```
API Response JSON
    ↓
UpdateApiModel.fromJson()
    ↓
UpdateEntity.toEntity()
    ↓
UpdateHiveModel.fromEntity()
    ↓
Store in Hive
```

---

## ⚡ Key Features

### 1. Offline Support
- Automatically caches data in Hive
- Detects network status
- Falls back to local storage when offline
- Syncs when back online

### 2. Error Handling
- Type-safe error handling with Either
- Specific error types (ServerFailure, LocalDatabaseFailure)
- User-friendly error messages

### 3. Type Safety
- Null safety
- Strong typing throughout
- Compile-time error checking

### 4. Testability
- Each layer independently testable
- No side effects
- Pure functions

### 5. Maintainability
- Clear separation of concerns
- Single responsibility principle
- Easy to understand and modify

### 6. Scalability
- Add new features without changing existing code
- Reuse components across features
- Share datasources and repositories

---

## 🎯 Usage Patterns

### Load Profile on Screen Init
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(updateViewModelProvider.notifier).getUserProfile();
  });
}
```

### Display Loaded Profile
```dart
final updateState = ref.watch(updateViewModelProvider);
Text(updateState.profileEntity?.fullName ?? 'User')
```

### Update Profile
```dart
ref.read(updateViewModelProvider.notifier).updateProfile(
  fullName: 'New Name',
  email: 'new@email.com',
  phoneNumber: '9876543210',
  profilePicture: null,
);
```

### Upload Picture
```dart
ref.read(updateViewModelProvider.notifier).uploadProfilePicture(
  imagePath: imageFile.path,
);
```

### Handle States
```dart
final state = ref.watch(updateViewModelProvider);

if (state.isLoading) {
  // Show loading indicator
}

if (state.status == UpdateStatus.error) {
  // Show error message
  SnackbarUtils.showError(context, state.errorMessage);
}

if (state.status == UpdateStatus.updateSuccess) {
  // Show success message
  SnackbarUtils.showSuccess(context, 'Profile updated!');
}
```

---

## 🔍 Error Handling Flow

```
Exception occurs in API call
        ↓
Caught as DioException
        ↓
Converted to ServerFailure
        ↓
Repository returns Left(ServerFailure)
        ↓
Use Case returns Left(ServerFailure)
        ↓
ViewModel receives Left
        ↓
Updates state:
  status = UpdateStatus.error
  errorMessage = failure.message
        ↓
UI rebuilds with error state
        ↓
Shows error message to user
```

---

## 📊 State Machine

```
       Initial
          ↓
    User takes action
          ↓
       Loading
       ↙   ↘
    Success Error
       ↓      ↓
   [Success] [Error]
       ↓      ↓
    ← Back ←
```

### State Values
- `UpdateStatus.initial` - Starting state
- `UpdateStatus.loading` - Operation in progress
- `UpdateStatus.profileLoaded` - Profile successfully loaded
- `UpdateStatus.updateSuccess` - Profile successfully updated
- `UpdateStatus.uploadSuccess` - Picture successfully uploaded
- `UpdateStatus.error` - Operation failed

---

## 🚀 Performance Optimizations

1. **Local Caching** - Reduces API calls
2. **Offline Support** - No need for internet
3. **Lazy Loading** - Load only when needed
4. **State Reuse** - Don't rebuild unnecessary widgets
5. **Efficient Models** - Lightweight data structures

---

## 🔐 Security Considerations

1. **Token Management** - Handled by TokenService
2. **Data Encryption** - Can be added to Hive
3. **Network Security** - Uses HTTPS
4. **Input Validation** - On both client and server
5. **Error Messages** - Don't expose sensitive info

---

## 📱 Typical UI Integration

```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile on screen open
    Future.microtask(() {
      ref.read(updateViewModelProvider.notifier).getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch state changes
    final updateState = ref.watch(updateViewModelProvider);

    return Scaffold(
      body: updateState.isLoading
          ? const CircularProgressIndicator()
          : ProfileContent(
              state: updateState,
              onUpdateProfile: _updateProfile,
              onUploadPicture: _uploadPicture,
            ),
    );
  }

  void _updateProfile() {
    ref.read(updateViewModelProvider.notifier).updateProfile(
      fullName: 'New Name',
      email: 'new@email.com',
      phoneNumber: '1234567890',
      profilePicture: null,
    );
  }

  void _uploadPicture(String imagePath) {
    ref.read(updateViewModelProvider.notifier).uploadProfilePicture(
      imagePath: imagePath,
    );
  }
}
```

---

## 🎓 Why This Architecture?

✅ **Separation of Concerns**
   - Each layer has one job
   - Easy to understand

✅ **Testability**
   - Mock dependencies easily
   - Test each layer independently

✅ **Reusability**
   - Share use cases across features
   - Reuse repositories

✅ **Maintainability**
   - Change implementation without affecting business logic
   - Add features without breaking existing code

✅ **Scalability**
   - Grow without complexity
   - Add new data sources easily

✅ **Framework Independence**
   - Business logic doesn't depend on Flutter
   - Can use with different UI frameworks

---

## 📚 Learn More

- **CLEAN_ARCHITECTURE_GUIDE.md** - Detailed explanation
- **ARCHITECTURE_DIAGRAMS.md** - Visual representations
- **UPDATE_FEATURE_QUICK_REFERENCE.md** - Quick tips
- **Your auth feature** - Reference implementation

---

## ✨ Summary

This architecture provides:
- Clear separation of concerns
- Type-safe error handling
- Offline support
- Testability
- Maintainability
- Scalability

Perfect for production apps! 🚀
