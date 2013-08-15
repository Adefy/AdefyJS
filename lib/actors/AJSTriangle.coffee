# Implements a triangular actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSTriangle extends AJSBaseActor

  _base: null
  _height: null

  # Set up vertices, with the resulting triangle centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] angle rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->

    # Sanity checks
    if options == undefined then throw "No params provided"

    if options.base not instanceof Number then throw "Base must be provided"
    if options.height not instanceof Number then throw "Height must be provided"

    if options.base <= 0 then throw "Base must be wider than 0"
    if options.height <= 0 then throw "Height must be greater than 0"

    # Set up properties
    @_base = options.base
    @_height = options.height

    if options.color not instanceof AJSColor3
      @_color = new AJSColor3()
    else
      @_color = options.color

    # Build vertices
    hB = @_base / 2.0
    hH = @_height / 2.0

    verts = [
      x: -hB
      y: -hH
    ,
      x: 0
      y: hH
    ,
      x: hB
      y: -hH
    ]

    super verts

    # Position and rotation
    if options.position instanceof AJSVec2 then @setPosition options.position
    if options.rotation instanceof Number then @setRotation options.rotation

    if options.psyx instanceof Boolean
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
