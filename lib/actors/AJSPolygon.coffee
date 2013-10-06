##
## Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved
##

# Implements a variable-side polygon actor. The android engine implements
# this natively!
#
# NOTE: On WebGL, the radius and side-count should NEVER be animated at the
#       same time! This is a limitation of our vertice animations; side-count
#       and radius modifications both require a complete vertex-recalculation,
#       and as such are applied as absolute changes instead of relative ones
#       like width/height for AJSRectangle. Make sure your radius and
#       segment-count animations never overlap!
#
# NOTE 2: Even when the radius and side-count are animated seperately, very
#         strange things will happen as a result of the uni-directional line
#         of communication between us and the engine. Animating the radius does
#         not actually update our stored radius value. Sad pandas. The android
#         engine implements a polygon natively, and as such solves this
#         problem. Expect your WebGL exports to behave strangely if you animate
#         both on the same object.
#
# NOTE 3: Things work alright if you animate the radius first, then the seg
#         count. Keep this in mind.
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSPolygon extends AJSBaseActor

  # Set up vertices, with the resulting nGon centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] radius
  # @option options [Number] segments
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    param.required options
    @_radius = param.required options.radius
    @_segments = param.required options.segments
    options.psyx = param.optional options.psyx, false

    if @_radius <= 0 then throw "Radius must be larger than 0"
    if @_segments < 3 then throw "Shape must consist of at least 3 segments"

    @_rebuildVerts true

    # Creates and registers our actor, valides physics properties
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
    if options.color instanceof AJSColor3
      @setColor options.color
    else if options.color != undefined and options.color.r != undefined
      @setColor new AJSColor3 options.color.r, options.color.g, options.color.b

    if options.position instanceof AJSVector2
      @setPosition options.position
    else if options.position != undefined and options.position.x != undefined
      @setPosition new AJSVector2 options.position.x, options.position.y

    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx()

    @_setPhysicsVertices @_verts.slice(0, @_verts.length - 2)
    @_setRenderMode 2

  # Private method that rebuilds our vertex array.
  #
  # @param [Boolean] ignorePsyx defaults to false, only true in constructor
  # @param [Boolean] sim signals a simulation, returns verts (default false)
  # @param [Number] segments segment count for simulation
  # @param [Number] radius radius for simulation
  _rebuildVerts: (ignorePsyx, sim, segments, radius) ->
    ignorePsyx = param.optional ignorePsyx, false
    sim = param.optional sim, false
    segments = param.optional segments, @_segments
    radius = param.optional radius, @_radius

    # Build vertices
    # Uses algo from http://slabode.exofire.net/circle_draw.shtml
    x = radius
    y = 0
    theta = (2.0 * 3.1415926) / segments
    tanFactor = Math.tan theta
    radFactor = Math.cos theta

    verts = []

    for i in [0...segments]
      index = i * 2
      verts[index] = x
      verts[index + 1] = y

      tx = -y
      ty = x

      x += tx * tanFactor
      y += ty * tanFactor

      x *= radFactor
      y *= radFactor

    # Cap the shape
    verts.push verts[0]
    verts.push verts[1]

    # Reverse winding!
    _tv = []
    for i in [0...verts.length] by 2
      _tv1 = verts[verts.length - 2 - i]
      _tv2 = verts[verts.length - 1 - i]
      if sim then _tv.push "`#{_tv1}" else _tv.push _tv1
      if sim then _tv.push "`#{_tv2}" else _tv.push _tv2

    verts = _tv

    if !ignorePsyx and not sim

      # NOTE: We need to prepend ourselves with (0, 0) for rendering, but pass
      #       the original vert array as our physical representation!
      @_setPhysicsVertices verts

    if sim then verts.push "`0" else verts.push 0
    if sim then verts.push "`0" else verts.push 0

    if sim then return verts else @_verts = verts

  # Set radius. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] radius new radius, > 0
  setRadius: (r) ->
    param.required r

    if r <= 0 then throw new Error "New radius must be >0 !"

    @_radius = r
    @_rebuildVerts()
    @_updateVertices()

  # Set segments. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] segments new segment count, >= 3
  setSegments: (s) ->
    param.required s

    if s < 3 then throw new Error "New segment count must be >=3 !"

    @_segments = s
    @_rebuildVerts()
    @_updateVertices()

  # Get radius
  #
  # @return [Number] radius
  getRadius: -> @_radius

  # Get segment count
  #
  # @return [Number] segments
  getSegments: -> @_segments

  # This is called by AJS.mapAnimation(), which is in turn called by
  # AJS.animate() when required. You shouldn't map your animations yourself,
  # let AJS do that by passing them to AJS.animate() as-is.
  #
  # Generates an engine-supported animation for the specified property and
  # options. Use this when animating a property not directly supported by
  # the engine.
  #
  # @param [Array<String>] property property name
  # @param [Object] options animation options
  # @return [Object] animation object containing "property" and "options" keys
  mapAnimation: (property, options) ->
    param.required property
    param.required options

    anim = {}

    # Grab current vertices
    @_fetchVertices()

    # Attaches the appropriate prefix, returns "." for 0
    prefixVal = (val) ->
      if val == 0 then val = "."
      else if val >= 0 then val = "+#{val}"
      else val = "#{val}"
      val

    JSONopts = JSON.stringify options

    # We have two unique properties, radius and segments, both of which
    # must be animated in the same way. We first calculate values at
    # each step, then generate vert deltas accordingly.
    if property[0] == "radius"

      bezValues = window.AdefyGLI.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # Create delta sets
      for val in bezValues.values

        val = Number val
        delay += Number bezValues.stepTime

        if val != 0
          options.udata.push val
          options.deltas.push @_rebuildVerts true, true, @_segments, val
          options.delays.push delay

      # Update our stored radius on each step
      options.cbStep = (radius) => @_radius = radius

      anim.property = ["vertices"]
      anim.options = options

    else if property[0] == "sides"

      bezValues = window.AdefyGLI.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # Create delta sets
      for val in bezValues.values

        val = Number val
        delay += Number bezValues.stepTime

        if val != 0
          options.udata.push val
          options.deltas.push @_rebuildVerts true, true, val, @_radius
          options.delays.push delay

      # Update our stored seg count on each step
      options.cbStep = (segments) => @_segments = segments

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    if property[0] == "sides" or property[0] == "radius" then return true
    else return false

  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [Array<String>] property property name
  # @return [Boolean] absolute hope to the gods this is false
  absoluteMapping: (property) -> true