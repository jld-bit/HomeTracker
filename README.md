# HomeTracker (SwiftUI)

Original SwiftUI iPhone app concept for managing personal inventory with an original visual style, naming, copywriting, and flows.

## Features
- Onboarding flow to add first item quickly
- Add item fields: name, photo, category, value, room, notes
- Search, category/room filtering
- List and grid presentation modes
- Value stats by room and category
- Freemium model with StoreKit 2
  - Free: 25 items
  - Premium: unlimited items + export + backup
- Export options
  - CSV
  - PDF
  - JSON backup

## Architecture
- MVVM
- SwiftData persistence (`InventoryItem` model)
- Service layer for StoreKit and export handling

## Legal / Originality Disclaimer
This project intentionally avoids copying protected branding, copyrighted assets, trade dress, or exact UX from any existing app.
