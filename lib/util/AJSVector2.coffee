##
## Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved
##

# 2D Vector class
class AJSVector2

  # Vector constructor, components default to 0
  #
  # @param [Number] x x coordinate
  # @param [Number] y y coordinate
  constructor: (x, y) ->
    @x = x || 0
    @y = y || 0

  # Returns a new negated vector
  #
  # @return [AJSVector2] negated
  negative: -> new AJSVector2 -@x, -@y

  # Returns the sum of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] sum
  add: (v) ->
    if v instanceof AJSVector2
      return new AJSVector2 @x + v.x, @y + v.y
    else
      return new AJSVector2 @x + v, @y + v

  # Returns the difference between this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] difference
  subtract: (v) ->
    if v instanceof AJSVector2
      return new AJSVector2 @x - v.x, @y - v.y
    else
      return new AJSVector2 @x - v, @y - v

  # Returns the product of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] product
  multiply: (v) ->
    if v instanceof AJSVector2
      return new AJSVector2 @x * v.x, @y * v.y
    else
      return new AJSVector2 @x * v, @y * v

  # Returns the quotient of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] quotient
  divide: (v) ->
    if v instanceof AJSVector2
      return new AJSVector2 @x / v.x, @y / v.y
    else
      return new AJSVector2 @x / v, @y / v

  # Checks the equality of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Boolean] equality
  equals: (v) -> @x == v.x && @y == v.y

  # Returns the dot product of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Number] dotProduct
  dot: (v) -> (@x * v.x) + (@y * v.y)

  # Returns the cross product of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Number] crossProduct
  cross: (v) -> (@x * v.y) - (@y * v.x)

  # Returns a new vector orthogonal to this one
  #
  # @return [AJSVector2] unit
  ortho: -> new AJSVector2 @y, -@x

  # Returns the length of this vector
  #
  # @return [Number] length
  length: -> Math.sqrt @dot(this)

  # Returns a normalized version of this vector
  #
  # @return [AJSVector2] normalized
  normalize: -> @divide @length()

  # Returns the vector in string double format
  #
  # @return [String] str
  toString: -> "(#{@x}, #{@y})"
