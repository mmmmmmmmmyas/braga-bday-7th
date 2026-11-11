# Braga Star Constellation Timeline — project rules

Read `README.md` for the full spec. These rules are the user's established direction; do not change them unless asked.

## Pages
- `index.html` is the intro and entry point. `timeline.html` is the constellation, reachable only after accepting the invitation. `sky.js` holds the shared stars and aurora.

## Phones
- No mobile version. On phones (touch screen, shorter side under 600px) the intro shows a white chip "Please visit on desktop or tablet for maximum experience" in place of "Accept invitation" (and no Skip login or volume note). Tablets and desktops are unaffected.

## Sign in
- The intro's Accept invitation opens a Name + Work email form in place of the message, at its size. "Accept as" is inactive until a name is picked, then shows the first name; the work email is checked as a password by Supabase's `sign_in()`. Only names reach the browser. Staff data lives in Supabase, never in the repo (`supabase/*.private.sql` and `assets/` are git-ignored). Crew photos are in the Supabase Storage bucket `crew-photos` under random file names; `sign_in()` returns the photo link, which fills the crew card's photo tile.
- Skip login (hidden only on `*.vercel.app`) signs in a guest who joined in 2020. Guests remember nothing: every visit starts each interaction as a first visit. New interactions should use `recall()` / `remember()` in `timeline.html` so this holds automatically.
- Signing in again with the same account is allowed, any number of times and on any device. Someone who has already sent a message can sign in again but only revisit: sign-in returns their message, the message section opens in its sent state (box disabled), and `submit_message()` refuses a second one. Some upcoming interactions will be usable only once per person; enforce those in Supabase (keyed to the crew member), never only in the browser.

## Working style
- Make ONLY the change requested. Don't restyle, re-space or "improve" anything else.
- Be concise in replies. Summarise changes in 1–3 lines.
- Content (stars, lines, years, images, info cards) lives in `constellation.json` — prefer data edits over code edits.

## Locked aesthetic
- Background `#080504` (warm, orange-leaning black — never blue-black). Ink `#f4f3ef`. Hover grey `#9e9891` (all hover states are grey, never the yellow accent).
- Aurora behind the dust stars: horizontal ribbons on one continuous path along the whole timeline at a fixed scale, in the bottom 30vh of the sky, using muted olive, sage green, teal, mauve and rust from the user's reference, fading to the `#080504` background at its top edge.
- Timeline card: minimized cells read S, 19–27 (the year each section reaches), then F (an empty 1440-wide section after 2027). The active cell shows only its label, no number. White text, bold numbers, regular labels, cell strokes in white at 12%, active fill in white at 8%. The yellow accent is no longer used there.
- Fonts: Archivo (UI, star labels), Oswald 600 (year numerals, "c"-style labels), League Gothic (event lockups), Barlow Condensed (intro page, Starting Point set).
- Stars & year dots: hollow 2pt rings (2.67px) filled with `#080504` when they have no content; solid fill when they have images/content, and stars with photos or video also glow brighter and wider (0.6 white, blur 3.2× radius, spread 0.5× radius). Stars/years with an `info` card get 8 spinning sun rays (2pt wide, 6px long), which pause on hover; ring fills grey on hover.
- 2026 is a pill, not a dot.
- Background dust stars: opacity 0.17–0.80. They sit in front of the aurora, which is the backmost layer.
- Unfocused-section connector lines: opacity 0.07. Section guides: dashed, vertical gradient mask (transparent → full at 50% → transparent).

## UI scale
- Top nav, timeline card section cells and pop-up cards render at 0.85 (`UI` in `timeline.html`, `zoom:0.85` in the template). The nav keeps a 20px margin to the screen.

## Starting Point
- The crew card stays at the exact page centre, horizontally and vertically, when the camera rests on section 00. The rest of the set is positioned relative to it. The set renders at 75% of design size, keeps full opacity until section 01 takes focus (80% of the way there), then fades to 10%. The navigation info's "screen" (a rectangle reading "drag/scroll") and its arrow nudge 10px right on a loop, like "Invitation unlocked".

## Stellar classification
- Dims to 22% with Day 0 → 2019's stars whenever that section isn't focused.
- A tutorial on Day 0 → 2019, its own layer at 117% of the old size (90% of the first move's 130%), at the section's left edge. The moment any of that section shows on screen, title, Memories, Pictures, Stories and the note fade in one by one (no delay); then "Hover star to interact" with a short (23px) arrow, nudging like the navigation chip, points at the 2019 star. The hint sits 24px clear of the star's rays. Until that star is hovered, the camera can only go a quarter of the way towards '19–20 (which stays unfocused) and springs back to Day 0 → 2019 when the scroll or drag stops; then the arrow goes, the classification stays, and the timeline opens up.

## Timeline entrance
- Never white on load. Soft fade from a dark cover, with a loading ring only if loading is slow. Then in order: top nav and timeline card fly in and fade in, crew card pops in with a slight zoom from a random tilt to front-facing, then the invitation note ("Scroll to the end of the timeline" underlined) with a "Got it!" button fades in to the card's left; clicking "Got it!" hides the button and brings in the navigation info to the card's right (remembered per tab for signed-in people). Until "Got it!" is clicked the camera stays on the Starting Point; blocked scroll, drag, keys or timeline-bar jumps shake the button.

## Message section (M)
- 1440-wide section between 2026 → 2027 and F, content at 75% of Figma size: a note, a message box in the shared field style, and "Unlock invitation" that moves on to F. The button always looks active; a message needs 80–240 characters (trimmed; the box stops at 240), shown by a helper line under the box ("Minimum 80, maximum 240 characters" plus a live "n / 240" count). Clicked with an empty box it shakes and shows "Leave a Message / to Unlock Invitation" in red for 1s; with a short one it shows "At Least 80 Characters / to Unlock Invitation" and the helper turns red. A valid message gives 1s of loading (spinner in the button), then "Invitation unlocked": a secondary (outlined) button nudging 10px right on a loop, which takes you to F when clicked, and the box goes inactive (emptied, disabled, "We Appreciate Your Good Message" centred). F stays locked until a message is sent. Saved once per person in Supabase (`submit_message()`, during the loading); a failed save goes back to editing with a red "Couldn't send" note. Testing phase: `supabase/reset-messages.sql` archives and clears all messages.

## RSVP block
- Centred on the final section (F), 20px above the page centre, at 60% of Figma size. On reaching F: the corner cards fly down, the top nav's event lockup fades out, and the content appears in sequence: the event lockup (at 64.8%), then the text, then the "Open invitation" button (at 110%). "Open invitation" (slow pulsing glow) opens the invitation modal: the PDF's three pages (pre-rendered WebP in `uploads/invitation/`) in a scrollable 960px frame over a soft 12px blur, with "Download invitation" (the PDF) and "Close" 8px under the frame; Esc or the backdrop closes it.
- Behind everything on F, a 16-column grid of pure white lines (lines hidden for now: opacity 0, was 8%): 20px from the screen sides, full screen height, fading out over 80px toward the top nav and the timeline card and hidden behind them. 32 columns long (two screen widths) and 10 rows tall: 8 rows between the navs plus one empty spacer row above and one below. It pans with F and fades in when F takes focus. On F the grid scrolls sideways, keeping the timeline's horizontal flow: wheel, horizontal drag and Arrow Right/Left scroll it (the RSVP block stays put); going back past its start continues back along the timeline.
- 72 message stars, one per crew member (Figma 137:4531: photo tile + crew tag, placeholders for now) sit one per cell at 100%, 90% or 80% (random) of the cell width minus 8px padding each side, scattered organically. Stars unlock when that person has sent a message; # 001–004, # 012, # 013 and # 020 (the chiefs) and # 008 are also unlocked with placeholder text until they send their own (filled tile showing that crew member's photo, via Supabase `crew_profiles()`, or the git-ignored `assets/crew-local.json` locally); locked stars show an empty tile at 40% size and their number at 50%. Any grid cell that intersects the invitation's container (lockup + text + button, 353 × 296px on screen) stays empty: a star whose cell becomes blocked as the grid scrolls fades out, shrinks, and pops back in another random free cell. Hovering an unlocked star opens one text card, in the regular pop-up style and behaviour: the message in quotation marks, the person's name (0.08em tracking, first two names if too long) and their title under it at 80%, no headline or chip, half the regular star-to-card gap; the hovered star's photo tile glows and grows to 144% while hovered (real messages from Supabase, placeholder text in `MSTAR_SAMPLES` until then; your own sent message's star also gets 8 spinning sun rays around its photo tile).

## Star legend
- Above the timeline bar, at the bar's label size (11px × 0.85, stars as tall as the text): outline "Memories", filled "Pictures and Videos", rays "Stories". Flies in from '19–20 through the message section; flies out on S, Day 0 → 2019 and F.

## Small crew card
- Past Starting Point, a 50% copy of the crew card sits 20px from the bottom-left corner, with the same hover tilt. It floats up with the entrance tilt and zoom, and reverses down on returning to Starting Point.

## Scroll hint card
- Bottom-right, 20px from the edges, the same size as the small crew card (120 × 127.5px), card and content scaled together (0.682). Icon on top, text below in Archivo 400 (normal case), sized to fill the rest of the card (19 design px, about 13px); icon 23 design px. Outline 1px heavier than before: 1.58px on screen, white 32%, as an inset shadow. Enters and leaves with the small crew card, in the same way.

## Crew card hover
- On both the main and small card: tilt of 12° at most per axis, starting within 30px of the card, building as the cursor nears, strongest touching its rim and sides.

## Locked interactions
- Scroll / horizontal drag travel the timeline with 0.8× sensitivity (20% resistance), momentum on release, soft-snap to nearest section only between section 01 and the 2026 section (no snapping between Starting Point and 01, which are 400 apart by a spacer, or from the 2026 section to the end).
- Vertical drag tilts pitch, clamped ±10°. Drag locks to one axis after 6px.
- Only the focused section's stars (and its two bounding years) are hoverable. Changing section clears hover.
- Hover pop-ups: chip ("Kind · YYYY → YYYY"), optional info card, optional photo cards. All absolutely positioned, randomly placed in any direction that fits the viewport, spawned from the star centre with scale + move (back-out ease, 0.42s in / 0.24s out, staggered 0.12).
- Pop-ups persist while the cursor is on the star OR any card; 600ms grace after leaving.
- Any open pop-up card (chip, text, photo, video, message) can be dragged to move it out of the way: it comes to the front, stays on screen, keeps following its star, and keeps the hover open while dragged. A press that doesn't move (under 4px) still opens a photo's zoom.
- Images start at native resolution (never upscaled), capped 280px (220px when multiple), then × the 0.85 UI scale. Per-image `scale` supported. `.mp4` / `.webm` entries work as media too, muted and looping on hover. Zooming one plays its sound at 50%, with no volume control, and drops the music to 10% until closed.
- Click a photo → zoom 3× (capped to viewport − 40px margin) to centre over a dim backdrop; click anywhere or Esc closes.
- Cursor ring: 100px at rest (2.5% pulse, 2.2s), 200px over a star (slower 3.6s pulse). After 400ms idle: ring pulses 100%↔60%, arched text "Drag, Scroll, Hover" (top) / "to Traverse The Timeline" (bottom), 8pt white, opacity 0.8↔0.6; text path stays on the base radius.
- Audio: BGM `space-music.mp3` loops with silence-trim + 4s equal-power crossfade, master 0.385. The timeline defaults to sound on at the middle step, "low" (BGM 0.12, SFX 0.6; music starts on first gesture if the browser blocks autoplay). Top nav volume icon cycles full → low (BGM 0.12, SFX unchanged) → off (no BGM, SFX at half volume, 0.3); its soundwave reads the audible mix. Hover SFX `hover.mp3` on stars, and at 50% on all other interactive UI (both pages): single voice, 8ms attack, 70ms retrigger guard, compressor.
