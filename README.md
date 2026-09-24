# Pi-hole Modern

A modern light/dark theme for the **Pi-hole v6** web interface. Pure CSS — it touches neither Pi-hole's markup nor its JavaScript.

- Soft-shadowed cards, rounded corners, tidy tables and forms.
- Light and dark schemes in **one file**, plus an "auto" mode that follows the OS setting.

```
pihole-modern.css     ← the theme itself (the only file needed on the server)
install.sh            ← install / roll back on the server
```

## Installing

The script copies `pihole-modern.css` over `default-light.css` and `default-dark.css`. The originals are kept as `*.orig`.

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
