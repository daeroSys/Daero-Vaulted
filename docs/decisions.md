# Architecture Decision Log (ADR)

This document tracks all deviations, deferrals, additions, and significant technical decisions made during the implementation of the Vaulted app that may not be fully reflected in the original `architecture.md` or `roadmap.md`.

---

## Decision 001: Deferral of iOS Authentication (Phase 2)
**Date:** August 2026
**Context:** Apple Sign-In and iOS specific configurations require a paid Apple Developer Account to test and provision correctly. 
**Decision:** Deferred the iOS portion of Phase 2. The Android implementation is fully complete.
**Next Steps:** Revisit when an Apple Developer Account is provisioned prior to deployment (Phase 13).

---

## Decision 002: Deferral of iOS Share Extension (Phase 4)
**Date:** August 2026
**Context:** Similar to Authentication, creating an iOS Share Extension requires provisioning profiles and a paid developer account to compile and run on physical devices.
**Decision:** Deferred the iOS Share Extension. The Android Share Intent is fully functional.
**Next Steps:** Implement the iOS Share Extension using Swift/Objective-C when the Apple Developer Account is available.

---

## Decision 003: Use of Local HTML/OpenGraph Parsing for Metadata (Phase 5)
**Date:** August 2026
**Context:** We needed a way to fetch titles, descriptions, and thumbnails for shared links (like Instagram and generic websites). Third-party scraper APIs are often paid or rate-limited.
**Decision:** We implemented custom local scrapers using standard `oEmbed` (for YouTube/TikTok) and `html` package OpenGraph parsing (for Instagram/Generic). 
**Consequences:** This keeps the app 100% free to run without requiring backend API keys, though it means the app relies on the user's device network to fetch metadata.

---

## Decision 004: Addition of Phase 5.5 - Folder Details Screen
**Date:** August 2026
**Context:** The original roadmap did not explicitly allocate a phase for the UI that displays the contents inside a folder. Phase 5 fetched the metadata, and Phase 6 was slated for Search.
**Decision:** Inserted "Phase 5.5" immediately after Phase 5 to build the `FolderDetailsScreen`. This allowed us to immediately visually verify the metadata and thumbnails fetched in Phase 5 before moving on to Search.
**Consequences:** Replaced the default folder tap behavior (which previously opened the Edit Folder sheet) with intuitive navigation to the new grid view. Editing folders was moved to a pencil icon in the App Bar.

---

## Decision 005: Deferred Postgres Search (Phase 6)
**Date:** August 2026
**Context:** The original Phase 6 scope included Postgres Full Text Search alongside local SQLite FTS5.
**Decision:** We deferred remote Postgres search. The local FTS5 implementation handles search flawlessly and instantly, adhering strictly to the local-first mandate.
**Next Steps:** Remote search capabilities can be re-evaluated after Phase 7 (Synchronization) when the cloud database mirrors the local data perfectly.

---

## Decision 006: Integration of Microlink API for Metadata (Phase 6)
**Date:** August 2026
**Context:** Standard HTML scraping (Decision 003) failed for Facebook and Instagram links due to aggressive scraper blocking (403 Forbidden) and login walls. 
**Decision:** We integrated the Microlink API specifically for Facebook and Instagram to securely bypass login walls and extract rich OpenGraph metadata (titles, creators, and thumbnails). We also implemented a graceful fallback to prevent scraping failures from crashing the app.
**Consequences:** Improved reliability for social media links. Other platforms (TikTok, YouTube) still use direct oEmbed endpoints.

---

## Decision 007: Deferral of Supabase Row Level Security (RLS) Configuration (Phase 7)
**Date:** August 2026
**Context:** During the implementation of Phase 7 (Offline Synchronization), the Supabase SQL editor prompts to enable Row Level Security (RLS) when creating the cloud tables. 
**Decision:** We deferred enabling RLS ("Run without RLS") to immediately allow the background `SyncService` to test data flow and synchronization logic without being blocked by 403 Forbidden errors.
**Next Steps:** RLS must be formally enabled and proper policy rules (matching `userId` to the authenticated token) must be written and applied before the app is deployed to production (Phase 13).

---

## Decision 008: Database Triggers for Users Table and Shared Content Architecture (Phase 7)
**Date:** August 2026
**Context:** When a user signs up via Supabase Auth, they must exist in the public `users` table to satisfy foreign key constraints (e.g. `folders.user_id`). Relying on the Flutter client to sync the user profile immediately after signup creates a race condition and is unreliable. Additionally, Android Share Sheets sometimes filter apps if their MIME types are too generic.
**Decision:** 
1. We bypassed client-side syncing for new user signups by using a Postgres Database Trigger (`on_auth_user_created`) to instantly copy data from `auth.users` to `public.users`. 
2. We broadened Android intent filters to explicitly include both `text/plain` and `*/*` to ensure compatibility with strict apps like YouTube and TikTok.
3. We maintained our shared `content` table architecture (no `user_id` on the `content` table) relying entirely on `saved_items` as the joining table.
**Consequences:** The `users` table is always perfectly synchronized with Supabase Auth. Content de-duplication works perfectly. The app reliably receives share intents across all major apps.

---

## Decision 009: Native Share Extension UX via App Lifecycle (Phase 8)
**Date:** August 2026
**Context:** Creating a true floating "Share Extension" overlay that works smoothly over external apps like YouTube requires complex native iOS Swift and Android Kotlin UI, breaking cross-platform uniformity.
**Decision:** We implemented a "Get In, Get Out" UX pattern using pure Flutter. When shared to, the app opens directly to the `SaveShareBottomSheet`. Upon saving, the app invokes a custom Kotlin `MethodChannel` (`moveTaskToBack(true)`) to instantly background the app, returning the user exactly to their previous context. 
**Consequences:** Users get the seamless speed and feel of a native Share Extension without leaving the Flutter codebase. Backgrounding (instead of killing) the app allows asynchronous `MetadataService` tasks to safely complete before the OS suspends the isolate.

---

## Decision 010: Notification Payloads and Database Syncing (Phase 9)
**Date:** August 2026
**Context:** Tying Firebase Cloud Messaging (FCM) push notifications directly to specific user accounts requires storing device tokens securely on our backend. Additionally, when a user taps a notification, the app needs to route them to a specific context (like a folder).
**Decision:** 
1. We implemented an automatic sync of the FCM token to a new Supabase table (`user_fcm_tokens`) during the `NotificationService` initialization, ensuring the token is only synced when `Supabase.auth.currentUser` is active.
2. We used `go_router` in conjunction with a `StreamController` inside the `NotificationService` to instantly route users (e.g., `/folders/:id`) when tapping a deep-linked notification.
**Consequences:** This allows the backend to send targeted notifications to specific devices and creates a seamless deep-linking experience for users opening the app via notifications.

---

## Decision 011: Deferral of RevenueCat API Configuration (Phase 10)
**Date:** August 2026
**Context:** During the implementation of the Premium paywalls and quotas, we needed a way to test the UI and global state changes without relying on a fully configured RevenueCat environment (which requires generating API keys and setting up subscription products in Apple App Store Connect and Google Play Console).
**Decision:** We deferred the actual configuration of RevenueCat and the invocation of the native payment sheets. Instead, we implemented a "mock purchase" function (`mockPurchasePremium`) in the `RevenueCatService` that forces the application into the Premium state.
**Consequences:** This allows development to continue smoothly into the remaining phases without being blocked by administrative store setups. 
**Next Steps:** RevenueCat API keys must be injected into `revenuecat_service.dart`, store products must be created, and the mock logic must be replaced with the actual `Purchases.purchasePackage()` call prior to deploying the app to the app stores (Phase 13).

---

## Decision 012: Soft Delete for Account Deletion (Phase 11)
**Date:** August 2026
**Context:** When users request account deletion, entirely purging their record from Supabase immediately could break relational constraints or remove analytical history abruptly. Furthermore, Vaulted operates entirely offline-first, meaning local data must also be securely wiped.
**Decision:** We implemented a "Soft Delete" approach for the backend. When a user deletes their account:
1. The local SQLite database is completely wiped to ensure privacy.
2. An RPC or update call marks their Supabase `users` record with a `deleted_at` timestamp.
3. The user is signed out and returned to the login screen.
**Consequences:** This satisfies data deletion compliance while maintaining database integrity. User data is protected on the local device, but the backend can use a cron job to permanently purge soft-deleted records after a grace period.
