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
    @_engine.initialize width, height, ((agl) -> ad agl), 1

  # Set camera position. Leaving out a component leaves it unmodified
  #
  # @param [Number] x
  # @param [Number] y
  @setCameraPosition: (x, y) ->
    window.AdefyGLI.Engine().setCameraPosition x, y

  # Fetch camera position. Returns an object with x, y keys
  #
  # @return [Object] pos
  @getCameraPosition: ->
    JSON.parse window.AdefyGLI.Engine().getCameraPosition()

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

    col = JSON.parse window.AdefyGLI.Engine().getClearColor()
    new AJSColor3 col.r, col.g, col.b

  # Override engine log level
  #
  # @param [Number] level 0-4
  @setLogLevel: (level) ->
    param.required level, [0, 1, 2, 3, 4]

    window.AdefyGLI.Engine().setLogLevel level

  @_syntheticMap:

    "width": ""

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
  # @param [Array, Array<Array>] properties properties to animate
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

    # Helpful below
    _registerDelayedMap = (actor, property, options, time) ->

      setTimeout ->
        result = AJS.mapAnimation actor, property, options
        property = JSON.stringify result.property
        options = JSON.stringify result.options
        Animations.animate actor.getId(), property, options
      , time

    for i in [0...properties.length]
      if options[i].fps == undefined then options[i].fps = fps
      if options[i].start == undefined then options[i].start = start

      # Check if the property is directly supported by the engine. If not, we
      # need to map it to the corresponding property and options structure our
      # engine requires to execute it.
      if not Animations.canAnimate properties[i][0]

        # Check if we can map the property
        if not actor.canMapAnimation properties[i]
          throw new Error "Unrecognized property! #{properties[i]}"

        # Check if an absolute change is required
        if actor.absoluteMapping properties[i]
          timeout = options[i].start
          options[i].start = -1
          _registerDelayedMap actor, properties[i], options[i], timeout

        else
          result = AJS.mapAnimation actor, properties[i], options[i]
          properties[i] = JSON.stringify result.property
          options[i] = JSON.stringify result.options
          Animations.animate actor.getId(), properties[i], options[i]

      # Animate normally if we can
      else
        options[i] = JSON.stringify options[i]
        properties[i] = JSON.stringify properties[i]
        Animations.animate actor.getId(), properties[i], options[i]

  # Generates an engine-supported animation for the specified property and
  # options. Use this when animating a property not directly supported by
  # the engine.
  #
  # Note that AJS.animate() uses this internally upon encountering an
  # unsupported property!
  #
  # @param [AJSBaseActor] actor actor animation applies to
  # @param [String] property property name
  # @param [Object] options animation options
  # @return [Object] animation object containing "property" and "options" keys
  @mapAnimation: (actor, property, options) ->
    param.required actor
    param.required property
    param.required options

    # We actually pass this down to the actor. Evil, eh? Muahahahaha
    actor.mapAnimation property, options

  # Load package.json source; used only by the WebGL engine, in turn loads
  # textures relative to our current path.
  #
  # @param [String] json valid package.json source
  # @param [Method] cb callback to call after load (textures)
  @loadManifest: (json, cb) ->
    param.required json
    cb = param.optional cb, ->
    window.AdefyGLI.Engine().loadManifest json, cb

  # Create new rectangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] w width
  # @param [Number] h height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  @createRectangleActor: (x, y, w, h, r, g, b) ->
    param.required x
    param.required y
    param.required w
    param.required h

    new AJSRectangle
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      w: w
      h: h

  # Create a new square actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] l side length
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  @createSquareActor: (x, y, l, r, g, b) ->
    AJS.createRectangleActor x, y, l, l, r, g, b

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  @createCircleActor: (x, y, radius, r, g, b) ->
    AJS.createPolygonActor x, y, radius, 32, r, g, b

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] segments
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  @createPolygonActor: (x, y, radius, segments, r, g, b) ->
    param.required x
    param.required y
    param.required radius
    param.required segments

    new AJSPolygon
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      radius: radius
      segments: segments

  # Create a new triangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] base base width
  # @param [Number] height height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  @createTriangleActor: (x, y, base, height, r, g, b) ->
    param.required x
    param.required y
    param.required base
    param.required height

    if r == undefined then r = Math.floor (Math.random() * 255)
    if g == undefined then g = Math.floor (Math.random() * 255)
    if b == undefined then b = Math.floor (Math.random() * 255)

    new AJSTriangle
     position: { x: x, y: y }
     color: { r: r, g: g, b: b }
     base: base
     height: height

  # Get texture by name
  #
  # @param [String] name
  # @return [Object] texture
  @getTexture: (name) ->
    param.required name

    window.AdefyGLI.Engine().getTexture name
