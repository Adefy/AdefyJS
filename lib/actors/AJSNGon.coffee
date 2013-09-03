# Implements a variable-side polygon actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSNGon extends AJSBaseActor

  # Set up vertices, with the resulting nGon centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] radius
  # @option options [Number] segments
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] angle rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    param.required options
    @_radius = param.required options.radius
    @_segments = param.required options.segments
    options.psyx = param.optional options.psyx, false

    if @_radius <= 0 then throw "Radius must be larger than 0"
    if @_segments < 3 then throw "Shape must consist of at least 3 segments"


    # Creates and registers our actor, valides physics properties
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
    if options.color instanceof AJSColor3
      @setColor options.color
    if options.position instanceof AJSVector2
      @setPosition options.position
    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx @_mass, @_friction, @_elasticity

    @_setRenderMode 2


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

    super verts

    # Position and rotation
    if options.position instanceof AJSVec2 then @setPosition options.position
    if typeof options.rotation == "number" then @setRotation options.rotation

    if typeof options.psyx == "boolean"
      if options.psyx
        @enablePsyx()
      else
        @disablePsyx()

  # Returns radius
  #
  # @return [Number] radius
  getRadius: -> @_radius

  # Returns number of segments comprising the shape
  #
  # @return [Number] segments
  getSegments: -> @_segments
