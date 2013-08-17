# Implements a rectangular actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSRectangle extends AJSBaseActor

  # Dimensions, not modifyable
  _w: null
  _h: null

  # Set up vertices, with the resulting rectangle centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] angle rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->

    if options == undefined then throw "No params provided"

    if options.w not instanceof Number then throw "Width must be provided"
    if options.h not instanceof Number then throw "Height must be provided"

    if options.w <= 0 then throw "Width must be greater than 0"
    if options.h <= 0 then throw "Height must be greater than 0"

    # Set up properties using options object
    @_w = options.width
    @_h = options.height

    # Color
    if options.color not instanceof AJSColor3
      @_color = new AJSColor3(255, 255, 255)
    else
      @_color = options.color

    # Build vertices
    hW = @_w / 2.0
    hH = @_h / 2.0

    # Extra vert caps the shape
    verts = [10]

    verts[0] = -hW
    verts[1] = -hH

    verts[2] = -hW
    verts[3] =  hH

    verts[4] =  hW
    verts[5] = -hH

    verts[6] =  hW
    verts[7] =  hH

    verts[8] = -hW
    verts[9] = -hH

    super verts

    # Position and rotation
    if options.position instanceof AJSVector2 then @setPosition options.position
    if typeof options.rotation == "number" then @setRotation options.rotation

    if typeof options.psyx == "boolean"

      if options.mass == undefined or options.mass < 0
        throw "Mass must be set and >= 0: #{options.mass}"

      if options.friction == undefined or options.friction < 0
        throw "Friction must be set and >= 0: #{options.friction}"

      if options.elasticity == undefined or options.elasticity < 0
        throw "Elasticity must be set and >= 0: #{options.elasticity}"

      if typeof options.mass != "number" then throw "Mass must be a number"
      if typeof options.friction != "number" then throw "Friction must be a number"
      if typeof options.elasticity != "number" then throw "Elasticity must be a number"

      if options.psyx
        @enablePsyx(options.mass, options.friction, options.elasticity)
      else
        @disablePsyx()

  # Returns width
  #
  # @return [Number] width
  getWidth: -> @_w

  # Returns height
  #
  # @return [Number] height
  getHeight: -> @_h
