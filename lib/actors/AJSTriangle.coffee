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
    options = param.required options
    @_base = param.required options.base
    @_height = param.required options.height

    if @_base <= 0 then throw "Base must be wider than 0"
    if @_height <= 0 then throw "Height must be greater than 0"

    @_rebuildVerts()
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
    if options.color instanceof AJSColor3
      @setColor options.color
    if options.position instanceof AJSVector2
      @setPosition options.position
    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx @_mass, @_friction, @_elasticity

  # Private method that rebuilds our vertex array.
  _rebuildVerts: ->
    hB = @_base / 2.0
    hH = @_height / 2.0

    @_verts = [8]

    @_verts[0] = -hB
    @_verts[1] = -hH

    @_verts[2] =   0
    @_verts[3] =  hH

    @_verts[4] =  hB
    @_verts[5] = -hH

    @_verts[6] = -hB
    @_verts[7] = -hH

  # Returns base width
  #
  # @return [Number] base
  getBase: -> @_base

  # Returns height
  #
  # @return [Number] height
  getHeight: -> @_height
