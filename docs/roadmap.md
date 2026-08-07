# Vaulted Development Roadmap

Welcome to the implementation contract for the Vaulted project.

*   `docs/architecture.md` is the **architectural source of truth**. 
*   `docs/roadmap.md` is the **implementation sequence**.
*   If this roadmap ever conflicts with `architecture.md`, **`architecture.md` always wins**.
*   Every phase strictly depends on the previous phase being completed.
*   **Never skip phases.**
*   **Never implement future phases early.**

---

## Current Project Status

**Current Status**
✅ Architecture Approved
✅ Phase 0 - Project Foundation COMPLETE
✅ Phase 1 - Local Database & Domain Layer COMPLETE
✅ Phase 2 - Authentication PARTIAL (iOS deferred)
✅ Phase 3 - Folder Management COMPLETE
✅ Phase 4 - Share Sheet PARTIAL (iOS deferred)

**Current Phase**
➡ **Phase 5 - Metadata System**

*Future phases must always begin from Phase 5.*

---

## Implementation Rules

The following rules are mandatory and must be observed in every phase:

*   Never redesign the architecture.
*   Never bypass Clean Architecture.
*   Never access SQLite directly from the UI.
*   Never access Supabase directly from Widgets.
*   Repositories communicate with Data Sources.
*   Presentation depends only on Domain.
*   Data implements Domain interfaces.
*   Always use UUIDv7.
*   Never duplicate Content records.
*   Always normalize URLs.
*   Always use `canonicalUrl`.
*   Every mutation enters `SyncQueue`.
*   All writes are local-first.
*   Synchronization must never block the UI.
*   Metadata retrieval must always be asynchronous.
*   Offline support is mandatory.
*   Search must work offline.
*   Every feature must compile before starting the next phase.
*   Every completed phase must pass `flutter analyze`.

---

## Phases

### Phase 1: Local Database & Domain Layer

**Objective**
Implement the offline local database schema, DAO layer, and Domain repository interfaces.

**Deliverables**
*   Configure Drift
*   Database connection
*   Database migrations
*   Tables:
    *   Users
    *   Folders
    *   Content
    *   ContentMetadata
    *   SavedItems
    *   Tags
    *   ContentTags
    *   FolderTags
    *   SyncQueue
*   DAO layer
*   Repository interfaces
*   Repository implementations
*   SQLite FTS5 setup
*   Soft delete integration
*   Indexes
*   UUIDv7 integration
*   Enums
*   Unit tests

**Definition of Done**
*   Database opens successfully.
*   CRUD operations work locally.
*   FTS search works locally.
*   Repositories pass unit tests.

**Out of Scope**
*   No Supabase synchronization.
*   No UI implementation.

**Dependencies**
*   Phase 0 (Completed)

**Validation Checklist**
- [x] Compiles successfully
- [x] Passes `flutter analyze`
- [x] Passes repository unit tests

---

### Phase 2: Authentication

**Objective**
Implement user authentication and session management.

**Deliverables**
*   Google Sign-In
*   Apple Sign-In (Deferred: Requires Paid Developer Account)
*   Email Authentication
*   Secure Storage integration
*   Session management
*   Profile sync

**Definition of Done**
*   User can log in and log out across providers.
*   Session persists via Secure Storage.
*   Profile maps to local database.

**Out of Scope**
*   UI Polish (keep minimal).
*   Deep linking.

**Dependencies**
*   Phase 1

**Validation Checklist**
- [x] Compiles successfully
- [x] Passes `flutter analyze`
- [x] Auth state evaluates correctly

---

### Phase 3: Folder Management

**Objective**
Implement the UI and logic for managing Folders.

**Deliverables**
*   CRUD operations for Folders
*   Colors assignment
*   Icons assignment
*   Ordering logic
*   Restore functionality
*   Soft delete logic

**Definition of Done**
*   User can create, edit, reorder, and soft-delete folders.

**Out of Scope**
*   Syncing folders to the cloud.

**Dependencies**
*   Phase 1, Phase 2

**Validation Checklist**
- [x] Compiles successfully
- [x] Passes `flutter analyze`

---

### Phase 4: Share Sheet

**Objective**
Implement native share intent handling to parse incoming shared links.

**Deliverables**
*   Android Share Intent
*   iOS Share Extension (Deferred: Requires Paid Developer Account)
*   ShareParser implementation
*   Canonical URLs normalization
*   DuplicateDetectionService integration
*   Folder Picker UI

**Definition of Done**
*   App receives URLs from external apps.
*   URLs are parsed to canonical representation.
*   Content is saved accurately without duplicates.

**Out of Scope**
*   Metadata fetching (handled in Phase 5).

**Dependencies**
*   Phase 1, Phase 3

**Validation Checklist**
- [x] Compiles successfully
- [x] Passes `flutter analyze`
- [x] Android intent filters work

---

### Phase 5: Metadata System

**Objective**
Implement background processing to fetch metadata for saved content.

**Deliverables**
*   MetadataService
*   MetadataProvider (Providers architecture)
*   Thumbnail cache functionality
*   Background metadata fetch
*   Retry mechanisms

**Definition of Done**
*   Content receives metadata asynchronously after saving.
*   Thumbnails are cached locally.

**Out of Scope**
*   Complex retry queue synchronization.

**Dependencies**
*   Phase 1, Phase 4

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`

---

### Phase 6: Search

**Objective**
Implement local and remote search capabilities.

**Deliverables**
*   SQLite FTS5 UI integration
*   Postgres Full Text search logic
*   SearchRepository
*   Search UI
*   Recent Searches functionality

**Definition of Done**
*   Users can instantly search local content.
*   Fallback to server search when applicable.

**Out of Scope**
*   Complex ML-based search.

**Dependencies**
*   Phase 1

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`
- [ ] FTS resolves results instantly

---

### Phase 7: Offline Synchronization

**Objective**
Implement the background synchronization engine to reconcile local and remote data.

**Deliverables**
*   SyncQueue UI / Logic
*   Background Scheduler
*   Batch Sync implementation
*   Conflict Resolution
*   Retry logic
*   Connectivity handling

**Definition of Done**
*   All queued mutations sync safely to Supabase in batches.
*   Conflicts resolve elegantly.

**Out of Scope**
*   Realtime WebSockets (unless required by conflict resolution).

**Dependencies**
*   Phase 1, Phase 2

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`
- [ ] Disconnected mutations sync upon reconnection

---

### Phase 8: UI Polish

**Objective**
Finalize application aesthetics and dynamic interactions.

**Deliverables**
*   Animations & Micro-interactions
*   Material 3 complete integration
*   Loading States (Shimmers)
*   Dark Mode styling
*   Accessibility optimizations

**Definition of Done**
*   App feels premium, dynamic, and responsive.

**Out of Scope**
*   New feature logic.

**Dependencies**
*   Phase 3, Phase 4, Phase 6

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`

---

### Phase 9: Notifications

**Objective**
Add push and local notification capabilities.

**Deliverables**
*   Firebase Messaging
*   Reminder Notifications
*   Sync Notifications

**Definition of Done**
*   App safely receives and displays push notifications.

**Out of Scope**
*   Complex in-app messaging centers.

**Dependencies**
*   Phase 2

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`

---

### Phase 10: Premium

**Objective**
Implement in-app purchases and subscription gates.

**Deliverables**
*   RevenueCat integration
*   Entitlements logic
*   Paywall UI

**Definition of Done**
*   Users can purchase and manage premium subscriptions.

**Out of Scope**
*   Custom payment gateways.

**Dependencies**
*   Phase 2

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`

---

### Phase 11: Settings & Profile

**Objective**
Finalize user configuration and account management.

**Deliverables**
*   Theme selector
*   Privacy options
*   Data Export
*   Delete Account

**Definition of Done**
*   Users can manage all personal configuration and comply with deletion requests.

**Out of Scope**
*   Social profile pages.

**Dependencies**
*   Phase 2

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`

---

### Phase 12: Testing & Optimization

**Objective**
Ensure the application is hardened for production release.

**Deliverables**
*   Repository Tests
*   Widget Tests
*   Integration Tests
*   Performance Profiling
*   Memory Profiling
*   Offline Stress Testing

**Definition of Done**
*   Coverage thresholds met.
*   No memory leaks identified.
*   Offline queue handles high-volume stress without blocking.

**Out of Scope**
*   New features.

**Dependencies**
*   All prior phases.

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`
- [ ] All tests pass

---

### Phase 13: Deployment

**Objective**
Publish the application to app stores.

**Deliverables**
*   Android Build (Play Store)
*   iOS Build (App Store)
*   Store Assets
*   Signing Configuration
*   Analytics validation
*   Crashlytics validation

**Definition of Done**
*   Release builds generated, signed, and uploaded to respective stores.

**Out of Scope**
*   Marketing web pages.

**Dependencies**
*   Phase 12

**Validation Checklist**
- [ ] Compiles successfully
- [ ] Passes `flutter analyze`
- [ ] App signs successfully

---

## Execution Policy

*   **Only one phase may be implemented at a time.**
*   Implementation must **stop immediately** after the Definition of Done is satisfied.
*   **Do not begin the next phase automatically.**
*   Wait for explicit user approval before advancing to the next phase.

---

## How Future AI Sessions Should Use This Roadmap

1.  Read `docs/architecture.md` first.
2.  Read `docs/roadmap.md`.
3.  Determine the next unfinished phase from the "Current Project Status" section.
4.  Implement **only** that phase.
5.  Do not modify completed phases unless fixing bugs.
6.  Do not redesign the architecture.
7.  **Stop after Definition of Done.**
