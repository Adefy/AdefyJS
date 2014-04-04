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
