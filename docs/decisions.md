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
