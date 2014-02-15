# Implements a circle actor
#
## @depend AJSBaseActor.coffee
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
class AJSCircle extends AJSBaseActor

  # Spawn circle
  #
  # @param [Object] options instantiation options
  # @option options [Number] radius
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    options = param.required options
    @_radius = param.required options.radius

    if @_radius <= 0 then throw new Error "Radius must be greater than 0"

    scale = AJS.getAutoScale()
    @radius *= Math.min scale.x, scale.y

    @_rebuildVerts()
    super @_verts, options.mass, options.friction, options.elasticity

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
    @_setRenderMode 2

  # Creates the engine actor object
  #
  # @return [Number] id actor id
  interfaceActorCreate: ->
    AJS.info "Creating circle actor [#{@_radius}]"
    window.AdefyGLI.Actors().createCircleActor @_radius, JSON.stringify(@_verts)

  # @private
  # Private method that rebuilds our vertex array.
  #
  # @param [Boolean] sim signals a simulation, returns verts (default false)
  # @param [Number] radius radius for simulation
  _rebuildVerts: (sim, radius) ->
    ignorePsyx = param.optional ignorePsyx, false
    sim = param.optional sim, false
    radius = param.optional radius, @_radius

    segments = 32

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

    if sim then verts.push "`0" else verts.push 0
    if sim then verts.push "`0" else verts.push 0

    if sim then return verts else @_verts = verts

  # Fetches radius from engine
  #
  # @return [Number] radius
  getRadius: ->
    AJS.info "Fetching actor (#{@_id}) radius..."
    @_radius = window.AdefyGLI.Actors().getCircleActorRadius @_id

  # Set radius and rebuild vertices. Enforces minimum and updates actor
  #
  # @param [Number] radius new radius, > 0
  setRadius: (radius) ->
    param.required radius
    if radius <= 0 then throw new Error "New radius must be >0 !"
    AJS.info "Setting actor (#{@_id}) radius [#{radius}]..."

    @_radius = radius
    @_rebuildVerts()
    @_updateVertices()
    window.AdefyGLI.Actors().setCircleActorRadius @_id, radius
    @

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

    # Attaches the appropriate prefix, returns "." for 0
    prefixVal = (val) ->
      if val == 0 then val = "."
      else if val >= 0 then val = "+#{val}"
      else val = "#{val}"
      val

    # Our only unique property is our radius. We first calculate values at each
    # step, then generate vert deltas accordingly.
    if property[0] == "radius"

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
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
          options.deltas.push @_rebuildVerts true, val
          options.delays.push delay

      # Update our stored radius on each step
      options.cbStep = (radius) => @_radius = radius

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    if property[0] == "radius" then return true
    else return false

  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [Array<String>] property property name
  # @return [Boolean] absolute hope to the gods this is false
  absoluteMapping: (property) -> false
