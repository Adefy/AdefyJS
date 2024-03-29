# Implements a rectangular actor
#
## @depend AJSBaseActor.coffee
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
class AJSRectangle extends AJSBaseActor

  # Spawn rectangle
  #
  # @param [Object] options instantiation options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    @_width = options.w
    @_height = options.h

    throw new Error "Width must be greater than 0" if @_width <= 0
    throw new Error "Height must be greater than 0" if @_height <= 0

    scale = AJS.getAutoScale()

    # Scale square actors by scale midpoint
    if @_width == @_height
      scale = (scale.x + scale.y) / 2
      @_width *= scale unless options.noScaleW
      @_height *= scale unless options.noScaleH

    # Scale by scale midpoint while maintaining aspect ratio
    else if options.scaleAR

      ar = @_width / @_height
      scale = (scale.x + scale.y) / 2

      if @_width > @_height
        @_height *= scale
        @_width = ar * @_height
      else
        @_width *= scale
        @_height = @_width / ar

    # Scale per-axis
    else
      @_width *= scale.x unless options.noScaleW
      @_height *= scale.y unless options.noScaleH

    super null, options.mass, options.friction, options.elasticity

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
    AJS.info "Creating rectangle actor (#{@_width}x#{@_height})"
    window.AdefyRE.Actors().createRectangleActor @_width, @_height

  # Fetches width from engine
  #
  # @return [Number] width
  getWidth: ->
    AJS.info "Fetching actor (#{@_id}) width..."
    @_width = window.AdefyRE.Actors().getRectangleActorWidth @_id

  # Fetches height from engine
  #
  # @return [Number] height
  getHeight: ->
    AJS.info "Fetching actor (#{@_id}) height..."
    @_height = window.AdefyRE.Actors().getRectangleActorHeight @_id


  # Set height. Enforces minimum and updates actor
  #
  # @param [Number] height new height, > 0
  setHeight: (h) ->
    throw new Error "New height must be >0 !" if h <= 0
    AJS.info "Setting actor (#{@_id}) height [#{h}]..."

    @_height = h
    window.AdefyRE.Actors().setRectangleActorHeight @_id, h
    @

  # Set width. Enforces minimum and updates actor
  #
  # @param [Number] width new width, > 0
  setWidth: (w) ->
    throw new Error "New width must be >0 !" if w <= 0
    AJS.info "Setting actor (#{@_id}) width [#{w}]..."

    @_width = w
    window.AdefyRE.Actors().setRectangleActorWidth @_id, w
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

      options.cbStep = (width) => @_width += width * 2

      anim.property = ["vertices"]
      anim.options = options

    else if property[0] == "height"

      options.startVal /= 2
      options.endVal /= 2
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

      options.cbStep = (height) => @_height += height * 2

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    property[0] == "height" or property[0] == "width"

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
  # If either width or height is null, it is left unmodified
  #
  # @param [Number] endW target width
  # @param [Number] endH target height
  # @param [Number] startW current width
  # @param [Number] startH current height
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  resize: (endW, endH, startW, startH, duration, start, cp) ->

    unless duration
      @setWidth endW if endW
      @setHeight endH if endH
      return @
    else

      start ||= 0
      cp ||= []
      components = []
      args = []

      if endW != null

        components.push ["width"]
        args.push
          endVal: endW
          startVal: startW
          controlPoints: cp
          duration: duration
          start: start
          property: "width"

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
