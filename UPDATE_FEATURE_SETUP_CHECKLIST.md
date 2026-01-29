# Update Feature Implementation Checklist

## ✅ Already Completed

### Domain Layer
- [x] `update_entity.dart` - Created
- [x] `update_repository.dart` - Created (abstract interface)
- [x] `update_profile_usecase.dart` - Created (3 use cases)

### Data Layer
- [x] `update_api_model.dart` - Created with JSON serialization
- [x] `update_hive_model.dart` - Created with Hive annotations
- [x] `update_datascource.dart` - Created (abstract interfaces)
- [x] `update_remote_datasource.dart` - Created with API client
- [x] `update_local_datasource.dart` - Created with Hive operations
- [x] `update_repository.dart` - Created (implementation)

### Presentation Layer
- [x] `update_state.dart` - Created (Riverpod state)
- [x] `update_view_model.dart` - Created (Riverpod ViewModel)
- [x] `profile_clean_architecture.dart` - Created (example UI)

### Configuration
- [x] `api_endpoints.dart` - Updated with 3 new endpoints
- [x] `hive_table_constant.dart` - Updated with update type ID
- [x] Documentation files created

---

## 🔧 Your Action Items

### Priority 1: Essential Setup (Do this first!)

#### 1. Generate Build Files
```bash
cd /Users/prajesh/BSc_Computing/Mobile_Application_Development/Coursework/stockex
flutter pub run build_runner build --delete-conflicting-outputs
```
**Why:** Generates JSON serialization and Hive adapters
**Status:** [ ] Not done  [ ] Done

---

#### 2. Extend HiveService
**File:** `lib/core/services/hive/hive_service.dart`

Add these methods:
```dart
// Save update profile to local storage
Future<void> saveUpdateProfile(UpdateHiveModel profile) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  await box.put('profile_key', profile);
}

// Get update profile from local storage
Future<UpdateHiveModel?> getUpdateProfile(String userId) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  return box.get('profile_key');
}

// Delete update profile from local storage
Future<void> deleteUpdateProfile(String userId) async {
  final box = await Hive.openBox<UpdateHiveModel>('update_table');
  await box.delete('profile_key');
}
```
**Status:** [ ] Not done  [ ] Done

---

#### 3. Register Hive Adapter
**File:** `lib/main.dart` (in initializeApp or setup)

Add:
```dart
import 'package:stockex/features/update/data/model/update_hive_model.dart';

// In your setup function
Hive.registerAdapter(UpdateHiveModelAdapter());
```
**Status:** [ ] Not done  [ ] Done

---

#### 4. Import Generated Files
**File:** `lib/features/update/data/model/update_hive_model.dart`

Already has: `part 'update_hive_model.g.dart';`
**Status:** [ ] Already done  [ ] Verify

---

### Priority 2: Backend Integration

#### 5. Verify API Endpoints
Check your backend has these endpoints:
```
PUT  /api/auth/update-profile           (Update profile data)
POST /api/auth/upload-profile-picture   (Upload image file)
GET  /api/auth/profile                  (Get user profile)
```
**Status:** [ ] Not verified  [ ] Verified  [ ] Need to create

---

#### 6. API Request/Response Format
**Update Profile Request:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "1234567890"
}
```

**Upload Picture Request:** Multipart form-data with `profilePicture` field

**Get Profile Response:**
```json
{
  "success": true,
  "data": {
    "_id": "user123",
    "username": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "1234567890",
    "profilePicture": "url/to/image",
    "updatedAt": "2024-01-28T10:00:00Z"
  }
}
```
**Status:** [ ] Not verified  [ ] Verified

---

### Priority 3: UI Integration

#### 7. Update Your ProfileScreen (Optional)
Choose one:
- [ ] Use the new `profile_clean_architecture.dart` as reference
- [ ] Update existing `profile.dart` to use ViewModel

**Example implementation:**
```dart
// Add to top of ProfileScreen
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/update/presentation/view_model/update_view_model.dart';

// Change to ConsumerStatefulWidget
class ProfileScreen extends ConsumerStatefulWidget { ... }

// In initState, load profile
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(updateViewModelProvider.notifier).getUserProfile();
  });
}

// In build, use state
final updateState = ref.watch(updateViewModelProvider);
```
**Status:** [ ] Not done  [ ] Done

---

#### 8. Update EditProfileScreen (Optional)
Replace manual API calls with ViewModel:
```dart
// Before: direct API call
// After: use ViewModel
ref.read(updateViewModelProvider.notifier).updateProfile(
  fullName: nameController.text,
  email: emailController.text,
  phoneNumber: phoneController.text,
  profilePicture: null,
);
```
**Status:** [ ] Not done  [ ] Done

---

### Priority 4: Testing (Recommended)

#### 9. Create Unit Tests
**File to create:** `test/features/update/domain/usecase/update_profile_usecase_test.dart`

```dart
void main() {
  test('UpdateProfileUsecase should call repository with correct params', () async {
    // Test implementation
  });
}
```
**Status:** [ ] Not done  [ ] Done

---

#### 10. Create Widget Tests
**File to create:** `test/features/update/presentation/view_model/update_view_model_test.dart`

```dart
void main() {
  test('updateProfile should update state on success', () async {
    // Test implementation
  });
}
```
**Status:** [ ] Not done  [ ] Done

---

### Priority 5: Documentation

#### 11. Update Project README
Add section about Update Feature architecture
**Status:** [ ] Not done  [ ] Done

---

## 🔍 Verification Steps

After completing Priority 1:

### Test 1: Build Completes
```bash
flutter pub get
flutter clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk (or ios)
```
**Expected:** No errors
**Status:** [ ] Not tested  [ ] Passed  [ ] Failed

---

### Test 2: Load Profile Screen
1. Run app
2. Navigate to Profile
3. Check if profile data loads
**Expected:** Profile displays without errors
**Status:** [ ] Not tested  [ ] Passed  [ ] Failed

---

### Test 3: Upload Picture
1. Click camera icon
2. Take or select image
3. Observe state changes
**Expected:** Upload indicator, success/error message
**Status:** [ ] Not tested  [ ] Passed  [ ] Failed

---

### Test 4: Offline Mode
1. Turn off internet
2. Navigate to profile
3. Check fallback behavior
**Expected:** Loads from local cache if available
**Status:** [ ] Not tested  [ ] Passed  [ ] Failed

---

## 🎯 Quick Start (For Impatient Developers)

### Minimum Setup (15 minutes)
1. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
2. Add HiveService methods (3 methods)
3. Register adapter in main.dart
4. **DONE!** - Use in UI with ViewModel

### Full Setup (1 hour)
Complete all Priority 1-3 items

### Production Ready (2+ hours)
Complete all Priority 1-5 items

---

## 📋 File Locations for Reference

**Already created:**
- ✅ `lib/features/update/domain/entities/update_entity.dart`
- ✅ `lib/features/update/domain/repository/update_repository.dart`
- ✅ `lib/features/update/domain/usecase/update_profile_usecase.dart`
- ✅ `lib/features/update/data/model/update_api_model.dart`
- ✅ `lib/features/update/data/model/update_hive_model.dart`
- ✅ `lib/features/update/data/datascources/update_datascource.dart`
- ✅ `lib/features/update/data/datascources/remote/update_remote_datasource.dart`
- ✅ `lib/features/update/data/datascources/local/update_local_datasource.dart`
- ✅ `lib/features/update/data/repositories/update_repository.dart`
- ✅ `lib/features/update/presentation/state/update_state.dart`
- ✅ `lib/features/update/presentation/view_model/update_view_model.dart`
- ✅ `lib/screen/bottom_screen/profile_clean_architecture.dart`

**Need to create/modify:**
- [ ] `lib/core/services/hive/hive_service.dart` - Add 3 methods
- [ ] `lib/main.dart` - Register Hive adapter
- [ ] Backend API endpoints (on your server)

---

## 🆘 Common Issues & Solutions

### Issue: "UpdateHiveModelAdapter not found"
**Solution:** Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: "State not updating in UI"
**Solution:** Use `ConsumerStatefulWidget` and `ref.watch()`

### Issue: "API calls failing"
**Solution:** Verify endpoints in `api_endpoints.dart` match your backend

### Issue: "Hive box not found"
**Solution:** Make sure adapter is registered in `main.dart`

### Issue: "Build files not generating"
**Solution:** 
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✨ Summary

You now have a complete clean architecture implementation for the Update feature!

**What you get:**
- ✅ Scalable, maintainable architecture
- ✅ Offline support with Hive
- ✅ Proper error handling
- ✅ Type-safe with Riverpod
- ✅ Same pattern as your Auth feature
- ✅ Ready to extend

**What you need to do:**
1. Generate build files (1 command)
2. Add 3 methods to HiveService
3. Register Hive adapter
4. Update your UI (optional)

**That's it!** 🎉

---

## 📞 Need Help?

Refer to:
- `CLEAN_ARCHITECTURE_GUIDE.md` - Detailed explanation
- `UPDATE_FEATURE_QUICK_REFERENCE.md` - Quick tips
- `lib/features/auth/` - Your existing implementation
- `lib/screen/bottom_screen/profile_clean_architecture.dart` - Example UI

Happy coding! 💪
