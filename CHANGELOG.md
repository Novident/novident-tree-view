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
