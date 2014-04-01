# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
#
## @depend ../util/AJSVector2.coffee
class AJSBaseActor

  # Instantiates the actor in the engine, gets a handle for it
  #
  # @param [Array<Number>] verts flat 2d capped array of vertices
  # @param [Number] mass object mass
  # @param [Number] friction object friction
  # @param [Number] elasticity object elasticity
  constructor: (@_verts, mass, friction, elasticity) ->
    @_verts = param.optional @_verts
    @_m = param.optional mass, 0
    @_f = param.optional friction, 0.2
    @_e = param.optional elasticity, 0.3

    if @interfaceActorCreate == null
      throw new Error "Actor class doesn't provide interface actor creation!"

    if mass < 0 then mass = 0
    if @_verts != undefined and @_verts != null and @_verts.length < 6
      throw new Error "At least three vertices must be provided"

    @_psyx = false

    # Actual actor creation
    @_id = @interfaceActorCreate()

    if @_id == -1
      throw new Error "Failed to create actor!"

    @setPosition new AJSVector2()
    @setRotation 0
    @setColor new AJSColor3 255, 255, 255

  # Creates the engine actor object
  #
  # This method needs to be overloaded in all child classes
  #
  # @return [Number] id actor id
  interfaceActorCreate: null

  # De-registers the actor, clearing the physics and visual bodies.
  # Note that the instance in question should not be used after this is called!
  destroy: ->
    AJS.info "Destroying actor #{@_id}"
    window.AdefyRE.Actors().destroyActor @_id

  # Set our render layer. Higher layers render last (on top)
  # Default layer is 0
  #
  # @param [Number] layer
  setLayer: (layer) ->
    AJS.info "Setting actor (#{@_id}) layer #{layer}"
    window.AdefyRE.Actors().setActorLayer param.required(layer), @_id
    @

  # Set our physics layer. Actors will only collide if they are in the same
  # layer! There are only 16 physics layers (1-16, with default layer 0)
  #
  # Default layer is 0
  #
  # Physics layers persist between physics body creations
  #
  # @param [Number] layer
  setPhysicsLayer: (layer) ->
    AJS.info "Setting actor (#{@_id}) physics layer #{layer}"
    window.AdefyRE.Actors().setActorPhysicsLayer param.required(layer), @_id
    @

  # @private
  # Provide an alternate set of vertices for our physics body.
  #
  # @param [Array<Number>] verts
  _setPhysicsVertices: (verts) ->
    param.required verts
    AJS.info "Setting actor physics vertices (#{@_id}) [#{verts.length} verts]"
    window.AdefyRE.Actors().setPhysicsVertices JSON.stringify(verts), @_id

  # @private
  # Set render mode, documented on the interface
  #
  # @param [Number] mode
  _setRenderMode: (mode) ->
    AJS.info "Setting actor (#{@_id}) render mode #{mode}"
    window.AdefyRE.Actors().setRenderMode param.required(mode, [1, 2, 3]), @_id

  # @private
  # Re-creates our actor with our current vertices. This does not modify
  # the vertices, only re-sends them!
  _updateVertices: ->
    AJS.info "Updating actor (#{@_id}) vertices [#{@_verts.length} verts]"
    window.AdefyRE.Actors().updateVertices JSON.stringify(@_verts), @_id

  # @private
  # Fetches vertices from the engine
  _fetchVertices: ->
    AJS.info "Fetching actor vertices (#{@_id})..."
    res = window.AdefyRE.Actors().getVertices @_id
    if res.length > 0
      try
        @_verts = JSON.parse res
      catch e
        console.error "Invalid verts [#{e}]: #{res}"

    @_verts

  ###
  # Return actor id
  #
  # @return [Number] id
  ###
  getId: -> @_id

  ###
  # Modifies the position of the native object, and stores
  # a local copy of it
  #
  # @param [Boolean] _bool New visibility
  ###
  setVisible: (_bool) ->
    AJS.info "Setting actor visiblity (#{@_id}) #{_bool}"
    @_visible = _bool
    window.AdefyRE.Actors().setActorVisible @_visible, @_id
    @

  ###
  # Modifies the position of the native object, and stores
  # a local copy of it
  #
  # @param [AJSVector2] position New position
  ###
  setPosition: (v) ->
    AJS.info "Setting actor position (#{@_id}) #{JSON.stringify v}"

    scale = AJS.getAutoScale()
    v.x *= scale.x
    v.y *= scale.y

    @_position = v
    window.AdefyRE.Actors().setActorPosition v.x, v.y, @_id
    @

  ###
  # Modifies the rotation of the native object, and stores
  # a local copy of it
  #
  # @param [Number] angle New angle in degrees
  # @param [Boolean] radians set in radians, defaults to false
  ###
  setRotation: (a, radians) ->
    AJS.info "Setting actor (#{@_id}) rotation #{a} [radians: #{radians}]"

    if radians != true then radians = false
    @_rotation = a
    window.AdefyRE.Actors().setActorRotation a, @_id, radians
    @

  ###
  # Returns the position of the object, as stored locally
  #
  # @return [AJSVector2] Position
  ###
  getPosition: ->
    AJS.info "Fetching actor position..."

    raw = JSON.parse window.AdefyRE.Actors().getActorPosition @_id

    scale = AJS.getAutoScale()
    raw.x /= scale.x
    raw.y /= scale.y

    new AJSVector2 raw.x, raw.y

  ###
  # Returns the rotation of the native object, as stored locally
  #
  # @param [Boolean] radians return in radians, defaults to false
  # @return [Number] Angle in degrees
  ###
  getRotation: (radians) ->
    AJS.info "Fetching actor rotation [radians: #{radians}]..."

    if radians != true then radians = false
    window.AdefyRE.Actors().getActorRotation @_id, radians

  ###
  # Set actor color
  #
  # @param [AJSColor3] color
  ###
  setColor: (col) ->
    AJS.info "Setting actor (#{@_id}) color #{JSON.stringify col}"
    window.AdefyRE.Actors().setActorColor col._r, col._g, col._b, @_id
    @

  setTexture: (texture) ->
    AJS.info "Setting actor (#{@_id}) texture #{texture}"
    window.AdefyRE.Actors().setActorTexture texture, @_id
    @

  setTextureRepeat: (x, y) ->
    y = param.optional y, 1
    AJS.info "Setting actor (#{@_id}) texture repeat (#{x}, #{y})"

    window.AdefyRE.Actors().setActorTextureRepeat x, y, @_id
    @

  # Get actor color
  #
  # @return [AJSColor3] color
  getColor: ->
    AJS.info "Fetching actor (#{@_id}) color..."
    raw = JSON.parse window.AdefyRE.Actors().getActorColor @_id
    new AJSColor3 raw.r, raw.g, raw.b

  # Check if psyx simulation is enabled
  #
  # @return [Boolean] psyx psyx enabled status
  hasPsyx: -> @_psyx

  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  enablePsyx: (m, f, e) ->
    @_m = param.optional m, @_m
    @_f = param.optional f, @_f
    @_e = param.optional e, @_e
    AJS.info "Enabling actor physics (#{@_id}) [m: #{m}, f: #{f}, e: #{e}]"

    @_psyx = window.AdefyRE.Actors().enableActorPhysics @_m, @_f, @_e, @_id
    @

  # Destroys the physics body if one exists
  disablePsyx: ->
    AJS.info "Disabling actor (#{@_id}) physics..."
    if window.AdefyRE.Actors().destroyPhysicsBody @_id then @_psyx = false
    @

  # Attach a texture to the actor. This creates a square actor, textures it,
  # and anchors it to ourselves. Use this when texturing actors that don't
  # currently directly support textures.
  #
  # @param [String] texture texture name
  # @param [Number] width attached actor width
  # @param [Number] height attached actor height
  # @param [Number] offx anchor point offset
  # @param [Number] offy anchor point offset
  # @param [Angle] angle anchor point rotation
  attachTexture: (texture, w, h, x, y, angle) ->
    param.required texture
    param.required w
    param.required h
    x = param.optional x, 0
    y = param.optional y, 0
    angle = param.optional angle, 0

    AJS.info "Attaching texture #{texture} #{w}x#{h} to actor (#{@_id})"

    scale = AJS.getAutoScale()
    x *= scale.x
    y *= scale.y

    if w == h
      scale = (scale.x + scale.y) / 2
      w *= scale
      h *= scale
    else
      w *= scale.x
      h *= scale.y

    window.AdefyRE.Actors().attachTexture texture, w, h, x, y, angle, @_id

  # Remove attached texture if we have one
  #
  # @return [Boolean] success
  removeAttachment: ->
    AJS.info "Removing actor (#{@_id}) texture attachment"
    window.AdefyRE.Actors().removeAttachment @_id

  # Set attached texture visiblity
  #
  # @param [Boolean] visible
  # @return [Boolean] success
  setAttachmentVisible: (visible) ->
    param.required visible
    AJS.info "Setting actor texture attachment visiblity [#{visible}]"
    window.AdefyRE.Actors().setAttachmentVisible visible, @_id

  # This is called by AJS.mapAnimation(), which is in turn called by
  # AJS.animate() when required. You shouldn't map your animations yourself,
  # let AJS do that by passing them to AJS.animate() as-is.
  #
  # Actors extending us should also extend this method to support animating
  # their unique properties.
  #
  # Generates an engine-supported animation for the specified property and
  # options. Use this when animating a property not directly supported by
  # the engine.
  #
  # @param [Array<String>] property property name
  # @param [Object] options animation options
  # @return [Object] animation object containing "property" and "options" keys
  mapAnimation: (property, options) ->

    # Since we don't have any properties not already supported by the engine,
    # we return null to signal an error (calls to actors get passed down to us
    # for unrecognized properties)
    null

  # Checks if the property is one we provide animation mapping for
  #
  # @param [String] property property name
  # @return [Boolean] support
  canMapAnimation: (property) -> false

  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [String] property property name
  # @return [Boolean] absolute hope to the gods this is false
  absoluteMapping: (property) -> false

  # Schedule a rotation animation
  # If only an angle is provided, the actor is immediately and instantly
  # rotated
  #
  # @param [Number] angle target angle
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  rotate: (angle, duration, start, cp) ->
    param.required angle

    if duration == undefined
      @setRotation angle
      return @
    else

      if start == undefined then start = 0
      if cp == undefined then cp = []

      AJS.animate @, [["rotation"]], [
        endVal: angle
        controlPoints: cp
        duration: duration
        property: "rotation"
        start: start
      ]

      @

  # Schedule a movement
  # If only target coordinates are provided, the actor is immediately and
  # instantly moved
  #
  # If either coordinate is null, it is not modified
  #
  # @param [Number] x target x coordinate
  # @param [Number] y target y coordinate
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  move: (x, y, duration, start, cp) ->

    scale = AJS.getAutoScale()
    if x != null then x *= scale.x
    if y != null then y *= scale.y

    if duration == undefined
      if x == null or x == undefined then x = @getPosition().x
      if y == null or y == undefined then y = @getPosition().y

      @setPosition x: x, y: y
      return @
    else

      if start == undefined then start = 0
      if cp == undefined then cp = []

      for point in cp
        if point.y > 1
          if x == null then point.y *= scale.y
          else if y == null then point.y *= scale.x
          else point.y *= (scale.x + scale.y) / 2

      if x != null
        AJS.animate @, [["position", "x"]], [
          endVal: x
          controlPoints: cp
          duration: duration
          start: start
        ]

      if y != null
        AJS.animate @, [["position", "y"]], [
          endVal: y
          controlPoints: cp
          duration: duration
          start: start
        ]

      @

  # Schedule a color change
  # If only target components are provided the color is immediately set
  #
  # If either coordinate is null, it is not modified
  #
  # @param [Number] r target red component
  # @param [Number] g target green component
  # @param [Number] b target blue component
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  colorTo: (r, g, b, duration, start, cp) ->

    if duration == undefined
      if r == null or r == undefined then r = @getColor().r
      if g == null or g == undefined then g = @getColor().g
      if b == null or b == undefined then b = @getColor().b

      @setColor { _r: r, _g: g, _b: b }
      return @

    else

      if start == undefined then start = 0
      if cp == undefined then cp = []

      if r != null
        AJS.animate @, [["color", "r"]], [
          endVal: r
          controlPoints: cp
          duration: duration
          start: start
        ]

      if g != null
        AJS.animate @, [["color", "g"]], [
          endVal: g
          controlPoints: cp
          duration: duration
          start: start
        ]

      if b != null
        AJS.animate @, [["color", "b"]], [
          endVal: b
          controlPoints: cp
          duration: duration
          start: start
        ]

      @
