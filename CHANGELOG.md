## 1.1.0

* Feat(breaking changes): `NodeDraggableBuilder` and `NodeTargetBuilder` replaced by a single `NodeDragAndDropBuilder` widget. The unified widget removes a frame delay that existed between `DraggableListener` updates and `DragTarget` reactions when the two widgets were nested, eliminates duplicate `NodeDragGestures` construction, and makes drag-start events immediately visible to the `DragTarget` on the same node.
* Feat(breaking changes): `TreeConfiguration` renamed `components` → `builders`, `draggableConfigurations` → `dragConfig`, and `extraArgs` → `sharedData`. Removed internal-use properties `onHoverContainer`, `onHoverContainerExpansionDelay`, and `listViewConfigurations` (use `listView` instead). Added `indent` shorthand, `topZoneHeight`, and `bottomZoneHeight`.
* Feat(breaking changes): `NodeConfiguration.onHover` renamed to `onHoverInkWell`.
* Feat(breaking changes): `DragHandlerPosition` enum replaced by `DropPosition` (exported from `novident_nodes`). All APIs that referenced `DragHandlerPosition` (`isDropPositionValid`, `exactPosition`, `mapDropPosition`) now operate on `DropPosition`.
* Feat(breaking changes): `DraggableConfigurations.allowAutoExpandOnHover` renamed to `expandOnHover`. Added factory `DraggableConfigurations.simple()` for quick setups. `childDragAnchorStrategy` changed from Flutter's `DragAnchorStrategy` to `EffectiveDragAnchorStrategy` for correct cursor-relative feedback placement.
* Feat(breaking changes): `NodeComponentBuilder.validate()` now receives `int depth` as a second parameter; builders must implement `bool validate(Node node, int depth)`.
* Feat(breaking changes): `IndentConfiguration.basic()` constructor renamed parameters: `indentPerLevel` → `indent`, `sizeOfLeading` removed. Added `directoryLeading`, `addExtraPaddingFromLevel`, and `systemFile()` factory preset.
* Feat(NIP-01): `NodeComponentBuilder` now receives `ComponentContext` in `dispose`, `didUpdateWidget`, and `didChangeDependencies` lifecycle methods.
* Feat: `isDragging` flag added to `NodeComponentBuilder` and `ComponentContext`. Unlike `context.details` (which is only non-null while hovering over a drop target), `isDragging` remains `true` for the entire drag lifecycle — enabling persistent visual feedback on the row being dragged.
* Feat: `marksNeedBuild` callback added to `ComponentContext` so builders can request a tree rebuild from inside gesture handlers.
* Fix: tree state corruption after a sequence of mutations (insert, delete, move, reorder) no longer leaves stale node references that required a full restart to recover. The root cause was `NodeContainer.update()` returning a cloned node whose `NodeDetails` compared equal to the original via `==`, causing `didUpdateWidget` guards to skip necessary rebuilds. The fix switches selection-change detection from value equality (`==`) to `identical()` comparison on node details.
* Fix: `DraggableListener` could be `null` during early tree lifecycle stages (before the first layout pass). The listener is now lazily resolved and re-checked on each drag-start event.
* Fix: `DragTarget` on the node being dragged itself ("hover over self") now correctly receives `onWillAcceptWithDetails` on the first frame after drag-start, eliminating a one-frame visual glitch where drag feedback was invisible until the pointer moved.
* Fix: `NovDragAndDropDetails` were not being propagated to `DragAndDropDetailsListener` on every drag-move event, causing the live error badge on `NodeDragCard` to miss updates during rapid pointer movement.
* Fix: `standardDragAndDrop` factory incorrectly accepted drops in the "above" zone when `isDropIntoAllowed` returned `false` and in the "below" zone when `isDropPositionValid` returned `false`.
* Fix: hover-expansion timer leak — `_timer` was not cancelled on fast subsequent `_onMove` calls, causing multiple pending timers to fire and expand a collapsed node repeatedly.
* Fix: `LongPressDraggable` drag-completion lifecycle was not calling `_onDragCompleted`, leaving `DragListener` state (`draggedNode`, `globalPosition`) uncleaned after a successful drop.
* Fix: folder icon logic corrected — `folder_open` is now shown whenever a directory is expanded, regardless of whether it has children (previously only shown when expanded AND empty).
* Fix(example): `NodeContainer.update()` side-effect no longer mutates `_lastNode.details.owner` — details are cloned before the update.
* Fix(example): child nodes can be re-inserted into their original parent again after being moved out.
* Chore: deprecated `onHoverContainer` and `onHoverContainerExpansionDelay` in `TreeConfiguration`. Their behaviour is now handled by `NodeComponentBuilder.onTryExpand()` and `onHoverCallDelay`.
* Chore: removed unused `wrapWithDragAndDropWidgets` utility and `default_nodes_wrapper.dart`.
* Chore: removed `dart:io` dependency and `Platform.isAndroid`/`Platform.isIOS` checks from library code (now handled by `DraggableConfigurations.preferLongPressDraggable` at configuration time).
* Docs: complete rewrite of all files under `doc/` and `README.md` — every class signature, parameter table, constructor, and code example now reflects the 1.1.0 API.
* Example: redesigned the desktop workspace as a Scrivener-like binder + editor pane. Binder re‑styled with animated disclosure chevrons, child‑count badges, compact 28 px row height, and a warm `#F0EFEE` surface. Editor replaced the fragile `Stack` layout with a stable `Column` containing breadcrumb, single‑row format bar, and a sheet‑of‑paper metaphor (white page centered over `#ECECEC` background with a two‑layer shadow). Drag‑over‑editor overlay shows a veil + accent‑bordered "Open `<file>`" card. Expanda example content from 3 placeholder documents to 6 narrative documents with varied Quill attribute usage (headers, bold, italic, blockquote, lists, links, code blocks).
* Test: example smoke test replaced the broken template counter test with a real workspace boot test that verifies the binder, breadcrumb, README selection, and all root folders.

## 1.0.8 -> 1.0.9

* Chore: update dependencies.

## 1.0.7

* Fix: If we change something into the `validate` method of `NodeComponentBuilder` class the `componentBuilders` are not reloaded.
* Fix: Inconsistencies with `ListenableBuilder` implementation in `ContainerBuilder` widget.
* Feat(breaking changes): added property `depth` to validate method in `NodeComponentBuilder` class.
* Feat: added methods for state management like `didUpdateWidget`, `didChangeDependencies`, `initState` and `dispose` methods for `NodeComponentBuilder` class.
* Chore: deprecated `onHoverContainerExpansionDelay` and `onHoverContainer`, and them were replaced by `onHoverCallDelay` and `onTryExpand` into the `NodeComponentBuilder` class.
* Chore: deprecated `onHover` method in NodeConfiguration class and was replaced by `onHoverInkWell` that makes more sense with its function.
* Fix: `DraggableListener` is not being updated correctly in certain situations.
* Fix: missing `NovDragAndDropDetails` updates at some dragging events.
* Chore(breaking changes): changed type `DragAnchorStrategy` to `EffectiveDragAnchorStrategy`.
* Chore(example): added trash icon for remove nodes manually dragging them over it.

## 1.0.6

* Fix: changelog typos.

## 1.0.5 

* Feat: added `buildChildrenAsync` and related helper methods to create async rendering for Nodes (like github does).
* Feat: added `index` property to `ComponentContext`.
* Fix(example): children can be re-inserted into its parent again.

## 1.0.2

* Fix: bad example code in `NodeDragGestures` class.
* Fix: outdated documentation.
* Fix: added `TreeView` basic example in README.
* Fix: `addRepaintBoundaries` isn't doing anything.

## 1.0.1

* Fix: missed imports and constant for widgets constructors.

## 1.0.0

* First commit
