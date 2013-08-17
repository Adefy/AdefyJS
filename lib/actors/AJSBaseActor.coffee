# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
#
# @depend ../util/AJSVector2.coffee
class AJSBaseActor

  # Actor handle
  _id: -1

  _color: null
  _psyx: false

  # Instantiates the actor in the engine, gets a handle for it
  constructor: (@_verts) ->

    # Sanity checks
    if @_verts == null or @_verts == undefined
      throw "No vertices provided!"

    if @_verts.length < 6
      throw "At least three vertices must be provided"

    # Actual actor creation
    @_id = window.AWGLI.Actors().createActor @_verts

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
    window.AWGLI.Actors().setActorPosition v, @_id

  # Modifies the rotation of the native object, and stores
  # a local copy of it
  #
  # @param [Number] angle New angle in degrees
  setRotation: (a) ->
    @_rotation = a
    window.AWGLI.Actors().setActorRotation a, @_id

  # Returns the position of the object, as stored locally
  #
  # @return [AJSVector2] Position
  getPosition: -> @_position

  # Returns the rotation of the native object, as stored locally
  #
  # @return [Number] Angle in degrees
  getRotation: -> @_rotation

  # Enable psyx simulation
  # Set actor color
  #
  # @return [Boolean] success
  enablePsyx: -> false
  # @param [AJSColor3] color
  setColor: (col) ->
    window.AWGLI.Actors().setActorColor col._r, col._g, col._b, @_id

  # Disable psyx simulation
  # Get actor color
  #
  # @return [Boolean] success
  disablePsyx: -> false
  # @return [AJSColor2] color
  getColor: ->
    return window.AWGLI.Actors().getActorColor @_id

  # Check if psyx simulation is enabled
  #
  # @return [Boolean] psyx psyx enabled status
  hasPsyx: -> return @_psyx
