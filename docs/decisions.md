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
