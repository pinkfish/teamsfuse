// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection' show SplayTreeMap, HashMap;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// An element that lazily builds children for a [SliverMultiBoxAdaptorWidget].
///
/// Implements [RenderSliverBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverMultiBoxAdaptor].
class CenterSliverMultiBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  CenterSliverMultiBoxAdaptorElement(_SliverListCenter widget) : super(widget);

  @override
  _SliverListCenter get widget {
    var bing = super.widget as _SliverListCenter;
    return bing;
  }

  @override
  RenderSliverMultiBoxAdaptor get renderObject {
    var frog = super.renderObject as RenderSliverMultiBoxAdaptor;
    return frog;
  }

  @override
  void update(covariant _SliverListCenter newWidget) {
    var oldWidget = widget;
    super.update(newWidget);
    var newDelegate = newWidget.delegate;
    var oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      performRebuild();
    }
  }

  // We inflate widgets at two different times:
  //  1. When we ourselves are told to rebuild (see performRebuild).
  //  2. When our render object needs a child (see createChild).
  // In both cases, we cache the results of calling into our delegate to get the widget,
  // so that if we do case 2 later, we don't call the builder again.
  // Any time we do case 1, though, we reset the cache.

  final Map<int, Widget> _childWidgetsMe = HashMap<int, Widget>();
  final SplayTreeMap<int, Element> _childElementsMe =
      SplayTreeMap<int, Element>();
  RenderBox _currentBeforeChildMe;

  @override
  void performRebuild() {
    _childWidgetsMe.clear(); // Reset the cache, as described above.
    super.performRebuild();
    _currentBeforeChildMe = null;
    assert(_currentlyUpdatingChildIndex == null);
    try {
      var firstIndex = _childElementsMe.firstKey();
      var lastIndex = _childElementsMe.lastKey();
      if (_childElementsMe.isEmpty) {
        firstIndex = 2;
        lastIndex = 2;
      } else if (_didUnderflow) {
        lastIndex += 1;
      }
      for (var index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        var newChild =
            updateChild(_childElementsMe[index], _build(index), index);
        if (newChild != null) {
          _childElementsMe[index] = newChild;
          var box = newChild.renderObject as RenderBox;
          _currentBeforeChildMe = box;
        } else {
          _childElementsMe.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  Widget _build(int index) {
    return _childWidgetsMe.putIfAbsent(
        index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index, {@required RenderBox after}) {
    assert(_currentlyUpdatingChildIndex == null);
    owner.buildScope(this, () {
      var insertFirst = after == null;
      assert(insertFirst || _childElementsMe[index - 1] != null);
      var box = insertFirst
          ? null
          : _childElementsMe[index - 1].renderObject as RenderBox;
      _currentBeforeChildMe = box;
      Element newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(_childElementsMe[index], _build(index), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElementsMe[index] = newChild;
      } else {
        _childElementsMe.remove(index);
      }
    });
  }

  @override
  void forgetChild(Element child) {
    assert(child != null);
    assert(child.slot != null);
    assert(_childElementsMe.containsKey(child.slot));
    _childElementsMe.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    var index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner.buildScope(this, () {
      assert(_childElementsMe.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        var result = updateChild(_childElementsMe[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElementsMe.remove(index);
      assert(!_childElementsMe.containsKey(index));
    });
  }

  double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    var childCount = this.childCount;
    if (childCount == null) {
      return double.infinity;
    }
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }
    var reifiedCount = lastIndex - firstIndex + 1;
    var averageExtent =
        (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    var remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        );
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount;

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    var firstIndex = _childElementsMe.firstKey() ?? 0;
    var lastIndex = _childElementsMe.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    var childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertChildRenderObject(covariant RenderObject child, int slot) {
    assert(slot != null);
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    var box = child as RenderBox;
    renderObject.insert(box, after: _currentBeforeChildMe);
    assert(() {
      var childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveChildRenderObject(covariant RenderObject child, int slot) {
    // TODO(ianh): At some point we should be better about noticing when a
    // particular LocalKey changes slot, and handle moving the nodes around.
    assert(false);
  }

  @override
  void removeChildRenderObject(covariant RenderObject child) {
    assert(_currentlyUpdatingChildIndex != null);
    var box = child as RenderBox;
    renderObject.remove(box);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElementsMe.values.any((child) => child == null));
    _childElementsMe.values.toList().forEach(visitor);
  }
}

/// A sliver that places multiple box children in a linear array along the main
/// axis.
///
/// Each child is forced to have the [SliverConstraints.crossAxisExtent] in the
/// cross axis but determines its own main axis extent.
///
/// [RenderSliverList] determines its scroll offset by "dead reckoning" because
/// children outside the visible part of the sliver are not materialized, which
/// means [RenderSliverList] cannot learn their main axis extent. Instead, newly
/// materialized children are placed adjacent to existing children. If this dead
/// reckoning results in a logical inconsistency (e.g., attempting to place the
/// zeroth child at a scroll offset other than zero), the [RenderSliverList]
/// generates a [SliverGeometry.scrollOffsetCorrection] to restore consistency.
///
/// If the children have a fixed extent in the main axis, consider using
/// [RenderSliverFixedExtentList] rather than [RenderSliverList] because
/// [RenderSliverFixedExtentList] does not need to perform layout on its
/// children to obtain their extent in the main axis and is therefore more
/// efficient.
///
/// See also:
///
///  * [RenderSliverFixedExtentList], which is more efficient for children with
///    the same extent in the main axis.
///  * [RenderSliverGrid], which places its children in arbitrary positions.
class RenderSliverCenterList extends RenderSliverMultiBoxAdaptor {
  /// Creates a sliver that places multiple box children in a linear array along
  /// the main axis.
  ///
  /// The [childManager] argument must not be null.
  RenderSliverCenterList(
      {@required RenderSliverBoxChildManager childManager, this.startIndex = 0})
      : super(childManager: childManager);

  /// The start index to use for the list.
  final num startIndex;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    var scrollOffset = constraints.scrollOffset;
    assert(scrollOffset >= 0.0);
    var remainingPaintExtent = constraints.remainingPaintExtent;
    assert(remainingPaintExtent >= 0.0);
    var targetEndScrollOffset = scrollOffset + remainingPaintExtent;
    var childConstraints = constraints.asBoxConstraints();
    var leadingGarbage = 0;
    var trailingGarbage = 0;
    var reachedEnd = false;

    // This algorithm in principle is straight-forward: find the first child
    // that overlaps the given scrollOffset, creating more children at the top
    // of the list if necessary, then walk down the list updating and laying out
    // each child and adding more at the end if necessary until we have enough
    // children to cover the entire viewport.
    //
    // It is complicated by one minor issue, which is that any time you update
    // or create a child, it's possible that the some of the children that
    // haven't yet been laid out will be removed, leaving the list in an
    // inconsistent state, and requiring that missing nodes be recreated.
    //
    // To keep this mess tractable, this algorithm starts from what is currently
    // the first child, if any, and then walks up and/or down from there, so
    // that the nodes that might get removed are always at the edges of what has
    // already been laid out.

    //print('offset $scrollOffset');

    // Make sure we have at least one child to start from.
    if (firstChild == null) {
      //print('Making first child');
      if (!addInitialChild(index: 2, layoutOffset: scrollOffset)) {
        // There are no children.
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    // We have at least one child.

    // These variables track the range of children that we have laid out. Within
    // this range, the children have consecutive indices. Outside this range,
    // it's possible for a child to get removed without notice.
    RenderBox leadingChildWithLayout, trailingChildWithLayout;

    // Find the last child that is at or before the scrollOffset.
    var earliestUsefulChild = firstChild;
    for (var earliestScrollOffset = childScrollOffset(earliestUsefulChild);
        earliestScrollOffset > scrollOffset;
        earliestScrollOffset = childScrollOffset(earliestUsefulChild)) {
      // We have to add children before the earliestUsefulChild.
      earliestUsefulChild =
          insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

      if (earliestUsefulChild == null) {
        var childParentData =
            firstChild.parentData as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        //print("earlierusefulchild ${childParentData.layoutOffset}");

        if (scrollOffset == 0.0) {
          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;
          break;
        } else {
          // We ran out of children before reaching the scroll offset.
          // We must inform our parent that this sliver cannot fulfill
          // its contract and that we need a scroll offset correction.
          geometry = SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          //print("Geometry correct ${childParentData.layoutOffset}");
          return;
        }
      }

      var firstChildScrollOffset =
          earliestScrollOffset - paintExtentOf(firstChild);
      if (firstChildScrollOffset < 0.0) {
        // The first child doesn't fit within the viewport (underflow) and
        // there may be additional children above it. Find the real first child
        // and then correct the scroll position so that there's room for all and
        // so that the trailing edge of the original firstChild appears where it
        // was before the scroll offset correction.
        // TODO(hansmuller): do this work incrementally, instead of all at once,
        // i.e. find a way to avoid visiting ALL of the children whose offset
        // is < 0 before returning for the scroll correction.
        var correction = 0.0;
        while (earliestUsefulChild != null) {
          assert(firstChild == earliestUsefulChild);
          correction += paintExtentOf(firstChild);
          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
              parentUsesSize: true);
        }
        geometry = SliverGeometry(
          scrollOffsetCorrection: correction - earliestScrollOffset,
        );
        var childParentData =
            firstChild.parentData as SliverMultiBoxAdaptorParentData;
        childParentData.layoutOffset = 0.0;
        //print("correctring here ${childParentData.layoutOffset} == 0.0");

        return;
      }

      var childParentData =
          earliestUsefulChild.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = firstChildScrollOffset;
      //print("layout offset update ${childParentData.layoutOffset} == 0.0");

      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

    // At this point, earliestUsefulChild is the first child, and is a child
    // whose scrollOffset is at or before the scrollOffset, and
    // leadingChildWithLayout and trailingChildWithLayout are either null or
    // cover a range of render boxes that we have laid out with the first being
    // the same as earliestUsefulChild and the last being either at or after the
    // scroll offset.

    assert(earliestUsefulChild == firstChild);
    assert(childScrollOffset(earliestUsefulChild) <= scrollOffset);

    // Make sure we've laid out at least one child.
    if (leadingChildWithLayout == null) {
      earliestUsefulChild.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    // Here, earliestUsefulChild is still the first child, it's got a
    // scrollOffset that is at or before our actual scrollOffset, and it has
    // been laid out, and is in fact our leadingChildWithLayout. It's possible
    // that some children beyond that one have also been laid out.

    var inLayoutRange = true;
    var child = earliestUsefulChild;
    var index = indexOf(child);
    var endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
    bool advance() {
      // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child);
      if (child == null) {
        inLayoutRange = false;
      }
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.
          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            //print('No children $geometry');
            return false;
          }
        } else {
          // Lay out the child.
          child.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      var childParentData = child.parentData as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = endScrollOffset;
      assert(childParentData.index == index);
      endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
      //print('froggy frogg ${childParentData.layoutOffset}');
      return true;
    }

    // Find the first child that ends after the scroll offset.
    while (endScrollOffset < scrollOffset) {
      leadingGarbage += 1;
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        var extent = childScrollOffset(lastChild) + paintExtentOf(lastChild);
        geometry = SliverGeometry(
          scrollExtent: extent,
          paintExtent: 0.0,
          maxPaintExtent: extent,
        );
        //print("Stuff here");
        return;
      }
    }

    // Now find the first child that ends after our end.
    while (endScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      child = childAfter(child);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child);
      }
    }

    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.

    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild),
        lastIndex: indexOf(lastChild),
        leadingScrollOffset: childScrollOffset(firstChild),
        trailingScrollOffset: endScrollOffset,
      );
      assert(estimatedMaxScrollOffset >=
          endScrollOffset - childScrollOffset(firstChild));
    }
    var paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: endScrollOffset > targetEndScrollOffset ||
          constraints.scrollOffset > 0.0,
    );
    //print('fluffy rabbits $geometry');

    // We may have started the layout while scrolled to the end, which would not
    // expose a child.
    if (estimatedMaxScrollOffset == endScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    //print('render $child ${super.childCrossAxisPosition(child)}');
    return super.childCrossAxisPosition(child);
  }
}

class _SliverListCenter extends RenderObjectWidget {
  /// Creates a sliver that places box children in a linear array.
  const _SliverListCenter(
      {@required this.delegate, Key key, this.startIndex = 0})
      : super(key: key);

  /// The start index to use in the list.
  final num startIndex;

  @override
  CenterSliverMultiBoxAdaptorElement createElement() =>
      CenterSliverMultiBoxAdaptorElement(this);

  @override
  RenderSliverCenterList createRenderObject(BuildContext context) {
    var element = context as CenterSliverMultiBoxAdaptorElement;
    return RenderSliverCenterList(
        childManager: element, startIndex: startIndex);
  }

  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this widget to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverChildBuilderDelegate] and [SliverChildListDelegate], which are
  ///    commonly used subclasses of [SliverChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  final SliverChildDelegate delegate;

  /// Returns an estimate of the max scroll extent for all the children.
  ///
  /// Subclasses should override this function if they have additional
  /// information about their max scroll extent.
  ///
  /// This is used by [SliverMultiBoxAdaptorElement] to implement part of the
  /// [RenderSliverBoxChildManager] API.
  ///
  /// The default implementation defers to [delegate] via its
  /// [SliverChildDelegate.estimateMaxScrollOffset] method.
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<SliverChildDelegate>('delegate', delegate));
  }
}
