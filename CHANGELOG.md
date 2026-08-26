## 2.3.0

### ✨ Image Insights: File Information & Accessibility Analysis

- **New: Image information panel** (below the viewer):
  - Shows file name, true format, file size, original dimensions, megapixels, aspect ratio and orientation for the dropped image
  - Format is detected from magic bytes (JPEG/PNG/GIF/WebP/AVIF, with SVG by extension) instead of trusting the file extension
  - Metadata is captured at drop time, before the image is resized/re-encoded for display
  - Warns when the image resolution is too low to survive zooming

- **New: SVG support**:
  - `.svg` files can now be dropped for analysis like any raster image
  - SVGs are rasterized once into PNG pixels (via `image_pixels_plus`'s `rasterizeSvg`), so display, palette extraction and hover color sampling all share one identical pixel source
  - Added `svg` to the accepted file formats

- **New: Accessibility insights**:
  - WCAG 2.1 contrast ratios of the dominant palette colors against white and black text
  - AA (4.5:1) / AAA (7:1) PASS/FAIL badges per color, styled with the theme's success/error colors
  - Average image brightness with a plain-language recommendation for overlaying text

- **Fixed: magnifier UX & rendering**:
  - The loupe is now centered on the cursor instead of offset to its bottom-right (the `+` crosshair sits dead-center on the sampled pixel)
  - Replaced `RawMagnifier`'s backdrop-filter rendering with direct painting of the magnified region (`CustomPainter` + decoded image); fixes the lens flickering/vanishing on Flutter web whenever frames stopped being produced
  - Lens stays solid while the cursor rests inside the image; hover/click still pass through to the image below

- **Under the hood**:
  - Migrated from `image_pixels` to `image_pixels_plus`, a maintained fork that fixes Flutter web pixel readback and keeps the same `ImgDetails` API
  - `ImageProcessingService.processImageFile` now returns a `ProcessedImage` (display bytes + original-file analysis)
  - Added immutable `ImageAnalysis` and `AccessibilityReport` models; `HomePageState` carries them through the sentinel `copyWith` pattern and resets them on clear
  - Added unit tests covering size formatting, aspect-ratio reduction, orientation, low-resolution detection and WCAG threshold logic

## 2.2.0

### 🐛 Critical Bug Fixes & Hover Performance Overhaul

- **Bug Fixes**:
  - **Fixed crash when dropping an image** ("Trying to render a disposed EngineFlutterView"): the analyzing dialog lifecycle was coupled to processing through `Navigator.pop` calls; any race could pop the page route and dispose the view on web
  - **Fixed copied hex codes**: colors are now copied in the standard `#RRGGBB` format (previously emitted 8-digit `ffRRGGBB` with alpha and no `#`, which design tools reject)
  - Analyzing dialog is no longer dismissible by clicking outside, and can never get stuck on screen

- **Performance Enhancements**:
  - Eliminated full-page rebuilds on mouse move (previously ~2 full-tree rebuilds per pointer event): hover state now lives in `ValueNotifier`s consumed by leaf widgets (`ValueListenableBuilder`), so only the magnifier and hovered-color chip rebuild while hovering
  - Removed duplicate `ImagePixels` widget that held a second full RGBA pixel buffer of the loaded image
  - Pixel color lookups now happen imperatively from the cached pixel buffer instead of through build + post-frame callback round-trips

- **Reliability & Architecture**:
  - Added concurrency guard: dropping a second image while one is being analyzed is safely ignored instead of racing dialogs
  - Dialog dismissal uses `Navigator.removeRoute` with a captured `DialogRoute` handle, structurally preventing page-route pops regardless of navigation state
  - Added `mounted` checks after all async gaps before using `BuildContext`
  - Slimmed `HomePageState` (hover fields moved to notifiers) and removed dead code (unused `AnimationController`)

## 2.1.2

### 🔧 Major Code Refactoring & Architecture Improvements

- **Architecture Overhaul**: Complete refactoring for better maintainability and performance
  - Created `AppTheme` class for centralized color and text style management
  - Implemented immutable `HomePageState` model with proper state management
  - Added `ImageProcessingService` for better separation of concerns
  - Created reusable UI components: `ImageDropZone`, `ColorInfoSection`, `InteractiveImageViewer`, `ColorPaletteDialog`

- **Code Quality Improvements**:
  - Moved `validImageFormats` to const for better performance
  - Fixed dependency placement (`very_good_analysis` moved to dev_dependencies)
  - Added proper error handling with custom `ImageProcessingException`
  - Implemented late initialization for required fields
  - Added const constructors where applicable

- **Bug Fixes**:
  - **Fixed clear image functionality**: Resolved issue where "Clear image" button wasn't properly resetting the uploaded image due to faulty `copyWith` method implementation
  - Improved error handling with specific exceptions instead of generic catches
  - Enhanced snackbar utilities with centralized `UiHelper` class

- **Performance Enhancements**:
  - Better memory management with proper state handling
  - Optimized widget rebuilds with targeted state updates
  - Improved image processing workflow

- **Developer Experience**:
  - Deprecated old constants with migration path to new `AppTheme`
  - Added comprehensive documentation and type safety improvements
  - Better code organization with clear separation of UI, business logic, and data models

## 2.1.0

- Refresh color design

## 2.0.2

## 2.0.1

- Adds meta tag information

## 2.0.0

- Migrates to Dart 3.0 & Flutter 3.10.0

## 1.3.2

- Updates color container with brush asset

## 1.3.1

- Updates and refines app's color scheme

## 1.3.0

- Adds coming soon messages for mobile & tablet users
- Fixes minor layout issues

## 1.2.3

- Revamped magnifying glass design for enhanced user experience.
- Added the ability to toggle the color palette by tapping on the palette icon when an image is loaded, removing clutter from below the image.
- Addressed layout inconsistencies to ensure a more consistent and polished look throughout the app.

## 1.2.2

- Adds magnifying effect when analyzing image

## 1.2.1

- Updates image dependency
- Adds field for hex color check

## 1.2.0

- Changes the UI colors

## 1.1.0

- Redesigns the UI
- Fixes loading dialog style issues

## 1.0.1

- Checks if the image dropped is in valid image format (JPG, JPEG, PNG, WEBP, GIF)
- Adds loading dialog while processing image
- Adds version below title

## 1.0.0

- Initial release
