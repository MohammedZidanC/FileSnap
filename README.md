# FileSnap

![FileSnap Theme](https://img.shields.io/badge/Flutter-3.11-blue.svg?style=flat-square&logo=flutter)

FileSnap is a premium, offline-first digital utility application meticulously crafted in Flutter. Designed to operate completely client-side to ensure maximum privacy, FileSnap empowers users with an advanced suite of PDF manipulation workflows and image editing capabilities wrapped in a highly interactive dynamic UI.

## 🚀 Download APK
Get the latest stable Android build directly:
👉 [Download FileSnap v1.0 APK](https://github.com/MohammedZidanC/FileSnap/releases/download/1.0/FileSnap.v1.0.apk)

---

## Features

### 📄 PDF Tools
- **Camera to PDF**: Digitize documents instantly natively utilizing device optics.
- **Merge & Split**: Consolidate multiple PDFs into a single file or surgically parse individual pages.
- **Rearrange & Compress**: Intuitive drag-and-drop page reorganization and algorithm-driven compression for smaller file sizes.
- **PDF to Images**: Extract high-fidelity images directly from native vector layers.
- **Watermark**: Embed persistent custom text onto your documentation.

### 🖼️ Image Tools
- **Dynamic Swiping Context**: Quickly flip between active batch files directly in the editor environment.
- **Matrix Filtering**: Instantly apply complex visual matrices including Enhanced, B&W, Warm, Cool, Vivid, and Food palettes natively rendered through `ColorFiltered` systems without relying on bulky external dependencies.
- **Overlay Engineering**: Fully configurable watermarks providing Opacity control, exact Cartesian positioning, Font parameters, and strict rotation configurations.
- **Batch Processing**: "Apply to All" workflows to duplicate modifications across every actively loaded image.

### ✨ UI & Experience
- **Performance Driven**: Global execution wrapped inside structured `RepaintBoundary` nodes, ensuring perfectly fluid navigation.
- **Physics**: Zero-stretch (`ClampingScrollPhysics`) lists providing hard boundary resistance across views avoiding rubber-banding.
- **Interactive Environment**: Procedurally generated dynamic particle background complete with ambient blur, toggleable glow matrices, and idle state interactions.
- **Customizable Experience**: In-depth Settings Suite accommodating UI Density mapping (Compact, Comfort), interactive Animation Intensity speeds, dynamic Typography mapping, and unique Color Themes (Slate Sand, Ocean Teal, Dark, Light).
- **Stylized Boot Animation**: Vector-based animated 'FS' paths rendered precisely at run-time matching the Android Adaptive Icons layer.

---

## 🚀 Setup Instructions

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.11.x or higher)
- Android Studio or VS Code

### Installation (Flutter)
1. Clone this repository:
   ```bash
   git clone https://github.com/MohammedZidanC/FileSnap.git
   ```
2. Navigate into the application root:
   ```bash
   cd FileSnap
   ```
3. Fetch required Flutter packages:
   ```bash
   flutter pub get
   ```
4. Build the application:
   ```bash
   flutter run --profile
   ```

### Installation (APK)
Simply download the standard APK from the Download link securely hosted inside the GitHub Releases section and install it locally onto your Android device. 

---

## 🧠 Tech Stack
- **Framework**: `Flutter` utilizing Material guidelines intertwined with bespoke dynamic painters.
- **State Management**: `Riverpod` (`flutter_riverpod`) providing strict reactive configurations globally attached to `SharedPreferences`.
- **Plugins Sub-System**: Standardized plugin architectures including `pdf`, `share_plus`, `image_picker`, `path_provider`, and `lucide_icons`.

---

## 📁 Folder Structure
```
lib/
├── main.dart                 # Application Bootstrapper & Theme Entry
├── providers/                # Core Riverpod State Notifiers
├── services/                 # Native System Implementations (Storage APIs)
├── theme/                    # Dynamic Color Systems & Font Handling
└── ui/
    ├── screens/              # Core Application Modules
    │   ├── image_tools/      # Batch Image Graphics Manipulation
    │   ├── pdf_tools/        # Parsing, Merging, Editing tools
    │   ├── splash_screen/    # Render-heavy Path Animation vectors
    │   └── settings_screen.dart # Environment Configurations
    └── widgets/              # Reusable Global Elements
```

---

## 📜 Author
Designed and Developed by **Mohammed Zidan C**.
Released beneath the MIT License.
