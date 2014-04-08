# This class implements some helper methods for function param enforcement
# It simply serves to standardize error messages for missing/incomplete
# parameters, and set them to default values if such values are provided.
#
# Since it can be used in every method of every class, it is created static
# and attached to the window object as 'param'
class AJSUtilParam

  # Defines an argument as required. Ensures it is defined and valid
  #
  # @param [Object] p parameter to check
  # @param [Array] valid optional array of valid values the param can have
  @required: (p, valid) ->
    if p == undefined then throw new Error "Required argument missing!"

    # Check for validity if required
    if valid instanceof Array
      isValid = false
      for v in valid
        if p == v
          isValid = true
          break
      if not isValid
        throw new error "Required argument is not of a valid value!"

    # Ship
    p

  # Defines an argument as optional. Sets a default value if it is not
  # supplied, and ensures validity (post-default application)
  #
  # @param [Object] p parameter to check
  # @param [Object] def default value to use if necessary
  # @param [Array] valid optional array of valid values the param can have
  @optional: (p, def, valid) ->
    if p == undefined then p = def

    # Check for validity if required
    if valid instanceof Array
      isValid = false
      for v in valid
        if p == v
          isValid = true
          break
      if not isValid
        throw new error "Required argument is not of a valid value!"

    p

if window.param == undefined then window.param = AJSUtilParam

# 2D Vector class
class AJSVector2

  # Vector constructor, components default to 0
  #
  # @param [Number] x x coordinate
  # @param [Number] y y coordinate
  constructor: (x, y) ->
    @x = x || 0
    @y = y || 0

  # Returns a new negated vector
  #
  # @return [AJSVector2] negated
  negative: -> new AJSVector2 -@x, -@y

  # Returns the sum of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] sum
  add: (v) ->
    if v instanceof AJSVector2
      new AJSVector2 @x + v.x, @y + v.y
    else
      new AJSVector2 @x + v, @y + v

  # Returns the difference between this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] difference
  subtract: (v) ->
    if v instanceof AJSVector2
      new AJSVector2 @x - v.x, @y - v.y
    else
      new AJSVector2 @x - v, @y - v

  # Returns the product of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] product
  multiply: (v) ->
    if v instanceof AJSVector2
      new AJSVector2 @x * v.x, @y * v.y
    else
      new AJSVector2 @x * v, @y * v

  # Returns the quotient of this vector and a vector or scalar
  #
  # @param [AJSVector2, Number] v
  # @return [AJSVector2] quotient
  divide: (v) ->
    if v instanceof AJSVector2
      new AJSVector2 @x / v.x, @y / v.y
    else
      new AJSVector2 @x / v, @y / v

  # Checks the equality of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Boolean] equality
  equals: (v) -> @x == v.x && @y == v.y

  # Returns the dot product of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Number] dotProduct
  dot: (v) -> (@x * v.x) + (@y * v.y)

  # Returns the cross product of this vector and one other
  #
  # @param [AJSVector2] v
  # @return [Number] crossProduct
  cross: (v) -> (@x * v.y) - (@y * v.x)

  # Returns a new vector orthogonal to this one
  #
  # @return [AJSVector2] unit
  ortho: -> new AJSVector2 @y, -@x

  # Returns the length of this vector
  #
  # @return [Number] length
  length: -> Math.sqrt @dot(this)

  # Returns a normalized version of this vector
  #
  # @return [AJSVector2] normalized
  normalize: -> @divide @length()

  # Returns the vector in string double format
  #
  # @return [String] str
  toString: -> "(#{@x}, #{@y})"

# Color class, holds r/g/b components
#
# Serves to provide a consistent structure for defining colors, and offers
# useful float to int (0.0-1.0 to 0-255) conversion functions
class AJSColor3

  ###
  # Sets component values
  #
  # @param [Number] r red component
  # @param [Number] g green component
  # @param [Number] b blue component
  ###
  constructor: (r, g, b) ->

    # @todo Check to see if this is necessary
    @_r = param.optional r, 0
    @_g = param.optional g, 0
    @_b = param.optional b, 0

  ###
  # Returns the red component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] red
  ###
  getR: (asFloat) ->
    if asFloat != true then return @_r
    if @_r == 0
      if asFloat
        return 0.0
      else
        return 0
    @_r / 255

  # Returns the green component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] green
  getG: (asFloat) ->
    if asFloat != true then return @_g
    if @_g == 0
      if asFloat
        return 0.0
      else
        return 0
    @_g / 255

  # Returns the blue component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] blue
  getB: (asFloat) ->
    if asFloat != true then return @_b
    if @_b == 0
      if asFloat
        return 0.0
      else
        return 0
    @_b / 255

  # Set red component, takes a value between 0-255
  #
  # @param [Number] c
  setR: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_r = c

  # Set green component, takes a value between 0-255
  #
  # @param [Number] c
  setG: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_g = c

  # Set blue component, takes a value between 0-255
  #
  # @param [Number] c
  setB: (c) ->
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_b = c

  # Returns the value as a triple
  #
  # @return [String] triple in the form (r, g, b)
  toString: -> "(#{@_r}, #{@_g}, #{@_b})"

class AJSPhysicsProperties

  ###
  # @param [Object] options
  #   @property [Number] mass
  #   @property [Number] elasticity
  #   @property [Number] friction
  ###
  constructor: (options) ->
    @_mass = param.optional options.mass, 0
    @_elasticity = param.optional options.elasticity, 0
    @_friction = param.optional options.friction, 0

  ###
  # Get the mass property
  # @return [Number] mass
  ###
  getMass: -> @_mass

  ###
  # Get the elasticity property
  # @return [Number] elasticity
  ###
  getElasticity: -> @_elasticity

  ###
  # Get the friction property
  # @return [Number] friction
  ###
  getFriction: -> @_friction

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
    window.AdefyRE.Actors().setActorLayer param.required(layer), @_id
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
    window.AdefyRE.Actors().setActorPhysicsLayer param.required(layer), @_id
    @

  ###
  # @private
  # Provide an alternate set of vertices for our physics body.
  #
  # @param [Array<Number>] verts
  ###
  _setPhysicsVertices: (verts) ->
    param.required verts
    AJS.info "Setting actor physics vertices (#{@_id}) [#{verts.length} verts]"
    window.AdefyRE.Actors().setPhysicsVertices JSON.stringify(verts), @_id

  ###
  # @private
  # Set render mode, documented on the interface
  #
  # @param [Number] mode
  ###
  _setRenderMode: (mode) ->
    # always be sure to keep this synced with ARERenderer.renderModes
    renderMode = param.required mode, [0, 1, 2]
    AJS.info "Setting actor (#{@_id}) render mode #{renderMode}"
    window.AdefyRE.Actors().setRenderMode renderMode, @_id

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
    y = param.optional y, 1
    AJS.info "Setting actor (#{@_id}) texture repeat (#{x}, #{y})"

    @_textureRepeat =
      x: x
      y: y

    window.AdefyRE.Actors().setActorTextureRepeat x, y, @_id
    @

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
  enablePsyx: (m, f, e) ->
    @_m = param.optional m, @_m
    @_f = param.optional f, @_f
    @_e = param.optional e, @_e
    AJS.info "Enabling actor physics (#{@_id}) [m: #{m}, f: #{f}, e: #{e}]"

    @_psyx = window.AdefyRE.Actors().enableActorPhysics @_m, @_f, @_e, @_id
    @

  ###
  # Destroys the physics body if one exists
  # @return [self]
  ###
  disablePsyx: ->
    AJS.info "Disabling actor (#{@_id}) physics..."
    if window.AdefyRE.Actors().destroyPhysicsBody @_id then @_psyx = false
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
    param.required visible
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
    param.required angle

    if duration == undefined
      @setRotation angle
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
    options = param.required options
    @_width = param.required options.w
    @_height = param.required options.h

    if @_width <= 0 then throw new Error "Width must be greater than 0"
    if @_height <= 0 then throw new Error "Height must be greater than 0"

    scale = AJS.getAutoScale()

    # Scale square actors by scale midpoint
    if @_width == @_height
      scale = (scale.x + scale.y) / 2
      if options.noScaleW != true then @_width *= scale
      if options.noScaleH != true then @_height *= scale

    # Scale by scale midpoint while maintaining aspect ratio
    else if options.scaleAR == true

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
      if options.noScaleW != true then @_width *= scale.x
      if options.noScaleH != true then @_height *= scale.y

    super null, options.mass, options.friction, options.elasticity

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
    param.required h
    if h <= 0 then throw new Error "New height must be >0 !"
    AJS.info "Setting actor (#{@_id}) height [#{h}]..."

    @_height = h
    window.AdefyRE.Actors().setRectangleActorHeight @_id, h
    @

  # Set width. Enforces minimum and updates actor
  #
  # @param [Number] width new width, > 0
  setWidth: (w) ->
    param.required w
    if w <= 0 then throw new Error "New width must be >0 !"
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
    endW = param.optional endW, null
    endH = param.optional endH, null

    if duration == undefined
      if endW != null then @setWidth endW
      if endH != null then @setHeight endH
      return @
    else

      if start == undefined then start = 0
      if cp == undefined then cp = []

      components = []
      args = []

      if endW != null
        param.required startW

        components.push ["width"]
        args.push
          endVal: endW
          startVal: startW
          controlPoints: cp
          duration: duration
          start: start
          property: "width"

      if endH != null
        param.required startH

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
    options = param.required options
    @_base = param.required options.base
    @_height = param.required options.height

    if @_base <= 0 then throw "Base must be wider than 0"
    if @_height <= 0 then throw "Height must be greater than 0"

    scale = AJS.getAutoScale()
    @_base *= scale.x
    @_height *= scale.y

    @_rebuildVerts()
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
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
    param.required h
    if h <= 0 then throw new Error "New height must be >0 !"

    h *= AJS.getAutoScale().y

    @_height = h
    @_rebuildVerts()
    @_updateVertices()
    @

  # Set base. Enforces minimum, rebuilds vertices, and updates actor
  setBase: (b) ->
    param.required b
    if b <= 0 then throw new Error "New base must be >0 !"

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
    param.required property
    param.required options

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
    if property[0] == "base" or property[0] == "height" then return true
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
    endB = param.optional endB, null
    endH = param.optional endH, null

    if duration == undefined
      if endB != null then @setBase endB
      if endH != null then @setHeight endH
      return @
    else
      if start == undefined then start = 0
      if cp == undefined then cp = []

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
        param.required startB

        components.push ["base"]
        args.push
          endVal: endB
          startVal: startB
          controlPoints: cp
          duration: duration
          start: start
          property: "base"

      if endH != null
        param.required startH

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

# Implements a variable-side polygon actor. The android engine implements
# this natively!
#
# NOTE: On WebGL, the radius and side-count should NEVER be animated at the
#       same time! This is a limitation of our vertice animations; side-count
#       and radius modifications both require a complete vertex-recalculation,
#       and as such are applied as absolute changes instead of relative ones
#       like width/height for AJSRectangle. Make sure your radius and
#       segment-count animations never overlap!
#
# NOTE 2: Even when the radius and side-count are animated seperately, very
#         strange things will happen as a result of the uni-directional line
#         of communication between us and the engine. Animating the radius does
#         not actually update our stored radius value. Sad pandas. The android
#         engine implements a polygon natively, and as such solves this
#         problem. Expect your WebGL exports to behave strangely if you animate
#         both on the same object.
#
# NOTE 3: Things work alright if you animate the radius first, then the seg
#         count. Keep this in mind.
#
## @depend AJSBaseActor.coffee
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
class AJSPolygon extends AJSBaseActor

  # Set up vertices, with the resulting nGon centered around its position
  #
  # @param [Object] options instantiation options
  # @option options [Number] radius
  # @option options [Number] segments
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    param.required options
    @_radius = param.required options.radius
    @_segments = param.required options.segments
    options.psyx = param.optional options.psyx, false

    if @_radius <= 0 then throw "Radius must be larger than 0"
    if @_segments < 3 then throw "Shape must consist of at least 3 segments"

    scale = AJS.getAutoScale()
    @radius *= Math.min scale.x, scale.y

    @_rebuildVerts true

    # Creates and registers our actor, valides physics properties
    super @_verts, options.mass, options.friction, options.elasticity

    # Set attributes if passed in
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

    @_setPhysicsVertices @_verts.slice(0, @_verts.length - 2)
    @_setRenderMode 1

  # Creates the engine actor object
  #
  # @return [Number] id actor id
  interfaceActorCreate: ->
    AJS.info "Creating polygon actor (#{@_verts.length} verts)"
    window.AdefyRE.Actors().createPolygonActor JSON.stringify @_verts

  # @private
  # Private method that rebuilds our vertex array.
  #
  # @param [Boolean] ignorePsyx defaults to false, only true in constructor
  # @param [Boolean] sim signals a simulation, returns verts (default false)
  # @param [Number] segments segment count for simulation
  # @param [Number] radius radius for simulation
  _rebuildVerts: (ignorePsyx, sim, segments, radius) ->
    ignorePsyx = param.optional ignorePsyx, false
    sim = param.optional sim, false
    segments = param.optional segments, @_segments
    radius = param.optional radius, @_radius

    # Build vertices
    # Uses algo from http://slabode.exofire.net/circle_draw.shtml
    x = radius
    y = 0
    theta = (2.0 * 3.1415926) / segments
    tanFactor = Math.tan theta
    radFactor = Math.cos theta

    verts = []

    for i in [0...segments]
      index = i * 2
      verts[index] = x
      verts[index + 1] = y

      tx = -y
      ty = x

      x += tx * tanFactor
      y += ty * tanFactor

      x *= radFactor
      y *= radFactor

    # Cap the shape
    verts.push verts[0]
    verts.push verts[1]

    # Reverse winding!
    _tv = []
    for i in [0...verts.length] by 2
      _tv1 = verts[verts.length - 2 - i]
      _tv2 = verts[verts.length - 1 - i]
      if sim then _tv.push "`#{_tv1}" else _tv.push _tv1
      if sim then _tv.push "`#{_tv2}" else _tv.push _tv2

    verts = _tv

    if not ignorePsyx and not sim

      # NOTE: We need to prepend ourselves with (0, 0) for rendering, but pass
      #       the original vert array as our physical representation!
      @_setPhysicsVertices verts

    if sim then verts.push "`0" else verts.push 0
    if sim then verts.push "`0" else verts.push 0

    if sim then return verts else @_verts = verts

  # Set radius. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] radius new radius, > 0
  setRadius: (r) ->
    param.required r

    if r <= 0 then throw new Error "New radius must be >0 !"

    @_radius = r
    @_rebuildVerts()
    @_updateVertices()
    @

  # Set segments. Enforces minimum, rebuilds vertices, and updates actor
  #
  # @param [Number] segments new segment count, >= 3
  setSegments: (s) ->
    param.required s

    if s < 3 then throw new Error "New segment count must be >=3 !"

    @_segments = s
    @_rebuildVerts()
    @_updateVertices()
    @

  # Get radius
  #
  # @return [Number] radius
  getRadius: -> @_radius

  # Get segment count
  #
  # @return [Number] segments
  getSegments: -> @_segments

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

    # Grab current vertices
    @_fetchVertices()

    # Attaches the appropriate prefix, returns "." for 0
    prefixVal = (val) ->
      if val == 0 then val = "."
      else if val >= 0 then val = "+#{val}"
      else val = "#{val}"
      val

    JSONopts = JSON.stringify options

    # We have two unique properties, radius and segments, both of which
    # must be animated in the same way. We first calculate values at
    # each step, then generate vert deltas accordingly.
    if property[0] == "radius"

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
      bezValues = window.AdefyRE.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # Create delta sets
      for val in bezValues.values

        val = Number val
        delay += Number bezValues.stepTime

        if val != 0
          options.udata.push val
          options.deltas.push @_rebuildVerts true, true, @_segments, val
          options.delays.push delay

      # Update our stored radius on each step
      options.cbStep = (radius) => @_radius = radius

      anim.property = ["vertices"]
      anim.options = options

    else if property[0] == "sides"

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
      bezValues = window.AdefyRE.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # Create delta sets
      for val in bezValues.values

        val = Number val
        delay += Number bezValues.stepTime

        if val != 0
          options.udata.push val
          options.deltas.push @_rebuildVerts true, true, val, @_radius
          options.delays.push delay

      # Update our stored seg count on each step
      options.cbStep = (segments) => @_segments = segments

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    if property[0] == "sides" or property[0] == "radius" then return true
    else return false

  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [Array<String>] property property name
  # @return [Boolean] absolute hope to the gods this is false
  absoluteMapping: (property) -> true

# Implements a circle actor
#
## @depend AJSBaseActor.coffee
## @depend ../util/AJSVector2.coffee
## @depend ../util/AJSColor3.coffee
class AJSCircle extends AJSBaseActor

  # Spawn circle
  #
  # @param [Object] options instantiation options
  # @option options [Number] radius
  # @option options [AJSColor3] color
  # @option options [AJSVec2] position
  # @option options [Number] rotation rotation in degrees
  # @option options [Boolean] psyx enable/disable physics sim
  constructor: (options) ->
    options = param.required options
    @_radius = param.required options.radius

    if @_radius <= 0 then throw new Error "Radius must be greater than 0"

    scale = AJS.getAutoScale()
    @_radius *= (scale.x + scale.y) / 2

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
    @_setRenderMode 1

  # Creates the engine actor object
  #
  # @return [Number] id actor id
  interfaceActorCreate: ->
    AJS.info "Creating circle actor [#{@_radius}]"
    window.AdefyRE.Actors().createCircleActor @_radius, JSON.stringify(@_verts)

  # @private
  # Private method that rebuilds our vertex array.
  #
  # @param [Boolean] sim signals a simulation, returns verts (default false)
  # @param [Number] radius radius for simulation
  _rebuildVerts: (sim, radius) ->
    ignorePsyx = param.optional ignorePsyx, false
    sim = param.optional sim, false
    radius = param.optional radius, @_radius

    segments = 32

    # Build vertices
    # Uses algo from http://slabode.exofire.net/circle_draw.shtml
    x = radius
    y = 0
    theta = (2.0 * 3.1415926) / segments
    tanFactor = Math.tan theta
    radFactor = Math.cos theta

    verts = []

    for i in [0...segments]
      index = i * 2
      verts[index] = x
      verts[index + 1] = y

      tx = -y
      ty = x

      x += tx * tanFactor
      y += ty * tanFactor

      x *= radFactor
      y *= radFactor

    # Cap the shape
    verts.push verts[0]
    verts.push verts[1]

    # Reverse winding!
    _tv = []
    for i in [0...verts.length] by 2
      _tv1 = verts[verts.length - 2 - i]
      _tv2 = verts[verts.length - 1 - i]
      if sim then _tv.push "`#{_tv1}" else _tv.push _tv1
      if sim then _tv.push "`#{_tv2}" else _tv.push _tv2

    verts = _tv

    if sim then verts.push "`0" else verts.push 0
    if sim then verts.push "`0" else verts.push 0

    if sim then return verts else @_verts = verts

  # Fetches radius from engine
  #
  # @return [Number] radius
  getRadius: ->
    AJS.info "Fetching actor (#{@_id}) radius..."
    @_radius = window.AdefyRE.Actors().getCircleActorRadius @_id

  # Set radius and rebuild vertices. Enforces minimum and updates actor
  #
  # @param [Number] radius new radius, > 0
  setRadius: (radius) ->
    param.required radius
    if radius <= 0 then throw new Error "New radius must be >0 !"
    AJS.info "Setting actor (#{@_id}) radius [#{radius}]..."

    @_radius = radius
    @_rebuildVerts()
    @_updateVertices()
    window.AdefyRE.Actors().setCircleActorRadius @_id, radius
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
    param.required property
    param.required options

    anim = {}

    # Attaches the appropriate prefix, returns "." for 0
    prefixVal = (val) ->
      if val == 0 then val = "."
      else if val >= 0 then val = "+#{val}"
      else val = "#{val}"
      val

    # Our only unique property is our radius. We first calculate values at each
    # step, then generate vert deltas accordingly.
    if property[0] == "radius"

      AJS.info "Pre-calculating Bezier animation values for #{JSONopts}"
      bezValues = window.AdefyRE.Animations().preCalculateBez JSONopts
      bezValues = JSON.parse bezValues
      delay = 0
      options.deltas = []
      options.delays = []
      options.udata = []

      # Create delta sets
      for val in bezValues.values

        val = Number val
        delay += Number bezValues.stepTime

        if val != 0
          options.udata.push val
          options.deltas.push @_rebuildVerts true, val
          options.delays.push delay

      # Update our stored radius on each step
      options.cbStep = (radius) => @_radius = radius

      anim.property = ["vertices"]
      anim.options = options

    else return super property, options

    anim

  # Checks if the property is one we provide animation mapping for
  #
  # @param [Array<String>] property property name
  # @return [Boolean] support
  canMapAnimation: (property) ->
    if property[0] == "radius" then return true
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

## Top-level file, used by concat_in_order
##
## As part of the build process, grunt concats all of our coffee sources in a
## dependency-aware manner. Deps are described at the top of each file, with this
## essentially serving as the root node in the dep tree.
##
## @depend util/AJSUtilParam.coffee
## @depend actors/AJSRectangle.coffee
## @depend actors/AJSTriangle.coffee
## @depend actors/AJSPolygon.coffee
## @depend actors/AJSCircle.coffee

# AJS main class, instantiates the engine and provides access to common methods
# Should never be instantiated, all methods are static.
class AJS

  @Version:
    MAJOR: 1
    MINOR: 0
    PATCH: 1
    BUILD: null
    STRING: "1.0.1"

  # Pointer to the engine, initalized (once) in init()
  # @private
  @_engine: null

  # Self-explanatory
  # @private
  @_initialized: false

  # Log level, between 0 and 4
  # @private
  @_logLevel: 2

  @_scaleX: 1
  @_scaleY: 1

  # AJS is a singleton, do not instantiate! Constructor throws an error.
  constructor: -> throw new Error "AJS shouldn't be instantiated!"

  # Set display scale, internal method used by our backend to scale creatives
  # for the target device display
  #
  # @param [Number] scaleX
  # @param [Number] scaleY
  # @private
  @setAutoScale: (scaleX, scaleY) ->
    AJS._scaleX = scaleX
    AJS._scaleY = scaleY

  # Fetch auto scale, used internally by AJS components
  #
  # @return [Object] scale scale object with x and y values
  # @private
  @getAutoScale: -> x: AJS._scaleX, y: AJS._scaleY

  # Initializes the engine with a specific screen size and ad length
  # The actual ad needs to be passed in as a method
  #
  # @param [Method] ad ad to execute
  # @param [Number] width
  # @param [Number] height
  # @param [String] canvasID optional canvas ID for WebGL engine
  @init: (ad, width, height, canvasID) ->
    param.required ad
    param.required width
    param.required height

    # Should never happen, so don't fail quietly
    if AJS._initialized
      return @error "AJS can only be initialized once"
    else AJS._initialized = true

    # Clear all existing timeouts
    lastTimeout = setTimeout (->), 1
    clearTimeout i for i in [0...lastTimeout]

    @_engine = window.AdefyRE.Engine()

    # Set render mode for the browser rendering engine (WebGL if we can)
    if @_engine.setRendererMode != undefined
      if !window.WebGLRenderingContext
        @_engine.setRendererMode 1
        @info "Dropping to canvas render mode"
      else
        @_engine.setRendererMode 2
        @info "Proceeding with WebGL render mode"

    # Initialize!
    @_engine.initialize width, height, ((agl) -> ad agl), 2, canvasID
    @info "Initialized AJS"

  # Override AJS and engine log level
  #
  # @param [Number] level 0-4
  @setLogLevel: (level) ->
    param.required level, [0, 1, 2, 3, 4]
    @info "Setting log level to #{level}"

    window.AdefyRE.Engine().setLogLevel level
    @_logLevel = level
    @

  # Base logging statement, issues the log message with an optional prefix
  # if the current log level allows it
  #
  # @param [Number] level
  # @param [String] message
  # @param [String] prefix optional prefix
  @log: (level, message, prefix) ->
    if prefix == undefined then prefix = ""

    # Return early if not at a suiteable level, or level is 0
    if level > @_logLevel or level == 0 or @_logLevel == 0 then return

    # Specialized console output
    if level == 1 and console.error != undefined
      if console.error then console.error "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 2 and console.warn != undefined
      if console.warn then console.warn "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 3 and console.debug != undefined
      if console.debug then console.debug "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level == 4 and console.info != undefined
      if console.info then console.info "#{prefix}#{message}"
      else console.log "#{prefix}#{message}"
    else if level > 4 and me.tags[level] != undefined
        console.log "#{prefix}#{message}"
      else
        console.log message

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 2
  #
  # @param [String] message
  @warning: (message) ->
    @log 2, message, "[WARNING] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 1
  #
  # @param [String] message
  @error: (message) ->
    @log 1, message, "[ERROR] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 4
  #
  # @param [String] message
  @info: (message) ->
    @log 4, message, "[INFO] "
    @

  # Shortcut for logging a warning. Nothing is logged if the log level is not
  # at least 3
  #
  # @param [String] message
  @debug: (message) ->
    @log 3, message, "[DEBUG] "
    @

  # Set camera position. Leaving out a component leaves it unmodified
  #
  # @param [Number] x
  # @param [Number] y
  @setCameraPosition: (x, y) ->
    param.required x
    param.required y

    @info "Setting camera position (#{x}, #{y})"

    x *= AJS._scaleX
    y *= AJS._scaleY

    window.AdefyRE.Engine().setCameraPosition x, y
    @

  # Fetch camera position. Returns an object with x, y keys
  #
  # @return [Object] pos
  @getCameraPosition: ->
    @info "Fetching camera position..."

    pos = JSON.parse window.AdefyRE.Engine().getCameraPosition()
    pos.x /= AJS._scaleX
    pos.y /= AJS.scaleY
    pos

  # Set renderer clear color, component values between 0 and 255
  #
  # @param [Number] r
  # @param [Number] g
  # @param [Number] b
  @setClearColor: (r, g, b) ->
    param.required r
    param.required g
    param.required b
    @info "Setting clear color to (#{r}, #{g}, #{b})"

    window.AdefyRE.Engine().setClearColor r, g, b

  # Returns the renderer clear color as an AJSColor3
  #
  # @return [AJSColor3] clearcol
  @getClearColor: ->
    @info "Fetching clear color..."

    col = JSON.parse window.AdefyRE.Engine().getClearColor()
    new AJSColor3 col.r, col.g, col.b

  @_syntheticMap:

    "width": ""

  # Animates actor properties. Pass in either a single property, or an array
  # of property definitions. The same goes for the animation options.
  #
  # Composite properties (r of color rgb) must be animated individually, and
  # specified as an array of [property, composite].
  #
  # @example Animating the Y coordinate of an actor
  #   animate actor, ["position", "y"], { ... }
  #
  # @example Animating the rotation of an actor
  #   animate actor, "rotation", { ... }
  #
  # @example Animating multiple properties
  #   animate actor, [
  #     ["position", "x"]
  #     ["position", "y"]
  #     "rotation"
  #   ], [
  #     { ... }
  #     { ... }
  #     { ... }
  #   ]
  #
  # When passing an animation start time, (< 0) signifies immediately, 0 no
  # automatic start, and (> 0) a start delay in ms from now.
  #
  # Start and fps are only set on animations if they do not already exist!
  #
  # @param [AJSBaseActor] actor actor to effect
  # @param [Array, Array<Array>] properties properties to animate
  # @param [Object, Array<Object>] options animation options
  # @param [Number] start optional, animation start time (applies to all)
  # @param [Number] fps optional animation rate, defaults to 30
  @animate: (actor, properties, options, start, fps) ->
    param.required actor
    param.required properties
    param.required options
    start = param.optional start, 0
    fps = param.optional fps, 30

    Animations = window.AdefyRE.Animations()

    # Helpful below
    _registerDelayedMap = (actor, property, options, time) ->

      setTimeout ->
        result = AJS.mapAnimation actor, property, options
        property = JSON.stringify result.property
        options = JSON.stringify result.options
        Animations.animate actor.getId(), property, options
      , time

    for i in [0...properties.length]
      if options[i].fps == undefined then options[i].fps = fps
      if options[i].start == undefined then options[i].start = start

      # Check if the property is directly supported by the engine. If not, we
      # need to map it to the corresponding property and options structure our
      # engine requires to execute it.
      if not Animations.canAnimate properties[i][0]

        # Check if we can map the property
        if not actor.canMapAnimation properties[i]
          throw new Error "Unrecognized property! #{properties[i]}"

        # Check if an absolute change is required
        if actor.absoluteMapping properties[i]
          timeout = options[i].start
          options[i].start = -1
          _registerDelayedMap actor, properties[i], options[i], timeout

        else
          result = AJS.mapAnimation actor, properties[i], options[i]
          properties[i] = JSON.stringify result.property
          options[i] = JSON.stringify result.options
          Animations.animate actor.getId(), properties[i], options[i]

      # Animate normally if we can
      else
        options[i] = JSON.stringify options[i]
        properties[i] = JSON.stringify properties[i]
        Animations.animate actor.getId(), properties[i], options[i]

  # Generates an engine-supported animation for the specified property and
  # options. Use this when animating a property not directly supported by
  # the engine.
  #
  # Note that AJS.animate() uses this internally upon encountering an
  # unsupported property!
  #
  # @param [AJSBaseActor] actor actor animation applies to
  # @param [String] property property name
  # @param [Object] options animation options
  # @return [Object] animation object containing "property" and "options" keys
  @mapAnimation: (actor, property, options) ->
    param.required actor
    param.required property
    param.required options

    # We actually pass this down to the actor. Evil, eh? Muahahahaha
    actor.mapAnimation property, options

  # Load package.json source; used only by the WebGL engine, in turn loads
  # textures relative to our current path.
  #
  # @param [String] json valid package.json source (can also be an object)
  # @param [Method] cb callback to call after load (textures)
  @loadManifest: (json, cb) ->
    param.required json

    # If the json is not a string, then stringify it
    if typeof json != "string" then json = JSON.stringify json

    cb = param.optional cb, ->
    @info "Loading manifest #{JSON.stringify json}"

    window.AdefyRE.Engine().loadManifest json, cb

  # Create new rectangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] w width
  # @param [Number] h height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createRectangleActor: (x, y, w, h, r, g, b, extraOptions) ->
    param.required x
    param.required y
    param.required w
    param.required h

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      w: w
      h: h

    for key, val of extraOptions
      options[key] = val

    new AJSRectangle options

  # Create a new square actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] l side length
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createSquareActor: (x, y, l, r, g, b, extraOptions) ->
    param.required x
    param.required y
    param.required l

    AJS.createRectangleActor x, y, l, l, r, g, b,

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createCircleActor: (x, y, radius, r, g, b, extraOptions) ->
    param.required x
    param.required y
    param.required radius

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      radius: radius

    for key, val of extraOptions
      options[key] = val

    new AJSCircle options

  # Create a new circle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] radius
  # @param [Number] segments
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createPolygonActor: (x, y, radius, segments, r, g, b, extraOptions) ->
    param.required x
    param.required y
    param.required radius
    param.required segments

    options =
      position: { x: x, y: y }
      color: { r: r, g: g, b: b }
      radius: radius
      segments: segments

    for key, val of extraOptions
      options[key] = val

    new AJSPolygon options

  # Create a new triangle actor
  #
  # @param [Number] x x spawn coord
  # @param [Number] y y spawn coord
  # @param [Number] base base width
  # @param [Number] height height
  # @param [Number] r red color component
  # @param [Number] g green color component
  # @param [Number] b blue color component
  # @param [Object] extraOptions optional options hash to pass to actor
  @createTriangleActor: (x, y, base, height, r, g, b, extraOptions) ->
    param.required x
    param.required y
    param.required base
    param.required height

    if r == undefined then r = Math.floor (Math.random() * 255)
    if g == undefined then g = Math.floor (Math.random() * 255)
    if b == undefined then b = Math.floor (Math.random() * 255)

    options =
     position: { x: x, y: y }
     color: { r: r, g: g, b: b }
     base: base
     height: height

    for key, val of extraOptions
      options[key] = val

    new AJSTriangle options

  # Get texture size by name
  #
  # @param [String] name
  # @return [Object] size
  @getTextureSize: (name) ->
    param.required name
    @info "Fetching texture size by name (#{name})"

    window.AdefyRE.Engine().getTextureSize name

  # Designate the rectangluar region defining the remind me later button
  #
  # @param [Number] x
  # @param [Number] y
  # @param [Number] w
  # @param [Number] h
  @setRemindMeLaterButton: (x, y, w, h) ->
    window.AdefyRE.Engine().setRemindMeButton x, y, w, h
