# Implements a triangular actor
#
## @depend AJSBaseActor.coffee
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
class AJSTriangle extends AJSBaseActor

  # Set up vertices, with the resulting triangle centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] base
  # @option options [Number] height
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    @_base = options.base
    @_height = options.height

    throw "Base must be wider than 0" if @_base <= 0
    throw "Height must be greater than 0" if @_height <= 0

    scale = AJS.getAutoScale()
    @_base *= scale.x
    @_height *= scale.y

    @_rebuildVerts()
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
    if options.color instanceof AJSColor3
      @setColor options.color
    else if options.color and options.color.r != undefined
      @setColor new AJSColor3 options.color.r, options.color.g, options.color.b

    if options.position instanceof AJSVector2
      @setPosition options.position
    else if options.position and options.position.x != undefined
      @setPosition new AJSVector2 options.position.x, options.position.y

    if typeof options.rotation == "number"
      @setRotation options.rotation

    if options.psyx then @enablePsyx()

  # Creates the engine actor object
  #
  # @return [Number] id actor id
  interfaceActorCreate: ->
    AJS.info "Creating triangle actor..."
    window.AdefyRE.Actors().createRawActor JSON.stringify @_verts

  # Fetches vertices from engine and returns base
  #
  # @return [Number] base
  getBase: ->
    @_fetchVertices()
    @_base = @_verts[4] * 2

  # Fetches vertices from engine and returns height
  #
  # @return [Number] height
  getHeight: ->
    @_fetchVertices()
    @_height = @_verts[3] * 2

  # @private
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

  # Set height. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] height new height, > 0
  setHeight: (h) ->
    throw new Error "New height must be >0 !" if h <= 0

    h *= AJS.getAutoScale().y

    @_height = h
    @_rebuildVerts()
    @_updateVertices()
    @

  # Set base. Enforces minimum, rebuilds vertices, and updates actor
  setBase: (b) ->
    throw new Error "New base must be >0 !" if b <= 0

    b *= AJS.getAutoScale().x

    @_base = b
    @_rebuildVerts()
    @_updateVertices()
    @

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
    scale = AJS.getAutoScale()
    anim = {}

    # Attaches the appropriate prefix, returns "." for 0
    prefixVal = (val) ->
      if val == 0 then val = "."
      else if val >= 0 then val = "+#{val}"
      else val = "#{val}"
      val

    # We have two unique properties, base and height, both of which
    # must be animated in the same way. We first calculate values at
    # each step, then generate vert deltas accordingly.
    if property[0] == "height"

      options.startVal /= 2
      options.endVal /= 2
      options.startVal *= scale.y
      options.endVal *= scale.y

      JSONopts = JSON.stringify options

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
      bezValues = window.AdefyRE.Animations().preCalculateBez JSONopts
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
            prefixVal val     # Top

            "."
            prefixVal -val    # Bottom-right

            "."
            prefixVal -val    # Bottom-left
          ]

          options.udata.push val
          options.delays.push delay

      options.cbStep = (height) => @_height += height * 2

      anim.property = ["vertices"]
      anim.options = options

    else if property[0] == "base"

      options.startVal /= 2
      options.endVal /= 2
      options.startVal *= scale.x
      options.endVal *= scale.x

      JSONopts = JSON.stringify options

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
      bezValues = window.AdefyRE.Animations().preCalculateBez JSONopts
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

            "."               # Top
            "."

            prefixVal val     # Bottom-right
            "."

            prefixVal -val    # Bottom-left
            "."
          ]

          options.udata.push val
          options.delays.push delay

      options.cbStep = (base) => @_base += base * 2

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    property[0] == "base" or property[0] == "height"

  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [Array<String>] property property name
  # @return [Boolean] absolute hope to the gods this is false
  absoluteMapping: (property) -> false

  # Animate a resize
  # If duration is undefined, changes are applied immediately
  #
  # If either base or height is null, it is left unmodified
  #
  # @param [Number] endB target width
  # @param [Number] endH target height
  # @param [Number] startB current width
  # @param [Number] startH current height
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  resize: (endB, endH, startB, startH, duration, start, cp) ->
    unless duration
      @setBase endB if endB
      @setHeight endH if endH
      return @
    else

      start ||= 0
      cp ||= []

      # NOTE: We only scale here, since the setBase() and setHeight() methods
      #       used if duration is undefined also apply scale!
      scale = AJS.getAutoScale()
      endB *= scale.x
      endH *= scale.y
      startB *= scale.x
      startH *= scale.y

      components = []
      args = []

      if endB != null

        components.push ["base"]
        args.push
          endVal: endB
          startVal: startB
          controlPoints: cp
          duration: duration
          start: start
          property: "base"

      if endH != null

        components.push ["height"]
        args.push
          endVal: endH
          startVal: startH
          controlPoints: cp
          duration: duration
          start: start
          property: "height"

      if components.length > 0 then AJS.animate @, components, args

      @
