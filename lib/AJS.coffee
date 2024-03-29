## Top-level file, used by concat_in_order
##
## As part of the build process, grunt concats all of our coffee sources in a
## dependency-aware manner. Deps are described at the top of each file, with this
## essentially serving as the root node in the dep tree.
##
## @depend util/AJSUtilParam.coffee
## @depend actors/AJSRectangle.coffee
## @depend actors/AJSTriangle.coffee
## @depend actors/AJSPolygon.coffee
## @depend actors/AJSCircle.coffee

# AJS main class, instantiates the engine and provides access to common methods
# Should never be instantiated, all methods are static.
class AJS

  @Version:
    MAJOR: 1
    MINOR: 1
    PATCH: 0
    BUILD: null
    STRING: "1.1.0"

  # Pointer to the engine, initalized (once) in init()
  # @private
  @_engine: null

  # Self-explanatory
  # @private
  @_initialized: false

  # Log level, between 0 and 4
  # @private
  @_logLevel: 2

  @_scaleX: 1
  @_scaleY: 1

  # AJS is a singleton, do not instantiate! Constructor throws an error.
  constructor: -> throw new Error "AJS shouldn't be instantiated!"

  # Set display scale, internal method used by our backend to scale creatives
  # for the target device display
  #
  # @param [Number] scaleX
  # @param [Number] scaleY
  # @private
  @setAutoScale: (scaleX, scaleY) ->
    AJS._scaleX = scaleX
    AJS._scaleY = scaleY

  # Fetch auto scale, used internally by AJS components
  #
  # @return [Object] scale scale object with x and y values
  # @private
  @getAutoScale: -> x: AJS._scaleX, y: AJS._scaleY

  # Initializes the engine with a specific screen size and ad length
  # The actual ad needs to be passed in as a method
  #
  # @param [Method] ad ad to execute
  # @param [Number] width
  # @param [Number] height
  # @param [String] canvasID optional canvas ID for WebGL engine
  @init: (ad, width, height, canvasID) ->

    # Should never happen, so don't fail quietly
    if AJS._initialized
      return @error "AJS can only be initialized once"
    else AJS._initialized = true

    # Clear all existing timeouts
    lastTimeout = setTimeout (->), 1
    clearTimeout i for i in [0...lastTimeout]

    @_engine = window.AdefyRE.Engine()

    # Set render mode for the browser rendering engine (WebGL if we can)
    if @_engine.setRendererMode != undefined
      if !window.WebGLRenderingContext
        @_engine.setRendererMode 1
        @info "Dropping to canvas render mode"
      else
        @_engine.setRendererMode 2
        @info "Proceeding with WebGL render mode"

    # Initialize!
    @_engine.initialize width, height, ((agl) -> ad agl), 2, canvasID
    @info "Initialized AJS"

  # Override AJS and engine log level
  #
  # @param [Number] level 0-4
  @setLogLevel: (level) ->
    @info "Setting log level to #{level}"

    window.AdefyRE.Engine().setLogLevel level
    @_logLevel = level
    @

  # Base logging statement, issues the log message with an optional prefix
  # if the current log level allows it
  #
  # @param [Number] level
  # @param [String] message
  # @param [String] prefix optional prefix
  @log: (level, message, prefix) ->
    if prefix == undefined then prefix = ""

    # Return early if not at a suiteable level, or level is 0
    if level > @_logLevel or level == 0 or @_logLevel == 0 then return

    # Specialized console output
    if level == 1 and console.error != undefined
      if console.error then console.error "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 2 and console.warn != undefined
      if console.warn then console.warn "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 3 and console.debug != undefined
      if console.debug then console.debug "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 4 and console.info != undefined
      if console.info then console.info "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level > 4 and me.tags[level] != undefined
        console.log "#{prefix}#{message}"
      else
        console.log message

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 2
  #
  # @param [String] message
  @warning: (message) ->
    @log 2, message, "[WARNING] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 1
  #
  # @param [String] message
  @error: (message) ->
    @log 1, message, "[ERROR] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 4
  #
  # @param [String] message
  @info: (message) ->
    @log 4, message, "[INFO] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 3
  #
  # @param [String] message
  @debug: (message) ->
    @log 3, message, "[DEBUG] "
    @

  # Set camera position. Leaving out a component leaves it unmodified
  #
  # @param [Number] x
  # @param [Number] y
  @setCameraPosition: (x, y) ->
    @info "Setting camera position (#{x}, #{y})"

    x *= AJS._scaleX
    y *= AJS._scaleY

    window.AdefyRE.Engine().setCameraPosition x, y
    @

  # Fetch camera position. Returns an object with x, y keys
  #
  # @return [Object] pos
  @getCameraPosition: ->
    @info "Fetching camera position..."

    pos = JSON.parse window.AdefyRE.Engine().getCameraPosition()
    pos.x /= AJS._scaleX
    pos.y /= AJS.scaleY
    pos

  # Set renderer clear color, component values between 0 and 255
  #
  # @param [Number] r
  # @param [Number] g
  # @param [Number] b
  @setClearColor: (r, g, b) ->
    @info "Setting clear color to (#{r}, #{g}, #{b})"

    window.AdefyRE.Engine().setClearColor r, g, b

  # Returns the renderer clear color as an AJSColor3
  #
  # @return [AJSColor3] clearcol
  @getClearColor: ->
    @info "Fetching clear color..."

    col = JSON.parse window.AdefyRE.Engine().getClearColor()
    new AJSColor3 col.r, col.g, col.b

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
    start ||= 0
    fps ||= 30

    Animations = window.AdefyRE.Animations()

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

    # We actually pass this down to the actor. Evil, eh? Muahahahaha
    actor.mapAnimation property, options

  # Load package.json source; used only by the WebGL engine, in turn loads
  # textures relative to our current path.
  #
  # @param [String] json valid package.json source (can also be an object)
  # @param [Method] cb callback to call after load (textures)
  @loadManifest: (json, cb) ->

    # If the json is not a string, then stringify it
    json = JSON.stringify json if typeof json != "string"

    cb ||= ->
    @info "Loading manifest #{JSON.stringify json}"

    window.AdefyRE.Engine().loadManifest json, cb

  # Create new rectangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] w width
  # @param [Number] h height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createRectangleActor: (x, y, w, h, r, g, b, extraOptions) ->

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      w: w
      h: h

    for key, val of extraOptions
      options[key] = val

    new AJSRectangle options

  # Create a new square actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] l side length
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createSquareActor: (x, y, l, r, g, b, extraOptions) ->
    AJS.createRectangleActor x, y, l, l, r, g, b,

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createCircleActor: (x, y, radius, r, g, b, extraOptions) ->

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      radius: radius

    for key, val of extraOptions
      options[key] = val

    new AJSCircle options

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] segments
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createPolygonActor: (x, y, radius, segments, r, g, b, extraOptions) ->

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      radius: radius
      segments: segments

    for key, val of extraOptions
      options[key] = val

    new AJSPolygon options

  # Create a new triangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] base base width
  # @param [Number] height height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createTriangleActor: (x, y, base, height, r, g, b, extraOptions) ->

    r ||= Math.floor (Math.random() * 255)
    g ||= Math.floor (Math.random() * 255)
    b ||= Math.floor (Math.random() * 255)

    options =
     position: { x: x, y: y }
     color: { r: r, g: g, b: b }
     base: base
     height: height

    for key, val of extraOptions
      options[key] = val

    new AJSTriangle options

  # Get texture size by name
  #
  # @param [String] name
  # @return [Object] size
  @getTextureSize: (name) ->
    @info "Fetching texture size by name (#{name})"

    window.AdefyRE.Engine().getTextureSize name

  # Designate the rectangluar region defining the remind me later button
  #
  # @param [Number] x
  # @param [Number] y
  # @param [Number] w
  # @param [Number] h
  @setRemindMeLaterButton: (x, y, w, h) ->
    window.AdefyRE.Engine().setRemindMeButton x, y, w, h
