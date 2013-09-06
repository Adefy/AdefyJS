# Implements a rectangular actor
#
# @depend AJSBaseActor.coffee
# @depend ../util/AJSVector2.coffee
# @depend ../util/AJSColor3.coffee
class AJSRectangle extends AJSBaseActor

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
    options = param.required options
    @_w = param.required options.w
    @_h = param.required options.h

    if @_w <= 0 then throw "Width must be greater than 0"
    if @_h <= 0 then throw "Height must be greater than 0"

    @_rebuildVerts()
    super @_verts, options.mass, options.friction, options.elasticity

    if options.color instanceof AJSColor3
      @setColor options.color
    if options.position instanceof AJSVector2
      @setPosition options.position
    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx()

  # Private method that rebuilds our vertex array, allows us to modify our
  # dimensions
  _rebuildVerts: ->

    # Build vertices
    hW = @_w / 2.0
    hH = @_h / 2.0

    # Extra vert caps the shape
    @_verts = []

    @_verts.push -hW
    @_verts.push -hH

    @_verts.push -hW
    @_verts.push  hH

    @_verts.push  hW
    @_verts.push  hH

    @_verts.push  hW
    @_verts.push -hH

    @_verts.push -hW
    @_verts.push -hH

  # Returns width
  #
  # @return [Number] width
  getWidth: -> @_w

  # Returns height
  #
  # @return [Number] height
  getHeight: -> @_h

  # Set height. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] height new height, > 0
  setHeight: (h) ->
    param.required h

    if h <= 0 then throw new Error "New height must be >0 !"

    @_h = h
    @_rebuildVerts()
    @_updateVertices()

  # Set width. Enforces minimum, rebuilds vertices, and updates actor
  setWidth: (b) ->
    param.required b

    if b <= 0 then throw new Error "New width must be >0 !"

    @_w = b
    @_rebuildVerts()
    @_updateVertices()