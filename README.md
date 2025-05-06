# OneStepGPSRP

**OneStepGPSRP** is an iOS application for real‑time GPS device tracking. It displays devices on a map with clustering, custom callouts, and a list view with search, sort, and visibility toggles.

---

## 🚀 Features

* **Map View** with UIKit-based `MKMapView` wrapper supporting:

  * Device annotation clustering
  * Status‑based icons (moving, stopped, paused, offline)
  * Custom drop‑down callouts with SwiftUI content
  * Zoom‑to‑fit and per‑pin “Zoom” buttons
* **List View** powered by SwiftUI:

  * Searchable and sortable by name, status, last updated, or speed
  * Visibility toggles (hide/show pins)
  * Persistent sort & visibility via `@AppStorage`
* **Robust Networking**:

  * Async/await calls with retry/backoff
  * ISO8601 date parsing (fractional seconds fallback)
  * Error banners on failure, auto‑clearing after a few seconds
  * Optional auto‑refresh timer

## 📁 Project Structure

```
OneStepGPSRP/
├── OneStepGPSRPApp.xcodeproj     # Xcode project file
├── OneStepGPSRP/                 # Main app target
│   ├── CustomUIComponents/       # Reusable UIKit views
│   │   └── PinLabelView.swift    # Custom map pin label
│   ├── DataModels/               # App data models
│   ├── Helpers/                  # Utility extensions
│   │   ├── DateExtensions.swift
│   │   └── SequenceExtensions.swift
│   ├── Preview Content/          # SwiftUI previews and assets
│   │   └── Preview Assets.xcassets
│   ├── Services/                 # Networking layers & config
│   │   ├── APIConfig.swift
│   │   ├── DeviceService.swift
│   │   ├── Endpoints.swift
│   │   └── NetworkError.swift
│   ├── Views/                    # SwiftUI and UIKit wrappers
│   │   ├── ListView/
│   │   │   └── DeviceListView.swift
│   │   └── MapView/
│   │       ├── DeviceCalloutView.swift
│   │       ├── DeviceMapUIKitView.swift
│   │       ├── DeviceMapView.swift
│   │       └── DevicesMapModel.swift
│   └── Assets/                   # Images and assets catalog
├── OneStepGPSRPTests/            # Unit tests target
│   ├── DeviceTests.swift
│   └── OneStepGPSRPTests.swift
└── OneStepGPSRPUITests/          # UI tests target
    ├── OneStepGPSRPUITests.swift
    └── OneStepGPSRPUITestsLaunchTests.swift
```

## 🛠 Prerequisites

* Xcode 15 or later
* iOS 16 SDK (deployment target iOS 16+)
* Swift 5.9

## 🎯 Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/your-org/OneStepGPSRP.git
   cd OneStepGPSRP
   ```
2. **Open in Xcode**

   ```bash
   open OneStepGPSRP.xcodeproj
   ```
3. **Build & Run**

   * Select the `OneStepGPSRP` scheme
   * Press `⌘R` to build and launch on simulator or device

## 🧪 Running Tests

* **Device model tests:** `DeviceTests.swift`
* **ViewModel tests:** `DeviceMapModelTests.swift`

Run all tests with **Product → Test** (`⌘U`).

## ⚙️ Configuration

* **API Base URLs**

  * Defined in `APIConfig.swift`
* **API Key**

  * Defined in `APIConfig.swift`
* ** Need to set API key to make app work
