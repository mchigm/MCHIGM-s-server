# NewVisualKeybing — Custom UI Textures

Drop PNG files in this folder to re-skin the mod's UI, then open the visual keybind screen and click the skin button until it shows "Custom".

## Texture packs

Textures are organised into packs, and one is active at a time:
- Loose PNGs placed directly in this folder form the "Default (loose files)" pack.
- A subfolder containing PNGs is a pack named after the folder.
- A `.zip` archive is a pack named after the file (textures may sit at the zip root or inside a single wrapping folder; each may carry its own `pack.json`).
- Shift+click the skin button to cycle to the next pack (it also reloads). The active pack is remembered in the config.

## How it works

- Each component below loads from one PNG named exactly as shown. Missing files fall back to the built-in vanilla look, so you can override only what you want.
- Format: 32-bit PNG with an alpha channel (RGBA). Any size works; non-power-of-two is fine.
- Nine-slice: the `border` (corner inset, in pixels) stays un-stretched while the edges and centre stretch to any widget size. Per-slot defaults are listed below; override them in `pack.json`.
- Stretch: the whole image is stretched to the target rectangle.
- Tile: the image repeats at its native size.
- `key` and `mouse_button` are tinted (multiplied) by the key's status colour — paint them light grey/white so the colour shows. Or supply the per-status `key_*` files for exact control (drawn untinted).
- After editing files, reopen the screen or Shift+click the skin button to reload / cycle packs.

## Components

| File | Scale | Default border | Tinted | Recommended size | Use |
|---|---|---|---|---|---|
| `panel.png` | nine-slice | 10 px | no | 48×48 px | Background of every panel/window (mod list, mouse, details, popovers). |
| `button.png` | nine-slice | 4 px | no | 80×24 px | Normal (idle) toolbar/header button. |
| `button_hover.png` | nine-slice | 4 px | no | 80×24 px | Hovered/focused button. Falls back to 'button' if absent. |
| `button_disabled.png` | nine-slice | 4 px | no | 80×24 px | Disabled button. Falls back to 'button' if absent. |
| `editbox.png` | nine-slice | 3 px | no | 64×24 px | Idle text field (search boxes, name fields). |
| `editbox_focused.png` | nine-slice | 3 px | no | 64×24 px | Focused text field. Falls back to 'editbox' if absent. |
| `tooltip.png` | nine-slice | 6 px | no | 32×32 px | Hover tooltip frame. |
| `key.png` | nine-slice | 6 px | yes | 32×32 px | Generic keycap, multiplied by the key's status colour. Make it light grey so the tint reads. |
| `key_free.png` | nine-slice | 6 px | no | 32×32 px | Unbound key (overrides the tinted 'key' for this status, drawn untinted). |
| `key_self.png` | nine-slice | 6 px | no | 32×32 px | Key bound to this mod (untinted override). |
| `key_other.png` | nine-slice | 6 px | no | 32×32 px | Key bound to another mod / single binding (untinted override). |
| `key_combo.png` | nine-slice | 6 px | no | 32×32 px | Key used in a key combination (untinted override). |
| `key_conflict.png` | nine-slice | 6 px | no | 32×32 px | Key with conflicting bindings (untinted override). |
| `keyboard_chassis.png` | nine-slice | 12 px | no | 64×64 px | The tray/board the keys sit on. |
| `mouse_body.png` | stretch | — | no | 80×116 px | The mouse silhouette. Stretched to the body rect (keep the 80x116 aspect for best results). |
| `mouse_button.png` | nine-slice | 6 px | yes | 32×32 px | A mouse button cell, tinted by status. Falls back to 'key' if absent. |
| `background.png` | tile | — | no | 32×32 px | Full-screen background, tiled at native size (like the vanilla dirt menu background). |

## pack.json (optional)

Override per-slot `border`, `tint`, and `scale` (`nineslice` / `stretch` / `tile`). A ready-to-edit template was generated next to this file.
