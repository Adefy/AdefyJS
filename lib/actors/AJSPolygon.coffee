# Implements a variable-side polygon actor
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

    _tempVerts = @_verts
    _tempVerts.length -= 2
    @_setPhysicsVertices _tempVerts

    @_setRenderMode 2

  # Private method that rebuilds our vertex array.
  #
  # @param [Boolean] ignorePsyx defaults to false, only true in constructor
  _rebuildVerts: (ignorePsyx) ->
    ignorePsyx = param.optional ignorePsyx, false

    # Build vertices
    # Uses algo from http://slabode.exofire.net/circle_draw.shtml
    x = @_radius
    y = 0
    theta = (2.0 * 3.1415926) / @_segments
    tanFactor = Math.tan theta
    radFactor = Math.cos theta

    @_verts = []

    for i in [0...@_segments]
      index = i * 2
      @_verts[index] = x
      @_verts[index + 1] = y

      tx = -y
      ty = x

      x += tx * tanFactor
      y += ty * tanFactor

      x *= radFactor
      y *= radFactor

    # Cap the shape
    @_verts.push @_verts[0]
    @_verts.push @_verts[1]

    # Reverse winding!
    _tv = []
    for i in [0...@_verts.length] by 2
      _tv.push @_verts[@_verts.length - 2 - i]
      _tv.push @_verts[@_verts.length - 1 - i]

    @_verts = _tv

    if !ignorePsyx

      # NOTE: We need to prepend ourselves with (0, 0) for rendering, but pass
      #       the original vert array as our physical representation!
      @_setPhysicsVertices @_verts

    @_verts.push 0
    @_verts.push 0

  # Returns radius
  #
  # @return [Number] radius
  getRadius: -> @_radius

  # Returns number of segments comprising the shape
  #
  # @return [Number] segments
  getSegments: -> @_segments

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