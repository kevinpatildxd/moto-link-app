# LiveKit Voice — Design Spec

**Date:** 2026-06-01
**Replaces:** Agora SDK (agora_rtc_engine)
**Scope:** Phase 3 voice communication (PTT + open mic, 5–15 riders per ride)

---

## Decision

Self-hosted LiveKit on Oracle Cloud Always Free ARM VM. Zero cost forever, no dependency on a startup's free tier, no limits at MotoLink's scale.

---

## Architecture

```
Flutter App ──HTTPS──► Oracle VM :3000  Token Server (Node.js)
Flutter App ──WSS────► Oracle VM :7880  LiveKit SFU
Flutter App ◄─TURN───► Oracle VM        LiveKit built-in TURN
```

One Oracle VM. Two processes (LiveKit + token server). Let's Encrypt SSL. Free domain via DuckDNS or Cloudflare.

---

## Server Stack

| Component | Detail |
|---|---|
| VM | Oracle Cloud Always Free ARM — 4 vCPUs, 24 GB RAM (using ~10%) |
| LiveKit server | Official Docker image, `docker compose up` |
| Built-in TURN | Enabled in LiveKit config — no separate coturn needed |
| Token server | Node.js, ~30 lines, signs JWT tokens with LiveKit API secret |
| SSL | Let's Encrypt via certbot, auto-renews |
| Domain | Free — DuckDNS subdomain or Cloudflare free plan |

---

## Token Flow

1. Flutter app calls token endpoint: `POST https://<vm>/token` with Firebase ID token + `rideId`
2. Token server verifies Firebase ID token (confirms caller is authenticated)
3. Token server returns a signed LiveKit JWT for room `rideId`
4. Flutter connects to LiveKit room using that token
5. Token expires after ride ends (configurable TTL)

The API secret never leaves the server.

---

## Room Lifecycle

- **Room name** = `rideId` (Firestore ride document ID)
- Created automatically by LiveKit when first participant joins
- Destroyed automatically when last participant leaves
- One room per active ride — isolated voice channels

---

## Flutter Integration

**Package:** `livekit_client` (pub.dev, official LiveKit Flutter SDK)

**File:** `lib/features/voice/data/livekit_service.dart` — replaces `agora_service.dart`

**Behaviours:**
| Mode | Mechanism |
|---|---|
| PTT hold | `LocalAudioTrack.publish()` on press, `unpublish()` on release |
| Open mic | `LocalAudioTrack` always published, toggled by user |
| Speaker indicators | `room.onSpeakingChanged` event → drives UI |
| Participant list | `room.participants` → drives speaker_indicator widgets |

---

## Constants

`lib/config/constants.dart` stores:
- `liveKitServerUrl` — WSS URL of Oracle VM
- `liveKitTokenEndpoint` — HTTPS URL of token server

No secrets in the app. Token server holds the API key + secret.

---

## Plan Changes Summary

| Area | Before | After |
|---|---|---|
| Dep | `agora_rtc_engine` | `livekit_client` |
| Voice service file | `agora_service.dart` | `livekit_service.dart` |
| Phase 0 setup | Agora console | Oracle VM + LiveKit Docker |
| constants.dart | Agora App ID | LiveKit URL + token endpoint |
| Free tier | 10,000 min/month | Unlimited (self-hosted) |
