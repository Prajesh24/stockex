# Update Feature - Clean Architecture Visualization

## Complete Architecture Overview

```
╔════════════════════════════════════════════════════════════════════════════╗
║                         PRESENTATION LAYER (UI)                           ║
║                                                                            ║
║  ┌────────────────────────────────────────────────────────────────────┐  ║
║  │                    ProfileScreen (UI)                              │  ║
║  │                                                                    │  ║
║  │  • Displays profile data                                          │  ║
║  │  • Shows loading indicators                                       │  ║
║  │  • Shows error messages                                           │  ║
║  │  • Handles image picking (camera/gallery)                         │  ║
║  │                                                                    │  ║
║  │  uses: ConsumerStatefulWidget                                     │  ║
║  │  state: UpdateState (from ViewModel)                              │  ║
║  └────────────┬───────────────────────────────────────────────────────┘  ║
║               │                                                            ║
║               │ watches UpdateState                                        ║
║               │ calls ViewModel methods                                    ║
║               ↓                                                            ║
║  ┌────────────────────────────────────────────────────────────────────┐  ║
║  │            UpdateViewModel (Riverpod Notifier)                     │  ║
║  │                                                                    │  ║
║  │  • updateProfile()                                                │  ║
║  │  • uploadProfilePicture()                                         │  ║
║  │  • getUserProfile()                                               │  ║
║  │  • resetState()                                                   │  ║
║  │                                                                    │  ║
║  │  @override UpdateState build() { ... }                            │  ║
║  │  Manages UpdateState                                              │  ║
║  └────────────┬───────────────────────────────────────────────────────┘  ║
║               │                                                            ║
║               │ injects dependencies via ref.read()                       ║
║               ↓                                                            ║
╚═══════════════│════════════════════════════════════════════════════════════╝
                │
                │ calls use cases
                ↓
╔═══════════════════════════════════════════════════════════════════════════╗
║                         DOMAIN LAYER (Business Logic)                     ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │            UpdateProfileUsecase                                 │   ║
║  │                                                                 │   ║
║  │  call(UpdateProfileUsecaseParams params)                        │   ║
║  │    ↓                                                            │   ║
║  │    • Convert params to UpdateEntity                            │   ║
║  │    • Call repository.updateProfile()                           │   ║
║  │    • Return Either<Failure, bool>                              │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │        UploadProfilePictureUsecase                              │   ║
║  │                                                                 │   ║
║  │  call(UploadProfilePictureUsecaseParams params)                 │   ║
║  │    ↓                                                            │   ║
║  │    • Call repository.uploadProfilePicture()                    │   ║
║  │    • Return Either<Failure, bool>                              │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │           GetUserProfileUsecase                                 │   ║
║  │                                                                 │   ║
║  │  call()                                                         │   ║
║  │    ↓                                                            │   ║
║  │    • Call repository.getUserProfile()                          │   ║
║  │    • Return Either<Failure, UpdateEntity>                      │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │            IUpdateRepository (Interface)                        │   ║
║  │                                                                 │   ║
║  │  • updateProfile(UpdateEntity) → Either<Failure, bool>         │   ║
║  │  • uploadProfilePicture(String) → Either<Failure, bool>        │   ║
║  │  • getUserProfile() → Either<Failure, UpdateEntity>            │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │            UpdateEntity (Immutable Model)                       │   ║
║  │                                                                 │   ║
║  │  • userId: String?                                             │   ║
║  │  • fullName: String?                                           │   ║
║  │  • email: String?                                              │   ║
║  │  • phoneNumber: String?                                        │   ║
║  │  • profilePicture: String?                                     │   ║
║  │  • updatedAt: DateTime?                                        │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
                │
                │ implements interface
                ↓
╔═══════════════════════════════════════════════════════════════════════════╗
║                         DATA LAYER (Data Sources)                         ║
║                                                                           ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │          UpdateRepository (Implementation)                      │   ║
║  │                                                                 │   ║
║  │  updateProfile(UpdateEntity)                                   │   ║
║  │    ├─→ Check NetworkInfo.isConnected                           │   ║
║  │    ├─→ if online: Try RemoteDatasource                         │   ║
║  │    │   └─→ Save to LocalDatasource                             │   ║
║  │    └─→ if offline: Try LocalDatasource                         │   ║
║  │        └─→ Return Either<Failure, bool>                        │   ║
║  │                                                                 │   ║
║  │  uploadProfilePicture(String imagePath)                        │   ║
║  │    ├─→ Check NetworkInfo.isConnected                           │   ║
║  │    ├─→ if online: Call RemoteDatasource.uploadProfilePicture() │   ║
║  │    └─→ if offline: Return LocalDatabaseFailure                 │   ║
║  │                                                                 │   ║
║  │  getUserProfile()                                              │   ║
║  │    ├─→ Check NetworkInfo.isConnected                           │   ║
║  │    ├─→ if online: Call RemoteDatasource.getUserProfile()       │   ║
║  │    │   └─→ Save to LocalDatasource                             │   ║
║  │    └─→ if offline: Return LocalDatabaseFailure                 │   ║
║  └──────┬─────────────────────────────────────────────────┬───────┘   ║
║         │                                                 │              ║
║         ↓                                                 ↓              ║
║  ┌────────────────────────────┐        ┌────────────────────────────┐  ║
║  │  IUpdateRemoteDatasource   │        │  IUpdateLocalDatasource    │  ║
║  │  (Remote/API)              │        │  (Hive Database)           │  ║
║  │                            │        │                            │  ║
║  │  • updateProfile()         │        │  • updateProfile()         │  ║
║  │  • uploadProfilePicture()  │        │  • getUserProfile()        │  ║
║  │  • getUserProfile()        │        │  • deleteProfile()         │  ║
║  └────────┬───────────────────┘        └────────────┬────────────────┘  ║
║           │                                        │                    ║
║           ↓                                        ↓                    ║
║  ┌────────────────────────────┐        ┌────────────────────────────┐  ║
║  │ UpdateRemoteDatasource     │        │ UpdateLocalDatasource      │  ║
║  │ Implementation             │        │ Implementation             │  ║
║  │                            │        │                            │  ║
║  │ Uses:                      │        │ Uses:                      │  ║
║  │ • ApiClient (Dio)          │        │ • HiveService              │  ║
║  │ • TokenService             │        │                            │  ║
║  │                            │        │ Handles:                   │  ║
║  │ Handles:                   │        │ • Save profiles to Hive    │  ║
║  │ • PUT /update-profile      │        │ • Retrieve from Hive       │  ║
║  │ • POST /upload-picture     │        │ • Delete from Hive         │  ║
║  │ • GET /profile             │        │                            │  ║
║  │ • JSON parsing             │        │ Models: UpdateHiveModel    │  ║
║  │ • Multipart form data      │        │                            │  ║
║  │ • DioException handling    │        │                            │  ║
║  │                            │        │                            │  ║
║  │ Models: UpdateApiModel     │        │                            │  ║
║  └────────┬───────────────────┘        └────────────┬────────────────┘  ║
║           │                                        │                    ║
║           ↓                                        ↓                    ║
║  ┌────────────────────────────┐        ┌────────────────────────────┐  ║
║  │  UpdateApiModel            │        │ UpdateHiveModel            │  ║
║  │  (JSON Serializable)       │        │ (Hive Persistent)          │  ║
║  │                            │        │                            │  ║
║  │  @JsonSerializable()       │        │ @HiveType(typeId: 1)       │  ║
║  │                            │        │ extends HiveObject         │  ║
║  │  • fromJson()              │        │                            │  ║
║  │  • toJson()                │        │ Fields with @HiveField     │  ║
║  │  • toEntity()              │        │                            │  ║
║  │  • fromEntity()            │        │ • fromEntity()             │  ║
║  │                            │        │ • toEntity()               │  ║
║  │ Fields: id, fullName,      │        │                            │  ║
║  │ email, phoneNumber,        │        │ Fields: userId, fullName,  │  ║
║  │ profilePicture, updatedAt  │        │ email, phoneNumber,        │  ║
║  │                            │        │ profilePicture, updatedAt  │  ║
║  └────────────────────────────┘        └────────────────────────────┘  ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
                                │
                                ↓
╔═══════════════════════════════════════════════════════════════════════════╗
║                    EXTERNAL RESOURCES                                     ║
║                                                                           ║
║  ┌──────────────────────────────────┐  ┌──────────────────────────────┐ ║
║  │     BACKEND API SERVER            │  │   LOCAL HIVE DATABASE        │ ║
║  │                                   │  │                              │ ║
║  │  PUT /api/auth/update-profile     │  │  • update_table              │ ║
║  │  POST /api/auth/upload-picture    │  │  • Stores UpdateHiveModel    │ ║
║  │  GET /api/auth/profile            │  │  • Type ID: 1                │ ║
║  │                                   │  │  • Offline cache             │ ║
║  │  Requires: Bearer token           │  │                              │ ║
║  │  Status: 200 (success)            │  │  Managed by: HiveService     │ ║
║  │           400/500 (error)         │  │                              │ ║
║  └──────────────────────────────────┘  └──────────────────────────────┘ ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝


## State Flow Diagram

                        ┌──────────────────┐
                        │   UpdateState    │
                        └────────┬─────────┘
                                 │
                  ┌──────────────┼──────────────┐
                  ↓              ↓              ↓
            ┌──────────┐   ┌──────────┐  ┌──────────────┐
            │ Status   │   │ Error    │  │ Profile      │
            │ Enum     │   │ Message  │  │ Entity       │
            └──────────┘   └──────────┘  └──────────────┘
                  │              │              │
      ┌───────────┼──────────────┼──────────────┼───────────┐
      │           │              │              │           │
      ↓           ↓              ↓              ↓           ↓
   Initial    Loading      UpdateSuccess    Error      ProfileLoaded


## Error Handling Flow

┌─────────────────────────────────┐
│    Exception/Error Occurs        │
└────────────┬────────────────────┘
             │
      ┌──────┴──────┐
      │             │
      ↓             ↓
   Online       Offline
      │             │
      ↓             ↓
  DioException  HiveError
      │             │
      ↓             ↓
ServerFailure  LocalDatabaseFailure
      │             │
      └──────┬──────┘
             ↓
      Either<Failure, T>
             │
      ┌──────┴──────┐
      │             │
      ↓             ↓
   Left()       Right()
 (Failure)     (Success)
      │             │
      ↓             ↓
Update State  Update State
(status:error) (status:success)


## Riverpod Dependency Injection

updateViewModelProvider
  └── references
      ├── updateProfileUsecaseProvider
      │   └── references updateRepositoryProvider
      │       ├── references updateLocalDatasourceProvider
      │       │   └── references hiveServiceProvider
      │       ├── references updateRemoteDatasourceProvider
      │       │   ├── references apiClientProvider
      │       │   └── references tokenServiceProvider
      │       └── references networkInfoProvider
      │
      ├── uploadProfilePictureUsecaseProvider
      │   └── references updateRepositoryProvider
      │
      └── getUserProfileUsecaseProvider
          └── references updateRepositoryProvider


## Data Transformation Pipeline

UpdateEntity
    ↓
UpdateProfileUsecase.call()
    ↓
IUpdateRepository.updateProfile()
    ├─→ Convert to UpdateApiModel
    │      ├─→ API Request (JSON)
    │      └─→ API Response (JSON)
    │      └─→ Convert to UpdateEntity
    │      └─→ Save to UpdateHiveModel
    │
    └─→ Return Either<Failure, bool>
           ├─→ Left(Failure) → State.error
           └─→ Right(true) → State.updateSuccess


## File Organization Summary

Update Feature/
├── domain/                          ← Business Rules
│   ├── entities/
│   │   └── update_entity.dart
│   ├── repository/
│   │   └── update_repository.dart
│   └── usecase/
│       └── update_profile_usecase.dart
│
├── data/                            ← Data Management
│   ├── datascources/
│   │   ├── update_datascource.dart
│   │   ├── remote/
│   │   │   └── update_remote_datasource.dart
│   │   └── local/
│   │       └── update_local_datasource.dart
│   ├── model/
│   │   ├── update_api_model.dart
│   │   ├── update_api_model.g.dart (generated)
│   │   ├── update_hive_model.dart
│   │   └── update_hive_model.g.dart (generated)
│   └── repositories/
│       └── update_repository.dart
│
└── presentation/                    ← UI & State
    ├── state/
    │   └── update_state.dart
    └── view_model/
        └── update_view_model.dart

```

---

## Color-Coded Layer Importance

🔵 **Domain Layer (CORE LOGIC)**
   - Independent of any framework
   - Highest abstraction level
   - Easiest to test

🟢 **Data Layer (DATA BRIDGE)**
   - Implements domain interfaces
   - Handles network & database
   - Error conversion layer

🟡 **Presentation Layer (UI)**
   - State management
   - User interaction
   - Display logic

---

## Key Design Patterns Used

✓ **Repository Pattern** - Data abstraction
✓ **Use Case Pattern** - Business logic encapsulation
✓ **Dependency Injection** - Loose coupling
✓ **Either Pattern** - Type-safe error handling
✓ **Strategy Pattern** - Online-first with offline fallback
✓ **Model Converter Pattern** - Transform between layers
✓ **Provider Pattern** - State management with Riverpod
