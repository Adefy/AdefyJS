# Implements a rectangular actor
class AJSRectangle extends AJSBaseActor

  # Dimensions, not modifyable
  _w: null
  _h: null

  # Set up vertices, with the resulting rectangle is
  # centered around its position
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

    if options.w is not instanceof Number then throw "Width must be provided"
    if options.h is not instanceof Number then throw "Height must be provided"

    if options.w <= 0 then throw "Width must be greater than 0"
    if options.h <= 0 then throw "Height must be greater than 0"

    # Set up properties using options object
    @_w = options.width
    @_h = options.height

    # Color
    if options.color is not instanceof AJSColor3
      @_color = new AJSColor3()
    else
      @_color = options.color

    # Build vertices
    hW = @_w / 2.0
    hH = @_h / 2.0

    verts = [
      x: -hW
      y: -hH
    ,
      x: -hW
      y: hH
    ,
      x: hW
      y: -hH
    ,
      x: hW
      y: hH
    ]

    super verts

    # Position and rotation
    if options.position is instanceof AJSVec2 then @setPosition options.position
    if options.rotation is instanceof Number then @setRotation options.rotation

  # Returns width
  #
  # @return [Number] width
  getWidth: -> @_w

  # Returns height
  #
  # @return [Number] height
  getHeight: -> @_h
