# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
#
# @depend ../util/AJSVector2.coffee
class AJSBaseActor

  # Instantiates the actor in the engine, gets a handle for it
  constructor: (@_verts) ->

    @_psyx = false
    @_color =
      r: 255
      g: 255
      b: 255

    # Sanity checks
    if @_verts == null or @_verts == undefined
      throw "No vertices provided!"

    if @_verts.length < 6
      throw "At least three vertices must be provided"

    # Actual actor creation
    # convert vertices to string form
    jsonVerts = JSON.stringify(@_verts).replace("[", "").replace "]", ""
    @_id = window.AdefyGLI.Actors().createActor jsonVerts

    if @_id == -1
      throw "Failed to create actor!"

    @setPosition new AJSVector2()
    @setRotation 0
    @setColor @_color

  # Modifies the position of the native object, and stores
  # a local copy of it
  #
  # @param [AJSVector2] position New position
  setPosition: (v) ->
    @_position = v
    window.AdefyGLI.Actors().setActorPosition v.x, v.y, @_id

  # Modifies the rotation of the native object, and stores
  # a local copy of it
  #
  # @param [Number] angle New angle in degrees
  # @param [Boolean] radians set in radians, defaults to false
  setRotation: (a, radians) ->
    if radians != true then radians = false
    @_rotation = a
    window.AdefyGLI.Actors().setActorRotation a, @_id, radians

  # Returns the position of the object, as stored locally
  #
  # @return [AJSVector2] Position
  getPosition: ->
    raw = JSON.parse window.AdefyGLI.Actors().getActorPosition @_id
    return new AJSVector2 raw.x, raw.y

  # Returns the rotation of the native object, as stored locally
  #
  # @param [Boolean] radians return in radians, defaults to false
  # @return [Number] Angle in degrees
  getRotation: (radians) ->
    if radians != true then radians = false
    return window.AdefyGLI.Actors().getActorRotation radians, @_id

  # Set actor color
  #
  # @param [AJSColor3] color
  setColor: (col) ->
    window.AdefyGLI.Actors().setActorColor col._r, col._g, col._b, @_id

  # Get actor color
  #
  # @return [AJSColor3] color
  getColor: ->
    raw = JSON.parse window.AdefyGLI.Actors().getActorColor @_id
    return new AJSColor3 raw.r, raw.g, raw.b

  # Check if psyx simulation is enabled
  #
  # @return [Boolean] psyx psyx enabled status
  hasPsyx: -> return @_psyx

  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  enablePsyx: (@_m, @_f, @_e) ->
    @_psyx = window.AdefyGLI.Actors().enableActorPhysics @_m, @_f, @_e, @_id

  # Destroys the physics body if one exists
  disablePsyx: ->
    @_psyx = !(window.AdefyGLI.Actors().destroyPhysicsBody @_id)
