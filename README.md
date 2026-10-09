# Galleyweave

Galleyweave is a cook-along for two dishes at once. You save meals, place a main and a second dish, then follow one lit step at a time until both are finished. It is for someone cooking a pair of recipes on one night, not for shopping or tracking calories.

## Architecture

The galley is a closed fold: bare, seated, weaving, served. Seat writes a saved meal onto an empty place. Begin runs only when both places are filled, and it builds one queue where ingredients come first and numbered steps follow. Tick, switch, and serve are folds over that queue. The store keeps one chart in memory and writes it as a single UserDefaults blob, so the screen never talks to the disk itself. A fold fits this product because the night only moves forward by a named step, and an early start or tick is a recorded drift instead of a silent no-op.

## Why this app

The reason to pick Galleyweave is seat-then-weave. Both dishes must be placed before the steps start. While the steps are running, the screen stays awake. Tick marks the lit step, and a timed step finishes on the device before the line advances. Switching dishes writes a handoff and changes which step is lit without dropping the current one. The tick that finishes both recipes stamps that day as served. Starting or ticking too early is recorded, and undo removes the last step or handoff. On the Simulator, a demo night is already placed so the first live tap is Start.

## Art

Gouache illustration, mixed media. Opaque gouache on paper, with visible brush, paper tooth, and scraps of torn paper and cotton thread pressed into the form. Subjects are solid kitchen objects with mass through the center: a two-berth board, a closed cookbook, a short rail of beads, a serving cloth. One playful notch of collage on each subject. Quiet, warm, and brief. No readable words, no numerals, no emoji, no glass, no clay, no neon line, no hollow frame. Use only the assigned palette and add no extra hue.

- `glw_AppIcon`: Gouache mixed-media emblem of a solid two-berth board with a short rail of opaque beads, painted mass filling the canvas edge to edge, no text, no numerals, no alpha, no rounded-corner mask, no shadow past the canvas.
- `glw_Splash`: Vertical gouache still life, a closed cookbook low in the frame, torn paper and thread at the edges, quiet empty middle third for a wordmark, filled canvas, no readable text, no numerals.
- `glw_Onboarding1`: Gouache cutout of a closed cookbook with a cotton thread bookmark, opaque painted subject in the center, transparent corners, torn paper collage, the job of saving a meal.
- `glw_Onboarding2`: Gouache cutout of two solid berth plates joined by a short bead rail, mixed media thread between them, opaque center, transparent corners, the weave of two dishes.
- `glw_Onboarding3`: Gouache cutout of a folded serving cloth beside two finished plates, opaque painted forms, torn paper edge, transparent corners, a night already served.
- `glw_EmptyHome`: Gouache cutout of an empty two-berth board, solid painted wood and paper, fully opaque through the center, transparent corners, calm and waiting.
- `glw_EmptyList`: Gouache cutout of a shut cookbook with a plain cloth tie, opaque pages, transparent corners, mixed-media thread, no writing on the cover.
- `glw_CardBackdrop`: Wide gouache field of paper tooth and soft brush, low contrast, filled canvas, no object fighting the type, no readable letters.
- `glw_ControlFace`: Gouache cutout of one solid rail bead, opaque painted sphere with a thread notch, mass through the center, transparent corners, the lit weave control.
- `glw_TwistHero`: Gouache cutout of two berth plates and a bead rail in one solid emblem, mixed media thread, opaque center, transparent corners, seat then weave.
- `glw_SuccessMark`: Gouache cutout of a solid filled serving seal, thick painted mass through the middle, torn paper edge, transparent corners, a finished pair.
- `glw_HeaderDecor`: Wide gouache ornament of torn paper and a single cotton thread, opaque painted bodies, transparent outer corners, no readable text.
- `glw_BerthPlate`: Gouache cutout of one oval serving plate, solid opaque paint, a scrap of torn paper at the rim, transparent corners, distinct from the rail bead.
- `glw_RailBead`: Gouache cutout of three beads on a cotton thread, the middle bead larger, opaque painted forms, transparent corners, the interleave rail.
- `glw_HandoffThread`: Gouache cutout of a loose cotton thread crossing from one plate edge to another, thread and paint both opaque, transparent corners, a lane change.

## How it differs

Other apps in this batch keep a plan, a hanging quiz, or a single list of records. Galleyweave keeps two dishes and one step line on the home screen for the whole session. Search, saved meals, and settings open as sheets and dismiss back to the same night. There is no tab bar and no separate cook screen.

## Build

From this folder:

```bash
xcodegen generate
xcodebuild build-for-testing -scheme Galleyweave -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Galleyweave -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

Signing stays automatic in the project. The signing flags above are for the local command only.
