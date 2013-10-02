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

  # AJS is a singleton, do not instantiate! Constructor throws an error.
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

  # Animates actor properties. Pass in either a single property, or an array
  # of property definitions. The same goes for the animation options.
  #
  # Composite properties (r of color rgb) must be animated individually, and
  # specified as an array of [property, composite].
  #
  # @example Animating the Y coordinate of an actor
  #   animate actor, ["position", "y"], { ... }
  #
  # @example Animating the rotation of an actor
  #   animate actor, "rotation", { ... }
  #
  # @example Animating multiple properties
  #   animate actor, [
  #     ["position", "x"]
  #     ["position", "y"]
  #     "rotation"
  #   ], [
  #     { ... }
  #     { ... }
  #     { ... }
  #   ]
  #
  # When passing an animation start time, (< 0) signifies immediately, 0 no
  # automatic start, and (> 0) a start delay in ms from now.
  #
  # Start and fps are only set on animations if they do not already exist!
  #
  # @param [AJSBaseActor] actor actor to effect
  # @param [String, Array, Array<String, Array>] properties properties to animate
  # @param [Object, Array<Object>] options animation options
  # @param [Number] start optional, animation start time (applies to all)
  # @param [Number] fps optional animation rate, defaults to 30
  @animate: (actor, properties, options, start, fps) ->
    param.required actor
    param.required properties
    param.required options
    start = param.optional start, 0
    fps = param.optional fps, 30

    Animations = window.AdefyGLI.Animations()

    if properties not instanceof Array then properties = [ properties ]
    if options not instanceof Array then options = [ options ]

    for i in [0...properties.length]
      if options[i].start == undefined then options[i].start = start
      if options[i].fps == undefined then options[i].fps = fps

      Animations.animate actor, properties[i], options[i]