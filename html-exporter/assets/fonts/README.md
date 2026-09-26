# Source Sans 3 font assets

These assets use Adobe's Source Sans 3 under the SIL Open Font License 1.1.
The original copyright notice and complete license are in [OFL.txt](OFL.txt).
The license permits webfont distribution and PDF embedding. Retain the license
and copyright notice when redistributing these font files.

## Provenance

The TTFs are unmodified copies from Adobe's `source-sans` release branch at
commit `87b37a2daaed80fcb8e8ccb0085c4d72ddade12e`:

- [Regular TTF](https://raw.githubusercontent.com/adobe-fonts/source-sans/87b37a2daaed80fcb8e8ccb0085c4d72ddade12e/TTF/SourceSans3-Regular.ttf)
- [Bold TTF](https://raw.githubusercontent.com/adobe-fonts/source-sans/87b37a2daaed80fcb8e8ccb0085c4d72ddade12e/TTF/SourceSans3-Bold.ttf)
- [Original license](https://raw.githubusercontent.com/adobe-fonts/source-sans/87b37a2daaed80fcb8e8ccb0085c4d72ddade12e/LICENSE.md)
- [Upstream project](https://github.com/adobe-fonts/source-sans)

The family name is `Source Sans 3`. Regular has weight 400 and Bold has weight
700. These are static fonts. No instancing, subsetting, scaling, hint removal,
or renaming was applied to the TTFs. Their original Adobe metadata is intact.

The license reserves the font name `Source`. Keep using the original font
software unless the license's requirements for modified versions are met.
The WOFF files apply standard lossless compression to the TTFs and retain all
font tables and metadata, apart from the format's file-checksum adjustment.

## Reproduction

Download the pinned TTFs above into this directory using their original
filenames and verify their SHA-256 values below. Save the original `LICENSE.md`
contents as `OFL.txt`. From the repository root, run:

```sh
python3 scripts/build_web_fonts.py
```

The script requires fontTools, generates `SourceSans3-Regular-web.woff` and
`SourceSans3-Bold-web.woff`, and updates their CSS cache versions. These WOFFs
were generated with fontTools 4.63.0. The TTFs remain byte-for-byte identical
to Adobe's files.

## Shipped checksums

| File | SHA-256 |
| --- | --- |
| `SourceSans3-Regular.ttf` | `4644c81b86ec9caaa76b634889968ed3c4f4f52f054855933acc7c2b21e53b0f` |
| `SourceSans3-Bold.ttf` | `9214b9d95e4231c609802815c2646c98174e2102d0d37f88978a7f8e71006e6a` |
| `SourceSans3-Regular-web.woff` | `3dbf4ec102f96f0e366a665e5800f3f19caae580f317a36427c20300788dac0b` |
| `SourceSans3-Bold-web.woff` | `46e53922ba5798382a353548d9e5eadbbc3b516e24cc7037720c09da44afffbf` |
| `OFL.txt` | `56af9b9c6715597e458284a474dc118a50a4150e9d547c70f7b4a33c3e6a9328` |
