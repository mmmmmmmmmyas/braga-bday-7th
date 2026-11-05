# Braga Star Constellation Timeline

## Quick start (VS Code)
1. Unzip, open the folder in VS Code.
2. **Rename `CLAUDE.template.md` → `CLAUDE.md`** (Claude Code auto-loads it; it holds the locked design rules).
3. Run `npm run dev` → open http://localhost:5173 (or right-click `index.html` → "Open with Live Server"). It must be served over HTTP — double-clicking `index.html` won't load the JSON/audio.

## Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit: constellation timeline prototype"
git branch -M main
git remote add origin https://github.com/<you>/braga-constellation-timeline.git
git push -u origin main
```
(`uploads/` has ~16 images + 2 MP3s; fine for normal git. If any file exceeds 100 MB, use Git LFS.)

## Project layout
- `index.html` — the intro page (plain HTML and JS), and the entry point.
- `timeline.html` — the working constellation prototype (template + logic in one file). It redirects to the intro until the invitation is accepted in that browser tab.
- `sky.js` — the dust stars and aurora shared by both pages.
- `support.js` — runtime that renders `timeline.html`. Keep it next to `timeline.html`.
- `constellation.json` — all content + geometry (stars, years, lines, images, info cards). Edit this to add content.
- `uploads/` — images and audio referenced by the JSON / code.
- `CLAUDE.template.md` — rules for Claude Code (rename to `CLAUDE.md`).

---

## Overview
A full-screen, interactive company timeline (Braga Technologies, Day 0 → 2027) drawn as a star constellation. Each year is a node on a main line; projects and milestones are stars connected by constellation lines. The user travels horizontally section-by-section (one section = the span between two years) through a pseudo-3D camera with depth layers, tilts, and hovers stars to reveal pop-up chips, info cards and photos. Background music and hover SFX.

## About the Design Files
`timeline.html` is a **working HTML prototype** of the intended look and behaviour. You can keep iterating on it directly, or port it to a framework (e.g. Vite + React / vanilla TS) — if porting, match everything below exactly.

The prototype is a "Design Component" (`timeline.html`) rendered by a small proprietary runtime (`support.js`). Treat the template as JSX-like markup (`{{ x }}` = value from `renderVals()`, `<sc-for>` = map, `<sc-if>` = conditional) and the `class Component` as a React class component whose `renderVals()` is `render()`'s data. All of the real logic (camera math, hover cards, audio) is plain DOM/JS and ports directly.

**Editing tips:** inline styles only in the template; `{{ }}` holes are dotted lookups only (compute values in `renderVals()`); per-frame motion lives in `tick()` and writes to the DOM directly.

## Fidelity
**High-fidelity.** Final colours, type, spacing, motion and audio. Recreate pixel- and timing-accurately.

## Screen: Intro (`index.html`, Figma `89:674`)

- Full-viewport invitation, centred: Braga logo, event lockup, message, "Accept invitation" button, volume note. Column gap 80px, 653px wide, 639px tall at design size, rendered at 80% (523 × 511px), and scaled down further only when the window is too small to fit it. The volume note sits 8px under the button on screen.
- Entrance: once fonts are loaded (800ms at most), the page fades in over 0.8s with the logo and lockup already in place. The first paragraph starts at 1.12s, the second at 2.212s, and the button with its note at 3.304s, each fading and rising 10px over 0.98s. The button can't be clicked or focused until its turn.
- Background: the same seeded dust stars and aurora as the timeline (`sky.js`), with the aurora in greyscale.
- Music: `space-music.mp3` at gain 0.12 with the timeline's seamless loop. No sound controls here. It tries to start as soon as the page opens. Where the browser's autoplay policy blocks that, it starts on the first click, tap or key press.
- Accept: sets `sessionStorage['braga7.accepted']`, fades the page and music out over 0.5s, then opens `timeline.html`. The profile input step is not designed yet.

## Screen: Timeline (single full-viewport screen)

### Layout
- Root: `position:fixed; inset:0`, bg `#080504`, text `#f4f3ef`, `user-select:none`, `overflow:hidden`.
- **Sky** (interactive area): `top:0; bottom:0; left/right:0`, `cursor:grab` (`grabbing` while dragging), `touch-action:none`.
- **Top nav** (inside Sky, under pop-ups and the cursor ring; Figma `80:545`): `top:20px; left/right:20px`, `border:1px solid rgba(236,235,231,.32)` × the 50% rest opacity, radius 11.4px on screen, 24px / 12px inner spacing, three-column grid (`1fr auto 1fr`) so the event lockup is truly centred, `pointer-events:none` except the volume button, so drag, scroll and hover pass through. Left to right: Braga logo (`uploads/nav/logo-braga.svg`), event lockup (League Gothic 5.678px, `uploads/nav/logo-event-line.svg`), sound control (`border-left` same colour, 24px left padding, gap 8px). Everything except the event lockup rests at 50% opacity and rises to 80% while the cursor is over the nav (0.2s); the lockup stays at 100%.
  - **Volume button** (`uploads/nav/volume-control.svg`, 18px, 30px hit area): click cycles full → low → off. The icon is clipped to show two arcs (full), one arc (low) or none (off), matching the music level.
  - **Soundwave**: 34 bars, 1px wide, 4px pitch, max 17px, `#ecebe7`, bottom-aligned, low → high frequency. Each frame reads an `AnalyserNode` (fftSize 2048) tapped after all gains; 50 Hz–14 kHz log bands, peak dB + 2.5 dB/octave tilt, mapped −92…−44 dB to 1–17px, fast rise / slow fall. Flat at 1px when silent or before the first gesture; in off it only reacts to hover SFX.
- **Aurora** (first child of Sky, behind the dust stars): a fragment shader draws five soft horizontal ribbons with fine horizontal streaks, in a band 30vh tall at the bottom of the sky. Each ribbon follows its own noise path, and its colour changes along the timeline through rust, mauve, olive, sage and teal. It renders into a quarter-resolution WebGL buffer at 30fps and is upscaled by the browser, so it stays soft and cheap. A static 128px grain tile covers the whole sky. It has one continuous path along the whole timeline: the view is centred on the camera's world position and is 2800 world units wide per 1440px of screen, so scale stays fixed, travel only moves it forward, and each section shows a different stretch. It animates continuously on its own, regardless of camera movement or the OS motion setting. Without WebGL it falls back to static CSS gradients.
- **Starting Point set** (Figma `92:699`, assets in `uploads/starting/`): 1400 × 340px at design size, rendered at 75% (1050 × 255px), flex row with 137px gaps: invitation note, crew card (320 × 340), navigation info, stellar classification. It is a screen-space layer, not part of the 3D world, so text stays crisp: the crew card sits at the exact page centre when the camera rests on section 0, and the set pans with the camera. Pointer events pass through. It stays at full opacity until section 01 takes focus, then fades to 0.1 over 0.5s.
- **UI scale**: the top nav, section cells and pop-up cards render at `UI = 0.85`. Sizes in this document for those parts are the values before scaling, except the nav's 20px screen margin. Hairline borders stay 1px.
- **Timeline card** (inside Sky; Figma `93:837`): 331 × 41px, centred horizontally, 29px from the page bottom, `border:1px solid rgba(255,255,255,.32)`, radius 8px, 12px padding left and right, none top and bottom, clips its content, no fill. Only the section cells take pointer events. It holds `timeline-frame`, 307 × 39px, with one cell per section. Cells are separated by vertical strokes in white at 12% opacity. All text is white. Minimized cells read `S`, then the year each section reaches (`19` … `27`), then `F`. The active cell shows only its label ("Starting Point", "’19–20", "F"). The minimized text is bold 10px / 0.14em and the name is regular 11px / 0.04em, both × `UI`. The active cell expands, with a white fill at 8% opacity, and animates its width over 0.3s. Inactive cells share the remaining width, show only the centred text, and hover to a white fill at 4% opacity. Click → go to section.
- Stars are still framed as if a 61.2px strip were reserved at the bottom (`RAIL`), so they stay clear of the card.

### World / data model (`constellation.json`)
World canvas 12556.6 × 1080. Fields:
- `years[]`: `{year, x, y, lx, base, pill?, image?, images?, info?}` — `x,y` dot centre; `lx` label left; `base` label baseline. 2026 has `pill:true`.
- `stars[]`: `{id, x, y, r, label, fs, lx, ly, kind:'project'|'milestone', style:'p'|'c'|'i', image?, images?, info?}`. `style` p = Archivo 500 0.04em; c = Oswald 600 0.04em; i = Archivo 700 italic −0.02em. Label `line-height = fs×1.35`, top = `ly − fs×1.08`, `white-space:pre` (labels may contain `\n`).
- `images`: array of path strings or `{src, scale}` (e.g. intan logo at `scale:0.3`).
- `info`: `{title, body: string[]}` → info card.
- `lines[]`: `{d, nodes}` — `d` is a filled outline SVG path in world coords (lines are drawn as filled shapes); `nodes` = keys (`s<id>` / `y<year>`) the line connects. A path with >30 `M` sub-paths is a **dashed** line: re-built as a stroked polyline through its nodes, stroke-width `max(1, 1.4·s)`, dasharray `9·s·1.4 12·s·1.4`.
- Sections: section 0 = x 0 → 1840, "Starting Point": 1440 of framed content (`START`) plus a 400 empty spacer (`SPACER`) before Day 0. Section 1 = 1840 → years[0].x ("Day 0 → 2019"), section i = years[i−2].x → years[i−1].x ("2019 → 2020"), the 2026 → 2027 section ends at W − 1440, and the last section is an empty 1440-wide one labelled "F" (`TAIL`). The camera opens on section 0, which holds the Starting Point set.

### Components
- **Background dust**: `round(W × 0.04096)` seeded-random circles (LCG seed 7, `seed = seed·16807 mod 2147483647`), x ∈ [−0.15W, 1.15W], y ∈ [−0.1H, 1.1H], r 0.6–1.7, fill `#f4f3ef`, opacity 0.17–0.80. Placed on its own depth layer (z = −30), in front of the aurora.
- **Constellation lines**: fill (or stroke if dashed) `#f4f3ef`; opacity 0.8 in focused section (0.45 while anything is hovered), **0.07** for unfocused sections, 1.0 + colour `#9e9891` for lines touching the hovered node. Transition `fill/stroke .25s, opacity .5s`.
- **Section guides**: vertical 1px dashed `#f4f3ef` line at each year x, full height 1080, masked `linear-gradient(to bottom, transparent, #000 50%, transparent)`. Opacity 0.35 for the two years bounding the focused section, else 0.1.
- **Star** (size = r×2; hit area `max(28, size+14)` circle):
  - Ring: `border:2.67px solid` (2pt), `box-sizing:border-box`, radius 50%.
  - Fill: `#080504` (hollow look, hides lines under it) unless the star has `image/images/content/media/text` → solid ink (`#f4f3ef`, grey `#9e9891` when hovered/linked). Info-only stars fill grey on hover.
  - Colour: `#f4f3ef`; hovered or linked → `#9e9891`.
  - Glow: `box-shadow: 0 0 round(r·1.4)px 0 rgba(244,243,239,.35)`; hovered `0 0 22px 4px rgba(158,152,145,.7)`.
  - Scale: hovered 1.7, linked 1.25. Transition `transform .3s cubic-bezier(.2,.8,.2,1)`, `background/border-color .25s`, `box-shadow .3s`, `opacity .5s`.
  - Label opacity: 0.55 when another node is hovered (and this one isn't linked).
  - **Sun rays** (stars with `info`): 8 bars at 45° steps, 2.67px × 6px, radius 1.5px, colour = star colour, centred on the star at radius `r·1.7 + 4` (inner end) → `+6`. Rotate continuously at 14°/s; paused while that star is hovered.
- **Year dot**: 26px ring, same 2pt ring/fill rules as stars (filled if `image/images`); glow `0 0 18px 4px rgba(244,243,239,.4)` / hovered `rgba(158,152,145,.6)`. Rays (if `info`) inner radius 17px, length 6px. Hit area 56px circle. Numeral: Oswald 600, 86px/86px, letter-spacing 0.09em, top = `base − 74`.
- **2026 pill**: world rect left = year x − 144, top 331, 288 × 126, `border:6px solid`, radius 63px, bg `#080504`, numeral Oswald 600 86px 0.09em centred; glow `0 0 40px 2px rgba(244,243,239,.12)` / hovered `rgba(158,152,145,.45)`.
- **Focus dimming**: everything outside the focused section at opacity 0.22 (years: all except the two bounding years).

### Hover pop-ups (screen space, absolutely positioned over the sky)
Order: chip → info card (if any) → images. Each element:
- **Chip**: flex, gap 10px, padding `7px 12px`, `border:1px solid rgba(158,152,145,.5)`, bg `#080504`, radius 999px, Archivo 13px, 0.12em, uppercase, nowrap. Left span = kind ("Project" / "Milestone" / "Year 2019") `#c9c4be` 600; right span = section name ("2019 → 2020") `#a9a8a3`.
- **Info card**: width 300px, padding `16px 18px 18px`, `border:1px solid rgba(158,152,145,.5)`, bg `#080504`, radius 14px, shadow `0 18px 44px rgba(0,0,0,.55)`, column gap 10px. Title 11px / 0.16em uppercase 600 `#c9c4be`; each body paragraph 14px / 1.5 `#f4f3ef`, `text-wrap:pretty`.
- **Video in pop-ups**: an `image` or `images` entry ending in `.mp4` or `.webm` renders as a muted, looping, autoplaying video, sized like a photo from its native dimensions. Clicking zooms it like a photo, and the zoomed copy continues from the same position while the card's copy pauses.
- **Photo card**: padding 6px, `border:1px solid rgba(158,152,145,.2)`, bg `rgba(8,5,4,.4)`, radius 14px, same shadow, `cursor:zoom-in`. Image radius 9px, `object-fit:cover`. Size: native px width, capped at 280 (220 when the node has ≥2 images), height capped 280 (keep ratio), then × `scale`.

## Interactions & Behavior
### Camera / travel
- Base scale `s = skyH·0.94 / 1080`. Each section has a depth z (`Z = [0,0,0,20,20,40,60,60,40,70]`); layer scale `k = max(0.2, 1 + z/100·depth)` with `depth = 2`. Layers are rendered with perspective `D = 3·max(vw, skyH)` and a per-frame `matrix3d` (see `tick()`); world points are projected with the same matrix for lines and pop-up anchors.
- Auto-framing: the focused section's bounding box (stars + labels + next year label) is fitted to `0.9·vw` wide and `skyH − 2·min(60, 0.18·skyH)` tall (zoom factor capped 2.2); blended smoothly between neighbouring sections with smoothstep, eased `1 − e^(−9·dt)`.
- **Wheel**: `targetX += (|dX|>|dY| ? dX : dY) · 0.8 / (s·fit)`. Camera follows `cam += (target − cam)·0.085` per frame. After 160ms without input, soft-snap target to the nearest section centre, from section 01 onward. Between the centres of sections 00 and 01 there is no snapping: the camera rests where it is left, and section 00 keeps focus until the camera is 80% of the way to section 01.
- **Drag** (pointer, left button): axis locks after 6px movement. Horizontal: 1:1 × 0.8 follow; on release, momentum `target −= v·260·0.8/(s·fit)` (v = smoothed px/ms; zeroed if pointer was still for >100ms), then soft-snap. Vertical: pitch = `p0 − dy/30`, clamped ±10°.
- **Keys**: ← / → previous/next section. Esc closes zoom.
- **Orbit**: when the camera settles on a new section (280ms), pick a random tilt of 70–100% × 10° (`orbitTilt`) on either yaw or pitch (sign random); critically-damped spring ω = 3.2. Section depth z also springs.
- Changing focused section clears hover and retracts pop-ups immediately (unless a photo is zoomed).

### Hover
- Only nodes in the focused section (and its two bounding year dots / pill) accept pointer events.
- Entering a node: play hover SFX (not when re-entering the same node within 250ms), set hovered key, spawn pop-ups.
- **Placement**: for each pop-up, try up to 60 random angles θ; distance from star centre = `starScreenRadius + 14 + rand·28 + (w/2)|cosθ| + (h/2)|sinθ|` (chip: `+10 + rand·14`). Score = area inside viewport (12px margin) − full area − 2 × overlap with already placed pop-ups (+10px padding). Take the first fully-inside, non-overlapping candidate, else the best. Final position is also clamped inside the viewport each frame and follows the star as the camera moves.
- **Animation**: progress p in [0,1]; in 0.42s, out 0.24s; stagger −0.12 per item. Position = lerp(star centre → target, easeOutCubic(p)); scale = `0.08 + 0.92·easeOutBack(p)` (c1 = 1.5); opacity = `min(1, 3p)`. Pop-ups ignore the pointer until p > 0.85.
- **Persistence**: pop-ups stay while the cursor is over the star (radius `max(rs+8, 16)`) or any pop-up (geometric check every frame). After leaving both: **600ms** grace, then retract. Hovering a different node replaces them immediately.
- **Zoom**: click a photo card → card grows to `min(3/UI, (vh−80)/h, (vw−80)/w)` × its size, centred, from its current rect (FLIP, 0.45s `cubic-bezier(.2,.8,.2,1)`), padding 10px, radius 18px (image 12px), bg `#080504`, backdrop `rgba(8,5,4,.8)` fading 0.35s. Click anywhere (image or backdrop) or Esc → shrink back into the card (0.35s `cubic-bezier(.4,0,.2,1)`).

### Cursor ring (sky only, hidden when pointer leaves)
- 1px `rgba(244,243,239,.35)` circle centred on the cursor. Size eases (`1 − e^(−10dt)`) to 100px (no hover) / 200px (hovering a node). Pulse `±2.5%`, period 2.2s (3.6s while hovering).
- **Idle hint** after 3s with no move/scroll/drag/key: blend factor fades in (rate 2.5/s, out 8/s). Ring pulse becomes 100% ↔ 60% of its base size (same period). Arched text via SVG `<textPath>`: "Drag, Scroll, Hover" on the top arc (radius base/2 + 7), "to Traverse The Timeline" on the bottom arc (radius base/2 + 15, drawn left→right so glyphs read upright). Archivo 10.67px (8pt), 0.08em, white; opacity 0.8 ↔ 0.6 (3s cosine loop). Text radius stays on the base (non-pulsing) size.

### Audio (Web Audio API)
- Sound ON by default; context resumes on first `pointerdown`/`keydown` (browser autoplay policy). Suspended when tab hidden.
- **BGM** `space-music.mp3`: decode, trim leading/trailing samples below |0.002|, loop by scheduling overlapping buffer sources with an equal-power crossfade of `min(4s, len/4)` (sin/cos curves, 128 points). Master gain 0.385 (full) / 0.12 (low) / 0 (off), fades over 1.2s on toggle. Hover SFX gain is 0.6 in full and low, and 0.3 in off, so it stays audible when the music is off.
- **Hover SFX** `hover.mp3`: gain 0.6 (0.3 when the music is off) → DynamicsCompressor (threshold −18, knee 12, ratio 6, attack 3ms, release 200ms). One voice at a time: previous voice fades to 0 in 60ms; new voice 8ms attack; ignore retriggers < 70ms; peak 0.55 if retriggered < 400ms after the last, else 1.

## State Management
- `soundMode: 'full'|'low'|'off'` (default `'full'`), `data` (loaded JSON), `vw/vh`, `centerSec` (focused section index), `hoverKey` (`s<id>` / `y<year>` / null).
- Per-frame (non-React) state: camera `camW/targetW`, `yaw/pitch` + velocities and targets, `zp`, `fitC/fitO/fitX`, drag object, cursor `mx/my`, `lastAct`, pop-up card list, zoom object, ray angles. Drive with one `requestAnimationFrame` loop writing transforms directly to DOM — don't push per-frame values through React state.
- Data: fetch `constellation.json` on mount; preload every image to learn natural dimensions before first hover.

## Design Tokens
- Colours: bg `#080504`; ink `#f4f3ef`; hover grey `#9e9891`; muted text `#6f6e6a`, `#a9a8a3`, `#c9c4be`; rail lines `#231d19`, `#312a25`; rail hover `#17120f`; rail active `#1c1613`.
- Fonts (Google Fonts): Archivo 400/500/600 + 700 italic; Oswald 500/600.
- Type scale: 10, 11, 13, 14, 10.67 (8pt), star labels per-data `fs`, year numerals 86px.
- Radii: 9 (photo image), 12 (zoomed image), 14 (cards), 18 (zoom card), 63 (pill), 999 (chips/buttons).
- Shadows: cards `0 18px 44px rgba(0,0,0,.55)`; zoom `0 30px 80px rgba(0,0,0,.6)`.
- Strokes: star/year ring 2.67px (2pt); text pop-ups 1px @ 50%; photo cards 1px @ 20% (`rgba(158,152,145,…)`).

## Assets (`uploads/`)
Audio: `space-music.mp3` (BGM), `hover.mp3` (SFX).
Images (node → file): 2019 → `braga-logo-2019.png`; 20m2 Office → `of-2019.png`; poin-platform → `poin-a.png`, `poin-b.png`; pandan → `pandan-a/b/c.png`; intan → `intan-b.png`, `intan-a.png` (scale 0.3); spatial-talks → `sp-talk.png`; geocreate → `gc-logo.png` (80px native — needs a hi-res replacement); 32 teammates → `team-2020.png`; saninten office → `so-a.png`, `so-b.png`.
Info cards: 2019, data collection, poin-platform (text in `constellation.json`).

## Files
- `index.html` — the intro page.
- `timeline.html` — the current, canonical prototype (template + logic).
- `sky.js` — shared dust stars and aurora.
- `support.js` — prototype runtime; required to run `timeline.html`, not needed if ported to a framework.
- `constellation.json` — all content and geometry. Keep this as the app's data source.
- `CLAUDE.md` — locked design/interaction rules for Claude Code.
