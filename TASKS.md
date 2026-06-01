# MotoLink — Task Checklist

> Tick boxes as you complete each task. One checkbox = one commit (see `PLAN.md` for the exact commit message).
> Push only after the entire phase ✅ is done and verified.

---

## Phase 0 — Firebase + LiveKit Setup
> 👤 Manual steps only. No code, no commits. Full details in PLAN.md Phase 0.

**Firebase:**
- [ ] Create Firebase project `motolink` (disable Analytics)
- [ ] Enable Google Sign-In in Firebase Auth
- [ ] Create Firestore database (`asia-south1`, production mode)
- [ ] Publish Firestore security rules (copy from PLAN.md Phase 0)
- [ ] Create Realtime Database (`asia-southeast1`, publish rules from PLAN.md)
- [ ] Enable Firebase Storage (`asia-south1`, apply rules)
- [ ] Register Android app → package `com.motolink.app` → get debug SHA-1 → download `google-services.json` → `android/app/`
- [ ] Create Firestore document `config/features` → `{ communitiesEnabled: false, marketplaceEnabled: false }`
- [ ] Create Firestore composite index: `rides` collection · `joinCode` ASC + `status` ASC
- [ ] Run `flutterfire configure` → confirm `lib/firebase_options.dart` generated

**LiveKit (Oracle Cloud VM):**
- [ ] Create Oracle Cloud account → provision Always Free ARM VM (Ubuntu 22.04)
- [ ] Open firewall ports: 22, 80, 443, 7880, 7881, 50000-60000/udp
- [ ] Install Docker + Docker Compose on VM
- [ ] Get free DuckDNS subdomain → point to VM IP
- [ ] Install Let's Encrypt SSL (`certbot`)
- [ ] Create `docker-compose.yml` + `livekit.yaml` (copy from PLAN.md)
- [ ] Create `token_server.js` + install deps + start with pm2
- [ ] `docker compose up -d`

**Archive + verify:**
- [ ] Archive existing UI: `mv lib/pages lib/_reference/pages && mv lib/widgets lib/_reference/widgets && mv lib/theme.dart lib/_reference/theme.dart`

**✅ Test Gate (all must pass):**
- [ ] `ls android/app/google-services.json` — file exists
- [ ] `ls lib/firebase_options.dart` — file exists
- [ ] Firebase Auth console shows Google Sign-In enabled
- [ ] `curl -X POST https://<domain>:3000/token -H "Content-Type: application/json" -d '{"uid":"test","rideId":"r1"}'` → returns `{"token":"eyJ..."}`
- [ ] `curl https://<domain>:7880` — responds (not connection refused)

---

## Phase 1 — Android Config + Dependencies
> ~2-3 hours · Push after all 5 commits done + `flutter build apk --debug` passes

- [ ] `android/app/build.gradle.kts` — rename to `com.motolink.app`, `minSdk = 23`, add google-services plugin
  - commit: `chore(android): rename package to com.motolink.app, set minSdk 23`
- [ ] `android/settings.gradle.kts` — add google-services classpath
  - commit: `chore(android): add google-services plugin for Firebase`
- [ ] `android/app/src/main/AndroidManifest.xml` — full replacement with all permissions + services
  - commit: `chore(android): add all required permissions and service declarations`
- [ ] Move `MainActivity.kt` to `com/motolink/app/`, update package name, delete old directory
  - commit: `chore(android): rename Kotlin package directory to com.motolink.app`
- [ ] `pubspec.yaml` — add all dependencies (Firebase, Riverpod, LiveKit, maps, utils)
  - commit: `chore(deps): add Firebase, Riverpod, LiveKit, maps, and utility packages`
- [ ] **Verify:** `flutter pub get` ✓ · `flutter analyze` ✓ · `flutter build apk --debug` ✓
- [ ] **PUSH** ⬆️

---

## Phase 2 — Auth + Profile + KMs + Badges
> ~2 days · Push after all commits done + manual sign-in test passes

- [ ] `lib/config/theme.dart` — copy from `_reference/theme.dart`
- [ ] `lib/config/constants.dart` — LiveKit server URL, token endpoint URL, limits
- [ ] `lib/config/badges.dart` — 5 badge definitions
  - commit: `feat(config): add theme, constants, and badge definitions`
- [ ] `lib/features/auth/domain/user_model.dart` — with `totalKm`, `badges[]`, `isProfileComplete`
  - commit: `feat(auth): add UserModel with totalKm, badges, and isProfileComplete`
- [ ] `lib/features/auth/data/auth_repository.dart` — Google Sign-In + `addRideDistance()`
  - commit: `feat(auth): add AuthRepository with Google Sign-In and addRideDistance`
- [ ] `lib/shared/providers/auth_provider.dart` — `authStateProvider`, `currentUserProvider`
  - commit: `feat(auth): add Riverpod providers for auth state and current user`
- [ ] `lib/shared/providers/features_provider.dart` — reads `config/features`
  - commit: `feat(config): add AppFeatures model and featuresProvider for feature flags`
- [ ] `lib/app/router.dart` — all routes + auth redirect + profile-complete redirect
  - commit: `feat(router): add GoRouter with auth and profile-complete redirect logic`
- [ ] `lib/app/app.dart` — `MaterialApp.router`
- [ ] `lib/main.dart` — Firebase init + ProviderScope
  - commit: `feat(app): wire up MaterialApp.router with Firebase init and ProviderScope`
- [ ] `lib/shared/widgets/navbar.dart` — port from `_reference`, tabs: Home/Guardian/Profile/Settings
- [ ] `lib/shared/widgets/loading_overlay.dart`
- [ ] `lib/shared/widgets/app_error_widget.dart`
- [ ] `lib/shared/widgets/coming_soon_page.dart` — needed here so navbar can import it
  - commit: `feat(app): add navbar, loading overlay, error widget, and coming soon page`
- [ ] `lib/features/auth/presentation/login_page.dart`
  - commit: `feat(auth): add login page with Google Sign-In button`
- [ ] `lib/features/auth/presentation/profile_setup_page.dart`
  - commit: `feat(auth): add profile setup page with bike and emergency contact form`
- [ ] `lib/features/profile/presentation/profile_page.dart` — KMs + badges grid + ride history
  - commit: `feat(profile): add profile page with KMs counter and badges grid`
- [ ] `lib/features/profile/presentation/edit_profile_page.dart`
  - commit: `feat(profile): add edit profile page`
- [ ] **Verify:** Sign in ✓ · Profile setup ✓ · Profile shows 0 KM ✓ · Kill/relaunch stays logged in ✓
- [ ] **PUSH** ⬆️

---

## Phase 3 — Standalone Ride (Day 1 Core)
> ~5-6 days · Push after 2-device physical test passes

- [ ] `lib/features/ride/domain/ride_model.dart` — `joinCode`, `communityId?`, `routePolyline[]`, `distanceKm`
- [ ] `lib/features/ride/domain/participant_model.dart`
  - commit: `feat(ride): add RideModel and ParticipantModel with join code support`
- [ ] `lib/features/chat/domain/message_model.dart`
  - commit: `feat(chat): add MessageModel for text-only in-ride chat`
- [ ] `lib/features/map/domain/rider_location_model.dart` + `poi_model.dart`
  - commit: `feat(map): add RiderLocationModel and PoiModel`
- [ ] `lib/features/ride/data/ride_repository.dart` — join code generation, full ride lifecycle
  - commit: `feat(ride): add RideRepository with join code generation and ride lifecycle`
- [ ] `lib/features/chat/data/chat_repository.dart`
  - commit: `feat(chat): add ChatRepository for ride messages`
- [ ] `lib/features/map/data/location_repository.dart` — Realtime DB live GPS
  - commit: `feat(map): add LocationRepository for Realtime DB live GPS`
- [ ] `lib/features/map/data/overpass_repository.dart` — gas stations + rest stops
  - commit: `feat(map): add OverpassRepository for gas stations and rest stops`
- [ ] `lib/features/voice/data/livekit_service.dart` — LiveKit RTC wrapper
  - commit: `feat(voice): add LiveKitService wrapper for PTT and open mic`
- [ ] `lib/shared/services/location_service.dart` — GPS stream + platform channel
  - commit: `feat(location): add LocationService with GPS stream and foreground service`
- [ ] `android/.../LocationForegroundService.kt` — foreground service notification
- [ ] `android/.../MainActivity.kt` — add MethodChannel `com.motolink.app/location_service`
  - commit: `feat(android): add LocationForegroundService and MainActivity MethodChannel`
- [ ] `lib/shared/providers/ride_provider.dart` + `location_provider.dart` + `chat_provider.dart` + `voice_provider.dart`
  - commit: `feat(ride): add Riverpod providers for ride, location, chat, and voice`
- [ ] `lib/features/ride/presentation/home_page.dart` — Start/Join buttons + recent rides
  - commit: `feat(ride): add home page with start and join ride buttons`
- [ ] `lib/features/ride/presentation/create_ride_page.dart` — map pin picker + join code display
  - commit: `feat(ride): add create ride page with map pin picker and join code display`
- [ ] `lib/features/ride/presentation/join_ride_page.dart` — OTP-style code input
  - commit: `feat(ride): add join ride page with OTP-style code input`
- [ ] `lib/features/ride/presentation/ride_lobby_page.dart` — waiting room + Start Ride
  - commit: `feat(ride): add ride lobby with real-time participant list`
- [ ] `lib/features/map/presentation/widgets/rider_marker.dart` — ported from `_reference/radar_page.dart`
- [ ] `lib/features/map/presentation/widgets/route_polyline.dart`
- [ ] `lib/features/map/presentation/widgets/poi_marker.dart`
  - commit: `feat(map): add rider marker ported from reference radar UI`
- [ ] `lib/features/voice/presentation/widgets/ptt_button.dart` — ported from `_reference/comms_page.dart`
- [ ] `lib/features/voice/presentation/widgets/speaker_indicator.dart`
- [ ] `lib/features/voice/presentation/voice_overlay.dart`
  - commit: `feat(voice): add PTT button ported from reference comms UI`
- [ ] `lib/features/chat/presentation/widgets/message_bubble.dart`
- [ ] `lib/features/chat/presentation/ride_chat_drawer.dart`
  - commit: `feat(chat): add message bubble and ride chat drawer`
- [ ] `lib/features/map/presentation/live_map_page.dart` — map + HUD + voice overlay + chat drawer
  - commit: `feat(map): add live map page with GPS HUD, voice overlay, and chat drawer`
- [ ] `lib/features/ride/presentation/ride_detail_page.dart`
- [ ] `lib/features/ride/presentation/widgets/ride_card.dart`
  - commit: `feat(ride): add completed ride detail page and ride card widget`
- [ ] **Verify (2 physical devices):**
  - [ ] Create ride → join by code → both in lobby
  - [ ] Start → both on live map → rider dots move
  - [ ] Lock screen → location continues (check Firebase Realtime DB)
  - [ ] Chat message received by other device
  - [ ] PTT voice heard by other device
  - [ ] End ride → KMs updated on profile
  - [ ] Badge awarded if threshold crossed
- [ ] **PUSH** ⬆️

---

## Phase 4 — Guardian Page
> ~1 day

- [ ] `lib/features/guardian/data/sensor_service.dart` — accelerometer + battery
  - commit: `feat(guardian): add SensorService for accelerometer and battery`
- [ ] `lib/features/guardian/presentation/widgets/sensor_card.dart`
  - commit: `feat(guardian): add sensor card widget`
- [ ] `lib/features/guardian/presentation/guardian_page.dart` — port from `_reference/guardian_page.dart`
  - commit: `feat(guardian): add guardian page with real sensors and SOS dial button`
- [ ] **Verify:** G-Force changes on phone movement ✓ · Battery shows real % ✓ · SOS opens dialer ✓
- [ ] **PUSH** ⬆️

---

## Phase 5 — Feature Flag Shell
> ~2 hours · `coming_soon_page.dart` already exists from Phase 2

- [ ] Update `navbar.dart` — add Communities + Marketplace tabs, wire to `featuresProvider`
- [ ] Update `router.dart` — add community + marketplace routes pointing to `ComingSoonPage`
  - commit: `feat(app): add communities and marketplace tabs with feature flag gating`

**✅ Test Gate:**
```bash
flutter analyze && flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```
- [ ] Communities tab → "Coming Soon" screen
- [ ] Marketplace tab → "Coming Soon" screen
- [ ] Firestore: set `communitiesEnabled = true` → restart app → feed screen shows (not coming soon) → set back to `false`
- [ ] **PUSH** ⬆️

---

## Phase 6 — Communities (locked)
> ~5-6 days · Unlock: set `communitiesEnabled: true` in `config/features`

- [ ] `lib/features/community/domain/community_model.dart`
- [ ] `lib/features/community/domain/member_model.dart` — `MemberRole` enum
  - commit: `feat(community): add CommunityModel, MemberModel, and MemberRole enum`
- [ ] `lib/features/community/data/community_repository.dart`
  - commit: `feat(community): add CommunityRepository with member management`
- [ ] `lib/features/community/presentation/community_feed_page.dart`
- [ ] `lib/features/community/presentation/widgets/community_card.dart`
  - commit: `feat(community): add community feed page with discover and my groups tabs`
- [ ] `lib/features/community/presentation/community_detail_page.dart`
  - commit: `feat(community): add community detail page with chat, rides, members tabs`
- [ ] `lib/features/community/presentation/create_community_page.dart`
  - commit: `feat(community): add create community page with photo and banner upload`
- [ ] `lib/features/chat/presentation/community_chat_page.dart`
  - commit: `feat(community): add community chat page extending existing chat infrastructure`
- [ ] `lib/features/community/presentation/widgets/member_tile.dart`
  - commit: `feat(community): add member tile with role badge and admin actions`
- [ ] Auto crash detection in `guardian_page.dart` + `SensorService`
  - commit: `feat(guardian): add auto crash detection with 30-second countdown dialog`
- [ ] **Verify:** Create community ✓ · Join from second device ✓ · Chat real-time ✓ · Promote member ✓ · Crash detection countdown ✓
- [ ] **PUSH** ⬆️

---

## Phase 7 — Marketplace + DMs (locked)
> ~5-6 days · Unlock: set `marketplaceEnabled: true` in `config/features`

- [ ] `lib/features/marketplace/domain/listing_model.dart` — category/condition/status enums
  - commit: `feat(marketplace): add ListingModel with category and condition enums`
- [ ] `lib/features/marketplace/data/marketplace_repository.dart`
  - commit: `feat(marketplace): add MarketplaceRepository with listing CRUD and report`
- [ ] `lib/features/marketplace/data/dm_repository.dart`
  - commit: `feat(marketplace): add DmRepository for buyer-seller conversations`
- [ ] `lib/features/marketplace/presentation/marketplace_page.dart`
- [ ] `lib/features/marketplace/presentation/widgets/listing_card.dart`
  - commit: `feat(marketplace): add marketplace page with category filters and search`
- [ ] `lib/features/marketplace/presentation/listing_detail_page.dart`
  - commit: `feat(marketplace): add listing detail page with photo carousel`
- [ ] `lib/features/marketplace/presentation/create_listing_page.dart`
  - commit: `feat(marketplace): add create listing page with fixed category enforcement`
- [ ] `lib/features/marketplace/presentation/conversations_page.dart`
- [ ] `lib/features/marketplace/presentation/dm_chat_page.dart`
  - commit: `feat(marketplace): add conversations page and DM chat page`
- [ ] **Verify:** Create listing ✓ · Category enforced ✓ · Message seller ✓ · Report listing ✓
- [ ] **PUSH** ⬆️

---

## Phase 8 — FCM + Update Check + Polish
> ~2-3 days

- [ ] `lib/shared/services/notification_service.dart` — channel setup + token save + foreground handler
  - commit: `feat(firebase): add FCM notification service with channel setup`
- [ ] FCM background handler in `main.dart`
  - commit: `fix(firebase): add FCM background message handler in main.dart`
- [ ] `lib/shared/services/update_service.dart` — GitHub version check + dialog
  - commit: `feat(app): add update check service with GitHub APK version comparison`
- [ ] `lib/features/settings/presentation/settings_page.dart` — port + connect real data
  - commit: `feat(settings): add settings page connected to real preferences and auth`
- [ ] Host update JSON on GitHub
- [ ] **Final verify:** `flutter analyze` zero warnings ✓ · `flutter build apk --release` ✓ · Full Day 1 flow on physical device ✓
- [ ] **PUSH** ⬆️

---

## Day 1 Launch Checklist

Before sharing the APK with your friends:

- [ ] Release keystore generated (`android/app/motolink.keystore`) — backed up safely
- [ ] `android/key.properties` exists and is in `.gitignore`
- [ ] Release SHA-1 added to Firebase Console → Android app fingerprints
- [ ] `flutter build apk --release` → `BUILD SUCCESSFUL`
- [ ] APK uploaded to GitHub Releases
- [ ] Update check JSON hosted on GitHub with correct version + download URL
- [ ] `config/features` confirmed: `communitiesEnabled: false`, `marketplaceEnabled: false`
- [ ] Firebase security rules deployed (not test mode — confirm in Firestore Rules tab)
- [ ] LiveKit server running on Oracle VM (`docker compose ps` shows `livekit` Up)
- [ ] Token server running (`pm2 status` shows `token_server` online)
- [ ] Tested on at least 2 physical Android devices end-to-end
- [ ] Guardian SOS dials correct emergency number
- [ ] KMs and badges working after a test ride
