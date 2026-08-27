# Impossible Objects

A browser-based designer for **impossible objects** — 3D printable shapes
that show one silhouette from the front and a completely different
silhouette from the rear (or in a mirror placed behind them). Pick two 2D
curves, preview the resulting 3D form live, and export a ready-to-print
OpenSCAD file.

Try it live: open `index.html` in a modern browser (Chrome, Firefox, Safari,
Edge — anything with WebGL).

## How it works

The object is a thin ribbon swept along a closed curve. At every point
around the loop, the curve's height above the "floor" is set so that:

- viewed head-on from the front, the ribbon's silhouette traces **Image 1**
- viewed head-on from the rear, the ribbon's silhouette traces **Image 2**

Because the two curves are independent, the printed object reads as one
shape from the front and an entirely different shape from the back.

### Two ways to view the 3D preview

- **Front/Rear view** — two independent cameras, one on each side, that you
  can freely orbit and zoom (drag to rotate, scroll/pinch to zoom).
- **Front/Mirror view** — locks both cameras together as if a mirror were
  propped up behind the object: the front pane shows the object directly,
  the rear pane shows its mirror image. This is how the illusion is
  actually meant to be viewed in person (see the in-app Instructions for
  photos and the physical viewing setup).

### Choosing shapes

Each side (Image 1 / Image 2) can be set from the built-in shape library
(`curve_defs/svg/`) or by uploading your own `.svg`. An uploaded curve must
be:

- a single closed outline (like the sample shapes)
- crossed at most twice by any vertical line — i.e. bounded above and below
  by two functions of *x* (indentations that violate this are ignored)

SVGs exported from **GeoGebra** and **Desmos** are supported directly — the
importer strips out the background rect, empty placeholder paths, and
grid/graphpaper chrome those tools include in their exports, leaving just
the curve.

### Exporting to print

**Export to OpenSCAD** downloads a self-contained `.scad` file with your
current dimensions pre-filled (also editable later via OpenSCAD's
Customizer). It optionally adds three ribbon-style support legs, spaced
120° apart, that follow the curve for a set width before dropping straight
to a flat foot — sized to match the ribbon's own wall thickness. Full
print/viewing instructions (including how to prop a mirror behind the
finished piece to see the second silhouette) are in the in-app
Instructions panel and `about.html`.

## Files

| Path | Purpose |
|---|---|
| `index.html` | The app itself — UI, 3D preview (Three.js), and OpenSCAD export, all in one file |
| `about.html` | Full instructions (design → export → print → view), shown in-app as a popup |
| `three.core.js`, `three.module.js` | Vendored [Three.js](https://threejs.org/) build used for the 3D preview |
| `curve_defs/svg/` | Built-in shape library shown in the dropdown menus |
| `photos/` | Reference photos used in the instructions (mirror/shadow viewing techniques) |

## Running locally

The app fetches shapes from `curve_defs/svg/` via `fetch()`, so it needs to
be served over HTTP rather than opened as a `file://` URL:

```bash
python3 -m http.server 8000
# then open http://localhost:8000/index.html
```

No build step, no dependencies to install — it's static HTML/CSS/JS.

## History

This app began as part of a larger project researching and printing
impossible objects; the LaTeX paper, print pipeline, and other research
material live in a separate repository. This repo contains just the
interactive web designer, split out with its full commit history.
