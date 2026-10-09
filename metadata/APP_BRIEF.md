<!-- gf-brief source=5615bd817a23ac492a7abfa5f4468ec741cba7f593a9ffdabf9b9f0f93d7455a written=2026-10-09T12:38:43+03:00 -->
# Galleyweave

## What it is

Galleyweave is a cook-along for two dishes at once. A person saves meals, places one on Main and one on Second, then follows a single interleaved line of checks and steps until both dishes are done. It is for someone cooking a pair of recipes on one night, not for shopping lists or calorie tracking.

## Launch and onboarding

A cold launch on a device shows a system launch screen, then three onboarding pages. Each page has **Skip** at the top. **Skip** ends onboarding and opens the empty kitchen.

1. Title **Two dishes, one line.** Body **Save a meal, then fill the open place.** Bottom button **Continue**.
2. Title **Follow the lit step.** Body **Mark it done. Move to the other dish when it needs you.** Bottom button **Next**.
3. Title **Finish the night.** Body **When both dishes are done, the pair stays on this device.** Bottom button **START**.

**Continue** and **Next** move to the next page. **START** ends onboarding and opens the kitchen. Onboarding is English only and does not ask for an account or a permission.

A later launch that already finished onboarding goes straight to the kitchen, with any placed dishes, lit step, saved meals, and served nights still there.

## Screens

There is no tab bar. The kitchen stays on screen. **Saved meals**, **Search**, and **Settings** open over it and **Close** returns to the same night.

### Kitchen (home)

There is no navigation title. The header reads **Cook both tonight**. A gear at the top right is **Settings** and opens **Settings**.

**Main** and **Second** each show a meal title, or **Open** if that place is empty. A status chip shows **Open**, **Seated**, **Lit**, or **Served**.

- **Place** — opens **Saved meals** for the first empty place (Main before Second). Disabled when both places already have a meal.
- **Start** — begins the live line for both dishes. Disabled until both places are filled and the chip is **Seated**.

When both dishes are placed and the night has not started, the heading **The line** lists every check and step in cook order. Each row shows **Main** or **Second**, **Check** or **Step**, a minute figure such as **8 min** when the step has a wait, and the check or step wording. Under the list: **Both dishes are ready. Start when you are.**

When only one place is filled, or both are empty but the kitchen (not the empty-kitchen page) is showing: **Fill both dishes, then start.**

While the night is running, the chip is **Lit**. A step rail of beads replaces **The line**. The lit bead holds:

- Chip **Lit**
- **Main** or **Second**
- The full wait in seconds when the step has one (for example **480**, not a countdown)
- The check or step wording
- **Done** — marks the lit check or untimed step finished and lights the next one. On a timed step, the first tap starts the wait; the control then reads **Timing** and will not take another tap until that wait ends, after which the line moves on its own.
- **Other dish** — lights a remaining check or step on the other dish. The current one stays in the line.
- **Undo** — puts back the last finished check or step, or undoes the last **Other dish**.

A strip shows a count labeled **Served nights** and a count labeled **Lane changes**.

When the last item is finished: **Both dishes are served.** Both places read **Open**, the chip is **Served**, **Place** works again, and **Start** does not.

#### Empty kitchen

Shown when both places are empty and no night is in progress.

- **The kitchen is clear.**
- **Fill a main and a second dish.**
- **Place** — opens **Saved meals** for Main.
- **Settings** (gear).

#### Night that could not be read

- **This night could not be read.**
- **Reset is the way forward.**
- **Reset** — opens **Reset tonight?** with **Saved recipes and served nights on this device will be removed.** Buttons **Reset** and **Cancel**. Confirming **Reset** clears this device and returns to onboarding.
- **Settings** (gear).

### Saved meals

Title **Saved meals**. **Close** dismisses. **Search** opens **Search**.

Empty:

- **Nothing is saved yet.**
- **Save a meal, then place it.**
- **Search**

With meals, section **Saved**. Each row shows the meal title and the number of steps. If this screen was opened from **Place**, the row also shows **Place**; tapping the row seats that meal on the open Main or Second place and closes the screen. If both places are already filled, **Place** on the kitchen is disabled, so this screen cannot be opened from the kitchen.

Section **Nights** lists days that have a served pair or a lane change. Each row shows that day in the device’s medium date style and a line **Served X, handoffs Y**.

### Search

Opened only from **Saved meals**. Title **Search**. **Close** dismisses. Field **Search meals**. Keyboard **Done** dismisses the keyboard.

- Empty field: section **On this device** — meals already on this device (bundled shelf meals and any saved or previously found meals).
- After a short pause while typing: section **Meals** — matching catalog meals, up to eight.
- While a lookup is in flight and the list is still empty: **Looking**.
- No matches, or the lookup fails: **Search missed.** **The shelf on this device still has meals.** **Try again** repeats the lookup. Section **Shelf** still lists meals on this device.

Each row shows the meal title, the number of steps, and **Save**. **Save** adds that meal to **Saved meals**. There is no on-screen confirmation. Saving a meal that is already saved does nothing visible. **Save** does not place the meal and does not close **Search**.

### Settings

Title **Settings**. **Close** dismisses.

- **TheMealDB** — opens the TheMealDB site.
- **Contact** — opens the support page.
- **Replay onboarding** — closes **Settings** and shows the three onboarding pages again. Saved meals and nights stay.
- **Reset** — same **Reset tonight?** dialog as the error page. Confirming **Reset** removes saved recipes and served nights on this device and returns to onboarding.

Footer: **Meals from TheMealDB stay credited. Everything else stays on this device.**

## Features

- Two dishes, one line: a Main and a Second share one cook order.
- **Place** a saved meal on an **Open** place.
- **Saved meals**, including a **Nights** history.
- **Search meals** in the TheMealDB catalog, with a shelf on this device when the lookup misses.
- **Save** a found meal.
- **The line** of **Check** and **Step** items before **Start**.
- **Start** when both dishes are **Seated**.
- A lit bead for the current check or step, with **Done**, **Timing**, **Other dish**, and **Undo**.
- Timed steps wait on this device before the line advances.
- **Served nights** and **Lane changes** counts.
- **Both dishes are served.** when the pair is finished.
- **Replay onboarding**.
- **Reset tonight?** to clear this device.
- **Contact** and a **TheMealDB** credit.
- The screen stays awake while the chip is **Lit**.

## Behaviours that can look like bugs

- **Start** stays dim until both Main and Second have a meal and the chip is **Seated**. Place the second dish, then tap **Start**.
- **Place** stays dim once both places are filled. Finish the night or **Reset** to open a place again. There is no way to open **Saved meals** or **Search** from the kitchen while both dishes are seated or lit.
- **Place** always fills the first empty place (Main first). There is no control to choose Second first.
- There is no control to remove one placed meal. The pair clears when the night is served, or both are removed by **Reset**.
- First **Place** on a new device opens **Nothing is saved yet.** even though four meals already sit on the Search shelf. Tap **Search**, **Save** a meal, **Close** Search, then tap that row (**Place**) in **Saved**.
- **Save** on a meal that is already saved does not change the list and shows no message. Use **Close**, then **Place** from **Saved**.
- **Search meals** does not update on every key. Wait a short pause, or tap **Try again** after **Search missed.**
- Catalog results stop at eight meals. Narrow the words in **Search meals**.
- **Done** on a timed step becomes **Timing** and will not take a tap until the wait finishes. Wait; do not look for a skip control.
- The lit wait shows the full second count (for example **480** for an 8-minute step), not remaining time and not **8 min**.
- **Other dish** does nothing when the other dish has no remaining checks or steps. Keep tapping **Done** on the lit dish.
- **Undo** does nothing before the first **Done** or **Other dish**, and nothing after **Both dishes are served.**
- **Undo** during **Timing** cancels that wait. If that step later already reads **Timing** and refuses a tap, tap **Other dish** or leave the app and open it again, then tap **Done**.
- After **Both dishes are served.**, **Start** stays dim until two meals are placed again.
- After **Reset**, the three onboarding pages appear again. Use **Skip** or finish to **START**.
- **Replay onboarding** also returns to those pages on purpose. Finish or **Skip** to get back to the kitchen; data is still there.
- A night that cannot be read blocks the kitchen with **This night could not be read.** The way forward is **Reset** in the **Reset tonight?** dialog.
- **Served nights** and **Lane changes** grow as nights are finished and **Other dish** is used. **Undo** of a lane change lowers that count. **Reset** returns both to **0**.
- The same saved meal can be placed on both Main and Second if both places are filled from **Saved**.

## Starter content and resume

Four meals are on this device from the first launch. They appear under **On this device** or **Shelf** in **Search**. They are not in **Saved** until **Save**.

- **Herb chicken** — checks **Chicken thighs**, **Thyme**, **Salt**. Steps **Pat the chicken dry and salt it.**, **Sear the thighs for 8 minutes.** (**8 min**), **Rest the chicken.**
- **Lemon greens** — checks **Greens**, **Lemon**, **Oil**. Steps **Rinse the greens.**, **Wilt them for 3 minutes.** (**3 min**), **Finish with lemon.**
- **Butter beans** — checks **Butter beans**, **Garlic**. Steps **Warm the beans for 6 minutes.** (**6 min**), **Stir in the garlic.**
- **Rice pilaf** — checks **Rice**, **Stock**. Steps **Rinse the rice.**, **Simmer the rice for 15 minutes.** (**15 min**)

On a device, onboarding runs and the kitchen is empty until those meals are saved and placed. A first run in the Simulator can skip onboarding, already place **Herb chicken** on Main and **Lemon greens** on Second, and show one served night and one lane change from the day before.

Unfinished work resumes: placed dishes, the remaining line, the lit check or step, saved meals, served nights, and lane changes come back after leaving the app. A **Timing** wait does not; tap **Done** again to start that wait. After a served night, a fresh launch shows **Served** and both places **Open**; the line **Both dishes are served.** may be gone until the next finish.

## Permissions

None.

## Absent

Login or accounts, in-app purchase, ads, analytics, user-generated content (meals are bundled or taken from TheMealDB; the person does not write recipes), account deletion flow, and an App Tracking Transparency prompt are absent.

## Data and support

Saved meals, the open night, and served nights stay on this device. **Search** can look up meals from TheMealDB; the Settings footer states **Meals from TheMealDB stay credited. Everything else stays on this device.**

**Contact** in **Settings** opens the support page.

## Scanning and health

None. The app does not scan barcodes or QR codes. It shows cooking checks and steps, not health, medical, or product-health information. Meal credit is the **TheMealDB** control and footer in **Settings**.

## Platform

English interface (`en`). Night dates follow the device calendar and locale. No region lock.

Portrait only, including iPad. Light appearance only. iPhone and iPad. Full screen on iPad. Minimum iOS 17.0.

## Category

Food & Drink.
