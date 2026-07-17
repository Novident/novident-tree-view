# Scrivener-like Example – Design Guide

> Reference document for the workspace shipped in `example/`.  
> Every colour, spacing, animation, layout constraint, and tree
> organisation decision is explained so it can be reused as a
> component library and visual benchmark for larger projects.

---

## Interface layout (at a glance)

```
┌────────────────────┬────────────────────────────────────────────────────────┐
│      BINDER        │                     EDITOR PANE                        │
│   240‥320 px       │                                                        │
│  ┌──────────────┐  │  ┌─ Breadcrumb ──────────────────────────────────────┐ │
│  │ 📖 Project   │  │  │  Research  ▸  README                               │ │
│  │   name       │  │  └────────────────────────────────────────────────────┘ │
│  ├──────────────┤  │  ┌─ Format bar (single scrollable row) ──────────────┐ │
│  │ + 📄  + 📁  │  │  │  B  I  U  S  H1  H2  "  ·  ≡  …                   │ │
│  │          🗑  │  │  └────────────────────────────────────────────────────┘ │
│  ├──────────────┤  │                                                        │
│  │              │  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  │ ▸ 📁 Chapter │  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  │ ▾ 📂 Research│  │  ░░  ┌──────────────────────────────────────────┐  ░░ │
│  │   📄 README  │  │  ░░  │                                          │  ░░ │
│  │ ▸ 📁 Charactr│  │  ░░  │           WHITE PAGE                    │  ░░ │
│  │ ▸ 📁 Places  │  │  ░░  │          750 px max                     │  ░░ │
│  │              │  │  ░░  │          margin 56 × 40                 │  ░░ │
│  │              │  │  ░░  │          shadow: 2‑layer                │  ░░ │
│  │              │  │  ░░  │                                          │  ░░ │
│  │              │  │  ░░  │    🌳 Novident Tree View                │  ░░ │
│  │              │  │  ░░  │    =================                    │  ░░ │
│  │              │  │  ░░  │                                          │  ░░ │
│  │              │  │  ░░  │    This package provides a flexible…     │  ░░ │
│  │              │  │  ░░  │                                          │  ░░ │
│  │              │  │  ░░  └──────────────────────────────────────────┘  ░░ │
│  │              │  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  │              │  │     workspace background: #ECECEC                    │
│  │              │  │                                                        │
│  └──────────────┘  │  ┌─ Drag veil (only visible during drag‑over) ───────┐ │
│                    │  │  ╔══════════════════════════════════════════════╗  │ │
│                    │  │  ║            ┌─────────────────────┐          ║  │ │
│  Binder surfaces:  │  │  ║            │ 📄 Open "README"    │          ║  │ │
│  #F0EFEE           │  │  ║            └─────────────────────┘          ║  │ │
│  border: #D6D6D6   │  │  ╚══════════════════════════════════════════════╝  │ │
│                    │  │  └──────────────────────────────────────────────────┘ │
└────────────────────┴────────────────────────────────────────────────────────┘
```

**Reading the diagram:**

| Zone | Background | Contains |
|---|---|---|
| Binder (left) | `#F0EFEE` warm off‑white | Project header, toolbar, scrollable tree |
| Editor pane (right) | `#ECECEC` workspace grey | Breadcrumb, format bar, sheet‑of‑paper, drag veil |
| Page | White (`#FFFFFF`) | Quill rich‑text document, 750 px max, 2‑layer shadow |
| Drag veil | 25 % black + accent border | Only visible while dragging a file over the editor |

The layout is a single `Row` with no nested `Scaffold` tricks —
the binder width is `(screen × 0.30).clamp(240, 320)` and the editor
fills the rest via `Expanded`.

---

## Scrivener design guidelines applied

This workspace is a deliberate **spatial‑and‑chromatic** adaptation
of Literature & Latte's Scrivener 3 for macOS, translated into
Material Design widgets.

### Guideline 1 — The Binder (sidebar tree)

**Scrivener's rule:** The leftmost column is a persistent tree
(“Binder”) that shows the whole project structure at a glance —
groups, documents, and metadata sheets live at the same level.
Folders open with a disclosure triangle; selected items receive a
full‑width highlight.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Persistent left column, constant width | `SizedBox(clamp 240‥320)` inside a `Row` | 5.1 |
| Project icon + title at top | `TreeViewHeaderTitle` with `book_fill` icon | 2.2 |
| Folders with disclosure triangle | `AnimatedRotation(chevron_right)` — 0.25 turns | 2.4 |
| Full‑row selection highlight | `NodeConfiguration.decoration` with `primaryColor.withAlpha(50)` on the row container | 10.4 |
| Child‑count badge on collapsed folders | `Text('${directory.length}')` shown only when `!isExpanded` | 2.4 |
| Compact row height | 4 px vertical padding → ~28 px total row height | 5.3 |

### Guideline 2 — Three‑column separation

**Scrivener's rule:** Binder, Editor, and Inspector are three
distinct visual zones separated by vertical dividers, never by
`Card` or `elevation` — the zones feel like they belong to the same
window.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Single divider between zones | `Border(right: 1px, #D6D6D6)` on the binder container | 2.1 |
| Binder tinted slightly warmer than editor | Binder `#F0EFEE` vs editor `#ECECEC` | 2.1, 12 |
| No card/chip frames around zones | Zero `elevation` on `Drawer`; binder is flat | 2 |
| Header/toolbar share the same colour as their zone | `bg: white` inside the editor, not a separate `AppBar` | 3.1–3.2 |

### Guideline 3 — The Editor as a sheet of paper

**Scrivener's rule:** The text area must feel like a physical page
resting on a desk. This is the most important psychological cue for
long‑form writing: a bounded white rectangle with a soft shadow over
a darker neutral background.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Grey desk background behind the paper | `Scaffold.backgroundColor: #ECECEC` | 1, 12 |
| Fixed‑width white page | `ConstrainedBox(maxWidth: 750)`, `bg: white`, `borderRadius: 3` | 3.3 |
| Soft layered shadow (“floating but grounded”) | Two `BoxShadow`s: deep (14 px blur) + tight (3 px blur) | 3.3 |
| Comfortable text margins | `padding: 56 h × 40 v` inside the editor scroll | 3.3 |
| Format bar above the paper (not floating) | `Column(breadcrumb, formatBar, Expanded(page))` — fixed position | 3.2 |

### Guideline 4 — Chromatic restraint

**Scrivener's rule:** The interface is chrome‑less. Only the
manuscript is “saturated”; every UI element uses low‑chroma greys
and a single accent colour.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Neutral‑grey theme seed | `ColorScheme.fromSeed(seedColor: Colors.blueGrey)` | 12 |
| One accent colour, used sparingly | `colorScheme.primary` drives header icon, breadcrumb accent, overlay border, and selection fill | 2.2, 3.1, 4.2, 10.4 |
| Icons are greyscale unless signalling state | Trash = grey unless hovered; chevron = grey; folder = `#6FA8DC` (the only coloured icon in the binder) | 2.1, 2.3 |
| Dividers are a single `#D6D6D6` everywhere | Binder border, toolbar divider, breadcrumb border | 2.1, 3.1, 3.2 |

### Guideline 5 — Drag‑and‑drop as a structural operation

**Scrivener's rule:** Reorganising the binder must be a one‑gesture
drag operation with immediate positional feedback (a coloured line
or box showing where the item will land) and a rejection indicator
for invalid targets.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Blue insertion line (above / inside / below) | `2px blueAccent Border` on `top`, all sides, or `bottom` | 10.1 |
| Red line for invalid drops | `2px redAccent Border` + `withAlpha(50)` red fill | 10.1 |
| No‑op detection (drop onto self / neighbouring sibling) | Red border when `draggedIndex + 1 == targetIndex` | 10.2 |
| Drag feedback card that mirrors the row | `NodeDragCard` — same icon rules + name + `minWidth: 80` | 11 |
| Error badge on the feedback card itself | Live `ValueListenableBuilder` reading `DragAndDropDetailsListener`; shows red ⊘ when target rejects | 11 |
| Dimmed source row while dragging | `Colors.grey.withAlpha(30)` fill + `beingDragged` muted icon/text | 2.6, 10.3 |
| Auto‑expand folders on hover | `expandOnHover: true` in `DraggableConfigurations` | (config) |

### Guideline 6 — Breadcrumb, not tab bar

**Scrivener's rule:** Scrivener 3 uses a breadcrumb path (e.g.
`Draft ▸ Chapter 1 ▸ Scene`) rather than document tabs. The last
segment is the current document, ancestors are deemphasised but
visible.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Path separated by chevrons | `CupertinoIcons.chevron_right`, 11 px | 3.1 |
| Current document = bold + darkest colour | Last segment: `weight: 600`, `color: black87` | 3.1 |
| Ancestors = regular weight + lighter | Prior segments: `weight: 400`, `color: grey.shade600` | 3.1 |
| Walk the tree to build the path | `_breadcrumbSegments()` walks `owner` chain, stops at `Root` | 3.1 |

### Guideline 7 — Project metadata as documents

**Scrivener's rule:** Character sheets, setting notes, and research
folders are first‑class binder items — not buried in a separate
panel. The binder is the single source of truth for *everything*
in the project.

| Scrivener feature | Our equivalent | Section |
|---|---|---|
| Characters and Places at root level | Directories `Characters/` and `Places/` next to `Manuscript/` | 8.1 |
| Structured metadata documents | Character sheet (`Role`, `Age`, `Home`, `Keepsake`), setting sheet (`Rules`, `Open questions`) | 8.2 |
| Research folder with reference material | `Research/` directory containing the package README as a reference document | 8.1 |

---

## 1. Workspace architecture (widget tree)

### 1.1 Desktop view

```
Scaffold (bg: #ECECEC)
└── Row
    ├── RepaintBoundary
    │   └── SizedBox (240‥320 px)
    │       └── TreeViewDrawer ── ► Binder (section 2)
    │
    └── Expanded
        └── Column
            ├── Breadcrumb (40 px, white, bottom border)
            ├── Format bar (white, bottom border)
            │   └── QuillSimpleToolbar (single row)
            └── Expanded
                └── Stack
                    ├── Positioned.fill
                    │   └── _buildPage()             ← sheet-of-paper
                    └── Positioned.fill
                        └── _buildEditorDropTarget()  ← drag veil
```

### 1.2 Binder

```
SafeArea
└── Drawer (elevation: 0, bg: #F0EFEE)
    └── Container (right border: #D6D6D6)
        └── Column
            ├── TreeViewHeaderTitle (project name + subtitle)
            ├── TreeViewToolbar (add doc / add folder / trash)
            ├── Divider (1 px, #D6D6D6)
            └── Expanded
                └── SingleChildScrollView
                    └── TreeView
                        ├── DirectoryTile ─ ─ ─ ─  or
                        └── FileTile
```

---

## 2. Binder — component details

### 2.1 Drawer colours

| Token | Value | Role |
|---|---|---|
| `_kBinderBackground` | `#F0EFEE` | Main binder surface |
| `_kBinderBorder` | `#D6D6D6` | Right-edge separator, toolbar divider |
| Folder icon | `#6FA8DC` | Directory icon (only folder; chevron stays grey) |
| Document icon | `Colors.blueGrey.shade400` | File icon |
| Muted colour (drag) | `Colors.black.withAlpha(150)` | Whole row dimmed while being dragged |

**Rationale.** `#F0EFEE` is a warm off-white — warmer than pure `#F5F5F5` — that creates a
soft contrast against the editor's `#ECECEC` without introducing visual noise.
`#D6D6D6` is a single non-black border colour used consistently everywhere
(binder, breadcrumb, toolbar).  A single divider token keeps the workspace
calm and predicable.

### 2.2 Header

```dart
// Padding: 12‥12‥12‥8 (top, right, bottom, left)
Row(
  children: [
    Icon(CupertinoIcons.book_fill, size: 18, color: Theme.primary),
    SizedBox(width: 8),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The Hollow Forest',
                style: 14, weight: 700, maxLines: 1, overflow: ellipsis),
          Text('Novident Tree View demo',
                style: 11, color: grey.shade600),
        ],
      ),
    ),
  ],
)
```

| Decision | Why |
|---|---|
| `CupertinoIcons.book_fill` | Carries the "manuscript / project" metaphor from the splash screen into the binder. |
| 18 px icon, 8 px gap | The icon is slightly larger than row icons (17/16 px) so it acts as a visual anchor — the reader's eye starts at the top-left. |
| Subtitle in `grey.shade600` at 11 px | Demotes supplementary information without hiding it. Anyone who needs to know the package name can read it, but it doesn't compete with document titles. |
| `overflow: ellipsis` | The binder column is narrow (240‥320 px). An ellipsis keeps the layout predictable; the full name is always visible in the editor breadcrumb. |

### 2.3 Toolbar

```dart
Row(
  children: [
    Tooltip('New document'   , IconButton(note_add_outlined   , size: 18)),
    Tooltip('New folder'     , IconButton(folder_fill_badge_plus, size: 18)),
    Spacer(),
    _buildTrashTarget(),  // AnimatedContainer + DragTarget
  ],
)
```

**Icon choices.**

| Action | Icon | Why |
|---|---|---|
| New document | `Icons.note_add_outlined` | Outlined variant avoids competing with the filled document icons inside the tree. |
| New folder | `CupertinoIcons.folder_fill_badge_plus` | The `+` badge is universally understood as "add" and the filled folder matches the tree's visual language. |
| Delete | `CupertinoIcons.trash` | Simple, universal; no text needed. |

**Trash target (AnimatedContainer + DragTarget).**

```dart
AnimatedContainer(
  duration: 150 ms,
  width: 30, height: 30,
  decoration: BoxDecoration(
    color: value ? Colors.redAccent : Colors.transparent,
    borderRadius: BorderRadius.circular(5),
  ),
  child: Icon(
    CupertinoIcons.trash, size: 18,
    color: value ? Colors.white : Colors.grey.shade700,
  ),
)
```

| Decision | Why |
|---|---|
| 30×30 px square | Match the 28 px row height — the icon doesn't stretch the toolbar bar. |
| `AnimatedContainer` 150 ms | Same duration as the chevron rotation (section 2.4). Consistent motion language across the sidebar. |
| Trash icon colour flip (grey → white on red) | When inactive it blends into the toolbar; when a node hovers it it screams "danger". The red background is `Colors.redAccent` — saturated enough to be unmistakable but not neon. |
| Only root-level children are removable | `onWillAcceptWithDetails` checks `widget.controller.root.contains(data)`. This prevents accidental deletion of deeply nested nodes whose parent might not be the root. |

### 2.4 Directory tile

```dart
Padding(symmetric(vertical: 4, horizontal: 3),
  child: Row(children: [
    AnimatedRotation(     turns: isExpanded ? 0.25 : 0.0 ),
      Icon(CupertinoIcons.chevron_right, size: 12),
    SizedBox(width: 4),
    Icon(CupertinoIcons.folder_fill / folder_open, size: 17, color: #6FA8DC),
    SizedBox(width: 6),
    Expanded(Text(name, size: 13)),
    if (!isExpanded && isNotEmpty) Text(childCount, size: 11, grey),
  ]),
)
```

**Chevron design.**

| Decision | Value | Why |
|---|---|---|
| Icon | `CupertinoIcons.chevron_right` | Small, neutral, universally recognised. |
| Size | 12 px | Smaller than the folder so the folder is the primary icon, not the chevron. |
| Rotation | `0` → `0.25` turns (90°) | A quarter-turn is the standard "open disclosure" animation. |
| Duration | 150 ms | Quick enough to feel snappy, slow enough to see the transition (matching the trash hover). |
| Curve | `Curves.easeOut` | Starts fast (the user already decided to click), ends slow (the folder appears smoothly). |

**Folder icon.**

| State | Icon | Meaning |
|---|---|---|
| Collapsed | `folder_fill` | "There is content inside, you just can't see it yet." |
| Expanded (any) | `folder_open` | "You are looking inside." |

Note: the old code used `folder_open` only when expanded AND empty — a
bug. The new code correctly shows `folder_open` whenever the directory
is expanded, regardless of child count.

**Child-count badge** (visible only when collapsed and non-empty).

```
Text('${directory.length}', size: 11, color: grey.shade500)
```

Scrivener shows a small badge next to collapsed folders. This is the
equivalent decision, rendered at 11 px `grey.shade500` so it's
informative but never distracting.

**Row alignment compensation.** Directory rows start at `x=0` (after
3 px horizontal padding). File rows add a 16 px spacer to compensate
for `chevron(12) + gap(4) = 16`. This makes file names align
vertically with directory names regardless of depth level.

### 2.5 File tile

```dart
Padding(symmetric(vertical: 4, horizontal: 3),
  child: Row(children: [
    SizedBox(width: 16),                         // ← compensates chevron
    Icon(doc_text / doc_text_fill, size: 16, color: blueGrey.shade400),
    SizedBox(width: 6),
    Expanded(Text(name, size: 13)),
  ]),
)
```

| Decision | Why |
|---|---|
| 16 px spacer | Aligns file icons under directory text (see row alignment above). |
| Icon size 16 px | Slightly smaller than the 17 px folder so the folder reads as "parent" and the file as "child". |
| `blueGrey.shade400` | Cool grey with a blue tint. Warmer than `Colors.grey` and distinct from the chevron/trash greys. |
| `doc_text` vs `doc_text_fill` | Empty files show outlined (they are "blank"); files with content show filled (they "have something"). A tiny detail that adds information density at zero cost. |

### 2.6 Drag-dimmed state

Both tiles receive a `beingDragged` bool from their parent builder.
When `true`:

```dart
final Color? mutedColor = beingDragged ? Colors.black.withAlpha(150) : null;
// applied to: chevron, folder icon, text colour
```

| Decision | Why |
|---|---|
| Dim everything, not just text | A dimmed icon and dimmed text together communicate "this entire row is currently being moved" — stronger than just fading the text. |
| `Colors.black.withAlpha(150)` | ~59 % opacity. Readable enough to identify the node, faded enough to distinguish it from static rows. |

---

## 3. Editor pane — component details

### 3.1 Breadcrumb

```dart
Container(height: 40, padding: horizontal 16, bg: white,
          border: bottom 1px #D6D6D6,
  child: Row(children: [
    for (int i = 0; i < segments.length; i++) ...[
      if (i > 0) Icon(chevron_right, size: 11, grey.shade500),
      Text(segments[i],
           color:     last ? black87 : grey.shade600,
           weight:    last ? w600 : w400,
           size:      13),
    ],
  ]),
)
```

**How segments are built.**

```dart
List<String> _breadcrumbSegments() {
  final segments = <String>[];
  Node? current = _lastNode;
  while (current != null && !current.isRoot) {
    if (current.isFile)      segments.insert(0, current.asFile.name);
    if (current.isDirectory) segments.insert(0, current.asDirectory.name);
    current = current.owner;
  }
  return segments;   // e.g. ["Research", "README"]
}
```

| Decision | Why |
|---|---|
| Walk `owner` chain, stop at `Root` | `Root` is a synthetic container that shouldn't appear in the breadcrumb (it has no name). |
| Insert at index 0 | We walk bottom-up (leaf → root) but render left-to-right (root → leaf). |
| `identical()` guard in `_handleOnChangeSelection` | A clone after `NodeContainer.update()` has a different `NodeDetails` reference but equal values. `==` would miss the change; `identical()` catches it. |
| Last segment bold + black87 | The user is editing *this* document — it must be the most prominent item on the bar. |
| Chevron size 11 px | Smaller than the text (13 px) so it reads as punctuation, not as a button. |

### 3.2 Format bar

```dart
Container(padding: horizontal 8, vertical 2, bg: white,
          border: bottom 1px #D6D6D6,
  child: QuillSimpleToolbar(config: multiRowsDisplay: false))
```

`multiRowsDisplay: false` collapses the toolbar into a single
scrollable row (Scrivener's format bar is a single compact row, never
multi-row).  The toolbar does **not** warp — horizontal overflow
scrolls, keeping the editor canvas at a fixed height.

### 3.3 Sheet-of-paper (page)

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 750),
    child: Container(
      margin: 32‥24‥32‥24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(#33000000, blur: 14, offset: 0,4),  // deep shadow
          BoxShadow(#14000000, blur:  3, offset: 0,1),  // tight shadow
        ],
      ),
      child: MyEditor(padding: horizontal 56, vertical 40),
    ),
  ),
)
```

**Layered shadow system.**

```
┌─────────────────────────────────┐
│ Shadow 1 (tight, ~8 % opacity)  │  blur 3 px, offset 0,1
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │  Shadow 2 (wide, ~20 %)   │  │  blur 14 px, offset 0,4
│  │                           │  │
└──┴───────────────────────────┴──┘
```

| Layer | Opacity | Blur | Offset | Role |
|---|---|---|---|
| Deep | `0x33` (20 %) | 14 px | `(0, 4)` | Elevates the page from the workspace background. |
| Tight | `0x14` (8 %) | 3 px | `(0, 1)` | Defines the edge; without it the deep shadow looks "floating" rather than "resting on a desk." |

Two shadows layered produce a more realistic depth cue than a single
large blur.  This technique is used by Apple's HIG (NSWindow shadows)
and by many writing apps (Ulysses, iA Writer).

**Margin: 56 px horizontal × 40 px vertical.**

These values are passed as the editor's `padding` (via
`QuillEditorConfig`), meaning they live *inside* the white container
and scroll with the content.  They reproduce an A4 / US Letter margin
ratio approximately on a 750 px canvas: 56 / 750 ≈ 7.5 % which matches
standard word-processor margins.

**`clipBehavior: Clip.antiAlias`** on the container ensures the shadow
and border-radius are clean at the corners — the Quill editor paints to
the edge but the container clips it to the rounded rect.

### 3.4 No-file placeholder

```dart
Center(
  child: Column(
    mainAxisSize: min,
    children: [
      Icon(doc_text, size: 44, color: grey.shade500),
      SizedBox(height: 12),
      Text("There's no File to watch...",
           size: 20, weight: w500, color: grey.shade600),
    ],
  ),
)
```

| Decision | Why |
|---|---|
| Icon 44 px | Large enough to fill the empty visual space without feeling aggressive. |
| `doc_text` (outlined) | An outlined document is a "blank sheet" — thematically consistent with "no file selected". |
| 12 px gap | Standard 8-point grid spacing (`12 ≈ 1.5 × 8`). |

---

## 4. Drag-over-Editor overlay

### 4.1 Architecture

The overlay sits in a `Stack` as `Positioned.fill`, meaning it covers
the entire editor region.  When **not** dragging a File over the
editor it renders `SizedBox.expand()` (transparent, does not block
events).  When dragging a File it renders a veil + card.

```dart
DragTarget<Node>(
  onWillAcceptWithDetails: (details) {         // toggles _isDraggingAboveEditor
    _isDraggingAboveEditor.value = true;
    return details.data is File;               // only Files can be opened
  },
  onAcceptWithDetails: (details) {             // drop → select (open)
    _isDraggingAboveEditor.value = false;
    widget.controller.selectNode(details.data);
  },
  onLeave: (_) => _isDraggingAboveEditor.value = false,
  builder: (ctx, candidates, rejected) {
    final candidate = candidates.firstOrNull;
    return ValueListenableBuilder<bool>(        // reacts to _isDraggingAboveEditor
      builder: (ctx, isDragging, _) {
        if (!isDragging) return SizedBox.expand();  // ← PASSIVE state
        return _buildVeil(candidate);               // ← ACTIVE state
      },
    );
  },
)
```

**Why `onWillAcceptWithDetails` returns `true` only for `File`.**

A `Directory` dragged over the editor should *not* open — there is no
meaningful "editor view" for a folder.  Returning `false` means the
`DragTarget` never enters the "accept" flow, thereby never setting
`_isDraggingAboveEditor = true` and never showing the veil.

### 4.2 Visual composition (active state)

```dart
Container(
  margin: 16,
  decoration: BoxDecoration(
    color: #40000000,              // 25 % black — darkens the page
    borderRadius: 10,
    border: Border.all(color: accent, width: 2),
  ),
  child: Center(
    child: Material(
      elevation: 6,
      borderRadius: 10,
      child: Padding(20‥14, child: Row(
        mainAxisSize: min,
        children: [
          Icon(CupertinoIcons.doc_text_fill, size: 20, color: accent),
          SizedBox(width: 10),
          Text('Open "${candidate.asFile.name}"', size: 15, weight: w600),
        ],
      )),
    ),
  ),
)
```

| Decision | Why |
|---|---|
| Veil opacity `0x40` | 25 % opacity darkens the page enough to signal "modal" without making the document unreadable. |
| Veil margin 16 px | Inset from the page edge so the border-radius (10 px) doesn't clip and the page shadow remains visible at the corners. |
| Accent colour from `Theme.of(context).colorScheme.primary` | Adapts to light / dark theme; if the user changes the seed colour the overlay responds automatically. |
| `Material(elevation: 6)` | Lifts the "Open" card above the veil — two depth layers (veil + card) feel more polished than one flat overlay. |
| `CupertinoIcons.doc_text_fill` + accent | Reuses the document metaphor from the binder tree so the mental model ("I am moving this document from the tree to the editor") stays consistent. |

---

## 5. Sizing & layout tokens

### 5.1 Binder width

```dart
final binderWidth =
    (MediaQuery.sizeOf(context).width * 0.30).clamp(240.0, 320.0).toDouble();
```

| Breakpoint | Behaviour |
|---|---|
| Window < 800 px | Binder = 240 px (30 % of 800 = 252, clamped to 240). Editor still gets ≥ 560 px. |
| Window = 1067 px | Binder = 320 px (30 % of 1067 = 320). Editor gets 747 px. |
| Window > 1067 px | Binder stays at 320 px. Editor grows. |

The formula guarantees the binder never shrinks below a usable width
(240 px) and never grows beyond a point where it steals space from the
editor (320 px).  30 % is the golden ratio approximation for sidebar
widths (GitHub's file tree uses ~25 %; Finder uses ~20 %; Scrivener's
binder defaults to ~28 %).

### 5.2 Page width

```
maxWidth: 750 px
```

750 px is roughly 65‥70 characters at 16‥18 px font — the
typographic ideal for long-form reading (Bringhurst, *The Elements
of Typographic Style*).  On a 1920 px screen with a 300 px binder
the editor gets ~1620 px; the page uses 750 of those, leaving ~435 px
of breathing room on each side.

### 5.3 Spacing scale

| Context | Value | Notes |
|---|---|---|
| Row vertical padding (tiles) | 4 px | 2 × 4 = 8 px total between rows. Compact but not cramped. |
| Row horizontal padding (tiles) | 3 px | Prevents icon/text touching the binder edge. |
| Breadcrumb / toolbar padding | horizontal 16, 8 px | 16 px matches the row indentation; 8 vertical is a multiple of 4. |
| Page margins (editor) | horizontal 56 px, vertical 40 px | See rationale in section 3.3. |
| Icon-text gap (tiles) | 6 px | Between folder/document icon and name. |
| Chevron-folder gap | 4 px | Tight — chevron is punctuation, not a standalone icon. |
| Section dividers | 1 px, colour `#D6D6D6` | Minimal separation; the colour contrast does the work. |

---

## 6. Typography scale

| Element | Size | Weight | Colour |
|---|---|---|---|
| Project title (header) | 14 px | 700 | `default` (adapts to theme) |
| Subtitle (header) | 11 px | 400 | `grey.shade600` |
| Breadcrumb (last) | 13 px | 600 | `Color(0xDD000000)` (black87) |
| Breadcrumb (ancestor) | 13 px | 400 | `grey.shade600` |
| Directory / file name (binder) | 13 px | 400 | `default` (or muted when dragged) |
| Child-count badge | 11 px | 400 | `grey.shade500` |
| Placeholder message | 20 px | 500 | `grey.shade600` |
| Drop-overlay card | 15 px | 600 | `default` |

All text sizes are multiples or near-multiples of a 4 px base unit
(11, 12, 13, 14, 15, 20), which keeps vertical rhythm predictable when
elements are stacked.

---

## 7. Motion tokens

| Element | Duration | Curve | Trigger |
|---|---|---|---|
| Directory chevron | 150 ms | `easeOut` | Expand / collapse |
| Trash background | 150 ms | `linear` (default `AnimatedContainer`) | Drag enters / leaves trash zone |

Only two animations.  Both are 150 ms — short enough to feel
instantaneous (the human brain perceives < 200 ms as "now"), long
enough to be visible.  Every other state change (selection highlight,
hover, drag-dim) is instantaneous via `setState` / `ValueListenableBuilder`
— no animation needed because the user is in a continuous drag gesture
and animation would lag behind the pointer.

---

## 8. Content design (example documents)

### 8.1 File organisation

```
example_delta_content.dart             ← README (package docs, uses every
                                          Flutter Quill attribute type)
constants/contents/
├── chapter_one_awakening_content.dart  ← Manuscript > Chapter 1 > Awakening
├── chapter_one_dark_woods_content.dart ← Manuscript > Chapter 1 > Dark Woods
├── chapter_two_tavern_content.dart     ← Manuscript > Chapter 2 > The Tavern
├── character_elara_content.dart        ← Characters > Elara
└── place_hollow_forest_content.dart    ← Places > The Hollow Forest
```

Every file exports a single `Delta` variable.  The file name and the
variable name mirror the document's path in the binder:

| Path | File | Variable |
|---|---|---|
| `Research > README` | `example_delta_content.dart` | `exampleDelta` |
| `Manuscript > Chapter 1 > Awakening` | `contents/chapter_one_awakening_content.dart` | `awakeningDelta` |
| `Characters > Elara` | `contents/character_elara_content.dart` | `characterElaraDelta` |

`default_files_nodes.dart` imports each variable and calls
`jsonEncode(delta.toJson())` via a single `_content()` helper.

### 8.2 Deliberate typographic variety

Each document exercises a *different* subset of Quill attributes so
the editor demo showcases the full toolbar:

| Document | Attributes used |
|---|---|
| README (`exampleDelta`) | `header` (H1/H2), `code`, `bold`, `italic`, `list: bullet`, `code-block`, `link`, `blockquote` |
| Awakening | `header` (H2), `bold`, `italic`, `blockquote` |
| Dark Woods | `header` (H2), `bold`, `italic` |
| The Tavern | `header` (H2), `bold`, `blockquote` |
| Elara (character sheet) | `header` (H2/H3), `bold`, `list: bullet` |
| Hollow Forest (setting sheet) | `header` (H2/H3), `list: ordered`, `list: bullet` |

### 8.3 Narrative cohesion

The three chapter fragments tell a connected micro-story
(Elara → the Hollow Forest → the twelve stones → the tavern).
This is intentional:

- A **connected narrative** is more engaging for a reviewer than
  lorem-ipsum placeholders.
- It demonstrates that the tree-editor architecture *works* for
  cross-referencing — the user can jump between "Dark Woods" and "The
  Hollow Forest" (Places) to see how setting descriptions relate to
  scenes.

The character and setting sheets use a **template format** (Role /
Age / Home / Keepsake + bulleted open questions) because Scrivener
users frequently create structured metadata documents alongside
their manuscript.

---

## 9. Drag-and-drop integration summary

| Surface | Drag from | Drop on | Result |
|---|---|---|---|
| Binder → binder | Any node | Directory / file | `Node.canMoveTo()` + standard D&D handled by `novident_tree_view` |
| Binder → trash | Any root-level node | Trash icon | Remove from tree |
| Binder → editor | `File` only | Editor pane | Select file (open in editor) |
| Binder → editor | `Directory` | Editor pane | Rejected (`onWillAcceptWithDetails` returns false) |

---

## 10. In-tree drag & drop visual language

The tree communicates the *result* of a pending drop before the user
releases the pointer, using a border + tinted fill drawn as a
**foreground** decoration (so it's painted over the row content, never
hidden behind it):

```dart
return DecoratedBox(
  decoration: decoration ?? BoxDecoration(),
  position: DecorationPosition.foreground,   // ← paints on top
  child: AutomaticNodeIndentation(...),
);
```

### 10.1 Drop-position grammar

`NovDragAndDropDetails.mapDropPosition` divides every row into three
vertical zones:

```
┌───────────────────────────────┐
│          Above Zone           │ → Border(top: …)      "insert before"
├───────────────────────────────┤
│                               │
│         Inside Zone           │ → Border.fromBorderSide "insert as child"
│                               │
├───────────────────────────────┤
│          Below Zone           │ → Border(bottom: …)   "insert after"
└───────────────────────────────┘
```

| Zone | Border | Fill | Meaning |
|---|---|---|---|
| Above (valid) | `top: blueAccent 2px` | `blueAccent.withAlpha(50)` | Will insert as previous sibling |
| Inside (valid) | all sides `blueAccent 2px` | `blueAccent.withAlpha(50)` | Will insert as child |
| Below (valid) | `bottom: blueAccent 2px` | `blueAccent.withAlpha(50)` | Will insert as next sibling |
| Any (invalid) | same side, `redAccent 2px` | `redAccent.withAlpha(50)` | Drop is rejected here |

All four states share `borderRadius: 5` so the highlight hugs the row
shape.

| Decision | Why |
|---|---|
| Border *edge* encodes position | The user reads "line on top = goes above; full box = goes inside" without any text. Identical grammar to Finder, VS Code, and Scrivener. |
| Blue = valid, red = invalid | Universal traffic-light convention; `withAlpha(50)` fills keep text readable under the tint. |
| 2 px border width | 1 px disappears on high-DPI screens; 3 px looks like a selection. 2 px reads as "indicator". |

### 10.2 No-op detection (red even when technically valid)

Dropping a node *immediately above its next sibling* or *below its
previous sibling* would be a move with no effect. The builders detect
this and flag it as an error:

```dart
final int targetIndex  = details.targetNode.index;
final int draggedIndex = details.draggedNode.index;
if (details.draggedNode.owner?.id == details.targetNode.owner?.id &&
    details.draggedNode.level == details.targetNode.level &&
    draggedIndex + 1 == targetIndex) {      // dragging onto "own shadow"
  error = true;
  return Border(top: errorBorderSide);
}
```

Signalling "this drop changes nothing" as red is kinder than allowing
a drop that silently does nothing — the user gets feedback *before*
releasing.

### 10.3 Being-dragged row state

The node that is being dragged keeps rendering in the tree (only the
feedback card follows the pointer). It's dimmed two ways at once:

```dart
// 1. Foreground fill over the whole row (component builder)
if (decoration == null && isDragging) {
  decoration = BoxDecoration(
    color: Colors.grey.withAlpha(30),
    borderRadius: BorderRadiusDirectional.circular(5),
  );
}

// 2. Muted icon + text inside the tile (see section 2.6)
FileTile(..., beingDragged: isDragging)
```

`isDragging` comes from `NodeComponentBuilder.isDragging` — persistent
for the entire drag lifecycle, unlike `context.details` which is only
non-null while hovering a target.

### 10.4 Selection highlight

```dart
NodeConfiguration(
  makeTappable: true,
  decoration: BoxDecoration(
    color: controller.selectedNode?.id == node.id
        ? Theme.of(context.nodeContext).primaryColor.withAlpha(50)
        : null,
  ),
  onTap: (BuildContext context) {
    if (node is Root) return;
    controller.selectNode(node);
  },
)
```

| Decision | Why |
|---|---|
| `primaryColor.withAlpha(50)` | Theme-aware tint (~20 %): visible but does not fight the drag-over blue. Selection = "state", drag highlight = "action"; the action colour is stronger. |
| Full-row highlight | Scrivener highlights the entire binder row, not just the label. The tree wraps the row in a decorated `Container` above the `InkWell`. |
| Compare by `id` | Node instances are cloned on update; identity comparison would drop the highlight after edits. |

### 10.5 Indentation

```dart
indentConfiguration: IndentConfiguration.systemFile(
  directoryLeading: false,
  indentation: 14,
),
```

14 px per level (slightly under the 16 px icon column) keeps deep
hierarchies usable inside the narrow binder: 5 levels cost only 70 px
of the 240‥320 px column.

---

## 11. Drag feedback card (`NodeDragCard`)

The widget that follows the pointer during a drag
(`tree_configurations.dart`):

```dart
Material(
  type: MaterialType.canvas,
  borderRadius: BorderRadius.circular(10),
  clipBehavior: Clip.hardEdge,
  child: Container(
    constraints: BoxConstraints(minWidth: 80, minHeight: 20),
    child: Padding(
      padding: EdgeInsets.all(5),
      child: Row(mainAxisSize: min, children: [
        Icon(/* doc_text(_fill) or folder_open/folder_fill */),
        Text(node.name),
        ValueListenableBuilder<NodeDragAndDropDetails?>(  // error badge
          valueListenable: DragAndDropDetailsListener.of(treeContext).details,
          builder: (ctx, value, child) {
            if (value == null || value.targetNode == null) {
              return SizedBox.shrink();
            }
            final bool canMove = Node.canMoveTo(
              node: value.draggedNode,
              target: value.targetNode!,
              inside: value.inside,
            );
            return canMove ? SizedBox.shrink() : child!;  // red ⊘ badge
          },
          child: /* red circle + white Icons.error, 15 px */,
        ),
      ]),
    ),
  ),
)
```

| Decision | Why |
|---|---|
| Card mirrors the tile (same icon rules + name) | The user must recognise "this is the exact node I grabbed". |
| `minWidth: 80` | Very short names still produce a grabbable-looking card instead of a sliver. |
| Live error badge | The card itself tells you the current hover target rejects the drop — feedback at the pointer, where the eyes are, not only at the row. Powered by `DragAndDropDetailsListener` (an `InheritedWidget` + `ValueNotifier`), so the badge updates without rebuilding the whole card. |
| Badge = red circle + white `Icons.error` at 15 px | Reads as the standard ⊘ "not allowed" cursor decoration. |

---

## 12. Global theme

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
  useMaterial3: true,
),
```

| Decision | Why |
|---|---|
| `blueGrey` seed | A writing tool should be chrome-less: the interface recedes, the manuscript is the only saturated area. `blueGrey` produces desaturated primaries that harmonise with `#F0EFEE` / `#ECECEC` / `#D6D6D6`. The previous `deepPurple` seed fought the neutral workspace. |
| Theme-derived accents | Selection tint, breadcrumb, overlay border and header icon all read `colorScheme.primary`, so changing the single seed restyles the whole workspace consistently. |

---

## 13. Test verification

The smoke test (`example/test/widget_test.dart`) validates:

- Workspace boots on a desktop viewport
- All four root folders are visible in the binder
- The README (`Research > README`, the initial selection at
  `root.atPath([1, 0])`) appears in both the binder tree **and**
  the breadcrumb — confirming the selection mechanism and breadcrumb
  builder are wired correctly
