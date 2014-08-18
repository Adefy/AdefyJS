class AJSPhysicsProperties

  ###
  # @param [Object] options
  #   @property [Number] mass
  #   @property [Number] elasticity
  #   @property [Number] friction
  ###
  constructor: (options) ->
    @_mass = options.mass || 0
    @_elasticity = options.elasticity || 0
    @_friction = options.friction || 0

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
