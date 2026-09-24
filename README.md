# Pi-hole Modern

A modern light/dark theme for the **Pi-hole v6** web interface. Pure CSS — it touches neither Pi-hole's markup nor its JavaScript.

- Soft-shadowed cards, rounded corners, tidy tables and forms.
- Light and dark schemes in **one file**, plus an "auto" mode that follows the OS setting.
- Dashboard charts pick up the theme colors (Pi-hole reads them from CSS).
- Works on mobile and with the sidebar collapsed.
- A single file, no dependencies: text uses the system font, nothing is loaded from the internet.

```
pihole-modern.css     ← the theme itself (the only file needed on the server)
install.sh            ← install / roll back on the server
preview/pages/        ← offline preview: 20 admin pages
preview/pihole/       ← Pi-hole v6.6 files (vendor libraries, pi-hole.css, scripts)
preview/api/data.js   ← recorded API responses for the preview
preview/assets/       ← preview panel and API stub (not needed on the server)
```

## Preview without a server

Open `preview/pages/index.html` in a browser — the admin interface runs locally, no Pi-hole required.

The pages were taken from a running Pi-hole v6.6 as they are: same markup, same scripts, same libraries. The data (queries, charts, lists, logs) is served by the `preview/assets/mock-api.js` stub from recorded API responses, in which domains, device names, IP and MAC addresses have been replaced with fictional ones.

The panel in the bottom-right corner:

- **Scheme** — auto / light / dark (the same choice as the theme setting in Pi-hole);
- **Page** — any of the 20 screens;
- **Collapse menu** and **Boxed layout**.

Available screens: dashboard, query log, groups, clients, domains, lists, seven settings pages, diagnosis, Gravity update, log viewer, list search, network interfaces, network table, login.

Edit `pihole-modern.css`, reload the page, and the change is there. URL parameters: `?theme=default-dark`, `?collapsed=1`, `?boxed=1`.

To refresh the preview data from your own Pi-hole, save the responses of the relevant `/api/...` endpoints into `preview/api/data.js` (the format is `window.PV_API = { "stats/summary": {…} }`).

## How the light/dark switch works

CSS alone cannot add a button to the interface that remembers a choice — that needs JavaScript or a markup change. So the theme rides on the switch Pi-hole already has: **Settings → Web interface / API → Theme**. Pi-hole puts the selected theme's class on `<body>`, and the CSS picks the scheme from it:

| Choice in Pi-hole                    | `body` class        | Scheme                  |
|--------------------------------------|---------------------|-------------------------|
| Pi-hole default theme (auto)         | `default-auto`      | follows the OS          |
| Pi-hole default theme (light)        | `default-light`     | light                   |
| Pi-hole default theme (dark)         | `default-dark`      | dark                    |

On the login page Pi-hole sets no theme class. The markup still reveals the choice through the stylesheet link (`.../themes/default-dark.css`; in "auto" mode both files are linked with a `media` attribute), and the theme reads the scheme from that — so the login form matches the rest of the interface.

## Installing on Pi-hole v6

Pi-hole v6 only knows its built-in themes (the list is compiled into FTL), so a new theme cannot be added — an existing one has to be replaced. The script copies `pihole-modern.css` over `default-light.css` and `default-dark.css`. The originals are kept as `*.orig`.

```bash
# copy the folder to the Pi-hole host (pihole-modern.css and install.sh are enough)
scp pihole-modern.css install.sh pi@pi.hole:~
ssh pi@pi.hole
chmod +x install.sh
sudo ./install.sh
```

Then pick *Pi-hole default theme (auto / light / dark)* in **Settings → Web interface / API** and reload with `Ctrl+F5`.

The same by hand:

```bash
cd /var/www/html/admin/style/themes/
sudo cp default-light.css default-light.css.orig
sudo cp default-dark.css  default-dark.css.orig
sudo cp ~/pihole-modern.css default-light.css
sudo cp ~/pihole-modern.css default-dark.css
```

**Docker:** the path inside the container is the same. Copy the files with `docker cp`, or mount them as volumes:

```yaml
volumes:
  - ./pihole-modern.css:/var/www/html/admin/style/themes/default-light.css:ro
  - ./pihole-modern.css:/var/www/html/admin/style/themes/default-dark.css:ro
```

### Rolling back

```bash
sudo ./install.sh --restore
# or with git: the Pi-hole web interface is a git repository
cd /var/www/html/admin && sudo git checkout -- style/themes
```

`pihole -up` restores the stock files. Run `install.sh` again after an update (or use the Docker volumes, which survive updates).

## Customizing

The accent color lives in one place, right at the top of `pihole-modern.css`. Links, the active menu item, buttons and the focus ring all follow it:

```css
--pm-accent-light: #5b5bd6; /* light scheme */
--pm-accent-dark: #7c7cff;  /* dark scheme  */
```

The remaining colors, radii and shadows are in the same "DESIGN TOKENS" block — separately for the light and the dark scheme.

⚠️ Give the row colors of the **Network** page (`--pm-net-*`) opaque `rgb(r, g, b)` values only. Pi-hole's `scripts/js/network.js` reads them from the CSS and parses them with a strict pattern: `color-mix()` or any transparency breaks the table.

## Accessibility

- The theme honors the "reduce motion" and "increase contrast" system settings.
- Print styles are included: only the page content goes on paper, on white, without the sidebar and the header.

## Limitations

- The colors of the pie charts and of "Client activity" are hardcoded in Pi-hole's JavaScript (`THEME_COLORS`) and cannot be changed from CSS.
- Text is rendered with the system font stack (Segoe UI, SF Pro, Roboto), so the exact look differs a little between operating systems.
- A current browser is required: the theme uses `:has()` and `color-mix()` (Chrome/Edge 111+, Firefox 121+, Safari 16.4+).

---

The Pi-hole originals in `preview/pihole/` (vendor libraries, `pi-hole.css`, the logo) come from [pi-hole/web](https://github.com/pi-hole/web) and are distributed under its license (EUPL, see `preview/pihole/LICENSE`). They are only needed for the preview.
