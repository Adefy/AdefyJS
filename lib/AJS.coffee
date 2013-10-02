##
## Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved
##

# Top-level file, used by concat_in_order
#
# As part of the build process, grunt concats all of our coffee sources in a
# dependency-aware manner. Deps are described at the top of each file, with this
# essentially serving as the root node in the dep tree.
#
# @depend util/AJSUtilParam.coffee
# @depend actors/AJSRectangle.coffee
# @depend actors/AJSTriangle.coffee
# @depend actors/AJSPolygon.coffee

# AJS main class, instantiates the engine and provides access to common methods
# Should never be instantiated, all methods are static.
class AJS

  # Pointer to the engine, initalized (once) in init()
  # @private
  @_engine: null

  # Self-explanatory
  # @private
  @_initialized: false

  # Muahahahahaha. You've been warned.
  constructor: -> throw new Error "AJS shouldn't be instantiated!"

  # Initializes the engine with a specific screen size and ad length
  # The actual ad needs to be passed in as a method
  #
  # @param [Method] ad ad to execute
  # @param [Number] width
  # @param [Number] height
  @init: (ad, width, height) ->
    param.required ad
    param.required width
    param.required height

    # Should never happen, so don't fail quietly
    if AJS._initialized
      throw new Error "AJS can only be initialized once"
      return
    else AJS._initialized = true

    @_engine = window.AdefyGLI.Engine()

    # Initialize!
    @_engine.initialize ((agl) -> ad agl), width, height, 1, ""

  # Set renderer clear color, component values between 0 and 255
  #
  # @param [Number] r
  # @param [Number] g
  # @param [Number] b
  @setClearColor: (r, g, b) ->
    param.required r
    param.required g
    param.required b

    window.AdefyGLI.Engine().setClearColor r, g, b

  # Returns the renderer clear color as an AJSColor3
  #
  # @return [AJSColor3] clearcol
  @getClearColor: ->

    col = window.AdefyGLI.Engine().getClearColor()
    new AJSColor3 col.r, col.g, col.b