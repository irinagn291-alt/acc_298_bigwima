# Galleyweave — Build Specification

> Portfolio app 200, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Cook two saved recipes on one interleaved step timeline.

| Field | Value |
| --- | --- |
| Product name | Galleyweave |
| Bundle identifier | `com.galleyweave.weave` |
| Domain | https://galleyweave-weave.pro |
| Contact URL | https://galleyweave-weave.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `glw_` |
| User-Agent | `Galleyweave/1.0 (iOS; +https://galleyweave-weave.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Galleyweave -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A home cook seats a main and a side from the cookbook, weaves their steps on one galley rail, and serves when both dishes finish so tonight's pair files on the device.

### 2.1 User flow

1. Tap Seat on the open Main or Side berth and pick a saved recipe from the cookbook
2. Tap Begin when both berths hold recipes so the interleave rail opens and idle sleep stays on
3. Tap the lit weave node to file the next step on the active lane
4. Tap Switch to write a HandoffMark and move focus to the other lane without advancing the queue
5. Search the catalog and save a recipe into the cookbook for later seating
6. Open Settings for catalog credit, peel, and data reset

### 2.2 Essential behaviour

- Two berths on Home; Seat refuses a third recipe until Serve clears the galley
- Weave interleave sorted by step timers and lane; idle timer held only while Weaving
- Cookbook of saved recipes; Search maps cgi search pl onto TheMealDB with local shelf fallback
- HandoffMark history, Peel on the last WeaveMark or HandoffMark, ServedMark stamped under daykey
- No shop, no calories, no meal slots, and no food barcode logging

---

## 3. Uniqueness assignment for Galleyweave

| Axis | Assigned value |
| --- | --- |
| Architecture | **Weave ADT fold (Bare | Seated | Weaving | Served); the galley is a fold over Berths and WeaveNodes; Seat writes a Recipe onto Main or Side and folds Bare to Seated when both berths are filled; Begin folds Seated to Weaving and builds the interleave queue; Tick on the lit node writes a WeaveMark and advances; Switch writes a HandoffMark and swaps lanes without advancing; Serve writes a ServedMark under daykey when both recipes are exhausted and folds Weaving to Served; Begin with an empty berth writes DriftMark; Tick before Weaving writes DriftMark; Peel drops the last WeaveMark or HandoffMark; empty galley writes Cold** |
| UI approach | **SwiftUI SceneKit integration · timeline** |
| Naming convention | **Expeditor / two-plate lexicon (Galley, Berth, Main, Side, Seat, Begin, Weave, WeaveNode, WeaveMark, HandoffMark, ServedMark, DriftMark, Peel, Switch, Tick, Serve)** |
| File organization | **By weave role (Galley, Berth, Main, Side, WeaveNode, WeaveMark, HandoffMark, ServedMark, DriftMark, Recipe, Cookbook, Peel)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **agentic · index-list · branded** |
| Typography | **Georgia** |
| Navigation pattern | **Weave-locked chrome (the dual-berth header and SceneKit interleave rail never leave; Search and Cookbook arrive as sheets; seat and begin fuse in the header; tick and switch fuse on the lit node; Settings from the gear; no tab bar)** |
| AI art style | **Gouache illustration · mixed-media** |
| Functional twist | **Seat-then-weave (both berths must Seat before Begin; Weaving holds idle; Tick advances the lit interleave node; Switch writes HandoffMark without dequeuing; Serve files ServedMark when both recipes finish; DriftMark on Begin or Tick too early; seed fills both berths so Begin is the first live tap)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — recipe_cook

**Core** — A home cook seats a main and a side from the cookbook, weaves their steps on one galley rail, and serves when both dishes finish so tonight's pair files on the device.

**Audience** — Home cooks who often run two dishes at once and need one interleaved step rail with the screen awake, not a blog feed, a single-recipe timer, or a meal tracker.

**User flow**

1. Tap Seat on the open Main or Side berth and pick a saved recipe from the cookbook
2. Tap Begin when both berths hold recipes so the interleave rail opens and idle sleep stays on
3. Tap the lit weave node to file the next step on the active lane
4. Tap Switch to write a HandoffMark and move focus to the other lane without advancing the queue
5. Search the catalog and save a recipe into the cookbook for later seating
6. Open Settings for catalog credit, peel, and data reset

**Essential features**

- Two berths on Home; Seat refuses a third recipe until Serve clears the galley
- Weave interleave sorted by step timers and lane; idle timer held only while Weaving
- Cookbook of saved recipes; Search maps cgi search pl onto TheMealDB with local shelf fallback
- HandoffMark history, Peel on the last WeaveMark or HandoffMark, ServedMark stamped under daykey
- No shop, no calories, no meal slots, and no food barcode logging

**Twist** — Seat-then-weave. Home is the dual-berth galley and SceneKit interleave rail. Seat writes a Recipe onto an empty Main or Side berth; when both berths hold recipes the fold is Seated. Begin folds Seated to Weaving, builds the interleave queue from both recipes, and holds idle sleep. Tick on the lit WeaveNode writes a WeaveMark and advances the queue; timed nodes run locally then auto-advance. Switch writes a HandoffMark and swaps the lit lane without dequeuing. When both recipes exhaust steps, Serve writes a ServedMark for the daykey and folds Weaving to Served. Begin on Bare or with one empty berth writes DriftMark. Tick before Begin writes DriftMark. Peel drops the last WeaveMark or HandoffMark. Seed already Seats a Main and Side so the opening tap is Begin. Home verb: weave-the-galley—not walk-the-fire, not beat-the-spine, not fill-the-jigger. History counts ServedMarks and HandoffMarks, not browse time.

**Why this is not a repeat** — Salamander's home verb is fire-walk taps on one pass ticket after mise bowls; Cookspine scales one recipe and beats a vertical spine after line checks. This product persists pairing two saved recipes and interleaving their steps on one SceneKit rail with explicit HandoffMarks—same family and catalog API, different ADT, navigation chrome, and home verb. It is not food_tracker, cocktail pour logging, or a browse-only recipe site.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Cookbook + cook mode (do-not-sleep steps).
- Invariant: Cook mode: ingredients checked, then numbered steps. Dish-of-the-day is optional chrome.
- Never: Not a shop.
- Desk `seating_harmony`: harmony=clamp(1−viol/seated+0.15*prefs/seated,0,1). Circular neighbors if ≥3.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

GalleyFold is a closed phase set of Bare, Seated, Weaving, and Served, the galley is a pure fold over the Main berth, the Side berth, and the remaining WeaveNodes, and a galley with both berths empty writes Cold and rests as Bare. Seat writes one Cookbook Recipe onto an empty Main or Side berth, refuses any third recipe while both berths are occupied, folds a Served galley or a Cold rest into Bare when the first berth fills, stays Bare while the other berth is empty, and folds Bare to Seated when both berths hold a recipe. Begin on Seated builds the interleave queue and folds Seated to Weaving, idle sleep is held only while the phase is Weaving, and cook mode keeps ingredients checked, then numbered steps, with ingredient WeaveNodes for Main then Side before every step WeaveNode, step nodes sorted by ascending timer, untimed steps after timed steps, Main before Side on a tie, and dish-of-the-day left as optional chrome outside the fold. Tick on an untimed lit WeaveNode writes a WeaveMark and advances, Tick on a timed node starts a local timer that writes that WeaveMark when it fires, Switch writes a HandoffMark and moves the lit lane to the other lane's earliest remaining node without removing the current node, the Tick that leaves both recipes with no remaining nodes writes a ServedMark under the YYYYMMDD daykey and folds Weaving to Served while clearing both berths, Begin while a berth is empty writes DriftMark, Tick outside Weaving writes DriftMark, and Peel during Weaving drops the last WeaveMark or HandoffMark while Peel during Served is refused. Unit tests cover both berths before Begin, the ingredient-then-step order, DriftMark on an early Begin or Tick, a HandoffMark that leaves the queue intact, ServedMark only after both recipes exhaust, Peel, and Cold on an empty galley.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Home is one SwiftUI screen. A dual-berth index sits at the top and one SceneKit timeline fills the remaining height, including on iPad. The SceneKit hero is a single SCNView hosted with UIViewRepresentable. WeaveNodes sit in queue order along that rail, the lit node is the only hero, and every other surface is stock SwiftUI. Search, Cookbook, and Settings are sheets built from List, Form, TextField, and Button, with no second SceneKit view and no TabView. The berth block is a flush-left typographic index: Main is the display line, Side is the quieter title line, and a hairline separates them from the rail, so the two blocks do not share a column structure and there is no row of equal cards. Seat and Begin fuse in that header. Tick and Switch fuse on the lit node. Settings opens from the gear. Radius is 4pt on the rail plate and sheets and 2pt on chips, elevation is one hairline, and the primary control uses the tinted glass material. The live verb wears the accent through a ButtonStyle with default, pressed, disabled, and loading. Reset uses the destructive variant. Rows and the lit control expose default, pressed, focused, disabled, loading, error, and selected, with a word such as Lit, Seated, or Served so color is never the only signal. Hover on iPhone is the pressed state. Hits cover the whole control, at least 44pt, with contentShape on the fill. Grouped index rows reveal in steps of 40 to 60ms and finish within 360ms. Reduce Motion fades the group in at once. One haptic fires on a successful Seat, Begin, Tick, Switch, Serve, or Peel, and none fires on a DriftMark or on opening a sheet. The idle timer is disabled only while Weaving, so the screen stays awake for the weave and sleeps again in every other phase. Empty Cold and empty Cookbook are full pages with generated art, one headline, one line, and a full-width button at the bottom. Cold reads The galley is clear. Seat a main and a side. Cookbook reads The cookbook is empty. Save a meal, then seat it. Search failure reads Search missed. The shelf on this device still has meals. Try again. Reset confirms with Reset this galley? Saved recipes and served nights on this device will be removed. The background fills the safe area. Icon-only controls, including the gear, have VoiceOver labels. Copy is warm and brief and uses periods or commas. The ui axis string is never a visible title.

### 3.3 Naming contract

Convention: Expeditor / two-plate lexicon (Galley, Berth, Main, Side, Seat, Begin, Weave, WeaveNode, WeaveMark, HandoffMark, ServedMark, DriftMark, Peel, Switch, Tick, Serve).

Examples to follow: `GalleyFold`, `seatRecipe(_:on:)`, `WeaveNode`, `HandoffMark`

### 3.4 Dependency contract

Galleyweave ships with zero external dependencies for the dual berth weave. No SPM entry, no CocoaPods, and no vendored source, and project.yml has no packages key. System frameworks are SwiftUI, SceneKit for the one rail hero, UIKit to host that view, Core Graphics, Foundation, and URLSession. AVFoundation stays unlinked, camera permission is never requested, and food barcodes are never read. Search honors cgi search pl with page_size 8 as on-device pagination over GET https://www.themealdb.com/api/json/v1/1/search.php?s= for the query and GET https://www.themealdb.com/api/json/v1/1/lookup.php?i= for a meal id. The meals array is sliced by page and page_size 8. The query debounces about 500ms and cancels the previous task. An empty query does not hit the network. Every request sets User-Agent Galleyweave/1.0 (iOS; +https://galleyweave-weave.pro). A dedicated JSONDecoder uses useDefaultKeys. The DTO maps idMeal and strMeal into a Recipe, strIngredient and strMeasure pairs into ingredient WeaveNodes, and strInstructions into numbered step WeaveNodes, with a minute phrase stored as seconds and every other step stored with zero seconds. Resolved meals cache on device. An empty or failed search shows the bundled shelf plus the cookbook, with a path to try again. The app never calls world.openfoodfacts.org. It stores no calories, no meal slots, and no barcode log. Settings credits TheMealDB as a tappable link to https://www.themealdb.com.

### 3.5 Navigation contract

Weave-locked chrome. The dual-berth header and the SceneKit interleave rail stay on Home for the whole session. Search and Cookbook arrive as sheets. Seat and Begin fuse in the header. Tick and Switch fuse on the lit node. Settings opens from the gear as a sheet. There is no tab bar and Cook is not a pushed scene. Dismissing a sheet returns to the same galley. ProcessInfo.processInfo.arguments is read once after onboarding. If onboarding is still showing, the hook does not fire. ReviewScreen today shows Home, log shows Cookbook, and goals shows Settings. The extra key search shows Search. Those keys are launch arguments, not tabs, and today, log, and goals open three different screens.

### 3.6 Screen composition contract

Weave-root fused cook (Home holds dual berths and the SceneKit interleave timeline with fused seat, begin, tick, and switch; Search, Cookbook and Settings are sheets; Cook is not a pushed scene; no TabView)

Physical screens: Onboarding, Home, Search, Cookbook, Settings.

Onboarding is three full pages. The bottom control is full width and reads Continue, then Next, then START. Skip still finishes onboarding and leaves a Cold galley with an empty cookbook. The simulator seed marks this complete so Home is the first frame.

Home is the mechanic. The header names Main and Side, Seat and Begin sit in that header, and the SceneKit rail uses the remaining height. In the seeded Seated frame Main shows Herb chicken, Side shows Lemon greens, Begin is enabled, and Tick stays disabled until Weaving. Cold is a full page: EmptyHome, the headline The galley is clear, the line Seat a main and a side, and a full-width Seat button. During Weaving the lit node carries Tick and Switch. The last Tick serves, clears the berths, and leaves the line Both dishes are served.

Search is a sheet. The field queries TheMealDB at page size 8, rows are a typographic index, and Save writes the meal into the cookbook. A thumbnail, when present, is framed and clipped inside its row. Failure and an empty result show the bundled shelf instead of an endless spinner, with the line Search missed. The shelf on this device still has meals. and the button Try again.

Cookbook is a sheet of saved recipes plus an index of ServedMarks and HandoffMarks grouped by daykey. Counts use NumberFormatter. Its empty page reads The cookbook is empty. Save a meal, then seat it. The button is Search. Seat from a row writes that recipe onto an empty berth.

Settings is a sheet with the tappable TheMealDB credit, the contact link https://galleyweave-weave.pro/contact-us, replay onboarding, and the destructive reset. Cook is not its own screen. ReviewScreen today opens Home, log opens Cookbook, goals opens Settings, and search opens Search. There is no Today screen, no Scan screen, and no tab bar.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By weave role (Galley, Berth, Main, Side, WeaveNode, WeaveMark, HandoffMark, ServedMark, DriftMark, Recipe, Cookbook, Peel)**

```
Galleyweave/
  Galley/GalleyFold.swift
Galley/GalleyChart.swift
Galley/GalleyStore.swift
Galley/Cold.swift
Galley/HomeView.swift
Galley/OnboardingView.swift
Galley/SettingsSheet.swift
Berth/Berth.swift
Berth/BerthHeader.swift
Main/MainBerth.swift
Side/SideBerth.swift
WeaveNode/WeaveNode.swift
WeaveNode/WeaveRailView.swift
WeaveMark/WeaveMark.swift
HandoffMark/HandoffMark.swift
ServedMark/ServedMark.swift
DriftMark/DriftMark.swift
Recipe/Recipe.swift
Recipe/MealLookup.swift
Recipe/SearchSheet.swift
Cookbook/Cookbook.swift
Cookbook/CookbookSheet.swift
Peel/Peel.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Home
A first-class screen for **Home**. Must render empty, populated and error states.

### 5.3 Search
A first-class screen for **Search**. Must render empty, populated and error states.

### 5.4 Cookbook
A first-class screen for **Cookbook**. Must render empty, populated and error states.

### 5.5 Cook
A first-class screen for **Cook**. Must render empty, populated and error states.

### 5.6 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.7 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.8 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Recipe** — named per this app's convention.
- **CookbookItem** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **agentic · index-list · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FFFFFF` | Screen background |
| `surface` | `#FFFFFF` | Cards, rows, sheets |
| `ink` | `#111827` | Primary text and icons |
| `accent` | `#FF5701` | Primary action, key figure, progress fill |
| `muted` | `#6A6F76` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Galleyweave/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Georgia**

Georgia sets every Galleyweave line from the berth names through the lit weave step. Georgia Bold is the display and the berth names, Georgia Italic is the single playful moment on the lit instruction, and Georgia regular is body and captions, with at most six steps behind one accessor: display, title, headline, body, caption, and micro. Display stays at most two lines and never above 34pt. Body sits on the 17pt step. There is no second family and no bundled font file. Timers, step counts, served counts, and handoff counts go through NumberFormatter, and the timer uses Georgia with monospacedDigit so columns hold still. Sizes come from one type accessor plus ScaledMetric. Dynamic Type may drop a step at the largest size so a berth title truncates at the tail instead of clipping. Day edges use Calendar.current.startOfDay and then fold to an Int in YYYYMMDD form.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **4pt** for cards, sheets and primary surfaces; **2pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **tinted glass** — primary chrome sits on a tinted translucent surface (`Material` plus the accent colour at low opacity), never plain flat colour.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI SceneKit integration · timeline**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI SceneKit integration · timeline** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **agentic** — steal rhythm and restraint, not their colours or logos.

Mood: **Conversational AI-first interface with minimal controls, clear outcomes, and delegated task flows for agentic workflows.**.

Home rhythm (`index-list`, comfortable): Dense typographic index. Table-like, almost no cards.

High-end agency: huge type, air, one accent, hairline depth. Layout `index-list`, density comfortable. Kit 4/2, material, tinted glass. Palette recipe `branded`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

GalleyChart keeps the weave in UserDefaults under the single key glw.chart.v1. The Codable root holds islands, books, sessions, runs, and rhumbs, and those five words stay out of the interface. schemaVersion starts at 1. Islands hold cached catalog meals and bundled shelf ids. Books hold Cookbook recipes with ingredient lines and numbered steps. Sessions hold the live GalleyFold, the Main recipe id, the Side recipe id, the remaining WeaveNode queue, and the lit node id. Runs hold the ordered tape of WeaveMark, HandoffMark, and DriftMark for the open weave. Rhumbs hold ServedMarks, each stamped with a daykey Int in YYYYMMDD form taken from Calendar.current.startOfDay. Idle sleep and the running timer are derived from Weaving and are not stored. GalleyStore is the in-memory source of truth, views never touch UserDefaults, and each mark schedules one debounced save about 400ms later, with an immediate flush when scenePhase leaves active and after reset. A failed decode keeps the key intact, shows a calm error with Reset as the way forward, and if memory has no chart yet starts from a Cold galley. resetAllData deletes that single key and is reachable from Settings. Tests use a private UserDefaults suite. The simulator seed runs once behind glw.demo.v1 under targetEnvironment(simulator), marks onboarding complete, writes Herb chicken, Lemon greens, Butter beans, and Rice pilaf into the cookbook, files one earlier ServedMark and one HandoffMark, and leaves Main and Side already seated so Begin is enabled. It never runs on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Galleyweave/1.0 (iOS; +https://galleyweave-weave.pro)` on every request. Never reuse another app's string.
Use the **cgi search pl page 8** search endpoint for this app.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.food-and-drink`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.food-and-drink
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Seat-then-weave (both berths must Seat before Begin; Weaving holds idle; Tick advances the lit interleave node; Switch writes HandoffMark without dequeuing; Serve files ServedMark when both recipes finish; DriftMark on Begin or Tick too early; seed fills both berths so Begin is the first live tap)

Home is the dual-berth galley and the SceneKit interleave rail, and the persisted verb is weave-the-galley. Seat fills an empty Main or Side from the cookbook, and Begin runs only from Seated, building one queue where ingredients are checked and then numbered steps follow, while Weaving holds idle sleep. Tick files the lit node, a timed node finishes on device and then advances, Switch writes a HandoffMark and changes lane without dequeuing, and the Tick that exhausts both recipes calls Serve to stamp a ServedMark for that daykey. Begin or Tick before Weaving writes DriftMark, and Peel drops the last WeaveMark or HandoffMark. The simulator seed seats a Main and a Side so the first enabled tap is Begin, and history counts ServedMarks and HandoffMarks.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Gouache illustration · mixed-media**


Base prompt, reused and extended for every asset:

```
Gouache illustration, mixed media. Opaque gouache on paper, with visible brush, paper tooth, and scraps of torn paper and cotton thread pressed into the form. Subjects are solid kitchen objects with mass through the center: a two-berth board, a closed cookbook, a short rail of beads, a serving cloth. One playful notch of collage on each subject. Quiet, warm, and brief. No readable words, no numerals, no emoji, no glass, no clay, no neon line, no hollow frame. Use only the assigned palette and add no extra hue.
```

All 15 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `glw_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `glw_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `glw_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `glw_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `glw_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `glw_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `glw_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `glw_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `glw_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `glw_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `glw_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Seat-then-weave (both berths must Seat before Begin; Weaving holds idle; Tick advances the lit interleave node; Switch writes HandoffMark without dequeuing; Serve files ServedMark when both recipes finish; DriftMark on Begin or Tick too early; seed fills both berths so Begin is the first live tap)' feature screen. |
| 11 | `glw_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `glw_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `glw_BerthPlate` | 1024x1024 | **required cutout** | Gouache cutout of one oval serving plate, solid opaque paint, a scrap of torn paper at the rim, transparent corners, distinct from the rail bead. |
| 14 | `glw_RailBead` | 1024x1024 | **required cutout** | Gouache cutout of three beads on a cotton thread, the middle bead larger, opaque painted forms, transparent corners, the interleave rail. |
| 15 | `glw_HandoffThread` | 1024x1024 | **required cutout** | Gouache cutout of a loose cotton thread crossing from one plate edge to another, thread and paint both opaque, transparent corners, a lane change. |

### Prompt per asset

**`glw_AppIcon`** — 1024x1024

```
Gouache mixed-media emblem of a solid two-berth board with a short rail of opaque beads, painted mass filling the canvas edge to edge, no text, no numerals, no alpha, no rounded-corner mask, no shadow past the canvas.
```

**`glw_Splash`** — 1290x2796

```
Vertical gouache still life, a closed cookbook low in the frame, torn paper and thread at the edges, quiet empty middle third for a wordmark, filled canvas, no readable text, no numerals.
```

**`glw_Onboarding1`** — 1024x1536

```
Gouache cutout of a closed cookbook with a cotton thread bookmark, opaque painted subject in the center, transparent corners, torn paper collage, the job of saving a meal.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_Onboarding2`** — 1024x1536

```
Gouache cutout of two solid berth plates joined by a short bead rail, mixed media thread between them, opaque center, transparent corners, the weave of two dishes.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_Onboarding3`** — 1024x1536

```
Gouache cutout of a folded serving cloth beside two finished plates, opaque painted forms, torn paper edge, transparent corners, a night already served.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_EmptyHome`** — 1024x1024

```
Gouache cutout of an empty two-berth board, solid painted wood and paper, fully opaque through the center, transparent corners, calm and waiting.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_EmptyList`** — 1024x1024

```
Gouache cutout of a shut cookbook with a plain cloth tie, opaque pages, transparent corners, mixed-media thread, no writing on the cover.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_CardBackdrop`** — 1200x800

```
Wide gouache field of paper tooth and soft brush, low contrast, filled canvas, no object fighting the type, no readable letters.
```

**`glw_ControlFace`** — 512x512

```
Gouache cutout of one solid rail bead, opaque painted sphere with a thread notch, mass through the center, transparent corners, the lit weave control.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_TwistHero`** — 1024x1024

```
Gouache cutout of two berth plates and a bead rail in one solid emblem, mixed media thread, opaque center, transparent corners, seat then weave.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_SuccessMark`** — 512x512

```
Gouache cutout of a solid filled serving seal, thick painted mass through the middle, torn paper edge, transparent corners, a finished pair.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_HeaderDecor`** — 1200x600

```
Wide gouache ornament of torn paper and a single cotton thread, opaque painted bodies, transparent outer corners, no readable text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_BerthPlate`** — 1024x1024

```
Gouache cutout of one oval serving plate, solid opaque paint, a scrap of torn paper at the rim, transparent corners, distinct from the rail bead.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_RailBead`** — 1024x1024

```
Gouache cutout of three beads on a cotton thread, the middle bead larger, opaque painted forms, transparent corners, the interleave rail.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`glw_HandoffThread`** — 1024x1024

```
Gouache cutout of a loose cotton thread crossing from one plate edge to another, thread and paint both opaque, transparent corners, a lane change.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`glw.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `GalleyweaveTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Galleyweave/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Galleyweave -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Weave ADT fold (Bare | Seated | Weaving | Served); the galley is a fold over Berths and WeaveNodes; Seat writes a Recipe onto Main or Side and folds Bare to Seated when both berths are filled; Begin folds Seated to Weaving and builds the interleave queue; Tick on the lit node writes a WeaveMark and advances; Switch writes a HandoffMark and swaps lanes without advancing; Serve writes a ServedMark under daykey when both recipes are exhausted and folds Weaving to Served; Begin with an empty berth writes DriftMark; Tick before Weaving writes DriftMark; Peel drops the last WeaveMark or HandoffMark; empty galley writes Cold** with no leakage across layers.
- [ ] UI approach matches **SwiftUI SceneKit integration · timeline**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Weave-locked chrome (the dual-berth header and SceneKit interleave rail never leave; Search and Cookbook arrive as sheets; seat and begin fuse in the header; tick and switch fuse on the lit node; Settings from the gear; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Georgia** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Galleyweave
xcodegen generate
xcodebuild build-for-testing -scheme Galleyweave -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.galleyweave.weave/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Galleyweave -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.galleyweave.weave/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Galleyweave -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.galleyweave.weave/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
