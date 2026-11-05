# Braga Star Constellation Timeline — project rules

Read `README.md` for the full spec. These rules are the user's established direction; do not change them unless asked.

## Pages
- `index.html` is the intro and entry point. `timeline.html` is the constellation, reachable only after accepting the invitation. `sky.js` holds the shared stars and aurora.

## Working style
- Make ONLY the change requested. Don't restyle, re-space or "improve" anything else.
- Be concise in replies. Summarise changes in 1–3 lines.
- Content (stars, lines, years, images, info cards) lives in `constellation.json` — prefer data edits over code edits.

## Locked aesthetic
- Background `#080504` (warm, orange-leaning black — never blue-black). Ink `#f4f3ef`. Hover grey `#9e9891` (all hover states are grey, never the yellow accent).
- Aurora behind the dust stars: horizontal ribbons on one continuous path along the whole timeline at a fixed scale, in the bottom 30vh of the sky, using muted olive, sage green, teal, mauve and rust from the user's reference, fading to the `#080504` background at its top edge.
- Timeline card: minimized cells read S, 19–27 (the year each section reaches), then F (an empty 1440-wide section after 2027). The active cell shows only its label, no number. White text, bold numbers, regular labels, cell strokes in white at 12%, active fill in white at 8%. The yellow accent is no longer used there.
- Fonts: Archivo (UI, star labels), Oswald 600 (year numerals, "c"-style labels), League Gothic (event lockups), Barlow Condensed (intro page, Starting Point set).
- Stars & year dots: hollow 2pt rings (2.67px) filled with `#080504` when they have no content; solid fill when they have images/content. Stars/years with an `info` card get 8 spinning sun rays (2pt wide, 6px long), which pause on hover; ring fills grey on hover.
- 2026 is a pill, not a dot.
- Background dust stars: opacity 0.17–0.80. They sit in front of the aurora, which is the backmost layer.
- Unfocused-section connector lines: opacity 0.07. Section guides: dashed, vertical gradient mask (transparent → full at 50% → transparent).

## UI scale
- Top nav, timeline card section cells and pop-up cards render at 0.85 (`UI` in `timeline.html`, `zoom:0.85` in the template). The nav keeps a 20px margin to the screen.

## Starting Point
- The crew card stays at the exact page centre, horizontally and vertically, when the camera rests on section 00. The rest of the set is positioned relative to it. The set renders at 75% of design size, keeps full opacity until section 01 takes focus (80% of the way there), then fades to 10%.

## Locked interactions
- Scroll / horizontal drag travel the timeline with 0.8× sensitivity (20% resistance), momentum on release, soft-snap to nearest section from section 01 onward (no snapping between Starting Point and section 01, which are 400 apart by a spacer).
- Vertical drag tilts pitch, clamped ±10°. Drag locks to one axis after 6px.
- Only the focused section's stars (and its two bounding years) are hoverable. Changing section clears hover.
- Hover pop-ups: chip ("Kind · YYYY → YYYY"), optional info card, optional photo cards. All absolutely positioned, randomly placed in any direction that fits the viewport, spawned from the star centre with scale + move (back-out ease, 0.42s in / 0.24s out, staggered 0.12).
- Pop-ups persist while the cursor is on the star OR any card; 600ms grace after leaving.
- Images start at native resolution (never upscaled), capped 280px (220px when multiple), then × the 0.85 UI scale. Per-image `scale` supported. `.mp4` / `.webm` entries work as media too, muted and looping.
- Click a photo → zoom 3× (capped to viewport − 40px margin) to centre over a dim backdrop; click anywhere or Esc closes.
- Cursor ring: 100px at rest (2.5% pulse, 2.2s), 200px over a star (slower 3.6s pulse). After 3s idle: ring pulses 100%↔60%, arched text "Drag, Scroll, Hover" (top) / "to Traverse The Timeline" (bottom), 8pt white, opacity 0.8↔0.6; text path stays on the base radius.
- Audio: BGM `space-music.mp3` loops with silence-trim + 4s equal-power crossfade, master 0.385, sound ON by default (starts on first gesture). Top nav volume icon cycles full → low (BGM 0.12, SFX unchanged) → off (no BGM, SFX at half volume, 0.3); its soundwave reads the audible mix. Hover SFX `hover.mp3`: single voice, 8ms attack, 70ms retrigger guard, compressor.
