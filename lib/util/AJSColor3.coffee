# Color class, holds r/g/b components
#
# Serves to provide a consistent structure for defining colors, and offers
# useful float to int (0.0-1.0 to 0-255) conversion functions
class AJSColor3

  ###
  # Sets component values
  #
  # @param [Number] r red component
  # @param [Number] g green component
  # @param [Number] b blue component
  ###
  constructor: (r, g, b) ->

    # @todo Check to see if this is necessary
    @_r = r || 0
    @_g = g || 0
    @_b = b || 0

  ###
  # Returns the red component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] red
  ###
  getR: (asFloat) ->
    return @_r unless asFloat

    if @_r == 0
      if asFloat
        return 0.0
      else
        return 0

    @_r / 255

  # Returns the green component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] green
  getG: (asFloat) ->
    return @_g unless asFloat

    if @_g == 0
      if asFloat
        return 0.0
      else
        return 0

    @_g / 255

  # Returns the blue component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] blue
  getB: (asFloat) ->
    return @_b unless asFloat

    if @_b == 0
      if asFloat
        return 0.0
      else
        return 0

    @_b / 255

  # Set red component, takes a value between 0-255
  #
  # @param [Number] c
  setR: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_r = c

  # Set green component, takes a value between 0-255
  #
  # @param [Number] c
  setG: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_g = c

  # Set blue component, takes a value between 0-255
  #
  # @param [Number] c
  setB: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_b = c

  # Returns the value as a triple
  #
  # @return [String] triple in the form (r, g, b)
  toString: -> "(#{@_r}, #{@_g}, #{@_b})"
