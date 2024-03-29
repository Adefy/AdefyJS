# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
#
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
## @depend ../util/AJSPhysicsProperties.coffee
class AJSBaseActor

  ###
  # Instantiates the actor in the engine, gets a handle for it
  #
  # @param [Array<Number>] verts flat 2d capped array of vertices
  # @param [Number] mass object mass
  # @param [Number] friction object friction
  # @param [Number] elasticity object elasticity
  ###
  constructor: (@_verts, mass, friction, elasticity) ->
    @_m = Math.max 0, (mass || 0)
    @_f = friction || 0.2
    @_e = elasticity || 0.3

    unless @interfaceActorCreate
      throw new Error "Actor class doesn't provide interface actor creation!"

    if @_verts and @_verts.length < 6
      throw new Error "At least three vertices must be provided"

    @_psyx = false

    # Actual actor creation
    if (@_id = @interfaceActorCreate()) == -1
      throw new Error "Failed to create actor!"

    @setPosition new AJSVector2()
    @setRotation 0
    @setColor new AJSColor3 255, 255, 255

  ###
  # Creates the engine actor object
  #
  # This method needs to be overloaded in all child classes
  #
  # @return [Number] id actor id
  ###
  interfaceActorCreate: null

  ###
  # De-registers the actor, clearing the physics and visual bodies.
  # Note that the instance in question should not be used after this is called!
  ###
  destroy: ->
    AJS.info "Destroying actor #{@_id}"
    window.AdefyRE.Actors().destroyActor @_id

  ###
  # Set our render layer. Higher layers render last (on top)
  # Default layer is 0
  #
  # @param [Number] layer
  ###
  setLayer: (layer) ->
    AJS.info "Setting actor (#{@_id}) layer #{layer}"
    window.AdefyRE.Actors().setActorLayer layer, @_id
    @

  ###
  # Set our physics layer. Actors will only collide if they are in the same
  # layer! There are only 16 physics layers (1-16, with default layer 0)
  #
  # Default layer is 0
  #
  # Physics layers persist between physics body creations
  #
  # @param [Number] layer
  ###
  setPhysicsLayer: (layer) ->
    AJS.info "Setting actor (#{@_id}) physics layer #{layer}"
    window.AdefyRE.Actors().setActorPhysicsLayer layer, @_id
    @

  ###
  # @private
  # Provide an alternate set of vertices for our physics body.
  #
  # @param [Array<Number>] verts
  ###
  _setPhysicsVertices: (verts) ->
    AJS.info "Setting actor physics vertices (#{@_id}) [#{verts.length} verts]"
    window.AdefyRE.Actors().setPhysicsVertices JSON.stringify(verts), @_id

  ###
  # @private
  # Set render mode, documented on the interface
  #
  # @param [Number] mode
  ###
  _setRenderMode: (mode) ->
    AJS.info "Setting actor (#{@_id}) render mode #{mode}"
    window.AdefyRE.Actors().setRenderMode mode, @_id

  ###
  # @private
  # Re-creates our actor with our current vertices. This does not modify
  # the vertices, only re-sends them!
  ###
  _updateVertices: ->
    AJS.info "Updating actor (#{@_id}) vertices [#{@_verts.length} verts]"
    window.AdefyRE.Actors().updateVertices JSON.stringify(@_verts), @_id

  ###
  # @private
  # Fetches vertices from the engine
  ###
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
  # Returns the layer of the actor
  #
  # @return [Number] layer
  ###
  getLayer: ->
    AJS.info "Fetching actor layer..."
    @_layer = window.AdefyRE.Actors().getActorLayer @_id

  ###
  # Returns the layer of the actor
  #
  # @return [Number] layer
  ###
  getPhysicsLayer: ->
    AJS.info "Fetching actor physics layer..."
    @_physicsLayer = window.AdefyRE.Actors().getActorPhysicsLayer @_id

  ###
  # Returns the visibility of the actor
  #
  # @return [Boolean] visible
  ###
  getVisible: ->
    AJS.info "Fetching actor visiblity..."

    @_visible = window.AdefyRE.Actors().getActorVisible @_id

  ###
  # Returns the opacity of the object, as stored locally
  #
  # @return [Number] opacity
  ###
  getOpacity: ->
    AJS.info "Fetching actor opacity..."
    @_opacity = window.AdefyRE.Actors().getActorOpacity @_id

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
  # Get actor color
  #
  # @return [AJSColor3] color
  ###
  getColor: ->
    AJS.info "Fetching actor (#{@_id}) color..."
    raw = JSON.parse window.AdefyRE.Actors().getActorColor @_id
    new AJSColor3 raw.r, raw.g, raw.b

  ###
  # Get actor physics
  # @return [Object] physics
  ###
  getPhysics: ->
    AJS.info "Fetching actor (#{@_id}) physics..."
    if @_psyx
      #data = JSON.parse window.AdefyRE.Actors().getActorPhysics @_id

      #@_m = data.mass
      #@_e = data.elasticity
      #@_f = data.friction

      new AJSPhysicsProperties mass: @_m, elasticity: @_e, friction: @_f
    else
      null

  ###
  # Get actor mass
  # @return [Number] mass
  ###
  getMass: ->
    AJS.info "Fetching actor (#{@_id}) mass..."
    #@_m = window.AdefyRE.Actors().getActorMass @_id
    @_m

  ###
  # Get actor elasticity
  # @return [Number] elasticity
  ###
  getElasticity: ->
    AJS.info "Fetching actor (#{@_id}) elasticity..."
    #@_e = window.AdefyRE.Actors().getActorElasticity @_id
    @_e

  ###
  # Get actor friction
  # @return [Number] friction
  ###
  getFriction: ->
    AJS.info "Fetching actor (#{@_id}) friction..."
    #@_f = window.AdefyRE.Actors().getActorFriction @_id
    @_f

  ###
  # Update actor visibility
  #
  # @param [Boolean] visible New visibility
  ###
  setVisible: (@_visible) ->
    AJS.info "Setting actor visiblity (#{@_id}) #{@_visible}"
    window.AdefyRE.Actors().setActorVisible @_visible, @_id
    @

  ###
  # Update actor opacity
  #
  # @param [Number] opacity
  ###
  setOpacity: (@_opacity) ->
    AJS.info "Setting actor opacty (#{@_id}) #{@_opacity}"
    window.AdefyRE.Actors().setActorOpacity @_opacity, @_id
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
  # Set actor color
  #
  # @param [AJSColor3] color
  ###
  setColor: (col) ->
    AJS.info "Setting actor (#{@_id}) color #{JSON.stringify col}"
    @_color = col
    window.AdefyRE.Actors().setActorColor col._r, col._g, col._b, @_id
    @

  ###
  # @param [Texture] texture
  # @return [self]
  ###
  setTexture: (texture) ->
    AJS.info "Setting actor (#{@_id}) texture #{texture}"
    @_texture = texture
    window.AdefyRE.Actors().setActorTexture texture, @_id
    @

  ###
  # @param [Number] x
  # @param [Number] y
  # @return [self]
  ###
  setTextureRepeat: (x, y) ->
    y ||= 1
    AJS.info "Setting actor (#{@_id}) texture repeat (#{x}, #{y})"

    @_textureRepeat =
      x: x
      y: y

    window.AdefyRE.Actors().setActorTextureRepeat x, y, @_id
    @

  ###
  # Get the name of our current texture
  #
  # @return [String] name
  ###
  getTexture: ->
    @_texture

  ###
  # Get Actor's texture repeat
  #
  # @return [Object]
  #   @option [Number] x
  #   @option [Number] y
  ###
  getTextureRepeat: ->
    unless @_textureRepeat
      texRepeat = window.AdefyRE.Actors().getActorTextureRepeat @_id
      @_textureRepeat = JSON.parse texRepeat

    @_textureRepeat

  ###
  # Set actor physics properties
  #
  # @param [Object]
  #   @property [Number] mass
  #   @property [Number] friction
  #   @property [Number] elasticity
  ###
  setPhysics: (object) ->
    if @_psyx
      @enablePsyx object.mass, object.friction, object.elasticity
    @

  ###
  # Set actor mass property
  #
  # @param [Number] mass
  ###
  setMass: (@_m) ->
    @setPhysics mass: @_m
    @

  ###
  # Set actor elasticity property
  #
  # @param [Number] elasticity
  ###
  setElasticity: (@_e) ->
    @setPhysics elasticity: @_e
    @

  ###
  # Set actor friction property
  #
  # @param [Number] friction
  ###
  setFriction: (@_f)->
    @setPhysics friction: @_f
    @

  ###
  # Check if psyx simulation is enabled
  #
  # @return [Boolean] psyx psyx enabled status
  ###
  hasPsyx: -> @_psyx

  ###
  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  ###
  enablePsyx: (@_m, @_f, @_e) ->
    AJS.info "Enabling actor physics (#{@_id}), m: #{@_m}, f: #{@_f}, e: #{@_e}"
    @_psyx = window.AdefyRE.Actors().enableActorPhysics @_m, @_f, @_e, @_id
    @

  ###
  # Destroys the physics body if one exists
  # @return [self]
  ###
  disablePsyx: ->
    AJS.info "Disabling actor (#{@_id}) physics..."
    @_psyx = false if window.AdefyRE.Actors().destroyPhysicsBody @_id
    @

  ###
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
  ###
  attachTexture: (texture, w, h, x, y, angle) ->
    x ||= 0
    y ||= 0
    angle ||= 0

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

  ###
  # Remove attached texture if we have one
  #
  # @return [Boolean] success
  ###
  removeAttachment: ->
    AJS.info "Removing actor (#{@_id}) texture attachment"
    window.AdefyRE.Actors().removeAttachment @_id

  ###
  # Set attached texture visiblity
  #
  # @param [Boolean] visible
  # @return [Boolean] success
  ###
  setAttachmentVisible: (visible) ->
    AJS.info "Setting actor texture attachment visiblity [#{visible}]"
    window.AdefyRE.Actors().setAttachmentVisible visible, @_id

  ###
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
  ###
  mapAnimation: (property, options) ->

    # Since we don't have any properties not already supported by the engine,
    # we return null to signal an error (calls to actors get passed down to us
    # for unrecognized properties)
    null

  ###
  # Checks if the property is one we provide animation mapping for
  #
  # @param [String] property property name
  # @return [Boolean] support
  ###
  canMapAnimation: (property) -> false

  ###
  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [String] property property name
  # @return [Boolean] absolute hope to the gods this is false
  ###
  absoluteMapping: (property) -> false

  ###
  # Schedule a rotation animation
  # If only an angle is provided, the actor is immediately and instantly
  # rotated
  #
  # @param [Number] angle target angle
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  # @return [self]
  ###
  rotate: (angle, duration, start, cp) ->
    if !duration
      @setRotation angle
    else

      AJS.animate @, [["rotation"]], [
        endVal: angle
        controlPoints: cp || []
        duration: duration
        property: "rotation"
        start: start || 0
      ]

    @

  ###
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
  # @return [self]
  ###
  move: (x, y, duration, start, cp) ->

    scale = AJS.getAutoScale()
    if x != null then x *= scale.x
    if y != null then y *= scale.y

    if duration == undefined
      if x == null or x == undefined then x = @getPosition().x
      if y == null or y == undefined then y = @getPosition().y

      @setPosition x: x, y: y
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

  ###
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
  # @return [self]
  ###
  colorTo: (r, g, b, duration, start, cp) ->

    if duration == undefined
      if r == null or r == undefined then r = @getColor().r
      if g == null or g == undefined then g = @getColor().g
      if b == null or b == undefined then b = @getColor().b

      @setColor { _r: r, _g: g, _b: b }

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
