# Implements a variable-side polygon actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSNGon extends AJSBaseActor

  _radius: null
  _segments: null

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

    # Sanity checks
    if options == undefined then throw "No params provided"

    if options.radius not instanceof Number then throw "Radius must be provided"
    if options.segments not instanceof Number
      throw "Segments must be provided"

    if options.radius <= 0 then throw "Radius must be larger than 0"
    if options.segments <= 0
      throw "Shape must consist of at least 3 segments"

    @_radius = options.radius
    @_segments = options.segments

    if options.color not instanceof AJSColor3
      @_color = new AJSColor3()
    else
      @_color = options.color

    # Build vertices
    # Uses algo from http://slabode.exofire.net/circle_draw.shtml
    x = @_radius
    y = 0
    theta = (2.0 * 3.1415926) / @_segments
    tanFactor = Math.tan theta
    radFactor = Math.cos theta

    verts = [2 * @_segments]

    for i in [0..@_segments]
      index = i * 2
      verts[i] = x
      verts[i + 1] = y

      tx = -y
      ty = x

      x += tx * tanFactor
      y += ty * tanFactor

      x *= radFactor
      y *= radFactor

    # Cap the shape
    verts.push verts[0]
    verts.push verts[1]

    super verts

    # Position and rotation
    if options.position instanceof AJSVec2 then @setPosition options.position
    if options.rotation instanceof Number then @setRotation options.rotation

    if options.psyx instanceof Boolean
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
