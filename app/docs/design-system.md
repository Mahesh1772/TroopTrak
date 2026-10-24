# TroopTrak Design System

The Parade State look of the app: the tokens in `app/lib/core/theme/`, the shared widgets in `app/lib/core/widgets/`, the tally strip, and the rules that drive the colours. Read [ARCHITECTURE.md](ARCHITECTURE.md) first for the layers; this guide covers only how things look and which piece to reach for.

The reference for every value is the approved mockup in `app/design_mockup/` (local and gitignored: `style.css` holds the tokens, `app.js` one render function per screen, `.review/*.png` the approved captures). The mockup is the source for the look; the code is the source for the names. Where the two differ, the code in this guide is what ships.

All sizes are design px on a 390 by 844 phone (`AppLayout.designSize`). Tokens are plain doubles; the call site scales them with `flutter_screenutil` (`.w`, `.h`, `.r`, `.sp`).

## Decisions that shape the system

| # | Decision | Effect |
|---|---|---|
| D3 | Barlow through `google_fonts` with bundled TTFs | `main.dart` sets `GoogleFonts.config.allowRuntimeFetching = false`; every weight used must have a file in `app/lib/assets/google_fonts/` |
| D4 | Built-in `Icons.*_rounded`, no symbols package | The mockup's Material Symbols map to the closest rounded glyph |
| D5 | ScreenUtil design size 390 by 844 | Mockup px map 1:1; `test/helpers/pump_app.dart` uses the same size |
| D6 | Soldiers get the light/dark toggle too | See [D6](#d6-soldiers-get-the-theme-toggle) |
| D9 | New parade-state colour rule | See [D9](#d9-the-parade-state-rule) |
| D10 | "(Next day)" only when the end is not after the start | See [D10](#d10-the-next-day-rule) |
| D11 | Approved copy changes (tab labels, no emoji in titles, "Received", "Search mode", no seasonal banners, splash tagline, Strength/Calendar switch, three-way status switch, duty picker as a bottom sheet) | Built as in the mockup; the Singlish validation copy and the "ADD A NEW SOLDIER" sheet titles are kept as they were |
| D12 | Four additions not in the mockup, kept by Mahesh | See [D12](#d12-what-was-kept-and-why) |

## 1. Theme tokens

Every file below is in `app/lib/core/theme/`. Colours are written only here; `test/architecture_test.dart` fails the build if `Color(0x`, `Color.fromARGB` or `Color.fromRGBO` appears anywhere else in `lib/`.

| File | Holds |
|---|---|
| `app_colors.dart` | `AppColors`: every raw colour constant |
| `app_palette.dart` | `AppPalette`: the theme-aware colours, a `ThemeExtension` with a dark and a light instance |
| `app_radii.dart` | `AppRadii` |
| `app_spacing.dart` | `AppSpacing` |
| `app_layout.dart` | `AppLayout`: fixed sizes and offsets |
| `app_shadows.dart` | `AppShadows` |
| `app_motion.dart` | `AppMotion` |
| `app_text_styles.dart` | `AppTextStyles` |
| `app_tab_indicator.dart` | `AppTabIndicator` |
| `theme_manager.dart` | `ThemeManager` |
| `theme_context.dart` | `ThemeContext` extension on `BuildContext` |
| `app_theme_builder.dart` | `buildAppTheme` and the component themes |
| `dark_theme.dart`, `light_theme.dart` | `darkColorScheme` / `buildDarkTheme`, `lightColorScheme` / `buildLightTheme` |

### Reading colours in a widget

Widgets never read `AppColors` for anything that changes with the theme. They read the palette:

```dart
final palette = context.palette;
Container(color: palette.card);
Text('Name', style: AppTextStyles.h3(palette.onCard));
```

`ThemeContext` (in `theme_context.dart`) adds these getters to `BuildContext`.

| Getter | Returns |
|---|---|
| `context.theme` | `Theme.of(context)` |
| `context.colors` | the `ColorScheme` (`surface`, `onSurface`, `tertiary`, `error`) |
| `context.textStyles` | the `TextTheme` |
| `context.palette` | the `AppPalette` extension |
| `context.isDark` | `true` when the brightness is dark |

`AppColors` is read directly only for colours that do not change with the theme: the `onGradient*` family, `white`, `black`, the brand and status colours, the scrim and the camera tokens.

### AppColors

#### Brand and accent

| Token | Value | Use |
|---|---|---|
| `brandIndigo` | `0xFF481EE5` | Start of the header gradient; dark app bar; `secondary` in both schemes; elevated button |
| `brandViolet` | `0xFF823CE5` | End of the header gradient |
| `accent` | `0xFF8147E6` | Focus ring, selection, progress, tab indicator, `StateTone.accent`, `FractionBar` fill |
| `buttonGradientStart` | `0xFF7E57C2` | Start of the primary button gradient |
| `buttonGradientEnd` | `0xFF512DA8` | End of the primary button gradient; flat FAB colour; button shadow colour |
| `navActiveEnd` | `0xFF5E35B1` | End of `navPillGradient` |
| `navPillGradient` | `[brandIndigo, navActiveEnd]` | Gradient pill behind the active bottom-nav icon |

#### Dark theme surfaces and text

| Token | Value | Palette field |
|---|---|---|
| `darkPrimary` | `0xFF202433` | `ColorScheme.primary`; `navBar` |
| `darkSurface` | `0xFF151922` | `ColorScheme.surface` (scaffold background); `qrInk` |
| `darkCard` | `0xFF2D3241` | `card`; `rankPlateDark` |
| `darkCardElevated` | `0xFF232837` | `cardElevated`; `sheet` |
| `darkPage` | `0xFF0D1016` | `page` |
| `darkPageLine` | `0xFF1C2130` | `pageLine` |
| `darkSecondaryText` | `0xFFB3B8C8` | `secondaryText`; `tooltipDetail` |
| `darkMutedText` | `0xFF8C92A5` | `mutedText` |
| `darkLine` | `0x14FFFFFF` (8% white) | `line` |
| `darkHover` | `0x0FFFFFFF` (6% white) | `hover` |
| `darkTickOff` | `0x21FFFFFF` (13% white) | `tickOff` |
| `darkTickFuture` | `0x0DFFFFFF` (5% white) | `tickFuture` |
| `darkAccentText` | `0xFFB196F5` | `accentText` |
| `darkSuccessText` | `0xFF6CCB70` | `successText` |
| `darkExcuseText` | `0xFFFF9840` | `excuseText` |
| `darkLeaveText` | `0xFFFF7A70` | `leaveText` |
| `darkMedicalText` | `0xFF5AA9F0` | `medicalText` |
| `darkRankPlate` | `0xFFE9EBF4` | `rankPlate` (the light plate under an insignia) |

#### Light theme surfaces and text

| Token | Value | Palette field |
|---|---|---|
| `lightPrimary` | `0xFFDBDBDB` | `ColorScheme.primary`; light app bar |
| `lightSurface` | `0xFFF3F6FE` | `ColorScheme.surface` |
| `lightCard` | `0xFFFFFFFF` | `card`; `sheet` |
| `lightCardElevated` | `0xFFEDEFF7` | `cardElevated`; `rankPlate` |
| `lightPage` | `0xFFE4E8F2` | `page` |
| `lightPageLine` | `0xFFD2D8E6` | `pageLine` |
| `lightSecondaryText` | `0xFF4B5168` | `secondaryText` |
| `lightMutedText` | `0xFF6E7489` | `mutedText` |
| `lightLine` | `0x1412151D` (8% ink) | `line` |
| `lightHover` | `0x0D12151D` (5% ink) | `hover` |
| `lightTickOff` | `0xFFDADEEA` | `tickOff` |
| `lightTickFuture` | `0xFFEBEEF6` | `tickFuture` |
| `lightAccentText` | `0xFF5B2BD0` | `accentText` |
| `lightSuccessText` | `0xFF2E7D32` | `successText` |
| `lightExcuseText` | `0xFFC25400` | `excuseText` |
| `lightLeaveText` | `0xFFC62828` | `leaveText` |
| `lightMedicalText` | `0xFF1565C0` | `medicalText` |

#### Status, success and danger

| Token | Value | Use |
|---|---|---|
| `success` | `0xFF4CAF50` | In-camp green; switch track when on; `StateTone.inCamp` fill; success snackbar icon |
| `danger` | `0xFFF44336` | Error borders, danger outline, delete action; `ColorScheme.error` |
| `warning` | `0xFFFFC107` | Calendar conduct dot (through `palette.warning`); the sun/moon icon on `ThemeToggle` |
| `statusExcuse` | `0xFFFF6F00` | Excuse orange: tick, chip, card gradient start |
| `statusLeave` | `0xFFF44336` | Leave red |
| `statusMedical` | `0xFF1E88E5` | Medical Appointment blue; edit slide action |
| `statusExcuseEnd` | `0xFFE65100` | Dark end of the Excuse card gradient |
| `statusLeaveEnd` | `0xFFC62828` | Dark end of the Leave card gradient |
| `statusMedicalEnd` | `0xFF1565C0` | Dark end of the Medical card gradient |
| `info` | `0xFF2196F3` | Defined, no reader in `lib/` (see [Known gaps](#6-known-gaps)) |
| `calendarDuty` | `0xFFE91E63` | Duty pink: calendar dot, `palette.duty`, `StateTone.duty` |

#### Neutrals and legacy tiles

| Token | Value | Use |
|---|---|---|
| `white` | `0xFFFFFFFF` | Text and icons on gradients, buttons and chips |
| `white70` | `0xB3FFFFFF` | Defined, no reader in `lib/` |
| `white60` | `0x99FFFFFF` (60% white) | Read once, by `scanner_footer.dart` |
| `black` | `0xFF000000` | Light-theme text; the scanner page background |
| `black54` | `0x8A000000` | `palette.shadow`; `AppShadows.tile` |
| `grey` | `0xFF9E9E9E` | `palette.muted` |
| `conductTile` | `0xFF350E91` | `palette.conductTile` (no widget reads it) |
| `personTile` | `0xFF353B4F` | `palette.personTile` (no widget reads it) |
| `personTileMuted` | `0xFF1D202B` | Defined, no reader in `lib/` |
| `tileBorder` | `0x402196F3` | Defined, no reader in `lib/` |
| `chartWoses` | `0xFF2196F3` | Defined, no reader in `lib/` |

#### Tick colours

Three families, one per background. `StateTone` picks among them, see [StateTone](#statetone).

| Background | Tokens |
|---|---|
| On a card | `palette.tickOff` (the "out" grey and the empty track), `palette.tickFuture` (a day not reached yet), plus the palette state fills |
| On the brand gradient | `onGradientTickOff` `0x33FFFFFF`, `onGradientTickFuture` `0x12FFFFFF`, `onGradientInCamp` `0xFF7EE07F`, `onGradientExcuse` `0xFFFFA84D`, `onGradientLeave` `0xFFFF8A80`, `onGradientMedical` `0xFF82C4FF` (white stands in for the accent tone) |

#### On-gradient

For anything drawn on `GradientHeader` or another brand-gradient surface.

| Token | Value | Use |
|---|---|---|
| `onGradientLabel` | `0xCCFFFFFF` (80%) | Small labels; unselected glass segment text; selected date tile caption |
| `onGradientGreeting` | `0xDBFFFFFF` (86%) | Dashboard greeting; duty points card text |
| `onGradientSubtitle` | `0xD1FFFFFF` (82%) | Subtitle under a gradient title |
| `onGradientTickOff` | `0x33FFFFFF` (20%) | "Out" tick on a gradient (one 20% white for the mockup's 18% and 22%) |
| `onGradientTickFuture` | `0x12FFFFFF` | Future tick on a gradient |
| `onGradientInCamp` | `0xFF7EE07F` | In-camp tick on a gradient |
| `onGradientExcuse` | `0xFFFFA84D` | Excuse tick on a gradient |
| `onGradientLeave` | `0xFFFF8A80` | Leave tick on a gradient |
| `onGradientMedical` | `0xFF82C4FF` | Medical tick on a gradient |
| `onGradientTrack` | `0x24FFFFFF` (14%) | Track of the glass `AppSegmentedControl` |
| `onGradientSolidText` | `0xFF2B1580` | Text on a white (solid) surface over the gradient: selected glass segment, solid header pill |
| `onGradientChip` | `0x29FFFFFF` (16%) | Translucent header pill and unit pill (one 16% for the mockup's 15% and 16%) |
| `onGradientPanel` | `0x470A0628` (28%) | Dark panel behind the profile month strip |
| `onGradientBadge` | `0x2E000000` (18%) | Dark badge on a status card |

#### Rank tiles

`AppColors.rankTile(RankGroup)` returns the chip colour for a rank group (`RankChip` uses it). The seven constants are read only through that method.

| Group | Token | Value |
|---|---|---|
| `enlisted` | `rankEnlisted` | `0xFF4E342E` |
| `specialistCadet` | `rankSpecialistCadet` | `0xFF8D6E63` |
| `specialist` | `rankSpecialist` | `0xFF303F9F` |
| `warrantOfficer` | `rankWarrantOfficer` | `0xFF5C6BC0` |
| `officerCadet` | `rankOfficerCadet` | `0xFF004D40` |
| `juniorOfficer` | `rankJuniorOfficer` | `0xFF00695C` |
| `seniorOfficer` and `unknown` | `rankSeniorOfficer` | `0xFF26A69A` |

#### Overlays, shadows, tooltip, camera and QR

| Token | Value | Use |
|---|---|---|
| `scrim` | `0x9E05060C` (62%) | Barrier behind sheets, dialogs and `HeroDialogRoute`; bottom sheet theme |
| `segmentShadow` | `0x59000000` | `AppShadows.segment` |
| `raisedShadowDark` | `0x99000000` | `AppShadows.raised(dark: true)` |
| `raisedShadowLight` | `0x59202433` | `AppShadows.raised(dark: false)` |
| `tooltipBackground` | `0xFF07080C` | Tooltip box, the same near-black in both themes |
| `tooltipDetail` | `darkSecondaryText` | Dimmed detail after the title in a tick tooltip |
| `onCameraText` | `0xE0FFFFFF` (88%) | Hint text over the camera |
| `onCameraLine` | `0x33FFFFFF` (20%) | The hairline of the "OR" divider over the camera |
| `qrInk` | `darkSurface` | The dark modules of the QR code on its white tile |

### AppPalette

A `ThemeExtension<AppPalette>` registered by `buildAppTheme` through `extensions: [palette]`. `AppPalette.dark` and `AppPalette.light` are the two instances. Fields that hold the same value in both themes are marked "same".

| Field | Dark | Light | Use |
|---|---|---|---|
| `card` | `darkCard` | `lightCard` | Cards, list cards, dialogs, date and time picker surfaces |
| `cardElevated` | `darkCardElevated` | `lightCardElevated` | Input fill, segmented track, snackbar, dropdown menu, pickers |
| `onCard` | `white` | `black` | Primary text on a card |
| `muted` | `grey` | same | No widget reads it |
| `shadow` | `black54` | same | Card theme shadow colour |
| `success` | `success` | same | In-camp fill, switch track when on |
| `danger` | `danger` | same | Error border, danger outline, delete action |
| `warning` | `warning` | same | Calendar dot for a conduct (`event_calendar.dart`) |
| `accent` | `accent` | same | Focus, selected chip, tab indicator, accent fills |
| `headerGradient` | `[brandIndigo, brandViolet]` | same | `GradientHeader`, `BrandPlate`, selected date tile |
| `buttonGradient` | `[buttonGradientStart, buttonGradientEnd]` | same | Primary button, FAB colour (the last stop) |
| `conductTile` | `conductTile` | same | No widget reads it |
| `personTile` | `personTile` | same | No widget reads it |
| `onTile` | `white` | same | No widget reads it |
| `statusExcuse` | `statusExcuse` | same | Excuse fill |
| `statusLeave` | `statusLeave` | same | Leave fill |
| `statusMedical` | `statusMedical` | same | Medical fill; edit slide action |
| `page` | `darkPage` | `lightPage` | Reserved page colour (tests read it; no widget does) |
| `pageLine` | `darkPageLine` | `lightPageLine` | Reserved page line (same) |
| `navBar` | `darkPrimary` | `white` | Bottom navigation bar background |
| `sheet` | `darkCardElevated` | `lightCard` | Bottom sheets, `HeroSheet`, the scan result dialog |
| `secondaryText` | `darkSecondaryText` | `lightSecondaryText` | Captions, meta lines, field labels, idle tabs |
| `mutedText` | `darkMutedText` | `lightMutedText` | Hints, field labels inside a field, empty-state icons |
| `line` | `darkLine` | `lightLine` | Hairlines, dividers, field borders at rest, tab bar divider |
| `hover` | `darkHover` | `lightHover` | Row hover; tint of the `out` tone |
| `tickOff` | `darkTickOff` | `lightTickOff` | "Out" tick, switch track when off, `FractionBar` and loader track, sheet handle |
| `tickFuture` | `darkTickFuture` | `lightTickFuture` | Tick for a day not reached yet |
| `accentText` | `darkAccentText` | `lightAccentText` | Accent text, cursor, tonal button text, mascot tint |
| `successText` | `darkSuccessText` | `lightSuccessText` | Text on a green tint |
| `excuseText` | `darkExcuseText` | `lightExcuseText` | Text on an orange tint |
| `leaveText` | `darkLeaveText` | `lightLeaveText` | Text on a red tint; every field error line |
| `medicalText` | `darkMedicalText` | `lightMedicalText` | Text on a blue tint |
| `rankPlate` | `darkRankPlate` | `lightCardElevated` | Plate under a dark-ink insignia |
| `rankPlateDark` | `darkCard` | `darkCard` | Plate under the pale warrant-officer insignia |
| `duty` | `calendarDuty` | same | Duty pink |

`copyWith` accepts only `card` and `onCard`; `lerp` snaps to the nearer palette instead of blending. Colour schemes: dark uses `primary darkPrimary`, `secondary brandIndigo`, `tertiary white`, `surface darkSurface`, `onSurface white`; light uses `primary lightPrimary`, `secondary brandIndigo`, `tertiary black`, `surface lightSurface`, `onSurface black`; both use `error danger`.

### AppRadii

| Token | px | Use |
|---|---|---|
| `xs` | 5 | `RankChip` |
| `sm` | 8 | `IconPlate`, tooltip |
| `md` | 10 | Country chip, past-status plate |
| `lg` | 12 | Default input, card theme, dialog, snackbar, dropdown menu |
| `segmented` | 13 | Outer radius of the segmented control (the inner segment is 13 minus the 3 px frame) |
| `control` | 14 | Date button on `DateHeader` |
| `tile` | 16 | Date tile, nav indicator shape, `BrandPlate`, month strip panel |
| `reticle` | 18 | Scanner reticle |
| `xl` | 20 | Cards, `AppListCard`, FAB |
| `sheet` | 28 | Top corners of a sheet |
| `pill` | 30 | Fully rounded bars (`LinearLoader`) |
| `sheetCorners` | `BorderRadius.vertical(top: 28)` | Sheet shape |

### AppSpacing

| Token | px | Typical use |
|---|---|---|
| `xxs` | 2 | Default tick gap, gap between title and meta, segment gap |
| `xs` | 4 | Label inset, tab label padding, icon gaps, wide duty tick gap |
| `inline` | 6 | Gap between an icon and its label, label above a field |
| `sm` | 8 | Row gaps, chip padding |
| `tight` | 10 | Calendar and parade-card gaps |
| `md` | 12 | Row gap, form field spacing, sticky bar vertical padding |
| `control` | 14 | Field and row inner padding |
| `lg` | 16 | Page side padding, form side padding |
| `xl` | 20 | Section and sheet side padding |
| `xxl` | 24 | Auth and onboarding side padding (the mockup's 24) |
| `xxxl` | 32 | Bottom padding under a tab list |

### AppLayout

Fixed sizes. A value used by one widget alone stays a private constant in that file; it moves here once a second file needs it.

#### Shell

| Token | Value | Use |
|---|---|---|
| `designSize` | 390 by 844 | `ScreenUtilInit` and the widget-test view |
| `navBarHeight` | 84 | `NavigationBarTheme` height |
| `shellNavBarHeight` | 62 | Height the shell passes; SafeArea adds the 22 px inset to reach the mockup's 84 |
| `navPill` | 60 by 32 | Gradient pill behind the active tab icon |
| `appBarHeight` | 56 | Shell app bar, `PageTitle`, form app bar |
| `fabSize` | 60 | FAB theme size |
| `fabIconSize` | 28 | FAB icon |

#### Header and profile

| Token | Value | Use |
|---|---|---|
| `headerBottom` | 22 | Default space under the child of `GradientHeader` |
| `overlapHeaderBottom` | 64 | Space under the dashboard header so a card can overlap it |
| `headerOverlap` | 48 | How far the dashboard card rises over the header |
| `headerPillHeight` | 36 | `HeaderPillButton` |
| `headerPillIcon` | 20 | Icon in a header pill |
| `unitChipHeight` | 30 | Unit pills on the profile header |
| `profileTick` | 26 | Tick height of the month strip |
| `profileIdTop` | 6 | Defined, no reader in `lib/` |
| `profileUnitTop` | 16 | Gap above the unit pills |
| `profileActionTop` | 14 | Gap above the action pills |
| `profileMonthTop` | 18 | Gap above the month strip |
| `tabIconSize` | 19 | Icon in an `IconTab` |
| `tabIndicatorHeight` | 3 | Tab underline thickness |
| `tabIndicatorInsetFraction` | 0.14 | Share of the tab width left clear at each end of the underline |
| `segmentHeight` | 38 | Segment inside the segmented control |
| `segmentFrame` | 3 | Frame around the segments |

#### List and cards

| Token | Value | Use |
|---|---|---|
| `sectionTop` | 28 | Space above a `SectionHeader` |
| `sectionBottom` | 10 | Space below a `SectionHeader` |
| `listRowMinHeight` | 62 | `AppListRow` |
| `listRowVertical` | 10 | Vertical padding in a row |
| `listDividerInset` | 66 | Default hairline inset (clears a 40 px plate) |
| `listFabClearance` | 96 | Bottom padding of a list under a FAB |
| `reportRowMinHeight` | 48 | Parade report row |
| `definitionRowMinHeight` | 50 | `DefinitionList` row |
| `definitionInset` | 18 | `DefinitionList` side padding |
| `columnHeaderHeight` | 38 | `ListColumnHeader` |
| `leaderboardRankColumn` | 44 | Rank column width |
| `leaderboardPointsColumn` | 92 | Points column width |
| `leaderboardFigure` | 30 | Rank figure plate |
| `leaderboardBar` | 6 | Points bar height |
| `sortArrow` | 18 | Sort direction arrow |
| `iconPlateSize` | 32 | `IconPlate` |
| `iconPlateIcon` | 20 | Icon inside it |
| `slideActionExtent` | 0.18 | Share of the row width per slide action |
| `badgeVertical` | 3 | Vertical padding of a status badge |
| `statusCardWidth` | 236 | Active status card |
| `statusCardIcon` | 24 | Type icon on a status card |
| `statusCardNameTop` | 18 | Gap above the status name |
| `statusCardDelete` | 40 | Delete button on a status card |
| `statusCardDeleteInset` | 6 | Its inset from the corner |
| `dateButtonSize` | 48 | Calendar button on `DateHeader` |
| `dateTile` | 54 by 72 | `HorizontalDateStrip` tile |

#### Field and search

| Token | Value | Use |
|---|---|---|
| `fieldLineHeight` | 24 | Line height inside a 52 px field (14 + 24 + 14) |
| `fieldIconSize` | 20 | `FieldIcon` and the password eye |
| `searchHeight` | 46 | `AppSearchField` pill |
| `searchIconSize` | 24 | Magnifier |
| `emptyIconSize` | 40 | `EmptyState` icon |
| `emptyVertical` | 36 | `EmptyState` vertical padding |

#### Button

| Token | Value | Use |
|---|---|---|
| `buttonHeight` | 50 | Regular `PrimaryButton` |
| `buttonTonalHeight` | 40 | Tonal button |
| `buttonCompactHeight` | 36 | Compact button |
| `buttonTonalCompactHeight` | 32 | Compact tonal button |
| `buttonIconSize` | 20 | Icon in a button |

#### Sheet

| Token | Value | Use |
|---|---|---|
| `sheetHandle` | 40 by 4 | Grab handle |
| `sheetTop` | 10 | Space above the handle |
| `sheetHandleGap` | 14 | Space below the handle |
| `sheetBottom` | 34 | Minimum bottom clearance |
| `sheetMaxHeightFraction` | 0.9 | Tallest a sheet may grow |
| `sheetCloseButton` | 44 | Close button on the QR sheet |

#### Tally

| Token | Value | Use |
|---|---|---|
| `tallyTall` | 46 | Tick height on the dashboard parade card |

The other tick heights are named under Profile (`profileTick`), Conduct and Duty.

#### Calendar

| Token | Value | Use |
|---|---|---|
| `calendarNavButton` | 44 | Previous and next month buttons |
| `calendarDayHeight` | 46 | Day cell |
| `calendarRowGap` | 4 | Gap between week rows |
| `calendarDot` | 5 | Event dot under a day |
| `calendarLegendDot` | 8 | Dot in the legend |
| `calendarSectionTop` | 22 | Space above the day's event list |
| `calendarEventBar` | 4 by 40 | Coloured bar at the start of an event row |
| `calendarMutedOpacity` | 0.5 | Days of the neighbouring months |
| `calendarTodayRing` | 1.5 | Ring on today |
| `calendarEventTime` | 64 | Width of the time column |

#### Conduct

| Token | Value | Use |
|---|---|---|
| `conductBadge` | 48 | Count badge or tick/cross plate on a conduct card |
| `conductBadgeIcon` | 26 | Icon in it |
| `conductTick` | 18 | Tick height on the conduct card |
| `conductDetailsTick` | 28 | Tick height on the details header |
| `conductDetailsStripTop` | 18 | Gap above that strip |
| `conductFormTick` | 22 | Tick height on the live "Added" strip |

#### Duty

| Token | Value | Use |
|---|---|---|
| `dutyPointsChip` | 26 | "1.5 PTS" chip height |
| `dutySlotBar` | 10 | Tick height of the 10-slot bar |
| `dutyParticipantVertical` | 7 | Vertical padding of a participant row |
| `dutySlotHeight` | 86 | Slot tile in the duty form |
| `dutySlotPlate` | 34 | Plate in a slot |
| `dutySlotAddIcon` | 24 | Plus icon in an empty slot |
| `dutyPickerHeight` | 578 | Fixed height of the picker sheet content |

#### QR

| Token | Value | Use |
|---|---|---|
| `qrTile` | 248 | White tile holding the code |
| `qrTilePadding` | 18 | Padding inside it |
| `qrHelpBottom` | 18 | Space under the help text |
| `qrCountdownFigure` | 26 | Countdown digits |
| `qrDrainBar` | 4 | Height of the draining bar |

#### Scan

| Token | Value | Use |
|---|---|---|
| `scanReticle` | 250 | Reticle square |
| `scanReticleCenter` | 0.417 | Vertical centre of the reticle as a share of the screen |
| `scanBracket` | 40 | Corner bracket length |
| `scanBracketStroke` | 4 | Bracket stroke |
| `scanLineStart` | 18 | Scan line start offset |
| `scanLineEnd` | 228 | Scan line end offset |
| `scanLineInset` | 14 | Side inset of the scan line |
| `scanLineHeight` | 2 | Scan line thickness |
| `scanFooterGap` | 23 | Gap in the scanner footer |
| `scanDividerGap` | 26 | Gap around the "OR" divider |
| `scanControl` | 44 | Torch, camera switch and start/stop buttons |
| `scanControlIcon` | 24 | Their icons |
| `scanResultBadge` | 64 | Badge on the result dialog |
| `scanResultIcon` | 34 | Icon in it |

#### Splash and onboarding

| Token | Value | Use |
|---|---|---|
| `splashLogo` | 230 | Splash logo width |
| `splashLoaderTop` | 40 | Gap above the loader |
| `loaderTrack` | 120 by 3 | `LinearLoader` track |
| `loaderFill` | 0.4 | Share of the track the moving segment covers |
| `loaderStart` | -1.0 | Segment start offset, in segment widths |
| `loaderEnd` | 2.6 | Segment end offset |
| `onboardingGap` | 28 | Gap between blocks on role selection and welcome |
| `onboardingLogo` | 120 | Logo width on those pages |
| `onboardingLogoShift` | 10 | Optical shift of that logo |
| `roleCardPadding` | 18 | Role card padding |
| `roleCardBorder` | 1.5 | Role card border at rest |
| `roleCardBorderSelected` | 2 | Border when selected |
| `roleRadio` | 24 | Radio ring |
| `roleRadioDot` | 12 | Radio dot |

#### Auth

| Token | Value | Use |
|---|---|---|
| `mascotHeight` | 132 | `BrandMascot` on phone entry |
| `brandPlate` | 64 | `BrandPlate` |
| `brandPlateIcon` | 36 | Its icon |
| `checklistIcon` | 18 | Password checklist icon |
| `pageBackButton` | 44 | `PageBackButton` |
| `phoneFieldHeight` | 58 | Phone number field |
| `countryChipHeight` | 44 | "+65" chip |
| `countryChipIcon` | 18 | Its icon |
| `otpBoxHeight` | 60 | One OTP box |
| `otpBorder` | 1 | OTP box border |
| `otpBorderActive` | 2 | Focused OTP box border |
| `otpCursor` | 2 by 22 | OTP cursor |

### AppShadows

| Member | Value | Use |
|---|---|---|
| `tile` | blur 2, spread 2, offset (10, 10), `black54` | Defined, no reader in `lib/` |
| `segment` | blur 6, spread -2, offset (0, 2), `segmentShadow` | Selected segment |
| `button(color)` | blur 18, spread -10, offset (0, 8), `color` at 90% | Primary button glow, given `buttonGradient.last` |
| `scanLine(color)` | blur 14, spread 2, offset (0, 4), `color` at 45% | Scan line glow |
| `raised({required bool dark})` | blur 32 / 28, spread -12 / -14, offset (0, 12), `raisedShadowDark` / `raisedShadowLight` | The dashboard parade card; pass `context.isDark` |

### AppMotion

| Token | Value | Use |
|---|---|---|
| `quick` | 200 ms | Segment, date tile and nav pill transitions |
| `standard` | 250 ms | Tally tick highlight and fade |
| `second` | 1 s | QR drain bar glide |
| `scanSweep` | 2400 ms | One pass of the scan line |
| `loaderSweep` | 1400 ms | One pass of the loader |
| `ease` | `Cubic(0.16, 1, 0.3, 1)` | The one curve for every transition |

Looping animations (`LinearLoader`, the scan line) hold still when `MediaQuery.disableAnimations` is true, so reduced-motion users and `pumpAndSettle` both settle.

### AppTextStyles

Two families: Barlow for text and Barlow Condensed for figures. Every method takes a colour and returns a `TextStyle` with the size scaled by `.sp`. Both builders assert the weight range, because `google_fonts` throws when a weight has no bundled file.

| Member | Size / weight | Use |
|---|---|---|
| `barlow(size, weight, color)` | any / w400 to w700 | The base builder; use it for one-off sizes |
| `figure(size, weight, color)` | any / w500 to w700, Barlow Condensed, tabular figures | Numbers, times, counts, ranks |
| `pageTitle` | 24 / w600 | Shell app bar and `PageTitle` |
| `profileName` | 24 / w700, tracking 0.01 em, height 1.1 | Name on the profile header |
| `headerTitle` | 28 / w700, height 1.1 | Title on a gradient header |
| `screenTitle` | 32 / w700, height 1.1 | Title of an auth or onboarding page |
| `screenSubtitle` | 16 / w400 | Subtitle under `screenTitle` |
| `tagline` | 17 / w400 | Splash tagline |
| `optionTitle` | 20 / w700 | Role card title |
| `phoneNumber` | figure 21 / w500, tracking 0.06 em | Phone number field |
| `otpDigit` | figure 28 / w600 | OTP digit |
| `compactTitle` | 20 / w600 | Form app bar title |
| `subtitle` | 14.5 / w400 | Form subtitle |
| `link` | 14.5 / w600 | Text links |
| `h2` | 18 / w600 | Card titles (the parade card) |
| `h3` | 16 / w600 | Section headers, row titles |
| `caption` | 13 / w400 | Captions, tally labels |
| `badge` | 13 / w600 | Badges on status cards |
| `cardTitle` | 21 / w700 | Status card name |
| `overline` | 12.5 / w700, tracking 0.08 em | Small uppercase label |
| `columnHeader` | 13 / w600, tracking 0.04 em | Column headings |
| `rowLabel` | 15 / w600, tracking 0.04 em | Uppercase tone-coloured row label (BOOK IN, BOOKOUT) |
| `textTheme(color)` | see below | The `TextTheme` of both themes |

`textTheme` maps `displayLarge` 28 bold, `displayMedium` 24 bold, `displaySmall` 20 bold, `headlineLarge` 18 bold, `headlineMedium` 16 bold, `headlineSmall` 14 bold, `titleLarge` 18 w500, `titleMedium` 16 w500, `titleSmall` 14 w500, `bodyLarge` 16, `bodyMedium` 16, `bodySmall` 14, `labelLarge` 16 w600, `labelMedium` 14 w500 and `labelSmall` 12 w500.

Bundled fonts (`app/lib/assets/google_fonts/`): Barlow Regular, Medium, SemiBold, Bold; Barlow Condensed Medium, SemiBold, Bold; `Barlow-OFL.txt`.

### AppTabIndicator

A `Decoration` for the tab bar underline: a bar `thickness` tall at the bottom of the tab, inset by `insetFraction` of the tab width on each side, rounded on its top corners. `UnderlineTabIndicator` takes pixel insets and cannot keep the same proportions across two and three tabs; this takes a fraction. Constructor: `AppTabIndicator({color, thickness, insetFraction})`. The tab bar theme uses `palette.accent`, `AppLayout.tabIndicatorHeight` and `AppLayout.tabIndicatorInsetFraction`.

### ThemeManager

A `ChangeNotifier` that holds the light or dark mode.

| Member | Behaviour |
|---|---|
| `ThemeManager({initialMode = ThemeMode.dark, onChanged})` | Starts dark unless told otherwise; a bare `ThemeManager()` saves nothing |
| `themeMode`, `isDark` | Current mode |
| `toggle()`, `setDark(bool)` | Switch; `setDark` ignores a request for the current mode |
| `onChanged` | Called with the new mode after `notifyListeners`, and only on a real change |

The choice is saved. `PreferencesService.isDarkTheme` returns `bool?` (null when nothing is saved) and `setDarkTheme(bool)` writes it under `PrefKeys.themeDark`, the key `theme_dark`. `AppDependencies.createThemeManager()` (in `core/di/injection.dart`) starts from the saved mode, dark unless a light choice is saved, and saves on every change. A `CacheException` while saving is swallowed, so the choice still applies for the current run. `App` reads `themeManager.themeMode` for `MaterialApp.themeMode` and builds both themes once.

### Component themes (`app_theme_builder.dart`)

`buildAppTheme({scheme, palette, appBarColor})` is the one place Material components are themed. `buildDarkTheme()` passes `darkColorScheme`, `AppPalette.dark` and `brandIndigo` as the app bar colour; `buildLightTheme()` passes `lightColorScheme`, `AppPalette.light` and `lightPrimary`.

| Theme | What it sets |
|---|---|
| `navigationBarTheme` | 84 high on `palette.navBar`; transparent indicator (the shell paints the gradient pill); label 12.5, w600 selected and w500 idle; selected icon white, idle `secondaryText` |
| `switchTheme` | White 24 px thumb in both states (a blank thumb icon forces it); track `palette.success` when on and `tickOff` when off; no outline |
| `segmentedButtonTheme` | 38 px segment inside a 3 px frame in `cardElevated`; selected segment `card`; radius 13; label 14.5 w600; callers pass `showSelectedIcon: false` |
| `bottomSheetTheme` | `palette.sheet`, 28 px top corners, scrim barrier, drag handle in `tickOff` at 40 by 4 |
| `tabBarTheme` | 13 w600 labels tracked 0.06 em, `labelPadding` 4 by 1 so a one-line label fits a third of the screen, `AppTabIndicator`, 1 px `line` divider |
| `inputDecorationTheme` (`buildInputDecorationTheme(palette, {radius, fill})`) | Filled with `cardElevated`, 14 px padding (52 px field), 1 px `line` border at rest, 2 px `accent` focus border, 2 px `danger` error border, all drawn inside the box; error text 13.5 in `leaveText`; hint and label in `mutedText`; prefix and suffix icons in `secondaryText` |
| `chipTheme` | Stadium shape; `cardElevated` at rest, `accent` when selected; no check mark; 1 px `line` border that turns transparent when selected; 14.5 w500 label that turns white when selected |
| `floatingActionButtonTheme` | Radius 20 (`AppRadii.xl`), 60 px square, 28 px icon, flat colour `buttonGradient.last` |
| `tooltipTheme` | `tooltipBackground` box, radius 8, 13 w500 white text, 10 by 6 padding |
| App bar | `appBarColor`, no elevation, `headlineLarge` title |
| Card | `palette.card`, elevation 2, radius 12, no margin |
| Dialog | `palette.card`, radius 12 |
| Text selection | `accentText` cursor and handles, `accent` selection at 45% |
| Elevated and text buttons | `brandIndigo` fill / `accent` text; `labelLarge` |
| Progress indicator | `accent` |
| Snackbar | Floating, `cardElevated`, radius 12 |
| Date and time pickers | `accent` header, day, hour, minute and dial hand; `card` surface; `cardElevated` dial |

## 2. Core widgets

All in `app/lib/core/widgets/`, 46 files. Parameters marked `*` are required. Defaults are in parentheses.

### Layout and pages

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `StickyCtaPage` (`sticky_cta_page.dart`) | The one scroll-plus-pinned-button page shell: a `Scaffold` whose children scroll and whose CTA stays above the keyboard. Use it for every page with one primary action. A `formKey` wraps the children in a `Form` that validates on user interaction | `children*`, `cta*`, `appBar`, `formKey`, `horizontal` (`AppSpacing.xxl`), `top` (`AppSpacing.xl`), `spacing` (0), `crossAxisAlignment` (start) | none |
| `FormPageScaffold` (`form_page_scaffold.dart`) | A form page on top of `StickyCtaPage`: 16 px sides, 12 px between fields, stretch, an optional app bar title and a subtitle. Use it for add and edit forms | `formKey*`, `children*`, `cta*`, `title` (no app bar when null), `subtitle` | none |
| `StickyCtaBar` (`sticky_cta_bar.dart`) | The strip that holds the primary action: surface colour, clears the home indicator, rides above the keyboard. `StickyCtaPage` already includes it; use it alone only inside a hand-built column | `child*`, `horizontal` (`AppSpacing.lg`) | none |
| `PageTitle` (`page_title.dart`) | The 56 px title row for soldier-side tab pages that the shell shows without an app bar | `title` (positional) | none |
| `GradientHeader` (`gradient_header.dart`) | The brand gradient that runs behind the status bar, with a light status-bar overlay. The child sets its own side padding. Use for dashboard, profile, conduct details | `child*`, `bottom` (`AppLayout.headerBottom`) | none |
| `DateHeader` (`date_header.dart`) | "October 8, 2026" over "Today" (or the weekday), a calendar button and an optional action on the right | `date*`, `today*`, `onPickDate*`, `pickerKey`, `action` | `pickerKey` (callers pass `pickConductDay`, `pickDutyDay`) |
| `PageBackButton` (`page_back_button.dart`) | A 44 px back arrow for a page with no app bar, tooltip "Back", shifted 12 px left so it lines up with the title | none | none |
| `AppScaffold` (`app_scaffold.dart`) | A thin `Scaffold` with an optional app bar and safe area. Only the router's not-found page uses it; do not use it for new pages | `body*`, `title`, `actions`, `leading`, `floatingActionButton`, `bottomNavigationBar`, `safeArea` (true) | none |

### Lists and rows

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `AppListCard` (`app_list_card.dart`) | A rounded card of stacked rows with an inset hairline between neighbours. Use for every list of rows | `children*`, `header`, `dividerInset` (66; use 0 for rows with no leading plate), `color` | none |
| `AppListRow` (`app_list_card.dart`) | One row: leading, a one-line title over an optional subtitle, trailing. Disabled rows fade to 45% and ignore taps; `dimmed` fades but stays tappable | `title*`, `leading`, `subtitle` (a widget; plain `Text` gets the meta style), `trailing`, `onTap`, `titleStyle`, `enabled` (true), `dimmed` (false) | caller's |
| `SoldierRow` (`soldier_row.dart`) | A soldier in a list: `RankPlate`, title-cased name, `RankChip` and a note. Use wherever a soldier is listed with an action | `soldier*`, `note*`, `trailing`, `onTap`, `dimmed` (false) | `person-<name>` |
| `DefinitionList` (`definition_list.dart`) | A card of label and right-aligned value rows, for read-only details | `entries*` (a list of `(label, value)` records) | none |
| `SectionHeader` (`section_header.dart`) | An `h3` heading with an optional caption on the right, such as a count | `title` (positional), `caption`, `padding` (xl sides, 28 above, 10 below) | none |
| `ListColumnHeader` (`list_column_header.dart`) | The two column titles above the rows of an `AppListCard`, as the card's `header` | `start*`, `end*` | none |
| `SlidableRow` (`slidable_row.dart`) | Slide a row left for edit and delete. A null callback drops its action; with neither, the child is returned unchanged | `child*`, `onEdit`, `onDelete`, `editKey`, `deleteKey` | `editKey`, `deleteKey` (callers pass `editStatus-<id>`, `deleteAttendance-<id>` and so on) |
| `AppSearchField` (`app_search_field.dart`) | A 46 px pill with a magnifier. The only file allowed to use `Icons.search` | `onChanged*`, `controller`, `hintText` ("Search..."), `fill` | caller's |
| `AppCard` (`app_card.dart`) | A plain rounded card on `palette.card` | `child*`, `padding`, `color`, `radius` (`AppRadii.xl`) | none |

### Fields

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `AppTextField` (`app_text_field.dart`) | A text field with the label above, an icon inside, a hint and a validator. An `obscureText` field ends in an eye with the tooltips "Show password" and "Hide password" | `controller*`, `label`, `hintText`, `icon`, `validator`, `keyboardType`, `obscureText` (false) | caller's |
| `AppDropdownField<T>` (`app_dropdown_field.dart`) | A dropdown laid out like the other fields | `items*`, `onChanged*`, `hintText*`, `label`, `value`, `itemLabel`, `validator`, `prefixIcon` | caller's |
| `DatePickerField` (`picker_fields.dart`) | A tappable field that opens the date picker and shows the day in tabular figures. With a `validator` it joins `Form.validate()`. `invalid` draws only the error border, for two side-by-side fields that share one message | `onChanged*`, `firstDate*`, `lastDate*`, `hintText*`, `label`, `value`, `initialDate`, `icon` (`calendar_month_rounded`), `errorText`, `invalid` (false), `validator` | caller's |
| `TimePickerField` (`picker_fields.dart`) | The same for time; a `note` (such as "next day") sits after the picked time | `onChanged*`, `hintText*`, `label`, `value`, `initialTime` (9:00), `icon` (`access_time_rounded`), `errorText`, `validator`, `note` | caller's |
| `LabeledField` (`field_chrome.dart`) | Puts a label above any field, as every field in the mockup does. No label means just the child | `child*`, `label` | none |
| `FieldIcon` (`field_chrome.dart`) | The leading icon of a field, 14 px from the edge. Pair it with `fieldPrefixConstraints` | `icon` (positional), `size` (`AppLayout.fieldIconSize`) | none |
| `FieldError` (`field_chrome.dart`) | A field's error line: an `InlineError` pulled back under the label. The field widgets use it for you | `message` (positional) | none |
| `fieldPrefixConstraints`, `fieldValueStyle` (`field_chrome.dart`) | The prefix constraints to pass to a decoration; the tabular-figure style for a picked value (17 w500, 24 px line) | `fieldValueStyle(context)` | none |
| `InlineError` (`inline_error.dart`) | An error line with an `error_rounded` icon in `leaveText`. Use for a message that belongs to a group of fields, or inside a sheet where a snackbar would sit behind it | `message` (positional) | none |
| `ProfileFormController`, `ProfileFormFields` (`profile_form_fields.dart`) | The soldier profile fields shared by register, profile capture and add/edit soldier. The controller holds the values; the fields validate through `SoldierValidators` | controller: `today` (commander forms default the dates to it; profile capture leaves them empty). Fields: `controller*`, `ranks*`, `nameValidator*`, `today*`, `nameLabel` | `profile-name`, `profile-appointment`, `profile-ration`, `profile-rank`, `profile-blood`, `profile-dob`, `profile-company`, `profile-platoon`, `profile-section`, `profile-enlistment`, `profile-ord` |

### Buttons, chips and plates

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `PrimaryButton` (`primary_button.dart`) | The pill button. `PrimaryButtonStyle.primary` is the gradient main action; `ghost` a neutral outline; `danger` a red outline for deletes; `tonal` a 40 px tinted pill beside a title. Disabled drops to 40% opacity; `loading` swaps the label for a spinner | `label*`, `onPressed*`, `icon`, `loading` (false), `style` (primary), `expand` (true; a tonal button always wraps), `compact` (false: 36 px, or 32 px tonal), `tone` (a `StateTone` that tints a tonal button; accent when null), `iconAtEnd` (false) | caller's |
| `StateChip` (`state_chip.dart`) | A 22 px pill that names a state, tinted by its tone | `label` (positional), `tone*`, `icon` | caller's |
| `RankChip` (`rank_chip.dart`) | The rank letters in white on the rank group's colour | `rank` (positional) | none |
| `RankPlate` (`rank_plate.dart`) | A rank's insignia on a rounded plate. Sizes `RankPlate.sm` 32, `md` 40, `lg` 64. Warrant officers use the dark plate because their insignia are pale. An unknown rank falls back to `military_tech_rounded` | `rank` (positional), `size` (`RankPlate.md`) | none |
| `IconPlate` (`icon_plate.dart`) | A 32 px rounded plate holding an icon in a tone's tint and text colour, as a row's leading element | `icon` (positional), `tone*` | none |
| `IconTab` (`icon_tab.dart`) | A `Tab` with an icon beside its label; the tab bar theme colours both | `icon*`, `label*` | none |
| `HeaderPillButton` (`header_buttons.dart`) | A 36 px pill on the gradient. `solid` is the white main action (SHOW QR CODE); the default is translucent (SIGN OUT) | `label*`, `icon*`, `onPressed*`, `solid` (false), `iconColor` | caller's |
| `HeaderIconButton` (`header_buttons.dart`) | A round 44 px white icon button on the gradient: back or sign out | `icon*`, `tooltip*`, `onPressed*` | caller's |
| `AppSegmentedControl<T>` (`app_segmented_control.dart`) | A framed row of equal segments with one selected. `glass` is for use on a gradient. Use it for Strength/Calendar, Participants/Non-Participants and the Excuse/Leave/MA switch | `segments*`, `selected*`, `onChanged*`, `glass` (false) | `segment-<value>` (an enum uses its name) unless a segment passes its own |
| `AppSegment<T>` (`app_segmented_control.dart`) | One segment of the control | `value*`, `label*`, `icon`, `count` (shown after the label in the figure font), `key` | see above |
| `HorizontalDateStrip` (`horizontal_date_strip.dart`) | One 54 by 72 tile per day; the selected day is on the brand gradient and scrolled to the middle | `firstDate*`, `lastDate*`, `selectedDate*`, `onDateSelected*` | `date-strip-<d MMM yyyy>` per tile |

### Sheets and dialogs

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `showAppSheet<T>` (`app_sheet.dart`) | Opens a modal bottom sheet on `palette.sheet` with 28 px top corners and a grab handle. As tall as its content, up to 90% of the screen, and rises above the keyboard. Use it for every sheet. Content that needs a fixed height uses `SizedBox(height: ...)` with an `Expanded` list inside | `context*`, `builder*`; returns `Future<T?>` | `sheetHandle` |
| `AppSheetFrame` (`app_sheet.dart`) | The inside of a sheet: handle, 20 px sides, bottom that clears the home indicator. `showAppSheet` and `HeroSheet` share it | `child*` | `sheetHandle` |
| `HeroSheet` (`hero_sheet.dart`) | A bottom-anchored sheet for a `HeroDialogRoute`; the `Hero` flies from the widget with the same tag. Content taller than 90% scrolls. Used by the QR sheet | `tag*`, `child*` | none |
| `HeroDialogRoute<T>` (`hero_dialog_route.dart`) | A transparent `PageRoute` over the current page, dimmed by the scrim, dismissible by a tap outside (300 ms, no transition of its own) | `builder*`, `settings` | none |
| `CustomRectTween` (`hero_dialog_route.dart`) | Ease-out rect tween for `Hero` flights into a `HeroDialogRoute` | `begin*`, `end*` | none |
| `ConfirmDialog` (`confirm_dialog.dart`) | A confirm or cancel `AlertDialog`; `ConfirmDialog.show` returns `Future<bool>` (false when dismissed). `destructive` colours the confirm label `palette.danger` | `title*`, `message*`, `confirmLabel` ("Confirm"), `cancelLabel` ("Cancel"), `destructive` (false) | none |
| `DarkSection` (`dark_section.dart`) | Forces the dark theme below it. Only the QR scanner page uses it, because the scanner is always dark on black | `child*` | none |

### Feedback

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `StateView<T>` (`state_view.dart`) | Renders a `ViewState<T>`: `LoadingView` while loading, `ErrorView` with the failure message on error, the empty widget when `isEmpty` says so, else `builder`. The default empty widget says "Nothing here yet" | `state*`, `builder*`, `isEmpty`, `empty`, `onRetry` | none |
| `LoadingView` (`feedback_views.dart`) | A centred spinner | none | none |
| `EmptyState` (`feedback_views.dart`) | A centred note for an empty list: optional muted icon, a bold message and a subtitle | `message*`, `icon`, `subtitle` | none |
| `ErrorView` (`feedback_views.dart`) | A centred error image and message with an optional Retry button | `message*`, `onRetry` | none |
| `AppSnackbar` and `SnackKind` (`app_snackbar.dart`) | Floating snackbar with an icon: `success`, `error`, `info`, `outcome(context, error, success:)` (error when non-null, else success), `show`, and `showOn(messenger, ...)` for results that arrive after the widget is gone | static methods taking `BuildContext` and a message | none |

### Data display and brand

| Widget | What it is for and when to use it | Constructor | Keys |
|---|---|---|---|
| `TallyStrip`, `TallyGroup`, `TallyTick` (`tally_strip.dart`) | One tick per soldier, day or participant, coloured by state. See [section 3](#3-the-tally-strip) | `TallyStrip`: `groups*`, `tickHeight` (36), `onGradient` (false), `maxGap` (`AppSpacing.xxs`), `highlight`. `TallyGroup`: `label`, `figure`, `ticks*`. `TallyTick`: `tone*`, `title`, `detail`, `isSelf`; `TallyTick.future({title, detail})` | `tick-<group>-<index>`, `tick-<group>-<index>-self` |
| `StateTone` (`state_tone.dart`) | The colour vocabulary shared by ticks, chips, plates and tonal buttons | enum `inCamp, excuse, leave, medical, out, accent, duty` | none |
| `FractionBar` (`fraction_bar.dart`) | A rounded track with an accent fill showing a fraction (clamped to 0..1). With a `duration` the fill glides to each new value | `fraction*`, `height*`, `fillKey`, `duration` | `fillKey` (callers pass `bar-<id>`, `qrDrain`) |
| `LinearLoader` (`linear_loader.dart`) | A thin indeterminate bar: a short accent segment sweeps across a faint track; rests in the middle under reduced motion | none | `loaderFill` on the moving segment |
| `BrandLogo` (`brand_logo.dart`) | The TroopTrak wordmark, inverted to white on the dark theme. Semantic label "TroopTrak" | `width*` | none |
| `BrandMascot` (`brand_mascot.dart`) | The mascot tinted with `accentText` | `height*` | none |
| `BrandPlate` (`brand_plate.dart`) | A 64 px gradient plate with a white icon, the mark above a sign-in heading | `icon` (positional) | none |

### StateTone

`StateTone` is how a state becomes a colour. Every widget that shows a parade state, a status type or a duty goes through it, so one change here recolours the whole app.

| Tone | `fill(palette)` | `text(palette)` | `tint(palette)` | `gradient(palette)` |
|---|---|---|---|---|
| `inCamp` | `success` | `successText` | `success` at 16% | flat |
| `excuse` | `statusExcuse` | `excuseText` | `statusExcuse` at 16% | `statusExcuse` to `statusExcuseEnd` |
| `leave` | `statusLeave` | `leaveText` | `statusLeave` at 16% | `statusLeave` to `statusLeaveEnd` |
| `medical` | `statusMedical` | `medicalText` | `statusMedical` at 18% | `statusMedical` to `statusMedicalEnd` |
| `out` | `tickOff` | `secondaryText` | `hover` | flat |
| `accent` | `accent` | `accentText` | `accent` at 18% | flat |
| `duty` | `duty` | `duty` | `duty` at 16% | flat |

Two extensions in `state_tone.dart` map domain values to tones: `ParadeStateTone` on `ParadeState` and `StatusTone` on `Status`. `ParadeState.tone` maps `inCamp`, `excuse`, `medical`, `leave` and `out` to the tone of the same name. `Status.tone` maps a Leave to `leave`, a Medical Appointment to `medical` and everything else to `excuse`. `StateTone.duty` is a guard-duty tone, not a parade state; `ParadeState` never maps to it.

## 3. The tally strip

`TallyStrip` replaces the old charts. It draws one thin vertical tick per soldier, day or participant, so a glance shows who is in, out or on a status. It lives in `app/lib/core/widgets/tally_strip.dart` and takes the bounded width it is given (it asserts that the width is bounded).

### Rules

1. One tick per item, never one per group. Ticks in a group share the group's width equally. The tick radius is 2 px.
2. A strip holds one or more groups, laid out in a row with 10 px between them. Group widths follow tick counts like `flex: n`, except that a labelled group keeps an 86 px minimum, so five officers beside thirty-seven others still leave room for "Officers 4/5". If the minimums would not fit, they are dropped.
3. A group with a `label` shows a row above its ticks: the label in `caption` (`secondaryText`) and, when `figure` is set, the figure on the right in 15 w600 Barlow Condensed with tabular figures (`onCard`). A group with no label draws the ticks alone.
4. The gap between ticks is at most `maxGap` (default `AppSpacing.xxs`, 2 px). A crowded group closes its gaps before its ticks get thinner than 2 px. The duty slot bar passes `maxGap: AppSpacing.xs` to spread ten ticks.
5. A tick's colour comes from its `StateTone` (`tone.fill(palette)`). A `TallyTick.future` has no tone: it is filled with `palette.tickFuture` and, off a gradient, gets a 1 px `line` border.
6. `onGradient: true` is for a strip drawn on the brand gradient. Tones then come from the `onGradient*` tokens: `inCamp`, `excuse`, `leave`, `medical` and `out` use their `AppColors.onGradient*` colours, `accent` is white, `duty` keeps its palette fill, and a future tick uses `onGradientTickFuture`. Labels use `onGradientLabel` and white figures.
7. The self ring: a tick with `isSelf: true` is outlined by a 1.5 px ring, 1 px outside the tick, in `palette.onCard` (white on a gradient). The ring is its own layer above all ticks and ignores pointer events, so it never changes a tick's size or its neighbours. It marks the signed-in soldier's own conduct tick and today in the month strip.
8. Tooltips: a tick with a `title` shows a tooltip on long press. The title is the tooltip text and the `detail` follows after " · " in `tooltipDetail`. The tooltip sits above the tick, on the near-black `tooltipBackground`. A tick with no title has no tooltip.
9. `highlight` is an optional `bool Function(int group, TallyTick tick)`. When given, ticks it accepts grow to 118% of their height and the others fade to 35% opacity, over 250 ms on `AppMotion.ease`. When null, every tick is shown as is. The ring follows its tick.
10. `tickHeight` is in design px (default 36). Callers use tokens, see below.

### Keys

| Key | Widget |
|---|---|
| `tick-<group>-<index>` | Tick `index` of group `group` (both zero-based) |
| `tick-<group>-<index>-self` | The self ring of that tick |

A strip with one unlabelled group, such as the month strip, uses group 0, so day 1 is `tick-0-0` and today's ring is `tick-0-<today-1>-self`.

### Where it is used

| Screen | Groups and figures | Tones | Tick height |
|---|---|---|---|
| Dashboard parade card | "Officers 3/5" and "WOSEs 31/37", ticks in `ParadeState` order | `ParadeState.tone`; title is "RANK NAME", detail is the state label; an open report row highlights its states | `tallyTall` 46 |
| Nominal roll | "Booked in 31 / 41", one tick per soldier | `inCamp` when booked in, else `out` | 22 (private) |
| Profile header (`onGradient`) | "October in camp  7 of 8 days", one tick per day, days not reached are `future`, today ringed | `ParadeState.tone` per day | `profileTick` 26 |
| Conduct card | No label; took part is `accent`, did not is `out`; the signed-in soldier ringed | `StateTone.accent` / `out` | `conductTick` 18 |
| Conduct details header (`onGradient`) | "Participation strength  x / y" | same | `conductDetailsTick` 28 |
| Conduct form | "Added  x / y", live | same | `conductFormTick` 22 |
| Duty card | No label; ten slots, filled is `duty`, empty is `out`; `maxGap` 4 | `StateTone.duty` / `out` | `dutySlotBar` 10 |

## 4. Parade-state and duty rules

### D9: the parade-state rule

Implemented in `app/lib/features/statuses/domain/services/parade_state.dart`, pure Dart.

`paradeStateOf(Soldier soldier, Status? activeStatus)` returns a `ParadeState`, checked in this order:

| Order | Condition | State | Tone | Colour |
|---|---|---|---|---|
| 1 | The status is a Leave | `leave` | `StateTone.leave` | Red |
| 2 | The status is a Medical Appointment | `medical` | `StateTone.medical` | Blue |
| 3 | The soldier is not booked in (`soldier.isInCamp` is false) | `out` | `StateTone.out` | Grey |
| 4 | The status is an Excuse | `excuse` | `StateTone.excuse` | Orange |
| 5 | Anything else | `inCamp` | `StateTone.inCamp` | Green |

So Leave and Medical Appointment override the booked-in flag, and an Excuse shows only while the soldier is in camp. The caller picks `activeStatus` (`null` for none).

`ParadeState` is declared in tick-strip order (`inCamp`, `excuse`, `medical`, `leave`, `out`), so `index` is the sort order. Its `label` is "In camp", "Excuse · in camp", "Medical Appointment", "Leave" and "Booked out".

What counts as in camp:

- `ParadeState.isInCamp` is true for `inCamp` and `excuse`. An excuse still counts as in camp; leave, medical and out do not. The dashboard's "in camp" figure (`StrengthSummary.inCampCount`), the officer and WOSE report rows, and the month strip's `inCampDays` all use it.
- `Soldier.isInCamp` is the booked-in flag. The live value is the effective presence from attendance records (`WatchSoldiersInCamp`, R21), not the stored field alone.
- A status counts while it is current (`Status.isCurrentOnDashboard`, R3): it has started and its end day has not passed (the end day is included).
- When a soldier has several current statuses, `paradeRoster` picks the primary one: Leave first, then Medical Appointment, then Excuse; within one type, the one that ends last; ties keep input order.
- A side effect of D9: a booked-in soldier on a current Leave or Medical Appointment counts as leave or medical, not in camp.

### D10: the "(Next day)" rule

The old duty tile printed "(Next day)" on every duty. Now `Duty.endsNextDay` (in `app/lib/features/guard_duty/domain/entities/duty.dart`) is `Duty.isOvernight(start, end)`, which is `!end.isAfter(start)`: an end time that is the same as or before the start runs into the next day.

- The duty card appends " (Next day)" to the time range only when `duty.endsNextDay` is true.
- The duty form shows a "next day" note beside the end time under the same rule (`DutyFormProvider.endsNextDay` calls `Duty.isOvernight`).
- The dashboard calendar keeps its own copy because the dashboard domain may not import guard duty: `CalendarEvent.endFor` adds a day when the end is not after the start, and `CalendarEvent.endsNextDay` is true when the end falls on a later day than the start.

### D6: soldiers get the theme toggle

Before the redesign the soldier side was always dark. Now `ProfileCapabilities.soldierSelf` has `showThemeToggle: true` (as `commanderSelf` already did), so a soldier sees `ThemeToggle` (key `themeToggle`) in the profile header. `SoldierShell` no longer wraps `DarkSection`; it follows `ThemeManager`, like the commander shell. The auth flow follows the theme too. `DarkSection` remains only on the QR scanner page.

### D12: what was kept and why

Four small additions that are not in the mockup. Mahesh kept all four on 2026-10-24:

| Addition | Where | Why it was kept |
|---|---|---|
| "No active statuses" and "No past statuses" | Statuses tab empty lists | The mockup only shows populated lists; an empty tab needs words |
| "Ends today" | `formatDaysLeft` in `core/utils/date_formats.dart`, for a status on its last day | The mockup shows only "N days left"; zero days left needs its own text |
| Remembering the light/dark choice | `PreferencesService.isDarkTheme` / `setDarkTheme`, key `theme_dark`, `ThemeManager.onChanged` | A choice that resets on every launch is not a choice; the default stays dark when nothing is saved |
| The conduct note for a soldier who is out | Soldier-side conduct card: "Not participating · <reason>", where the reason is the one stored with that conduct (the status name, or "Removed from conduct") | The mockup shows the status name; the app has the stored reason, which is accurate |

## 5. Conventions

### Where things go

- Colours are written only in `core/theme`. Widgets read `context.palette` for theme-aware colours and `AppColors` for fixed ones. The architecture test fails on a colour literal elsewhere.
- Spacing, radii, sizes, shadows, motion and text styles come from the tokens above. A value used by one widget may stay a private constant in its file; once a second file needs it, move it to `AppLayout` or `AppSpacing`.
- Build it once in `core/`. A piece used by two or more features lives in `core/widgets`. The architecture test also pins `Icons.search` to `core/widgets`, `army-ranks` asset paths to `core/constants/rank_assets.dart`, `DateFormat` to `core/utils/date_formats.dart` and `DateTime.now()` to `core/services/clock.dart`.
- A feature must not import another feature's `data/` or `presentation/`. Only the shared domains (`soldiers`, `statuses`, `attendance`, `enlistment`) may be imported across features, and only their `domain/`. `core/` imports feature code only through those shared domains.
- A feature-local widget that a second feature needs moves into `core/widgets`. `SoldierSummaryCard`, `BookOutNoteCard` (both in `soldier_profile`) and `OverlapUp` (in `dashboard`) are still local for that reason.

### Pages, sheets and errors

- Pages with one primary action use `StickyCtaPage` (forms use `FormPageScaffold` on top of it). Do not hand-build `Scaffold` plus `SafeArea` plus `StickyCtaBar` again.
- Sheets open with `showAppSheet`. A sheet that must fly from a `Hero` uses `HeroDialogRoute` with `HeroSheet`. Confirmations use `ConfirmDialog`.
- Errors show with `InlineError`. Field widgets already draw their errors through `FieldError`; use `InlineError` directly for a message that belongs to a group of fields (the status period) and for a refusal inside a sheet, where a snackbar would sit behind the sheet.
- The outcome of a write is reported with `AppSnackbar`. A failed load is `StateView`'s `ErrorView`.
- Rules live in domain validators and entities, not in widgets. The form wording (including the Singlish copy) is in the validators.
- Dark and light must both read correctly on every screen. Page tests run in both themes through `themeModes`.

### Tests

- Tests tap by key, not by position or by text where a key exists. The geometry-based toggle tests became key taps in the nominal roll.
- Pump widgets through `tester.pumpApp` or `tester.pumpThemed` (`test/helpers/pump_app.dart`), which set the 390 by 844 view, build both themes and provide a fixed `Clock` and a `ThemeManager`. Pass `mode` or use the `themeModes` variant to cover light and dark.
- Animations that loop hold still under `MediaQuery.disableAnimations`, so `pumpAndSettle` settles.
- Tests that pump `SoldierProfilePage` provide `Provider<WatchMonthPresence>`; use `StubWatchMonthPresence` from `test/helpers/month_presence_stub.dart`.

### Keys that tests and integration tests rely on

Keep these names stable. The ones marked (IT) are also tapped or read by `app/integration_test/commander_flow_test.dart` or `soldier_flow_test.dart`. A name with `<...>` is built from data.

| Area | Keys |
|---|---|
| Core | `tick-<group>-<index>`, `tick-<group>-<index>-self`, `segment-<value>`, `date-strip-<d MMM yyyy>`, `person-<name>`, `sheetHandle`, `loaderFill`, the `profile-*` fields below |
| Shell | Tabs `home` (IT), `nominalRoll` (IT), `conductTracker` (IT), `guardDuty` (IT) for the commander and `myProfile`, `conductTracker`, `guardDuty` for the soldier; `navPill-<tab>`; `userProfileIcon` |
| Onboarding | `role-soldier` (IT), `role-commander` (IT), `role-confirm` (IT), `roleCardBody`, `roleRadio`, `roleRadioDot` |
| Auth | `phone` (IT), `country`, `sendCode` (IT), `otp` (IT), `verify`, `resend`, `captureButton` (IT), `getStarted` (IT), `email` (IT), `password` (IT), `signInButton` (IT), `registerPageButton` (IT), `forgotPasswordButton`, `register-email` (IT), `register-password` (IT), `register-confirm` (IT), `registerButton` (IT), `signInPageButton`, `reset-email`, `resetButton` |
| Profile fields | `profile-name` (IT), `profile-appointment` (IT), `profile-ration` (IT), `profile-rank` (IT), `profile-blood` (IT), `profile-dob` (IT), `profile-company` (IT), `profile-platoon` (IT), `profile-section` (IT), `profile-enlistment` (IT), `profile-ord` (IT); the last three are picked only on forms that start the dates empty |
| Dashboard | `showStrength`, `showCalendar`, `inCampCount`, `legend-<state>`, `tile-<title>` (IT), `soldier-<id>`, `prevMonth`, `nextMonth`, `day-<d MMM yyyy>`, `dot-<day>-<kind>`, `legend-<kind>`, `event-<title>-<iso start>` |
| Nominal roll | `scanQr` (IT), `rosterSearch`, `soldierTile-<id>` (IT), `inCampToggle-<id>`, `chip-<category>`, `saveSoldier` (IT), `editSoldier`, `deleteSoldier` |
| Profile | `profileBack` (IT), `showQr` (IT), `themeToggle`, `signOutButton`, `signOutIcon`, `addStatus` (IT), `activeStatuses` (IT), `activeStatus-<id>`, `pastStatus-<id>`, `editStatus-<id>`, `deleteStatus-<id>`, `deletePastStatus-<id>`, `attendance-<id>`, `editAttendance-<id>`, `deleteAttendance-<id>` |
| Status and attendance forms | `statusType`, `segment-<type>` (IT: `segment-Excuse`), `statusName` (IT), `statusStart`, `statusEnd`, `periodError`, `bookOutNote`, `suggestion-<name>`, `saveStatus` (IT), `attendanceDate`, `attendanceTime`, `saveAttendance` |
| Conducts | `pickConductDay`, `addConduct` (IT), `conduct-<id>`, `count-<id>`, `participating-<id>`, `notParticipating-<id>`, `detailsBack`, `editConduct`, `deleteConduct`, `detailsSearch`, `segment-participants`, `segment-nonParticipants`, `conductType` (IT), `conductName` (IT), `conductDate` (IT), `startTime` (IT), `endTime` (IT), `participantSearch`, `participant-<name>` (IT), `toggle-<name>` (IT), `saveConduct` (IT) |
| Guard duty | `addDuty` (IT), `pickDutyDay`, `leaderboard`, `leaderboardSearch`, `row-<id>`, `bar-<id>`, `self-<id>`, `sort-<column>`, `duty-<id>`, `editDuty-<id>`, `deleteDuty-<id>`, `onDuty-<id>`, `offDuty-<id>`, `dutyDate` (IT), `dutyStart` (IT), `dutyEnd` (IT), `dayType`, `expectedPoints`, `slot-<n>` (IT: `slot-0`), `pickerSearch`, `pick-<name>` (IT), `pickerDone` (IT), `saveDuty` (IT) |
| Enlistment | `qrImage` (IT), `qrCountdown`, `qrDrain`, `closeQr` (IT), `scanReticle`, `scanLine`, `scanOrDivider`, `scanGallery`, `scanResultSoldier`, `goToEditPage` |

## 6. Known gaps

Open items as of the plan Log entry dated 2026-10-25.

- Step 11.3 is not done. The finders in `app/integration_test/commander_flow_test.dart` are updated (the greeting `Welcome, <name>`, and the `On Status` and `On MA` report rows without a total) but the file is uncommitted and the run on `emulator-5554` with the Firebase emulators never finished: it was stopped for low memory during the Gradle build. That is not a test result. Every key the two flows use was checked against `lib/` by reading.
- Step 11.4 is not done. No screen has been signed off against the approved captures in `app/design_mockup/.review/*.png` (`c1` to `c4` commander, `s1` to `s3` soldier, `o1` sign-in, `l1` and `l2` light theme, `v1` and `v2` fixes), in dark or light. Every "not eyeballed" note in the Log is waiting on it. In particular: the REC insignia on the light rank plate (`RankPlate` only handles the warrant-officer case), and the light-mode look of the soldier screens, which was checked by reading code only.
- The duty picker lists every soldier, officers included, while the mockup's picker hides officers. Decide in 11.4 whether the picker should filter them.
- The auth and enlistment screens were built from the phone-entry pattern and the scanner/QR mockups and were not eyeballed. The mockup has no register, forgot-password, profile-capture or welcome screens, so those follow the phone-entry pattern. The camera and gallery path (`mobile_scanner`, `image_picker`) is untested outside the emulator.
- Not in the mockup: the scan result dialog also shows the scanned soldier's name, rank and appointment in a `SoldierRow` card above GO TO EDIT PAGE. Mahesh can ask to drop it.
- Signing out clears every saved preference (`PreferencesService.clearAll()` through `AuthRepositoryImpl.signOut`, except on registration), which includes `theme_dark`. After a sign-out the next launch starts dark. Left as is pending Mahesh's call.
- Possibly unused, left in place on purpose: `RankAssets.menIcon`, `soldierIcon` and `personIcon` (still asserted in `constants_test.dart`, no use in `lib/`); `AppColors.white60` (one reader, `scanner_footer.dart`); `AuthValidators.confirmPassword` (used only by tests; the register page uses `repeatedPassword`).
- The unused images in `app/lib/assets/` are still there for Mahesh to decide: `icons8-doctors-folder-64.png`, `icons8-medals-64.png`, `icons8-user-96.png`, `Troop Trak Poster.png`, `TroopTrak_logo.jpg`, `TroopTrak_logo_unmasked.jpg`, `TroopTrak_Splash_Screen.jpg` and `user.png`. `lib/assets/` is declared as an asset root, and `flutter_native_splash.yaml` reads `TroopTrakSplashscreen.png`, so that one stays. `icons8-error-64.png` is still used by `ErrorView`.

Found while writing this guide, by reading the code (not from the Log):

- Tokens with no reader in `lib/`: `AppColors.chartWoses` (its last user, `expandable_count_tile.dart`, was removed in 11.1), `info`, `personTileMuted`, `tileBorder`, `white70`; `AppShadows.tile`; `AppLayout.profileIdTop`. Palette fields no widget reads: `muted`, `conductTile`, `personTile`, `onTile`, `page` and `pageLine` (tests read the last two).
- `app/lib/features/conducts/presentation/widgets/conduct_person_row.dart` is a tracked file with no importer in `lib/` or `test/`; the shared `SoldierRow` replaced it in 8.4.
- `ARCHITECTURE.md` (layout block) and `DEVELOPER_GUIDE.md` (testing section) still say the design size is 450x1000, and `ARCHITECTURE.md` still lists a "strength chart" and a "participation chart" in its feature table; the app uses 390 by 844 and both charts were replaced by the tally strip.
