##
## Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved
##

# Base actor class, defines all primitive methods and handles interactions
# with the native engine. This merely represents a handle on an internal actor
#
# @depend ../util/AJSVector2.coffee
class AJSBaseActor

  # Instantiates the actor in the engine, gets a handle for it
  #
  # @param [Array<Number>] verts flat 2d capped array of vertices
  # @param [Number] mass object mass
  # @param [Number] friction object friction
  # @param [Number] elasticity object elasticity
  constructor: (@_verts, mass, friction, elasticity) ->
    param.required @_verts
    @_m = param.optional mass, 0
    @_f = param.optional friction, 0.2
    @_e = param.optional elasticity, 0.3

    if mass < 0 then mass = 0
    if @_verts.length < 6 then throw "At least three vertices must be provided"

    @_psyx = false

    # Actual actor creation
    # convert vertices to string form
    @_id = window.AdefyGLI.Actors().createActor JSON.stringify @_verts

    if @_id == -1
      throw "Failed to create actor!"

    @setPosition new AJSVector2()
    @setRotation 0
    @setColor new AJSColor3 255, 255, 255

  # De-registers the actor, clearing the physics and visual bodies.
  # Note that the instance in question should not be used after this is called!
  destroy: ->
    window.AdefyGLI.Actors().destroyActor @_id

  # Provide an alternate set of vertices for our physics body.
  #
  # @param [Array<Number>] verts
  _setPhysicsVertices: (verts) ->
    window.AdefyGLI.Actors().setPhysicsVertices JSON.stringify(verts), @_id

  # Set render mode, documented on the interface
  #
  # @param [Number] mode
  _setRenderMode: (mode) ->
    window.AdefyGLI.Actors().setRenderMode param.required(mode, [1, 2]), @_id

  # Re-creates our actor with our current vertices. This does not modify
  # the vertices, only re-sends them!
  _updateVertices: ->
    window.AdefyGLI.Actors().updateVertices JSON.stringify(@_verts), @_id

  # Return actor id
  #
  # @return [Number] id
  getId: -> @_id

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
    return window.AdefyGLI.Actors().getActorRotation @_id, radians

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
  hasPsyx: -> @_psyx

  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  enablePsyx: (m, f, e) ->

    # Supply our values if not passed in
    @_m = param.optional m, @_m
    @_f = param.optional f, @_f
    @_e = param.optional e, @_e

    @_psyx = window.AdefyGLI.Actors().enableActorPhysics @_m, @_f, @_e, @_id

  # Destroys the physics body if one exists
  disablePsyx: ->

    if window.AdefyGLI.Actors().destroyPhysicsBody @_id then @_psyx = false
