# Project context

`smVendor` is the **forklift operator's** app ("wózkowy") in the transport
orders module - the person who physically moves what somebody ordered. It is
one half of that lifecycle; `../smOrder` (the line foreman who places the
order) is the other, and both sit on the same `orders` tables in
`../wpsapi`. See that repo's AGENTS.md, "Transport orders", for the data
model; this file is about the app.

| app | who uses it | what it does |
|---|---|---|
| `../wpsapi` | - | Express + Postgres backend. Owns all data. |
| `../wps` | office / supervisor | Next.js dashboard, incl. "Lista zamówień" and the requester's accept / report-problem on a delivered order. |
| `../smpda` | warehouse operator | Honeywell PDA: scans and issues the actual stock. |
| **`.` (smVendor)** | **forklift operator** | **Takes an order, watches it fill up, marks it delivered or reports a problem.** |
| `../smOrder` | line foreman | Places transport orders. |

Runs on the operator's own **phone/tablet** (Android), not on a scanner -
so every tap target here is deliberately bigger than wps's compact web
inputs or even smpda's PDA-sized ones.

## The lifecycle this app drives
`new -> in_progress -> delivered` (then wps closes it):
1. **"Rozpocznij realizację"** (`new -> in_progress`) - `OrdersApi.take`.
2. The materials are then issued **in smpda**, scan by scan, not here. This
   app only watches: `OrderDetailPage` polls every 3 s and ticks items off
   as `issuedQuantity` catches up with `quantity`.
3. Once the order **can be handed over** (`TransportOrder.canDeliver`:
   every item issued, or no items at all - water refill, goods transport,
   waste removal and warehouse return have nothing to issue, so they are
   deliverable straight after being taken), two buttons appear side by side:
   - **"Dostarczone"** (`in_progress -> delivered`) - `OrdersApi.deliver`.
     wpsApi re-checks fulfilment server-side, so a stale client cannot mark
     delivery early.
   - **"Zgłoś problem"** (`in_progress -> problem`) - for when everything
     is issued but the delivery itself cannot happen. A **description is
     required** (`_ReportProblemDialog`, enforced server-side too): the
     person who placed the order is being asked to act on it, and a problem
     nobody can read is not a report.
4. A `problem` order shows what is wrong, and **whose turn it is** -
   `TransportOrder.awaitingMyAnswer` (from `problemReportedFrom`) decides:
   - the operator reported it -> read-only here, waiting on the requester,
     who resolves it in smOrder or wps. That puts it back to
     `in_progress`, this app shows "{kto} oznaczył problem jako
     rozwiązany" above the pair of buttons, and the operator can deliver or
     report again.
   - **the requester rejected the delivery** -> it is this operator's to
     put right. They get **"Problem rozwiązany"** (`OrdersApi.resolveProblem`)
     next to a disabled **"Czat"** (deferred; shown so that marking it
     corrected is the obvious choice rather than the only one). The
     rejection already un-delivered the order, so "Dostarczone" has to be
     pressed again afterwards - the handover happens properly the second
     time.
   Neither direction cancels anything: nothing on this side closes an
   order, and the loop can run more than once, from both sides.
5. A `delivered` order is then read-only - it is waiting for the
   requester's "Zgadza się"/"Zgłoś problem", or the 10-minute auto-accept
   sweep in wpsApi.

The full step-by-step history (`GET /orders/:id/events`) is **deliberately
not shown here** - this screen is for what to do now. Reconstructing an
episode afterwards is wps's job (`OrderEventLog`).

Every one of the six types goes through this same path. It did not until
2026-10-01: delivery was refused for an order with no items, so those four
types had no confirmation step and could only be closed from wps.

## Design: `../wps` is the reference
**Take after wps, and not only its palette.** The same order has to read as
the same order in the dashboard and here - one person sees both during a
shift. So: colour/typography/radius from `theme/` (mirroring wps's
`app/globals.css` tokens), and also wps's **patterns** - bordered rounded
cards on the `card` background, status as a coloured pill with the same
per-status colours as its `STATUS_STYLES`, muted secondary text,
label-left / value-right info rows, per-type icons in wps's own per-type
colours. When a screen exists in wps, start from its structure and its
Polish wording ("Zlecający", "Zrealizował", "Wydano", "Zgłoś problem"),
then adapt the *interaction* for a touchscreen (bigger targets, sheets over
centered dialogs). Deviate only for a device-specific reason, and say so in
a comment - e.g. the order items here *are* struck through once issued,
because this screen is a working checklist, unlike smOrder's read-only view.

## Conventions
- **UI is `shadcn_ui`** on `package:flutter/widgets.dart`; Material is
  imported only for single names (`ThemeMode`, `TextInputAction`). `theme/`
  is a copy of smpda's, itself mirroring wps's Tailwind tokens as plain Dart
  hex. Don't add another UI package, and don't reach for `material.dart`
  widgets (`Tooltip`, `IconButton`, `RefreshIndicator` are **not**
  available - there is no `MaterialApp` ancestor; see `ShadApp` in
  `main.dart`).
- **i18n is `slang`**: edit `lib/i18n/pl.i18n.json` / `en.i18n.json`, run
  `dart run slang`. Polish is the base locale.
- **No router.** `login_screen.dart` pushes `widgets/app_shell.dart`
  directly, and the shell owns which tab is selected as plain widget state.
  Added a router only when there is more to navigate than this.
- **The shell is adaptive**: side nav on a wide screen (with a
  collapse-to-icons toggle), bottom bar below `_kWideBreakpoint` (600).
  smOrder deliberately differs - it is bottom-bar only.
- **Live data is plain REST polling**, not GraphQL subscriptions: Hasura's
  own subscriptions are short-interval polling under the hood and wpsApi has
  no per-user auth for them yet, so a 3-5 s `Timer.periodic` (with a
  `_polling` guard, silent on failure, never re-showing the loading state)
  gets the same felt behaviour. Keep that shape.
- **Session is in-memory only** (`core/session/session_providers.dart`), so
  a restart returns to the login screen. smOrder persists its session
  instead - copy that approach here if it is ever wanted.
- **Per-device settings are SharedPreferences-backed** small providers, one
  per concern: `locale_providers.dart`, `theme_providers.dart`. There was a
  third, `device_label_providers.dart`, holding an "Oznaczenie wózka" set on
  the Konto page and sent with every login; it and its input were removed on
  2026-10-02, and wpsApi now logs every login without it.

## Keyboard and system bars (`main.dart`)
Both wrappers sit inside `ShadApp`, so they cover every route pushed later.
- **`_AboveKeyboard`** pads the whole app by `MediaQuery.viewInsets.bottom`
  and strips that inset for everything below it. Android is already told to
  resize (`windowSoftInputMode="adjustResize"`), but that only makes it
  *report* the inset - Material's Scaffold is what normally turns it into
  padding, and these apps have none (shadcn_ui on
  `package:flutter/widgets.dart`), so the keyboard used to sit on top of
  whatever was at the bottom: the chat's send button, "Dostarczone", the
  problem footer. `removeViewInsets` matters: without it a scrolling field
  or a SafeArea counts the inset a second time and leaves a keyboard-sized
  gap.
- **`_SystemBars`** asks for dark status-bar icons on the light theme and
  light ones on the dark theme, reading the **resolved** brightness from
  `ShadTheme` so "system" lands on the right one. An app that asks for
  nothing gets light icons, which are invisible on this app's light
  background - the clock and the battery simply were not there.

## Configuration
`core/api/api_client.dart` has the wpsApi address **hardcoded** (the LAN
address the rest of the family uses) - there is no settings screen like
smpda's. The shared bearer token is **not** in the source (this repo is
public): it is a compile-time define, so run/build with
`--dart-define=API_TOKEN=...`. Without it no header is sent and every call
but login is refused.

## Running it
Android: `flutter run -d <device> --dart-define=API_TOKEN=...`, or
`flutter build apk --debug --dart-define=API_TOKEN=...` +
`flutter install --debug -d <device>` (plain `flutter install` looks for a
**release** apk and fails). `flutter analyze` must be clean.

Browser (the app also runs on web): `flutter build web
--dart-define=API_TOKEN=...`, then `node tool/serve_web.cjs` and open
http://localhost:8765 - or the machine LAN address from a tablet. **Do not
use `flutter run -d web-server`**: it hangs on this machine at "Waiting for
connection from debug service" and the hung process keeps serving an
out-of-date build on whatever --web-port it claimed, which looks exactly
like a change that did not apply. Kill such a leftover before serving.
