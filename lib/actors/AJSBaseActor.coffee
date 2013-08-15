# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
class AJSBaseActor


  # Instantiates the actor in the engine, gets a handle for it
  constructor: ->

    @setPosition new AJSVector2()
    @setRotation 0

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
