# Patched Fonts

## Pragmasevka Nerd Font

The original Pragmasevka Nerd Font has `isFixedPitch=0` in its `post` table, which causes some applications (like COSMIC Terminal) to not recognize it as a monospace font.

The fonts in `pragmasevka-nf.tar.gz` have been patched to set `isFixedPitch=1`.

### Upstream Source

Pragmasevka is maintained at: https://github.com/shytikov/pragmasevka

When a new version is released, download the Nerd Font variant and re-patch it using the script below.

### Installation

```bash
mkdir -p ~/.local/share/fonts/PragmasevkaNerdFont
tar -xzf pragmasevka-nf.tar.gz -C ~/.local/share/fonts/PragmasevkaNerdFont
fc-cache -f
```

### How to Patch Fonts Manually

If you need to re-patch fonts after an update, use this Python script:

```python
#!/usr/bin/env python3
"""Patch TTF font to set isFixedPitch=1 in the post table."""

import struct
import os

def read_u16(data, offset):
    return struct.unpack(">H", data[offset:offset+2])[0]

def read_u32(data, offset):
    return struct.unpack(">I", data[offset:offset+4])[0]

def write_u32(data, offset, value):
    data[offset:offset+4] = struct.pack(">I", value)

def patch_font(filepath):
    with open(filepath, "rb") as f:
        data = bytearray(f.read())

    num_tables = read_u16(data, 4)
    post_offset = None
    table_offset = 12

    for i in range(num_tables):
        tag = data[table_offset:table_offset+4].decode('ascii')
        if tag == "post":
            post_offset = read_u32(data, table_offset + 8)
            break
        table_offset += 16

    if post_offset is None:
        print(f"ERROR: post table not found in {filepath}")
        return

    # isFixedPitch is at offset 12 in the post table (uint32)
    current_value = read_u32(data, post_offset + 12)
    print(f"{os.path.basename(filepath)}: isFixedPitch was {current_value}", end="")

    if current_value != 1:
        write_u32(data, post_offset + 12, 1)
        with open(filepath, "wb") as f:
            f.write(data)
        print(" -> now 1")
    else:
        print(" (already 1)")

# Usage: patch_font("/path/to/font.ttf")
```

### Why This Is Needed

- The `post` table in TTF/OTF fonts contains an `isFixedPitch` flag
- When `isFixedPitch=0`, some applications don't list the font as monospace
- Nerd Fonts include double-width icons, so fontconfig detects them as `spacing: 90` (dual-width) instead of `spacing: 100` (monospace)
- COSMIC Terminal reads font metadata directly from files, bypassing fontconfig overrides
