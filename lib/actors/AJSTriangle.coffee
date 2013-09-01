# Implements a triangular actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSTriangle extends AJSBaseActor

  # Set up vertices, with the resulting triangle centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] base
  # @option options [Number] height
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] angle rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->

    # Sanity checks
    options = param.required options

    if options.base != "number" then throw "Base must be provided"
    if options.height != "number" then throw "Height must be provided"

    if options.base <= 0 then throw "Base must be wider than 0"
    if options.height <= 0 then throw "Height must be greater than 0"

    # Set up properties
    @_base = options.base
    @_height = options.height

    if options.color not instanceof AJSColor3
      @_color = new AJSColor3(255, 255, 255)
    else
      @_color = options.color

    # Build vertices
    hB = @_base / 2.0
    hH = @_height / 2.0

    verts = [8]

    verts[0] = -hB
    verts[1] = -hH

    verts[2] =   0
    verts[3] =  hH

    verts[4] =  hB
    verts[5] = -hH

    verts[6] = -hB
    verts[7] = -hH

    super verts

    # Position and rotation
    if options.position instanceof AJSVec2 then @setPosition options.position
    if typeof options.rotation == "number" then @setRotation options.rotation

    if typeof options.psyx == "boolean"
      if options.psyx
        @enablePsyx()
      else
        @disablePsyx()

  # Returns base width
  #
  # @return [Number] base
  getBase: -> @_base

  # Returns height
  #
  # @return [Number] height
  getHeight: -> @_height
