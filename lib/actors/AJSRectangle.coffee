##
## Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved
##

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
  # @option options [Number] rotation rotation in degrees
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
    else if options.color != undefined and options.color.r != undefined
      @setColor new AJSColor3 options.color.r, options.color.g, options.color.b

    if options.position instanceof AJSVector2
      @setPosition options.position
    else if options.position != undefined and options.position.x != undefined
      @setPosition new AJSVector2 options.position.x, options.position.y

    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx()

  # Fetches vertices from engine and returns width
  #
  # @return [Number] width
  getWidth: ->
    @_fetchVertices()
    @_w = @_verts[4] * 2

  # Fetches vertices from engine and returns height
  #
  # @return [Number] height
  getHeight: ->
    @_fetchVertices()
    @_h = @_verts[3] * 2

  # @private
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

    # We have two unique properties, width and height, both of which
    # must be animated in the same way. We first calculate values at
    # each step, then generate vert deltas accordingly.
    if property[0] == "width"

      options.startVal /= 2
      options.endVal /= 2
      JSONopts = JSON.stringify options

      bezValues = window.AdefyGLI.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # To keep things relative, we subtract previous deltas
      sum = Number bezValues.values[0]

      # Create delta sets
      for val in bezValues.values

        val = Number val
        val -= sum
        sum += val
        delay += Number bezValues.stepTime

        if val != 0
          options.deltas.push [
            prefixVal -val    # Bottom-left
            "."

            prefixVal -val    # Top-left
            "."

            prefixVal val     # Top-right
            "."

            prefixVal val     # Bottom-right
            "."

            prefixVal -val    # Bottom-left
            "."
          ]

          options.udata.push val * 2
          options.delays.push delay

      options.cbStep = (width) => @_w += width * 2

      anim.property = ["vertices"]
      anim.options = options

    else if property[0] == "height"

      options.startVal /= 2
      options.endVal /= 2
      JSONopts = JSON.stringify options

      bezValues = window.AdefyGLI.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # To keep things relative, we subtract previous deltas
      sum = Number bezValues.values[0]

      # Create delta sets
      for val in bezValues.values

        val = Number val
        val -= sum
        sum += val
        delay += Number bezValues.stepTime

        if val != 0
          options.deltas.push [
            "."
            prefixVal -val    # Bottom-left

            "."
            prefixVal val     # Top-left

            "."
            prefixVal val     # Top-right

            "."
            prefixVal -val    # Bottom-right

            "."
            prefixVal -val    # Bottom-left
          ]

          options.udata.push val
          options.delays.push delay

      options.cbStep = (height) => @_h += height * 2

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    if property[0] == "height" or property[0] == "width" then return true
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

  # We're special, we get texture support. Yay us!
  #
  # @param [String] name texture name as per the manifest
  setTexture: (name) ->
    param.required name
    window.AdefyGLI.Actors().setActorTexture name, @_id
