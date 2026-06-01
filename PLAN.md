# MotoLink — Master Plan

> Personal project. Free tiers only. Android only.

---

## App Overview

MotoLink is a motorcycle group riding app. Riders start a ride session, share a code with friends, and get live maps, GPS tracking, voice communication, and in-ride chat — all for free.

**Free tier fit:**
| Service | Limit | Our Usage |
|---|---|---|
| Firebase Auth | 50K MAU/month | Fine |
| Firestore Reads | 50K/day | Fine for small group |
| Firestore Writes | 20K/day | Fine |
| Realtime DB | 100 connections | Fine |
| Firebase Storage | 5 GB / 1 GB download/day | Fine |
| FCM | Unlimited | ✅ |
| LiveKit Voice | Unlimited (self-hosted Oracle VM) | ✅ |
| OpenStreetMap | Unlimited | ✅ |
| Overpass API | Unlimited | ✅ |

---

## Tech Stack

| Layer | Choice |
|---|---|
| Platform | Android only |
| Language | Dart / Flutter |
| Auth | Firebase Auth + Google Sign-In |
| Database | Firestore (structured) + Realtime DB (live GPS) |
| Storage | Firebase Storage |
| Notifications | FCM |
| State | Riverpod |
| Navigation | GoRouter |
| Maps | flutter_map + OpenStreetMap |
| GPS | geolocator |
| Voice | LiveKit (self-hosted, Oracle Cloud Always Free VM) |
| Distribution | GitHub Releases (APK) |
| OTA | Shorebird free hobby tier |

---

## Day 1 vs Locked Features

### ✅ Day 1 (available at launch)
- Google Sign-In + profile (bio, bike make/model/year, emergency contact)
- Lifetime KMs counter + milestone badges on profile
- Start Ride (6-digit join code + WhatsApp/SMS share fallback)
- Live map with GPS tracking + route polyline
- Rider markers (name + dot + speed + heading arrow)
- POI markers (gas stations + rest stops via Overpass API)
- Voice channel (LiveKit PTT + open mic)
- In-ride text chat
- Guardian (real G-Force, speed, battery + manual SOS dial)

### 🔒 Locked (flip switch in Firebase Console — no APK needed)
- Communities (create/join, chat, scheduled rides, member roles)
- Auto crash detection (G-Force spike → 30s countdown → auto-dial SOS)
- Marketplace (bike-only buy/sell + in-app DM)

**Feature flag location:** Firestore → `config/features`
```json
{ "communitiesEnabled": false, "marketplaceEnabled": false }
```
Set to `true` to unlock. All devices update instantly.

---

## Badges System

| Badge ID | Name | KMs | Tier | Icon |
|---|---|---|---|---|
| `first_ride` | First Ride | 1 | Starter | 🏁 |
| `road_warrior` | Road Warrior | 500 | Bronze | 🛣️ |
| `highway_ghost` | Highway Ghost | 1,000 | Silver | ⚡ |
| `iron_rider` | Iron Rider | 5,000 | Gold | 🛡️ |
| `legend` | Legend | 10,000 | Platinum | ⭐ |

Awarded automatically when `totalKm` crosses a threshold after any ride ends.

---

## Marketplace Categories

**Bikes** · **Riding Gear** (helmets, jackets, gloves, boots, rain gear) · **Parts & Accessories** · **Tyres & Wheels** · **Luggage** (saddlebags, tank bags, panniers) · **Electronics** (GPS, dash cams, intercoms)

Rules: category is a fixed dropdown (no free text), no services allowed, Report button on every listing.

---

## Database Schema

```
Firestore:
├── config/features              { communitiesEnabled, marketplaceEnabled }
├── users/{uid}                  { displayName, email, photoUrl, bio, bike{make,model,year},
│                                  emergencyContact{name,phone,relation}, communityIds[],
│                                  totalKm, badges[], fcmToken, createdAt, updatedAt }
├── rides/{rideId}               { title, communityId(null=standalone), joinCode, createdBy,
│                                  status(waiting|active|completed), maxRiders, departureLocation,
│                                  departureTime, waypoints[], routePolyline[], distanceKm, createdAt }
│   ├── participants/{uid}       { status(waiting|active|left), displayName, photoUrl, joinedAt }
│   └── messages/{messageId}    { senderId, senderName, content, timestamp }
├── communities/{communityId}    { name, description, photoUrl, bannerUrl, location, bikeType,
│                                  createdBy, memberCount, createdAt }
│   ├── members/{uid}           { role(admin|moderator|member), displayName, photoUrl, joinedAt }
│   ├── messages/{messageId}    { senderId, senderName, type, content, timestamp }
│   └── rides/{rideId}          { (same as rides collection but community-scoped) }
├── marketplace/{listingId}     { sellerId, title, description, price, negotiable, condition,
│                                  category, subCategory, photos[], location, status, reportCount,
│                                  createdAt, updatedAt }
└── conversations/{uid1_uid2}   { participants[], listingId, lastMessage, lastMessageAt }
    └── messages/{messageId}    { senderId, content, timestamp }

Realtime DB:
└── rides/{rideId}/{uid}        { lat, lng, speed, heading, timestamp }
```

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app.dart                     MaterialApp.router
│   └── router.dart                  GoRouter — all routes + auth redirect
├── config/
│   ├── theme.dart                   AppTheme (black + neon green #39FF14 + orange #FF5F1F)
│   ├── constants.dart               LiveKit server URL, token endpoint, limits
│   └── badges.dart                  Badge definitions + tiers
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/user_model.dart
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       └── profile_setup_page.dart
│   ├── ride/
│   │   ├── data/ride_repository.dart
│   │   ├── domain/ ride_model.dart, participant_model.dart
│   │   └── presentation/
│   │       ├── home_page.dart           Start/Join buttons + recent rides
│   │       ├── create_ride_page.dart    Title + map pin + time + waypoints
│   │       ├── join_ride_page.dart      6-digit OTP-style code input
│   │       ├── ride_lobby_page.dart     Waiting room + live participant list
│   │       ├── ride_detail_page.dart    Completed ride summary
│   │       └── widgets/ride_card.dart
│   ├── map/
│   │   ├── data/ location_repository.dart, overpass_repository.dart
│   │   ├── domain/ rider_location_model.dart, poi_model.dart
│   │   └── presentation/
│   │       ├── live_map_page.dart       Map + voice overlay + chat drawer
│   │       └── widgets/
│   │           ├── rider_marker.dart    Name label + dot + heading arrow
│   │           ├── poi_marker.dart      Gas station / rest stop icons
│   │           └── route_polyline.dart
│   ├── voice/
│   │   ├── data/livekit_service.dart    LiveKit RTC wrapper
│   │   └── presentation/
│   │       ├── voice_overlay.dart       Floating over live map
│   │       └── widgets/
│   │           ├── ptt_button.dart      Ported from _reference/comms_page.dart
│   │           └── speaker_indicator.dart
│   ├── chat/
│   │   ├── data/chat_repository.dart
│   │   ├── domain/message_model.dart
│   │   └── presentation/
│   │       ├── ride_chat_drawer.dart    Slide-in during ride
│   │       ├── community_chat_page.dart Phase 6
│   │       └── widgets/message_bubble.dart
│   ├── guardian/
│   │   ├── data/sensor_service.dart     Accelerometer + battery
│   │   └── presentation/
│   │       ├── guardian_page.dart
│   │       └── widgets/sensor_card.dart
│   ├── profile/
│   │   └── presentation/
│   │       ├── profile_page.dart        KMs + badges + ride history
│   │       └── edit_profile_page.dart
│   ├── settings/                        Phase 8
│   │   └── presentation/
│   │       └── settings_page.dart
│   ├── community/                       Phase 6 — locked
│   │   ├── data/community_repository.dart
│   │   ├── domain/ community_model.dart, member_model.dart
│   │   └── presentation/ (feed, detail, create, member_tile)
│   └── marketplace/                     Phase 7 — locked
│       ├── data/ marketplace_repository.dart, dm_repository.dart
│       ├── domain/ listing_model.dart
│       └── presentation/ (marketplace, listing_detail, create_listing, dm_chat)
├── shared/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── features_provider.dart       Reads config/features
│   │   ├── ride_provider.dart
│   │   ├── location_provider.dart
│   │   ├── chat_provider.dart
│   │   └── voice_provider.dart          LiveKit room state + speaking indicators
│   ├── services/
│   │   ├── location_service.dart        GPS + foreground service
│   │   ├── notification_service.dart    FCM setup
│   │   └── update_service.dart          GitHub APK version check
│   └── widgets/
│       ├── navbar.dart
│       ├── loading_overlay.dart
│       ├── app_error_widget.dart
│       └── coming_soon_page.dart        Shown for locked features
└── _reference/                          Archived original UI (visual reference only)
    ├── pages/ (radar, comms, guardian, settings)
    ├── widgets/ (navbar)
    └── theme.dart
```

---

## Route Table

| Route | Path | Widget |
|---|---|---|
| `login` | `/login` | `LoginPage` |
| `profileSetup` | `/profile-setup` | `ProfileSetupPage` |
| `home` | `/` | `HomePage` |
| `createRide` | `/ride/create` | `CreateRidePage` |
| `joinRide` | `/ride/join` | `JoinRidePage` |
| `rideLobby` | `/ride/:rideId/lobby` | `RideLobbyPage` |
| `liveMap` | `/ride/:rideId/map` | `LiveMapPage` |
| `rideDetail` | `/ride/:rideId` | `RideDetailPage` |
| `profile` | `/profile` | `ProfilePage` |
| `editProfile` | `/profile/edit` | `EditProfilePage` |
| `guardian` | `/guardian` | `GuardianPage` |
| `settings` | `/settings` | `SettingsPage` |
| `communities` | `/communities` | `CommunityFeedPage` OR `ComingSoonPage` |
| `communityDetail` | `/communities/:communityId` | `CommunityDetailPage` |
| `createCommunity` | `/communities/create` | `CreateCommunityPage` |
| `marketplace` | `/marketplace` | `MarketplacePage` OR `ComingSoonPage` |
| `listingDetail` | `/marketplace/:listingId` | `ListingDetailPage` |
| `createListing` | `/marketplace/create` | `CreateListingPage` |
| `conversations` | `/conversations` | `ConversationsPage` |
| `dmChat` | `/conversations/:conversationId` | `DmChatPage` |

---

# Phase Plan

> **How this plan works:**
> - 🤖 = AI does this (Claude writes/edits the files)
> - 👤 = Human does this (you run commands, use consoles, test on device)
> - Each phase ends with a **Test Gate** — all checkboxes must pass before moving to the next phase

---

## Phase 0 — Firebase + LiveKit Setup
> ~3-4 hours · All human tasks · No git commit

👤 **Firebase Console (`console.firebase.google.com`):**
1. Create project `motolink` — disable Analytics
2. Authentication → Google Sign-In → Enable
3. Firestore → Create → `asia-south1` → Production mode → apply security rules
4. Realtime Database → Create → `asia-southeast1` → apply rules
5. Storage → Create → `asia-south1` → apply rules
6. Add Android app → package `com.motolink.app` → get SHA-1 via `./gradlew signingReport` → download `google-services.json` → place at `android/app/google-services.json`
7. Create Firestore document `config/features`: `{ communitiesEnabled: false, marketplaceEnabled: false }`

👤 **Firestore Security Rules** (Firestore → Rules tab — paste and publish):
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Feature flags — read by all, write by none
    match /config/{doc} {
      allow read: if true;
      allow write: if false;
    }
    // Users — read/write own doc only
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    // Rides — authenticated users can read/write
    match /rides/{rideId} {
      allow read, write: if request.auth != null;
      match /participants/{uid} { allow read, write: if request.auth != null; }
      match /messages/{msgId} { allow read, write: if request.auth != null; }
    }
    // Communities — authenticated users can read; write requires membership check
    match /communities/{communityId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        get(/databases/$(database)/documents/communities/$(communityId)/members/$(request.auth.uid)).data.role == 'admin';
      match /members/{uid} { allow read, write: if request.auth != null; }
      match /messages/{msgId} { allow read, write: if request.auth != null; }
      match /rides/{rideId} { allow read, write: if request.auth != null; }
    }
    // Marketplace — authenticated users can read; write own listings only
    match /marketplace/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.sellerId;
    }
    // DM conversations — participants only
    match /conversations/{convId} {
      allow read, write: if request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      match /messages/{msgId} { allow read, write: if request.auth != null; }
    }
  }
}
```

👤 **Realtime Database Rules** (Realtime DB → Rules tab):
```json
{
  "rules": {
    "rides": {
      "$rideId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

👤 **Firestore Composite Index** (needed for join code query in Phase 3):
- Firestore Console → Indexes → Composite → Add index
- Collection: `rides` · Field 1: `joinCode` (Ascending) · Field 2: `status` (Ascending)
- (Alternatively, Firestore will prompt you with a direct link the first time the query runs)

👤 **FlutterFire CLI:**
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-project-id>
# Select Android only → generates lib/firebase_options.dart
```

👤 **LiveKit Server (Oracle Cloud Always Free ARM VM):**
8. Create Oracle Cloud account → Compute → Create Instance → select `VM.Standard.A1.Flex` (ARM, Always Free) → Ubuntu 22.04 → 1 OCPU / 1 GB RAM
9. Open firewall ports in Oracle Security List: `22` (SSH) · `80` (HTTP) · `443` (HTTPS) · `7880` (LiveKit WS) · `7881` (LiveKit RTC) · `50000-60000/udp` (WebRTC media)
10. SSH into VM, install Docker + Docker Compose:
    ```bash
    curl -fsSL https://get.docker.com | sh
    sudo apt install docker-compose-plugin -y
    ```
11. Get a free domain — DuckDNS (`duckdns.org`) → create subdomain e.g. `motolink.duckdns.org` → point to VM public IP
12. Install Let's Encrypt SSL:
    ```bash
    sudo apt install certbot -y
    sudo certbot certonly --standalone -d motolink.duckdns.org
    ```
13. Create `docker-compose.yml` on the VM:
    ```yaml
    version: "3"
    services:
      livekit:
        image: livekit/livekit-server:latest
        ports:
          - "7880:7880"
          - "7881:7881/tcp"
          - "50000-60000:50000-60000/udp"
        volumes:
          - ./livekit.yaml:/livekit.yaml
          - /etc/letsencrypt:/etc/letsencrypt:ro
        command: --config /livekit.yaml
    ```
14. Create `livekit.yaml` config:
    ```yaml
    port: 7880
    rtc:
      tcp_port: 7881
      udp_port: 7882
      use_external_ip: true
    keys:
      motolink: <generate a random 32-char secret>
    turn:
      enabled: true
      domain: motolink.duckdns.org
      tls_port: 5349
    ```
15. Create token server `token_server.js` on same VM:
    ```js
    const express = require('express')
    const { AccessToken } = require('livekit-server-sdk')
    const app = express()
    app.use(express.json())
    const API_KEY = 'motolink'
    const API_SECRET = '<same secret as livekit.yaml>'
    app.post('/token', async (req, res) => {
      const { uid, rideId } = req.body
      if (!uid || !rideId) return res.status(400).json({ error: 'missing fields' })
      const token = new AccessToken(API_KEY, API_SECRET, { identity: uid })
      token.addGrant({ roomJoin: true, room: rideId, canPublish: true, canSubscribe: true })
      res.json({ token: await token.toJwt() })
    })
    app.listen(3000, () => console.log('Token server on :3000'))
    ```
    ```bash
    npm install express livekit-server-sdk
    npm install -g pm2 && pm2 start token_server.js
    ```
16. Start LiveKit: `docker compose up -d`

👤 **Archive existing UI:**
```bash
mkdir -p lib/_reference
mv lib/pages lib/_reference/pages
mv lib/widgets lib/_reference/widgets
mv lib/theme.dart lib/_reference/theme.dart
```

### ✅ Test Gate — Phase 0
```bash
# Verify Firebase files exist
ls android/app/google-services.json
# Expected: file listed (no "No such file" error)

ls lib/firebase_options.dart
# Expected: file listed

# Verify LiveKit token server
curl -s -X POST https://motolink.duckdns.org:3000/token \
  -H "Content-Type: application/json" \
  -d '{"uid":"test","rideId":"test-ride-1"}'
# Expected: {"token":"eyJ..."} — a JWT string starting with eyJ

# Verify LiveKit server reachable
curl -s -o /dev/null -w "%{http_code}" https://motolink.duckdns.org:7880
# Expected: any response code except "connection refused"
```
- [ ] `android/app/google-services.json` exists
- [ ] `lib/firebase_options.dart` exists
- [ ] Firebase Auth console shows Google Sign-In enabled (green checkmark)
- [ ] Token endpoint returns a JWT (`{"token":"eyJ..."}`)
- [ ] LiveKit server reachable on port 7880

**All 5 must pass before Phase 1.**

---

## Phase 1 — Android Config + Dependencies
> ~2-3 hours

🤖 **AI tasks (in order):**
1. Modify `android/app/build.gradle.kts` — set `applicationId = "com.motolink.app"`, `namespace = "com.motolink.app"`, `minSdk = 23`, add `id("com.google.gms.google-services")` plugin
2. Modify `android/settings.gradle.kts` — add `id("com.google.gms.google-services") version "4.4.2" apply false`
3. Replace `android/app/src/main/AndroidManifest.xml` — all permissions + services
4. Move `MainActivity.kt` to `com/motolink/app/` package, update package declaration
5. Replace `pubspec.yaml` with full dependency list

**Permissions:** `INTERNET` · `ACCESS_NETWORK_STATE` · `ACCESS_FINE_LOCATION` · `ACCESS_COARSE_LOCATION` · `ACCESS_BACKGROUND_LOCATION` · `FOREGROUND_SERVICE` · `FOREGROUND_SERVICE_LOCATION` · `CAMERA` · `READ_MEDIA_IMAGES` · `READ_EXTERNAL_STORAGE(maxSdk=32)` · `POST_NOTIFICATIONS` · `WAKE_LOCK` · `RECORD_AUDIO` · `MODIFY_AUDIO_SETTINGS` · `BLUETOOTH(maxSdk=30)` · `VIBRATE`

**pubspec.yaml key dependencies:**
```
firebase_core, firebase_auth, cloud_firestore, firebase_database,
firebase_storage, firebase_messaging, google_sign_in,
flutter_riverpod, go_router,
flutter_map, geolocator, latlong2, flutter_map_cancellable_tile_provider,
livekit_client,
google_fonts, flutter_animate, cupertino_icons, cached_network_image, image_picker,
http, intl, uuid, shared_preferences, permission_handler,
sensors_plus, battery_plus, url_launcher, package_info_plus
```

### ✅ Test Gate — Phase 1
```bash
flutter pub get
# Expected: exits cleanly, pubspec.lock updated, no resolution errors

flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL
# APK at: build/app/outputs/flutter-apk/app-debug.apk
```
- [ ] `flutter pub get` — no errors
- [ ] `flutter analyze` — `No issues found!`
- [ ] `flutter build apk --debug` — `BUILD SUCCESSFUL`
- [ ] APK file exists: `ls build/app/outputs/flutter-apk/app-debug.apk`

**All 4 must pass before Phase 2.**

---

## Phase 2 — Auth + Profile + KMs + Badges
> ~2 days

🤖 **AI tasks (in order):**
1. `lib/config/theme.dart` — exact copy of `_reference/theme.dart`
2. `lib/config/constants.dart` — LiveKit server URL, token endpoint URL, limits, OSM tile URL
3. `lib/config/badges.dart` — 5 badge definitions with id/name/kmThreshold/tier/icon
4. `lib/features/auth/domain/user_model.dart` — includes `totalKm`, `badges[]`, `isProfileComplete` getter
5. `lib/features/auth/data/auth_repository.dart` — Google Sign-In, Firestore user CRUD, `addRideDistance()` (increment + badge check)
6. `lib/shared/providers/auth_provider.dart` — `authStateProvider`, `currentUserProvider`
7. `lib/shared/providers/features_provider.dart` — reads `config/features`
8. `lib/app/router.dart` — all routes + auth redirect + profile-complete redirect
9. `lib/app/app.dart` — `MaterialApp.router`
10. `lib/main.dart` — Firebase init + ProviderScope
11. `lib/shared/widgets/navbar.dart` — port exact CustomNavbar, tabs: Home/Guardian/Profile/Settings
12. `lib/shared/widgets/loading_overlay.dart`
13. `lib/shared/widgets/app_error_widget.dart`
14. `lib/shared/widgets/coming_soon_page.dart` — lock icon + feature name + description (navbar needs this even before Phase 5)
15. `lib/features/auth/presentation/login_page.dart`
16. `lib/features/auth/presentation/profile_setup_page.dart`
17. `lib/features/profile/presentation/profile_page.dart` — KMs counter + badges grid + ride history
18. `lib/features/profile/presentation/edit_profile_page.dart`

**Key method — `addRideDistance(uid, distanceKm)`:**
- `FieldValue.increment(distanceKm)` on `users/{uid}.totalKm`
- Read new total → compare against badge thresholds → `arrayUnion` new badge IDs

### ✅ Test Gate — Phase 2
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
# Expected: Performing Streamed Install / Success
```

👤 **On device:**
- [ ] App opens → Google Sign-In screen (black background, neon green button)
- [ ] Tap Sign In → Google account picker → select account → profile setup form appears
- [ ] Fill name, bio, bike (make/model/year), emergency contact → tap Save → home screen
- [ ] Kill app completely → reopen → goes straight to home (still signed in, no login screen)
- [ ] Profile tab → shows `0 KM`, no badges yet
- [ ] Tap Edit Profile → form pre-filled with saved data → make a change → save → change persists

**All 6 device checks must pass before Phase 3.**

---

## Phase 3 — Standalone Ride (Day 1 Core)
> ~5-6 days

🤖 **AI tasks (in order):**
1. `lib/features/ride/domain/ride_model.dart` — includes `joinCode`, `communityId?`, `routePolyline[]`, `distanceKm`
2. `lib/features/ride/domain/participant_model.dart`
3. `lib/features/chat/domain/message_model.dart`
4. `lib/features/map/domain/rider_location_model.dart` + `poi_model.dart`
5. `lib/features/ride/data/ride_repository.dart` — join code generation, create/join/start/end ride
6. `lib/features/chat/data/chat_repository.dart` — `watchRideMessages`, `sendRideMessage`
7. `lib/features/map/data/location_repository.dart` — Realtime DB read/write
8. `lib/features/map/data/overpass_repository.dart` — gas stations + rest stops query
9. `lib/features/voice/data/livekit_service.dart` — connect to room, publish/unpublish audio track, expose speaking events
10. `lib/shared/services/location_service.dart` — GPS stream + foreground service platform channel
11. `android/app/src/main/kotlin/com/motolink/app/LocationForegroundService.kt` — `START_STICKY`, notification "Tracking your ride..."
12. Update `MainActivity.kt` — add MethodChannel `com.motolink.app/location_service`
13. `lib/shared/providers/ride_provider.dart` + `location_provider.dart` + `chat_provider.dart` + `voice_provider.dart` — voice_provider wraps LiveKit room state (connection status, speaking participants, mute toggle) for the UI
14. `lib/features/ride/presentation/home_page.dart` — Start/Join buttons + recent rides
15. `lib/features/ride/presentation/create_ride_page.dart` — form + map pin picker + join code display
16. `lib/features/ride/presentation/join_ride_page.dart` — OTP-style code input
17. `lib/features/ride/presentation/ride_lobby_page.dart` — waiting room + Start Ride button
18. `lib/features/map/presentation/widgets/rider_marker.dart` — ported from `_reference/radar_page.dart`
19. `lib/features/map/presentation/widgets/route_polyline.dart`
20. `lib/features/map/presentation/widgets/poi_marker.dart`
21. `lib/features/voice/presentation/widgets/ptt_button.dart` — ported from `_reference/comms_page.dart`
22. `lib/features/voice/presentation/widgets/speaker_indicator.dart`
23. `lib/features/voice/presentation/voice_overlay.dart`
24. `lib/features/chat/presentation/widgets/message_bubble.dart`
25. `lib/features/chat/presentation/ride_chat_drawer.dart`
26. `lib/features/map/presentation/live_map_page.dart` — map + HUD + voice overlay + chat drawer
27. `lib/features/ride/presentation/ride_detail_page.dart` — completed ride summary
28. `lib/features/ride/presentation/widgets/ride_card.dart`

**Ride join code:** 6-char alphanumeric (e.g. `MR4829`). Firestore query `where('joinCode', '==', code).where('status', '==', 'waiting')`. Share text: *"Join my MotoLink ride! Code: MR4829"*.

### ✅ Test Gate — Phase 3
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

👤 **2 physical devices required — both with APK installed and signed in:**

**Ride creation & joining:**
- [ ] Device A: Home → "Start Ride" → enter title + drop map pin → 6-char code appears (e.g. `MR4829`)
- [ ] Device B: Home → "Join Ride" → enter code `MR4829` → enters lobby
- [ ] Both devices: lobby screen shows both participant names

**Live map:**
- [ ] Device A: tap "Start Ride" → both devices navigate to live map automatically
- [ ] Both devices: map shows 2 named rider dots
- [ ] Walk 10+ metres → both dots move within ~5 seconds
- [ ] Route polyline draws behind you as you move
- [ ] At least 1 gas station or rest stop POI visible (test outdoors with GPS)

**Voice:**
- [ ] PTT: Device A holds PTT → indicator turns orange → speaks → Device B hears audio clearly
- [ ] PTT: release → audio cuts off on Device B
- [ ] Open mic: toggle on Device A → speak → Device B hears continuously without holding

**Chat:**
- [ ] Device A sends "test message" → appears on Device B within 3 seconds
- [ ] Device B replies → appears on Device A

**Background GPS:**
- [ ] Lock Device A screen (screen off) → Device A's dot still updates on Device B's map within 15 seconds
- [ ] "Tracking your ride..." notification visible in Device A notification bar

**End ride:**
- [ ] Device A taps "End Ride" → ride summary appears showing non-zero distance
- [ ] Device A Profile tab → KMs updated to match ride distance
- [ ] First ride ever: `First Ride` badge appears on profile

**All checkboxes must pass before Phase 4.**

---

## Phase 4 — Guardian Page
> ~1 day

🤖 **AI tasks (in order):**
1. `lib/features/guardian/data/sensor_service.dart` — `watchGForce()` (accelerometer magnitude) + `watchBatteryLevel()`
2. `lib/features/guardian/presentation/widgets/sensor_card.dart`
3. `lib/features/guardian/presentation/guardian_page.dart` — port exact UI from `_reference/guardian_page.dart`

**Connections:** G-Force → `sensors_plus` stream · Speed → `currentPositionProvider` · Battery → `battery_plus` · SOS → `url_launcher` dials `tel:+91{emergencyPhone}`

### ✅ Test Gate — Phase 4
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

👤 **On device:**
- [ ] Guardian tab → page loads without error
- [ ] G-Force card shows a non-zero reading (e.g. `1.02`) — value changes visibly when you shake or tilt phone
- [ ] Speed shows `0.0 km/h` at rest (outdoors: changes when walking)
- [ ] Battery % matches what Android shows in status bar (within ±2%)
- [ ] SOS button → phone dialer opens with emergency contact number pre-filled
- [ ] Dialer shows the number — does NOT auto-call (you must press dial manually)

**All 6 must pass before Phase 5.**

---

## Phase 5 — Feature Flag Shell
> ~2 hours

🤖 **AI tasks (in order):**
1. Update `lib/shared/widgets/navbar.dart` — add Communities + Marketplace tabs, check `featuresProvider`, show `ComingSoonPage` if flag is false (`coming_soon_page.dart` already created in Phase 2)
2. Update `lib/app/router.dart` — add community + marketplace routes (pointing to `ComingSoonPage` until Phase 6/7)

### ✅ Test Gate — Phase 5
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

👤 **On device (flags OFF — default state):**
- [ ] Navbar shows Communities tab → tap → "Coming Soon" screen appears (lock icon + text)
- [ ] Navbar shows Marketplace tab → tap → "Coming Soon" screen appears

👤 **Flag toggle smoke test:**
- [ ] Firestore Console: set `config/features.communitiesEnabled = true`
- [ ] Restart app → Communities tab shows a list/feed screen (not coming soon)
- [ ] Firestore Console: set `communitiesEnabled` back to `false`
- [ ] Restart app → Communities tab shows coming soon again

**All 4 must pass before Phase 6.**

---

## Phase 6 — Communities
> ~5-6 days

👤 **Human prerequisite — do this before AI starts coding:**
- Firestore Console: set `config/features.communitiesEnabled = true`

🤖 **AI tasks (in order):**
1. `lib/features/community/domain/community_model.dart` + `member_model.dart` (enum `MemberRole { admin, moderator, member }`)
2. `lib/features/community/data/community_repository.dart` — watch all/my communities, create/join/leave, manage members, update roles
3. `lib/features/community/presentation/community_feed_page.dart` — search + "Discover"/"My Groups" tabs + 2-col GridView + FAB
4. `lib/features/community/presentation/widgets/community_card.dart`
5. `lib/features/community/presentation/community_detail_page.dart` — SliverAppBar + TabBar (Chat | Rides | Members)
6. `lib/features/community/presentation/create_community_page.dart` — name, description, location, bikeType dropdown, photo/banner
7. `lib/features/chat/presentation/community_chat_page.dart` — extends existing chat infrastructure
8. `lib/features/community/presentation/widgets/member_tile.dart` — avatar + role badge + admin/mod actions
9. Add auto crash detection to `lib/features/guardian/presentation/guardian_page.dart`:
   - `watchGForceSpikes()` (G > 4g) → show 30s countdown dialog → auto-dial if not cancelled
   - Settings toggle for sensitivity

### ✅ Test Gate — Phase 6
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

👤 **2 devices — communities flag ON:**
- [ ] Communities tab shows feed (Discover / My Groups tabs visible)
- [ ] Device A: tap `+` FAB → Create Community → fill name/description/location/bike type → save
- [ ] Community card appears in Discover tab on both devices
- [ ] Device B: tap community → Join → community appears in Device B's "My Groups"
- [ ] Members tab: Device A shows as Admin, Device B shows as Member
- [ ] Chat tab: Device A sends a message → Device B receives it in real time (under 3 seconds)
- [ ] Rides tab: Device A schedules a ride → ride card appears for Device B
- [ ] Device B RSVPs to the ride → RSVP count updates

👤 **Auto crash detection:**
- [ ] Guardian page: sharply jolt/shake phone several times → 30-second countdown dialog appears
- [ ] Tap Cancel within 30 seconds → dialog closes, no call made
- [ ] Sensitivity toggle in Settings changes the G threshold

**All checkboxes must pass before Phase 7.**

---

## Phase 7 — Marketplace + DMs
> ~5-6 days

👤 **Human prerequisite — do this before AI starts coding:**
- Firestore Console: set `config/features.marketplaceEnabled = true`

🤖 **AI tasks (in order):**
1. `lib/features/marketplace/domain/listing_model.dart` — enums: `ListingCategory`, `ListingCondition`, `ListingStatus`
2. `lib/features/marketplace/data/marketplace_repository.dart` — watch/filter listings, create/update/delete/report
3. `lib/features/marketplace/data/dm_repository.dart` — `conversationId = [uid1, uid2].sorted().join('_')`, watch convos + messages
4. `lib/features/marketplace/presentation/marketplace_page.dart` — category filter chips + search + ListView
5. `lib/features/marketplace/presentation/widgets/listing_card.dart`
6. `lib/features/marketplace/presentation/listing_detail_page.dart` — photo carousel + "Message Seller" button
7. `lib/features/marketplace/presentation/create_listing_page.dart` — photos (max 5) + fixed category dropdown + guidelines shown on first use
8. `lib/features/marketplace/presentation/conversations_page.dart`
9. `lib/features/marketplace/presentation/dm_chat_page.dart` — same bubble UI, listing preview at top

**Category enforcement:** fixed dropdown, no free text, Report button on every listing.

### ✅ Test Gate — Phase 7
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --debug
# Expected: BUILD SUCCESSFUL

adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

👤 **2 devices — marketplace flag ON:**
- [ ] Marketplace tab shows listing feed (not coming soon)
- [ ] Device A: tap `+` → Create Listing → category is a fixed dropdown (no free-text field) → upload 1 photo → set price → save
- [ ] Listing appears in feed on both devices within 5 seconds
- [ ] Tap listing → detail page shows photo, price, description
- [ ] Device B: tap "Message Seller" → DM chat opens with listing preview card at top
- [ ] Device A: receives message in Conversations tab
- [ ] Report button is visible on listing detail page
- [ ] Category filter chips filter the feed correctly (tap "Bikes" → only bike listings shown)

**All 7 must pass before Phase 8.**

---

## Phase 8 — FCM + Update Check + Polish
> ~2-3 days

🤖 **AI tasks (in order):**
1. `lib/shared/services/notification_service.dart` — create `motolink_default` channel, request permission, save FCM token to user doc, handle foreground messages
2. `lib/shared/services/update_service.dart` — fetch GitHub raw JSON, compare version, show update dialog
3. FCM background handler in `lib/main.dart` — top-level `@pragma('vm:entry-point')` function
4. `lib/features/settings/presentation/settings_page.dart` — port `_reference/settings_page.dart`, connect real prefs/version/sign-out
5. Add signing config to `android/app/build.gradle.kts` — reads from `key.properties`, applies to release build type

👤 **Human tasks:**

**Android release keystore** (one-time, do before first release build):
```bash
# Generate keystore — keep this file safe, you need it for every future release
keytool -genkey -v -keystore android/app/motolink.keystore \
  -alias motolink -keyalg RSA -keysize 2048 -validity 10000

# Create android/key.properties (add to .gitignore — never commit this)
storePassword=<your_password>
keyPassword=<your_password>
keyAlias=motolink
storeFile=motolink.keystore
```

Add to `android/app/build.gradle.kts` (signing config block — AI handles this).

**Add release SHA-1 to Firebase** (Google Sign-In breaks on release builds without this):
```bash
# Get release SHA-1
keytool -list -v -keystore android/app/motolink.keystore -alias motolink
# Copy the SHA-1 value
```
Firebase Console → Project Settings → Android app → Add fingerprint → paste release SHA-1.

**Host update JSON on GitHub:**
```json
{ "latestVersion": "1.0.0", "downloadUrl": "https://github.com/.../motolink.apk", "mandatory": false }
```

### ✅ Test Gate — Phase 8 (Final)
```bash
flutter analyze
# Expected: No issues found!

flutter build apk --release
# Expected: BUILD SUCCESSFUL  ← release build for final testing

adb install -r build/app/outputs/flutter-apk/app-release.apk
```

👤 **Notifications:**
- [ ] Fully close app → Firebase Console → Cloud Messaging → Send test message → notification arrives on device
- [ ] Tap notification → app opens and navigates to the correct screen

👤 **Update check:**
- [ ] Settings page shows the correct app version number
- [ ] Temporarily change `latestVersion` in GitHub JSON to `99.0.0` → relaunch app → update dialog appears with download button
- [ ] Tap download → browser opens with APK download link
- [ ] Restore `latestVersion` back to `1.0.0`

👤 **Settings:**
- [ ] Sign Out button → app returns to login screen
- [ ] Sign back in → same account, data intact

👤 **Full Day 1 regression — 2 devices:**
- [ ] Auth + profile complete on both devices
- [ ] Create ride → join by code → lobby → start → GPS dots move → PTT voice works → chat message delivered → end ride → KMs saved
- [ ] Guardian: G-Force updates on movement, battery accurate, SOS opens dialer
- [ ] No crashes during the entire flow

**All checkboxes pass = app is ready for APK distribution.**

---

# Git Workflow

## Branch Strategy

Single branch: `main`. Personal project — no feature branches needed. Push after each phase verification passes.

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body — only if WHY is non-obvious]
```

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs`

**Scopes:** `android` · `deps` · `auth` · `ride` · `map` · `voice` · `chat` · `guardian` · `profile` · `community` · `marketplace` · `config` · `router` · `firebase`

**Rules:**
- Subject line: max 72 characters, lowercase after colon, no period at end
- Body: only when the WHY is non-obvious (e.g., workarounds, constraints)
- Never mention issue numbers (personal project, no tracker)

---

## When to Commit

Commit after each **logical group** of files that compile and work together as a unit. Never commit broken code. Use the templates below as the exact trigger — one template line = one commit.

**Commit trigger rules:**
| Situation | Do this |
|---|---|
| Finished a domain model file | Commit immediately |
| Finished a repository + its provider | Commit as one unit |
| Finished a page + its widgets | Commit as one unit |
| `flutter analyze` shows errors | Fix first, then commit |
| Half-done feature, end of session | Do NOT commit — finish the unit first |
| Refactoring an existing file while building | Separate commit before continuing |

**Commit size rule:** If your diff touches more than 3 unrelated files, split it into smaller commits.

---

## When to Push

Push only after the **full phase verification passes** — not after individual commits.

**Push trigger rules:**
| Situation | Do this |
|---|---|
| Phase verification passes (analyze + build + manual test) | Push |
| Mid-phase, end of day | Do NOT push — only committed locally |
| `flutter analyze` has warnings | Fix first, then push |
| `flutter build apk --debug` fails | Fix first, then push |
| Phase 3+: physical device test not done yet | Do NOT push |
| Emergency — need to save work remotely | Push to a temp branch, not main |

**Pre-push checklist (run every time before `git push`):**
```bash
flutter analyze              # Must show: No issues found!
flutter build apk --debug    # Must succeed with no errors
# Phase 3 and above only:
# Install APK on physical device and run through the phase verification steps
git push origin main
```

---

## Commit Templates Per Phase

### Phase 0 (no code commits — manual setup only)

### Phase 1 — Android Config + Dependencies
```
chore(android): rename package to com.motolink.app, set minSdk 23
chore(android): add google-services plugin for Firebase
chore(android): add all required permissions and service declarations
chore(android): rename Kotlin package directory to com.motolink.app
chore(deps): add Firebase, Riverpod, LiveKit, maps, and utility packages
```

### Phase 2 — Auth + Profile + KMs + Badges
```
chore(ref): archive existing UI to lib/_reference for visual reference
feat(config): add theme, constants, and badge definitions
feat(auth): add UserModel with totalKm, badges, and isProfileComplete
feat(auth): add AuthRepository with Google Sign-In and addRideDistance
feat(auth): add Riverpod providers for auth state and current user
feat(config): add AppFeatures model and featuresProvider for feature flags
feat(router): add GoRouter with auth and profile-complete redirect logic
feat(auth): add login page with Google Sign-In button
feat(auth): add profile setup page with bike and emergency contact form
feat(profile): add profile page with KMs counter and badges grid
feat(profile): add edit profile page
feat(app): wire up MaterialApp.router with Firebase init and ProviderScope
feat(app): add navbar, loading overlay, error widget, and coming soon page
```

### Phase 3 — Standalone Ride
```
feat(ride): add RideModel and ParticipantModel with join code support
feat(chat): add MessageModel for text-only in-ride chat
feat(map): add RiderLocationModel and PoiModel
feat(ride): add RideRepository with join code generation and ride lifecycle
feat(chat): add ChatRepository for ride messages
feat(map): add LocationRepository for Realtime DB live GPS
feat(map): add OverpassRepository for gas stations and rest stops
feat(voice): add LiveKitService wrapper for PTT and open mic
feat(location): add LocationService with GPS stream and foreground service
feat(android): add LocationForegroundService and MainActivity MethodChannel
feat(ride): add Riverpod providers for ride, location, chat, and voice
feat(ride): add home page with start and join ride buttons
feat(ride): add create ride page with map pin picker and join code display
feat(ride): add join ride page with OTP-style code input
feat(ride): add ride lobby with real-time participant list
feat(map): add rider marker ported from reference radar UI
feat(map): add route polyline and POI marker widgets
feat(voice): add PTT button ported from reference comms UI
feat(voice): add voice overlay with speaker indicators
feat(chat): add message bubble and ride chat drawer
feat(map): add live map page with GPS HUD, voice overlay, and chat drawer
feat(ride): add completed ride detail page and ride card widget
```

### Phase 4 — Guardian
```
feat(guardian): add SensorService for accelerometer and battery
feat(guardian): add sensor card widget
feat(guardian): add guardian page with real sensors and SOS dial button
```

### Phase 5 — Feature Flag Shell
```
feat(app): add communities and marketplace tabs with feature flag gating
```

### Phase 6 — Communities
```
feat(community): add CommunityModel, MemberModel, and MemberRole enum
feat(community): add CommunityRepository with member management
feat(community): add community feed page with discover and my groups tabs
feat(community): add community detail page with chat, rides, members tabs
feat(community): add create community page with photo and banner upload
feat(community): add community chat page extending existing chat infrastructure
feat(community): add member tile with role badge and admin actions
feat(guardian): add auto crash detection with 30-second countdown dialog
```

### Phase 7 — Marketplace
```
feat(marketplace): add ListingModel with category and condition enums
feat(marketplace): add MarketplaceRepository with listing CRUD and report
feat(marketplace): add DmRepository for buyer-seller conversations
feat(marketplace): add marketplace page with category filters and search
feat(marketplace): add listing detail page with photo carousel
feat(marketplace): add create listing page with fixed category enforcement
feat(marketplace): add conversations page and DM chat page
```

### Phase 8 — Polish
```
feat(firebase): add FCM notification service with channel setup
feat(app): add update check service with GitHub APK version comparison
feat(settings): add settings page connected to real preferences and auth
fix(firebase): add FCM background message handler in main.dart
chore(android): add release signing config reading from key.properties
```

---

## Push Checklist (run before every push)

```bash
flutter analyze          # Must show: No issues found!
flutter build apk --debug  # Must succeed
# If Phase 3+: test on physical device
git push origin main
```

---

## Git Config (run once)

Set up the commit message template:
```bash
git config --global commit.template .gitmessage
```

Contents of `.gitmessage` (created in project root):
```
# <type>(<scope>): <short description — max 72 chars>
#
# Types: feat | fix | chore | refactor | docs
# Scopes: android | deps | auth | ride | map | voice | chat |
#         guardian | profile | community | marketplace | config | router | firebase
#
# Body (optional — only for non-obvious WHY):
#
```

---

## UI Design Tokens (preserved exactly from `_reference/theme.dart`)

| Token | Value |
|---|---|
| `bgColor` | `#000000` — all scaffolds |
| `cardBg` | `#121212` — all cards |
| `primary` | `#39FF14` — neon green, active states, KMs |
| `secondary` | `#FF5F1F` — neon orange, PTT active, compass |
| `alert` | `#FF0033` — SOS, errors, delete |
| `textMain` | `#FFFFFF` |
| `textMuted` | `#A0A0A0` — subtitles, hints |
| `borderColor` | `#333333` — all borders |
| Font | Google Fonts `Outfit` |

**Glow:** `BoxShadow(color: AppTheme.primary, blurRadius: 10, spreadRadius: 2)`

**Card:** `BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor))`

**Section header:** `Text(title.toUpperCase(), style: TextStyle(color: AppTheme.primary, letterSpacing: 1, fontWeight: FontWeight.bold, fontSize: 14))`

**AppBar:** "MOTO" white + "LINK" `#39FF14`, bold, 24px, letterSpacing 1 · Right: 8px green dot + glow + "ONLINE" label
