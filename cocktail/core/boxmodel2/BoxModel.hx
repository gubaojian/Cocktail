package cocktail.core.boxmodel2;

import haxe.ds.Option;

class BoxModel {

  public static function measure(styles:Styles, containingBlock:ContainingBlock):UsedStyles {

    var paddings = getPaddings(styles.paddings, containingBlock);
    var borders = getBorders(styles.borders);
    var constraints = getConstraints(styles.constraints, containingBlock);
    var width = getWidth(styles, paddings, borders, constraints, containingBlock);
    var positions = getPositions(styles.positions, containingBlock);
    var height = constrainDimension(
        getDimension(styles.dimensions.height, containingBlock.height),
        constraints.maxHeight, constraints.minHeight
        );

    var dimensions = {
      width: width,
      height: height
    }

    var margins = getMargins(
        styles.display,
        styles.margins,
        paddings,
        borders,
        dimensions,
        styles.dimensions.width == Auto,
        styles.dimensions.height == Auto,
        containingBlock
        );

    return {
      paddings: paddings,
      borders: borders,
      outline: getOutline(styles.outline),
      dimensions: dimensions,
      margins: margins,
      constraints: constraints,
      positions: positions
    }
  }

  static function getPositions(positions:Positions, containingBlock:ContainingBlock):UsedPositions {
    return {
      left: getPosition(positions.left, containingBlock.width),
      right: getPosition(positions.right, containingBlock.width),
      top: getPosition(positions.top, containingBlock.height),
      bottom: getPosition(positions.bottom, containingBlock.height)
    }
  }

  static function getPosition(position:Position, containingDimension:Int) {
    return switch(position) {
      case AbsoluteLength(value): value;
      case Percent(percent): percent.compute(containingDimension);
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getComputedAutoWidth(
      paddings:UsedPaddings,
      borders:UsedBorders,
      marginLeft:Int,
      marginRight:Int,
      containingBlock:ContainingBlock):Int
    return containingBlock.width - paddings.left - paddings.right - borders.left - borders.right - marginLeft - marginRight;

  static function getAutoWidth(
      node:Styles,
      usedPaddings:UsedPaddings,
      usedBorders:UsedBorders,
      containingBlock:ContainingBlock
      ):Int {

    var margins = getMargins(
        node.display,
        node.margins,
        usedPaddings,
        usedBorders,
        {width: 0, height: 0},
        true,
        true,
        containingBlock
        );

    return getComputedAutoWidth(usedPaddings, usedBorders, margins.left, margins.right, containingBlock);
  }

  static function getWidth(
      styles:Styles,
      usedPaddings:UsedPaddings,
      usedBorders:UsedBorders,
      usedConstraints:UsedConstraints,
      containingBlock:ContainingBlock):Int
    return switch (styles.dimensions.width) {
      case Auto: getAutoWidth(styles, usedPaddings, usedBorders, containingBlock);
      case _: constrainDimension(getDimension(styles.dimensions.width, containingBlock.width), usedConstraints.maxWidth, usedConstraints.minWidth);
    }

  @:allow(core.boxmodel.BoxModelTest)
  static function constrainDimension(dimension:Int, max:Option<Int>, min:Option<Int>):Int {
    var maxedDimension = switch(max) {
      case Some(max): if (dimension > max) max else dimension;
      case None: dimension;
    }

    return switch(min) {
      case Some(min): if (dimension < min) min else maxedDimension;
      case None: maxedDimension;
    }
  }

  static function getDimension(dimension:Dimension, containerDimension:Int):Int {
    return switch (dimension) {
      case AbsoluteLength(value): value;
      case Percent(percent): percent.compute(containerDimension);
      case Auto: 0;
    }
  }

  static function getMargins(
      display:Display,
      margins:Margins,
      paddings:UsedPaddings,
      borders:UsedBorders,
      dimensions:UsedDimensions,
      widthIsAuto:Bool,
      heightIsAuto:Bool,
      containingBlock:ContainingBlock
      ):UsedMargins {
    return switch (display) {
      case Block: getBlockMargins(
                      margins,
                      paddings,
                      borders,
                      dimensions,
                      widthIsAuto,
                      heightIsAuto,
                      containingBlock
                      );

      case InlineBlock: getInlineBlockMargins(
                             margins,
                             widthIsAuto,
                             heightIsAuto,
                             containingBlock
                            );
    }
  }

  static function getInlineBlockMargins(
      margins:Margins,
      widthIsAuto:Bool,
      heightIsAuto:Bool,
      containingBlock:ContainingBlock
      ):UsedMargins {

    return {
      left: getInlineBlockMargin(
          margins.left,
          containingBlock.width,
          widthIsAuto
          ),

      right: getInlineBlockMargin(
          margins.right,
          containingBlock.width,
          widthIsAuto
          ),

      top: getInlineBlockMargin(
          margins.top,
          containingBlock.height,
          heightIsAuto
          ),

      bottom: getInlineBlockMargin(
          margins.bottom,
          containingBlock.height,
          heightIsAuto
          )
    }
  }

  static function getBlockMargins(
      margins:Margins,
      paddings:UsedPaddings,
      borders:UsedBorders,
      dimensions:UsedDimensions,
      widthIsAuto:Bool,
      heightIsAuto:Bool,
      containingBlock:ContainingBlock
      ):UsedMargins {

    var usedWidth = paddings.left + paddings.right + borders.left + borders.right;
    return {
      left: getBlockMargin(
          margins.left,
          margins.right,
          containingBlock.width,
          dimensions.width,
          widthIsAuto,
          usedWidth,
          true
          ),

      right: getBlockMargin(
          margins.right,
          margins.left,
          containingBlock.width,
          dimensions.width,
          widthIsAuto,
          usedWidth,
          true
          ),

      top: getBlockMargin(
          margins.top,
          margins.bottom,
          containingBlock.height,
          dimensions.height,
          heightIsAuto,
          usedWidth,
          false
          ),

      bottom: getBlockMargin(
          margins.bottom,
          margins.top,
          containingBlock.height,
          dimensions.height,
          heightIsAuto,
          usedWidth,
          false
          )
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getBlockMargin(
      margin:Margin,
      oppositeMargin:Margin,
      containerDimension:Int,
      dimension:Int,
      dimensionIsAuto:Bool,
      paddingsAndBordersDimension:Int,
      marginIsHorizontal:Bool):Int {
    return switch (margin) {

      case AbsoluteLength(value): value;

      case Percent(percent):
        if (dimensionIsAuto) 0;
        else percent.compute(containerDimension);

      case Auto:
        if(!marginIsHorizontal || dimensionIsAuto) 0;
        else getAutoHorizontalMargin(
              oppositeMargin,
              containerDimension,
              dimension,
              paddingsAndBordersDimension
              );
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getInlineBlockMargin(
      margin:Margin,
      containerDimension:Int,
      dimensionIsAuto:Bool) {
    return switch (margin) {

      case AbsoluteLength(value): value;

      case Percent(percent):
        if (dimensionIsAuto) 0;
        else percent.compute(containerDimension);

      case Auto: 0;
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getAutoHorizontalMargin(
      oppositeMargin:Margin,
      containerDimension:Int,
      dimension:Int,
      paddingsAndBordersDimension:Int
      ):Int
    return switch (oppositeMargin) {
      case Auto:
        Math.round((containerDimension - dimension - paddingsAndBordersDimension) / 2);

      case _:
        var oppositeMarginDimension = getBlockMargin(
            oppositeMargin,
            Auto,
            containerDimension,
            dimension,
            false,
            paddingsAndBordersDimension,
            false
            );
        containerDimension - dimension - paddingsAndBordersDimension - oppositeMarginDimension;
    }

  static function getOutline(outline:Outline):Int {
    return switch(outline) {
      case AbsoluteLength(value): value;
    }
  }

  static function getBorders(borders:Borders):UsedBorders {
    return {
      left : getBorder(borders.left),
      right: getBorder(borders.right),
      top: getBorder(borders.top),
      bottom: getBorder(borders.bottom)
    }
  }

  static function getBorder(border:Border):Int {
    return switch (border) {
      case AbsoluteLength(value): value;
    }
  }

  static function getPaddings(paddings:Paddings, containingBlock:ContainingBlock):UsedPaddings {
    return {
      left: getPadding(paddings.left, containingBlock.width),
      right: getPadding(paddings.right, containingBlock.width),
      top: getPadding(paddings.top, containingBlock.width),
      bottom: getPadding(paddings.bottom, containingBlock.width),
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getPadding(padding:Padding, containerWidth:Int):Int {
    return switch (padding) {
      case AbsoluteLength(value): value;
      case Percent(percent): percent.compute(containerWidth);
    }
  }

  static function getConstraints(constraints:Constraints, containingBlock:ContainingBlock):UsedConstraints {
    return {
      maxHeight: getConstraint(constraints.maxHeight, containingBlock.height, containingBlock.isHeightAuto),
      minHeight: getConstraint(constraints.minHeight, containingBlock.height, containingBlock.isHeightAuto),
      maxWidth: getConstraint(constraints.maxWidth, containingBlock.width, containingBlock.isWidthAuto),
      minWidth: getConstraint(constraints.minWidth, containingBlock.width, containingBlock.isWidthAuto)
    }
  }

  @:allow(core.boxmodel.BoxModelTest)
  static function getConstraint(constraint:Constraint, containerDimension:Int, containingDimensionIsAuto:Bool):Option<Int> {
    return switch (constraint) {
      case AbsoluteLength(value): Some(value);

      case Percent(percent):
        if (containingDimensionIsAuto) None;
        else Some(percent.compute(containerDimension));

      case Unconstrained: None;
    }
  }
}

abstract Percentage(Int) from Int {

  inline function new (i) this = i;

  public inline function compute(reference:Int)
    return Math.round(reference * (this * 0.01));

}

typedef Styles = {
  var display:Display;
  var paddings:Paddings;
  var borders:Borders;
  var margins:Margins;
  var dimensions:Dimensions;
  var outline:Outline;
  var constraints:Constraints;
  var positions:Positions;
}

enum Display {
   Block;
   InlineBlock;
}

typedef UsedStyles = {
  var paddings:UsedPaddings;
  var borders:UsedBorders;
  var margins:UsedMargins;
  var dimensions:UsedDimensions;
  var outline:Int;
  var constraints:UsedConstraints;
  var positions:UsedPositions;
}

typedef Constraints = {
  var minHeight:Constraint;
  var maxHeight:Constraint;
  var minWidth:Constraint;
  var maxWidth:Constraint;
}

typedef UsedConstraints = {
  var minHeight:Option<Int>;
  var maxHeight:Option<Int>;
  var minWidth:Option<Int>;
  var maxWidth:Option<Int>;
}

enum Constraint {
  AbsoluteLength(value:Int);
  Percent(value:Percentage);
  Unconstrained;
}

enum Border {
  AbsoluteLength(value:Int);
}

enum Outline {
  AbsoluteLength(value:Int);
}

enum Dimension {
  AbsoluteLength(value:Int);
  Percent(value:Percentage);
  Auto;
}

typedef Dimensions = {
  var width:Dimension;
  var height:Dimension;
}

typedef UsedDimensions = {
   var width:Int;
   var height:Int;
}

enum Margin {
  AbsoluteLength(value:Int);
  Percent(value:Percentage);
  Auto;
}

typedef Positions = {
  var left:Position;
  var right:Position;
  var top:Position;
  var bottom:Position;
}

enum Position {
  AbsoluteLength(value:Int);
  Percent(value:Percentage);
}

typedef UsedPositions = {
  var left:Int;
  var right:Int;
  var top:Int;
  var bottom:Int;
}

typedef Margins = {
  var left:Margin;
  var right:Margin;
  var top:Margin;
  var bottom:Margin;
}

typedef Borders = {
  var left:Border;
  var right:Border;
  var top:Border;
  var bottom:Border;
}

typedef UsedMargins = {
  var left:Int;
  var right:Int;
  var top:Int;
  var bottom:Int;
}

typedef UsedBorders = {
  var left:Int;
  var right:Int;
  var top:Int;
  var bottom:Int;
}

enum Padding {
  AbsoluteLength(value:Int);
  Percent(value:Percentage);
}

typedef Paddings = {
  var left:Padding;
  var right:Padding;
  var top:Padding;
  var bottom:Padding;
}

typedef UsedPaddings = {
  var left:Int;
  var right:Int;
  var top:Int;
  var bottom:Int;
}

typedef ContainingBlock = {
  var width:Int;
  var height:Int;
  var isHeightAuto:Bool;
  var isWidthAuto:Bool;
}

