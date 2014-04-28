var AJS, AJSBaseActor, AJSCircle, AJSColor3, AJSPhysicsProperties, AJSPolygon, AJSRectangle, AJSTriangle, AJSUtilParam, AJSVector2,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

AJSUtilParam = (function() {
  function AJSUtilParam() {}

  AJSUtilParam.required = function(p, valid) {
    var isValid, v, _i, _len;
    if (p === void 0) {
      throw new Error("Required argument missing!");
    }
    if (valid instanceof Array) {
      isValid = false;
      for (_i = 0, _len = valid.length; _i < _len; _i++) {
        v = valid[_i];
        if (p === v) {
          isValid = true;
          break;
        }
      }
      if (!isValid) {
        throw new error("Required argument is not of a valid value!");
      }
    }
    return p;
  };

  AJSUtilParam.optional = function(p, def, valid) {
    var isValid, v, _i, _len;
    if (p === void 0) {
      p = def;
    }
    if (valid instanceof Array) {
      isValid = false;
      for (_i = 0, _len = valid.length; _i < _len; _i++) {
        v = valid[_i];
        if (p === v) {
          isValid = true;
          break;
        }
      }
      if (!isValid) {
        throw new error("Required argument is not of a valid value!");
      }
    }
    return p;
  };

  return AJSUtilParam;

})();

if (window.param === void 0) {
  window.param = AJSUtilParam;
}

AJSVector2 = (function() {
  function AJSVector2(x, y) {
    this.x = x || 0;
    this.y = y || 0;
  }

  AJSVector2.prototype.negative = function() {
    return new AJSVector2(-this.x, -this.y);
  };

  AJSVector2.prototype.add = function(v) {
    if (v instanceof AJSVector2) {
      return new AJSVector2(this.x + v.x, this.y + v.y);
    } else {
      return new AJSVector2(this.x + v, this.y + v);
    }
  };

  AJSVector2.prototype.subtract = function(v) {
    if (v instanceof AJSVector2) {
      return new AJSVector2(this.x - v.x, this.y - v.y);
    } else {
      return new AJSVector2(this.x - v, this.y - v);
    }
  };

  AJSVector2.prototype.multiply = function(v) {
    if (v instanceof AJSVector2) {
      return new AJSVector2(this.x * v.x, this.y * v.y);
    } else {
      return new AJSVector2(this.x * v, this.y * v);
    }
  };

  AJSVector2.prototype.divide = function(v) {
    if (v instanceof AJSVector2) {
      return new AJSVector2(this.x / v.x, this.y / v.y);
    } else {
      return new AJSVector2(this.x / v, this.y / v);
    }
  };

  AJSVector2.prototype.equals = function(v) {
    return this.x === v.x && this.y === v.y;
  };

  AJSVector2.prototype.dot = function(v) {
    return (this.x * v.x) + (this.y * v.y);
  };

  AJSVector2.prototype.cross = function(v) {
    return (this.x * v.y) - (this.y * v.x);
  };

  AJSVector2.prototype.ortho = function() {
    return new AJSVector2(this.y, -this.x);
  };

  AJSVector2.prototype.length = function() {
    return Math.sqrt(this.dot(this));
  };

  AJSVector2.prototype.normalize = function() {
    return this.divide(this.length());
  };

  AJSVector2.prototype.toString = function() {
    return "(" + this.x + ", " + this.y + ")";
  };

  return AJSVector2;

})();

AJSColor3 = (function() {
  /*
  # Sets component values
  #
  # @param [Number] r red component
  # @param [Number] g green component
  # @param [Number] b blue component
  */

  function AJSColor3(r, g, b) {
    this._r = param.optional(r, 0);
    this._g = param.optional(g, 0);
    this._b = param.optional(b, 0);
  }

  /*
  # Returns the red component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] red
  */


  AJSColor3.prototype.getR = function(asFloat) {
    if (asFloat !== true) {
      return this._r;
    }
    if (this._r === 0) {
      if (asFloat) {
        return 0.0;
      } else {
        return 0;
      }
    }
    return this._r / 255;
  };

  AJSColor3.prototype.getG = function(asFloat) {
    if (asFloat !== true) {
      return this._g;
    }
    if (this._g === 0) {
      if (asFloat) {
        return 0.0;
      } else {
        return 0;
      }
    }
    return this._g / 255;
  };

  AJSColor3.prototype.getB = function(asFloat) {
    if (asFloat !== true) {
      return this._b;
    }
    if (this._b === 0) {
      if (asFloat) {
        return 0.0;
      } else {
        return 0;
      }
    }
    return this._b / 255;
  };

  AJSColor3.prototype.setR = function(c) {
    if (c < 0) {
      c = 0;
    }
    if (c > 255) {
      c = 255;
    }
    return this._r = c;
  };

  AJSColor3.prototype.setG = function(c) {
    if (c < 0) {
      c = 0;
    }
    if (c > 255) {
      c = 255;
    }
    return this._g = c;
  };

  AJSColor3.prototype.setB = function(c) {
    if (c < 0) {
      c = 0;
    }
    if (c > 255) {
      c = 255;
    }
    return this._b = c;
  };

  AJSColor3.prototype.toString = function() {
    return "(" + this._r + ", " + this._g + ", " + this._b + ")";
  };

  return AJSColor3;

})();

AJSPhysicsProperties = (function() {
  /*
  # @param [Object] options
  #   @property [Number] mass
  #   @property [Number] elasticity
  #   @property [Number] friction
  */

  function AJSPhysicsProperties(options) {
    this._mass = param.optional(options.mass, 0);
    this._elasticity = param.optional(options.elasticity, 0);
    this._friction = param.optional(options.friction, 0);
  }

  /*
  # Get the mass property
  # @return [Number] mass
  */


  AJSPhysicsProperties.prototype.getMass = function() {
    return this._mass;
  };

  /*
  # Get the elasticity property
  # @return [Number] elasticity
  */


  AJSPhysicsProperties.prototype.getElasticity = function() {
    return this._elasticity;
  };

  /*
  # Get the friction property
  # @return [Number] friction
  */


  AJSPhysicsProperties.prototype.getFriction = function() {
    return this._friction;
  };

  return AJSPhysicsProperties;

})();

AJSBaseActor = (function() {
  /*
  # Instantiates the actor in the engine, gets a handle for it
  #
  # @param [Array<Number>] verts flat 2d capped array of vertices
  # @param [Number] mass object mass
  # @param [Number] friction object friction
  # @param [Number] elasticity object elasticity
  */

  function AJSBaseActor(_verts, mass, friction, elasticity) {
    this._verts = _verts;
    this._verts = param.optional(this._verts);
    this._m = param.optional(mass, 0);
    this._f = param.optional(friction, 0.2);
    this._e = param.optional(elasticity, 0.3);
    if (this.interfaceActorCreate === null) {
      throw new Error("Actor class doesn't provide interface actor creation!");
    }
    if (mass < 0) {
      mass = 0;
    }
    if (this._verts !== void 0 && this._verts !== null && this._verts.length < 6) {
      throw new Error("At least three vertices must be provided");
    }
    this._psyx = false;
    this._id = this.interfaceActorCreate();
    if (this._id === -1) {
      throw new Error("Failed to create actor!");
    }
    this.setPosition(new AJSVector2());
    this.setRotation(0);
    this.setColor(new AJSColor3(255, 255, 255));
  }

  /*
  # Creates the engine actor object
  #
  # This method needs to be overloaded in all child classes
  #
  # @return [Number] id actor id
  */


  AJSBaseActor.prototype.interfaceActorCreate = null;

  /*
  # De-registers the actor, clearing the physics and visual bodies.
  # Note that the instance in question should not be used after this is called!
  */


  AJSBaseActor.prototype.destroy = function() {
    AJS.info("Destroying actor " + this._id);
    return window.AdefyRE.Actors().destroyActor(this._id);
  };

  /*
  # Set our render layer. Higher layers render last (on top)
  # Default layer is 0
  #
  # @param [Number] layer
  */


  AJSBaseActor.prototype.setLayer = function(layer) {
    AJS.info("Setting actor (" + this._id + ") layer " + layer);
    window.AdefyRE.Actors().setActorLayer(param.required(layer), this._id);
    return this;
  };

  /*
  # Set our physics layer. Actors will only collide if they are in the same
  # layer! There are only 16 physics layers (1-16, with default layer 0)
  #
  # Default layer is 0
  #
  # Physics layers persist between physics body creations
  #
  # @param [Number] layer
  */


  AJSBaseActor.prototype.setPhysicsLayer = function(layer) {
    AJS.info("Setting actor (" + this._id + ") physics layer " + layer);
    window.AdefyRE.Actors().setActorPhysicsLayer(param.required(layer), this._id);
    return this;
  };

  /*
  # @private
  # Provide an alternate set of vertices for our physics body.
  #
  # @param [Array<Number>] verts
  */


  AJSBaseActor.prototype._setPhysicsVertices = function(verts) {
    param.required(verts);
    AJS.info("Setting actor physics vertices (" + this._id + ") [" + verts.length + " verts]");
    return window.AdefyRE.Actors().setPhysicsVertices(JSON.stringify(verts), this._id);
  };

  /*
  # @private
  # Set render mode, documented on the interface
  #
  # @param [Number] mode
  */


  AJSBaseActor.prototype._setRenderMode = function(mode) {
    var renderMode;
    renderMode = param.required(mode, [0, 1, 2]);
    AJS.info("Setting actor (" + this._id + ") render mode " + renderMode);
    return window.AdefyRE.Actors().setRenderMode(renderMode, this._id);
  };

  /*
  # @private
  # Re-creates our actor with our current vertices. This does not modify
  # the vertices, only re-sends them!
  */


  AJSBaseActor.prototype._updateVertices = function() {
    AJS.info("Updating actor (" + this._id + ") vertices [" + this._verts.length + " verts]");
    return window.AdefyRE.Actors().updateVertices(JSON.stringify(this._verts), this._id);
  };

  /*
  # @private
  # Fetches vertices from the engine
  */


  AJSBaseActor.prototype._fetchVertices = function() {
    var e, res;
    AJS.info("Fetching actor vertices (" + this._id + ")...");
    res = window.AdefyRE.Actors().getVertices(this._id);
    if (res.length > 0) {
      try {
        this._verts = JSON.parse(res);
      } catch (_error) {
        e = _error;
        console.error("Invalid verts [" + e + "]: " + res);
      }
    }
    return this._verts;
  };

  /*
  # Return actor id
  #
  # @return [Number] id
  */


  AJSBaseActor.prototype.getId = function() {
    return this._id;
  };

  /*
  # Returns the layer of the actor
  #
  # @return [Number] layer
  */


  AJSBaseActor.prototype.getLayer = function() {
    AJS.info("Fetching actor layer...");
    return this._layer = window.AdefyRE.Actors().getActorLayer(this._id);
  };

  /*
  # Returns the layer of the actor
  #
  # @return [Number] layer
  */


  AJSBaseActor.prototype.getPhysicsLayer = function() {
    AJS.info("Fetching actor physics layer...");
    return this._physicsLayer = window.AdefyRE.Actors().getActorPhysicsLayer(this._id);
  };

  /*
  # Returns the visibility of the actor
  #
  # @return [Boolean] visible
  */


  AJSBaseActor.prototype.getVisible = function() {
    AJS.info("Fetching actor visiblity...");
    return this._visible = window.AdefyRE.Actors().getActorVisible(this._id);
  };

  /*
  # Returns the opacity of the object, as stored locally
  #
  # @return [Number] opacity
  */


  AJSBaseActor.prototype.getOpacity = function() {
    AJS.info("Fetching actor opacity...");
    return this._opacity = window.AdefyRE.Actors().getActorOpacity(this._id);
  };

  /*
  # Returns the position of the object, as stored locally
  #
  # @return [AJSVector2] Position
  */


  AJSBaseActor.prototype.getPosition = function() {
    var raw, scale;
    AJS.info("Fetching actor position...");
    raw = JSON.parse(window.AdefyRE.Actors().getActorPosition(this._id));
    scale = AJS.getAutoScale();
    raw.x /= scale.x;
    raw.y /= scale.y;
    return new AJSVector2(raw.x, raw.y);
  };

  /*
  # Returns the rotation of the native object, as stored locally
  #
  # @param [Boolean] radians return in radians, defaults to false
  # @return [Number] Angle in degrees
  */


  AJSBaseActor.prototype.getRotation = function(radians) {
    AJS.info("Fetching actor rotation [radians: " + radians + "]...");
    if (radians !== true) {
      radians = false;
    }
    return window.AdefyRE.Actors().getActorRotation(this._id, radians);
  };

  /*
  # Get actor color
  #
  # @return [AJSColor3] color
  */


  AJSBaseActor.prototype.getColor = function() {
    var raw;
    AJS.info("Fetching actor (" + this._id + ") color...");
    raw = JSON.parse(window.AdefyRE.Actors().getActorColor(this._id));
    return new AJSColor3(raw.r, raw.g, raw.b);
  };

  /*
  # Get actor physics
  # @return [Object] physics
  */


  AJSBaseActor.prototype.getPhysics = function() {
    AJS.info("Fetching actor (" + this._id + ") physics...");
    if (this._psyx) {
      return new AJSPhysicsProperties({
        mass: this._m,
        elasticity: this._e,
        friction: this._f
      });
    } else {
      return null;
    }
  };

  /*
  # Get actor mass
  # @return [Number] mass
  */


  AJSBaseActor.prototype.getMass = function() {
    AJS.info("Fetching actor (" + this._id + ") mass...");
    return this._m;
  };

  /*
  # Get actor elasticity
  # @return [Number] elasticity
  */


  AJSBaseActor.prototype.getElasticity = function() {
    AJS.info("Fetching actor (" + this._id + ") elasticity...");
    return this._e;
  };

  /*
  # Get actor friction
  # @return [Number] friction
  */


  AJSBaseActor.prototype.getFriction = function() {
    AJS.info("Fetching actor (" + this._id + ") friction...");
    return this._f;
  };

  /*
  # Update actor visibility
  #
  # @param [Boolean] visible New visibility
  */


  AJSBaseActor.prototype.setVisible = function(_visible) {
    this._visible = _visible;
    AJS.info("Setting actor visiblity (" + this._id + ") " + this._visible);
    window.AdefyRE.Actors().setActorVisible(this._visible, this._id);
    return this;
  };

  /*
  # Update actor opacity
  #
  # @param [Number] opacity
  */


  AJSBaseActor.prototype.setOpacity = function(_opacity) {
    this._opacity = _opacity;
    AJS.info("Setting actor opacty (" + this._id + ") " + this._opacity);
    window.AdefyRE.Actors().setActorOpacity(this._opacity, this._id);
    return this;
  };

  /*
  # Modifies the position of the native object, and stores
  # a local copy of it
  #
  # @param [AJSVector2] position New position
  */


  AJSBaseActor.prototype.setPosition = function(v) {
    var scale;
    AJS.info("Setting actor position (" + this._id + ") " + (JSON.stringify(v)));
    scale = AJS.getAutoScale();
    v.x *= scale.x;
    v.y *= scale.y;
    this._position = v;
    window.AdefyRE.Actors().setActorPosition(v.x, v.y, this._id);
    return this;
  };

  /*
  # Modifies the rotation of the native object, and stores
  # a local copy of it
  #
  # @param [Number] angle New angle in degrees
  # @param [Boolean] radians set in radians, defaults to false
  */


  AJSBaseActor.prototype.setRotation = function(a, radians) {
    AJS.info("Setting actor (" + this._id + ") rotation " + a + " [radians: " + radians + "]");
    if (radians !== true) {
      radians = false;
    }
    this._rotation = a;
    window.AdefyRE.Actors().setActorRotation(a, this._id, radians);
    return this;
  };

  /*
  # Set actor color
  #
  # @param [AJSColor3] color
  */


  AJSBaseActor.prototype.setColor = function(col) {
    AJS.info("Setting actor (" + this._id + ") color " + (JSON.stringify(col)));
    this._color = col;
    window.AdefyRE.Actors().setActorColor(col._r, col._g, col._b, this._id);
    return this;
  };

  /*
  # @param [Texture] texture
  # @return [self]
  */


  AJSBaseActor.prototype.setTexture = function(texture) {
    AJS.info("Setting actor (" + this._id + ") texture " + texture);
    this._texture = texture;
    window.AdefyRE.Actors().setActorTexture(texture, this._id);
    return this;
  };

  /*
  # @param [Number] x
  # @param [Number] y
  # @return [self]
  */


  AJSBaseActor.prototype.setTextureRepeat = function(x, y) {
    y = param.optional(y, 1);
    AJS.info("Setting actor (" + this._id + ") texture repeat (" + x + ", " + y + ")");
    this._textureRepeat = {
      x: x,
      y: y
    };
    window.AdefyRE.Actors().setActorTextureRepeat(x, y, this._id);
    return this;
  };

  /*
  # Get the name of our current texture
  #
  # @return [String] name
  */


  AJSBaseActor.prototype.getTexture = function() {
    return this._texture;
  };

  /*
  # Get Actor's texture repeat
  #
  # @return [Object]
  #   @option [Number] x
  #   @option [Number] y
  */


  AJSBaseActor.prototype.getTextureRepeat = function() {
    var texRepeat;
    if (!this._textureRepeat) {
      texRepeat = window.AdefyRE.Actors().getActorTextureRepeat(this._id);
      this._textureRepeat = JSON.parse(texRepeat);
    }
    return this._textureRepeat;
  };

  /*
  # Set actor physics properties
  #
  # @param [Object]
  #   @property [Number] mass
  #   @property [Number] friction
  #   @property [Number] elasticity
  */


  AJSBaseActor.prototype.setPhysics = function(object) {
    if (this._psyx) {
      this.enablePsyx(object.mass, object.friction, object.elasticity);
    }
    return this;
  };

  /*
  # Set actor mass property
  #
  # @param [Number] mass
  */


  AJSBaseActor.prototype.setMass = function(_m) {
    this._m = _m;
    this.setPhysics({
      mass: this._m
    });
    return this;
  };

  /*
  # Set actor elasticity property
  #
  # @param [Number] elasticity
  */


  AJSBaseActor.prototype.setElasticity = function(_e) {
    this._e = _e;
    this.setPhysics({
      elasticity: this._e
    });
    return this;
  };

  /*
  # Set actor friction property
  #
  # @param [Number] friction
  */


  AJSBaseActor.prototype.setFriction = function(_f) {
    this._f = _f;
    this.setPhysics({
      friction: this._f
    });
    return this;
  };

  /*
  # Check if psyx simulation is enabled
  #
  # @return [Boolean] psyx psyx enabled status
  */


  AJSBaseActor.prototype.hasPsyx = function() {
    return this._psyx;
  };

  /*
  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  */


  AJSBaseActor.prototype.enablePsyx = function(m, f, e) {
    this._m = param.optional(m, this._m);
    this._f = param.optional(f, this._f);
    this._e = param.optional(e, this._e);
    AJS.info("Enabling actor physics (" + this._id + ") [m: " + m + ", f: " + f + ", e: " + e + "]");
    this._psyx = window.AdefyRE.Actors().enableActorPhysics(this._m, this._f, this._e, this._id);
    return this;
  };

  /*
  # Destroys the physics body if one exists
  # @return [self]
  */


  AJSBaseActor.prototype.disablePsyx = function() {
    AJS.info("Disabling actor (" + this._id + ") physics...");
    if (window.AdefyRE.Actors().destroyPhysicsBody(this._id)) {
      this._psyx = false;
    }
    return this;
  };

  /*
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
  */


  AJSBaseActor.prototype.attachTexture = function(texture, w, h, x, y, angle) {
    var scale;
    param.required(texture);
    param.required(w);
    param.required(h);
    x = param.optional(x, 0);
    y = param.optional(y, 0);
    angle = param.optional(angle, 0);
    AJS.info("Attaching texture " + texture + " " + w + "x" + h + " to actor (" + this._id + ")");
    scale = AJS.getAutoScale();
    x *= scale.x;
    y *= scale.y;
    if (w === h) {
      scale = (scale.x + scale.y) / 2;
      w *= scale;
      h *= scale;
    } else {
      w *= scale.x;
      h *= scale.y;
    }
    return window.AdefyRE.Actors().attachTexture(texture, w, h, x, y, angle, this._id);
  };

  /*
  # Remove attached texture if we have one
  #
  # @return [Boolean] success
  */


  AJSBaseActor.prototype.removeAttachment = function() {
    AJS.info("Removing actor (" + this._id + ") texture attachment");
    return window.AdefyRE.Actors().removeAttachment(this._id);
  };

  /*
  # Set attached texture visiblity
  #
  # @param [Boolean] visible
  # @return [Boolean] success
  */


  AJSBaseActor.prototype.setAttachmentVisible = function(visible) {
    param.required(visible);
    AJS.info("Setting actor texture attachment visiblity [" + visible + "]");
    return window.AdefyRE.Actors().setAttachmentVisible(visible, this._id);
  };

  /*
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
  */


  AJSBaseActor.prototype.mapAnimation = function(property, options) {
    return null;
  };

  /*
  # Checks if the property is one we provide animation mapping for
  #
  # @param [String] property property name
  # @return [Boolean] support
  */


  AJSBaseActor.prototype.canMapAnimation = function(property) {
    return false;
  };

  /*
  # Checks if the mapping for the property requires an absolute modification
  # to the actor. Multiple absolute modifications should never be performed
  # at the same time!
  #
  # NOTE: This returns false for properties we don't recognize
  #
  # @param [String] property property name
  # @return [Boolean] absolute hope to the gods this is false
  */


  AJSBaseActor.prototype.absoluteMapping = function(property) {
    return false;
  };

  /*
  # Schedule a rotation animation
  # If only an angle is provided, the actor is immediately and instantly
  # rotated
  #
  # @param [Number] angle target angle
  # @param [Number] duration animation duration
  # @param [Number] start animation start, default 0
  # @param [Array<Object>] cp animation control points
  # @return [self]
  */


  AJSBaseActor.prototype.rotate = function(angle, duration, start, cp) {
    param.required(angle);
    if (duration === void 0) {
      this.setRotation(angle);
    } else {
      if (start === void 0) {
        start = 0;
      }
      if (cp === void 0) {
        cp = [];
      }
      AJS.animate(this, [["rotation"]], [
        {
          endVal: angle,
          controlPoints: cp,
          duration: duration,
          property: "rotation",
          start: start
        }
      ]);
    }
    return this;
  };

  /*
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
  */


  AJSBaseActor.prototype.move = function(x, y, duration, start, cp) {
    var point, scale, _i, _len;
    scale = AJS.getAutoScale();
    if (x !== null) {
      x *= scale.x;
    }
    if (y !== null) {
      y *= scale.y;
    }
    if (duration === void 0) {
      if (x === null || x === void 0) {
        x = this.getPosition().x;
      }
      if (y === null || y === void 0) {
        y = this.getPosition().y;
      }
      this.setPosition({
        x: x,
        y: y
      });
    } else {
      if (start === void 0) {
        start = 0;
      }
      if (cp === void 0) {
        cp = [];
      }
      for (_i = 0, _len = cp.length; _i < _len; _i++) {
        point = cp[_i];
        if (point.y > 1) {
          if (x === null) {
            point.y *= scale.y;
          } else if (y === null) {
            point.y *= scale.x;
          } else {
            point.y *= (scale.x + scale.y) / 2;
          }
        }
      }
      if (x !== null) {
        AJS.animate(this, [["position", "x"]], [
          {
            endVal: x,
            controlPoints: cp,
            duration: duration,
            start: start
          }
        ]);
      }
      if (y !== null) {
        AJS.animate(this, [["position", "y"]], [
          {
            endVal: y,
            controlPoints: cp,
            duration: duration,
            start: start
          }
        ]);
      }
    }
    return this;
  };

  /*
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
  */


  AJSBaseActor.prototype.colorTo = function(r, g, b, duration, start, cp) {
    if (duration === void 0) {
      if (r === null || r === void 0) {
        r = this.getColor().r;
      }
      if (g === null || g === void 0) {
        g = this.getColor().g;
      }
      if (b === null || b === void 0) {
        b = this.getColor().b;
      }
      this.setColor({
        _r: r,
        _g: g,
        _b: b
      });
    } else {
      if (start === void 0) {
        start = 0;
      }
      if (cp === void 0) {
        cp = [];
      }
      if (r !== null) {
        AJS.animate(this, [["color", "r"]], [
          {
            endVal: r,
            controlPoints: cp,
            duration: duration,
            start: start
          }
        ]);
      }
      if (g !== null) {
        AJS.animate(this, [["color", "g"]], [
          {
            endVal: g,
            controlPoints: cp,
            duration: duration,
            start: start
          }
        ]);
      }
      if (b !== null) {
        AJS.animate(this, [["color", "b"]], [
          {
            endVal: b,
            controlPoints: cp,
            duration: duration,
            start: start
          }
        ]);
      }
    }
    return this;
  };

  return AJSBaseActor;

})();

AJSRectangle = (function(_super) {
  __extends(AJSRectangle, _super);

  function AJSRectangle(options) {
    var ar, scale;
    options = param.required(options);
    this._width = param.required(options.w);
    this._height = param.required(options.h);
    if (this._width <= 0) {
      throw new Error("Width must be greater than 0");
    }
    if (this._height <= 0) {
      throw new Error("Height must be greater than 0");
    }
    scale = AJS.getAutoScale();
    if (this._width === this._height) {
      scale = (scale.x + scale.y) / 2;
      if (options.noScaleW !== true) {
        this._width *= scale;
      }
      if (options.noScaleH !== true) {
        this._height *= scale;
      }
    } else if (options.scaleAR === true) {
      ar = this._width / this._height;
      scale = (scale.x + scale.y) / 2;
      if (this._width > this._height) {
        this._height *= scale;
        this._width = ar * this._height;
      } else {
        this._width *= scale;
        this._height = this._width / ar;
      }
    } else {
      if (options.noScaleW !== true) {
        this._width *= scale.x;
      }
      if (options.noScaleH !== true) {
        this._height *= scale.y;
      }
    }
    AJSRectangle.__super__.constructor.call(this, null, options.mass, options.friction, options.elasticity);
    if (options.color instanceof AJSColor3) {
      this.setColor(options.color);
    } else if (options.color !== void 0 && options.color.r !== void 0) {
      this.setColor(new AJSColor3(options.color.r, options.color.g, options.color.b));
    }
    if (options.position instanceof AJSVector2) {
      this.setPosition(options.position);
    } else if (options.position !== void 0 && options.position.x !== void 0) {
      this.setPosition(new AJSVector2(options.position.x, options.position.y));
    }
    if (typeof options.rotation === "number") {
      this.setRotation(options.rotation);
    }
    if (options.psyx) {
      this.enablePsyx();
    }
  }

  AJSRectangle.prototype.interfaceActorCreate = function() {
    AJS.info("Creating rectangle actor (" + this._width + "x" + this._height + ")");
    return window.AdefyRE.Actors().createRectangleActor(this._width, this._height);
  };

  AJSRectangle.prototype.getWidth = function() {
    AJS.info("Fetching actor (" + this._id + ") width...");
    return this._width = window.AdefyRE.Actors().getRectangleActorWidth(this._id);
  };

  AJSRectangle.prototype.getHeight = function() {
    AJS.info("Fetching actor (" + this._id + ") height...");
    return this._height = window.AdefyRE.Actors().getRectangleActorHeight(this._id);
  };

  AJSRectangle.prototype.setHeight = function(h) {
    param.required(h);
    if (h <= 0) {
      throw new Error("New height must be >0 !");
    }
    AJS.info("Setting actor (" + this._id + ") height [" + h + "]...");
    this._height = h;
    window.AdefyRE.Actors().setRectangleActorHeight(this._id, h);
    return this;
  };

  AJSRectangle.prototype.setWidth = function(w) {
    param.required(w);
    if (w <= 0) {
      throw new Error("New width must be >0 !");
    }
    AJS.info("Setting actor (" + this._id + ") width [" + w + "]...");
    this._width = w;
    window.AdefyRE.Actors().setRectangleActorWidth(this._id, w);
    return this;
  };

  AJSRectangle.prototype.mapAnimation = function(property, options) {
    var JSONopts, anim, bezValues, delay, prefixVal, sum, val, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;
    param.required(property);
    param.required(options);
    anim = {};
    prefixVal = function(val) {
      if (val === 0) {
        val = ".";
      } else if (val >= 0) {
        val = "+" + val;
      } else {
        val = "" + val;
      }
      return val;
    };
    if (property[0] === "width") {
      options.startVal /= 2;
      options.endVal /= 2;
      JSONopts = JSON.stringify(options);
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      sum = Number(bezValues.values[0]);
      _ref = bezValues.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        val = Number(val);
        val -= sum;
        sum += val;
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.deltas.push([prefixVal(-val), ".", prefixVal(-val), ".", prefixVal(val), ".", prefixVal(val), ".", prefixVal(-val), "."]);
          options.udata.push(val * 2);
          options.delays.push(delay);
        }
      }
      options.cbStep = function(width) {
        return _this._width += width * 2;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else if (property[0] === "height") {
      options.startVal /= 2;
      options.endVal /= 2;
      JSONopts = JSON.stringify(options);
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      sum = Number(bezValues.values[0]);
      _ref1 = bezValues.values;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        val = _ref1[_j];
        val = Number(val);
        val -= sum;
        sum += val;
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.deltas.push([".", prefixVal(-val), ".", prefixVal(val), ".", prefixVal(val), ".", prefixVal(-val), ".", prefixVal(-val)]);
          options.udata.push(val);
          options.delays.push(delay);
        }
      }
      options.cbStep = function(height) {
        return _this._height += height * 2;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else {
      return AJSRectangle.__super__.mapAnimation.call(this, property, options);
    }
    return anim;
  };

  AJSRectangle.prototype.canMapAnimation = function(property) {
    if (property[0] === "height" || property[0] === "width") {
      return true;
    } else {
      return false;
    }
  };

  AJSRectangle.prototype.absoluteMapping = function(property) {
    return false;
  };

  AJSRectangle.prototype.resize = function(endW, endH, startW, startH, duration, start, cp) {
    var args, components;
    endW = param.optional(endW, null);
    endH = param.optional(endH, null);
    if (duration === void 0) {
      if (endW !== null) {
        this.setWidth(endW);
      }
      if (endH !== null) {
        this.setHeight(endH);
      }
      return this;
    } else {
      if (start === void 0) {
        start = 0;
      }
      if (cp === void 0) {
        cp = [];
      }
      components = [];
      args = [];
      if (endW !== null) {
        param.required(startW);
        components.push(["width"]);
        args.push({
          endVal: endW,
          startVal: startW,
          controlPoints: cp,
          duration: duration,
          start: start,
          property: "width"
        });
      }
      if (endH !== null) {
        param.required(startH);
        components.push(["height"]);
        args.push({
          endVal: endH,
          startVal: startH,
          controlPoints: cp,
          duration: duration,
          start: start,
          property: "height"
        });
      }
      if (components.length > 0) {
        AJS.animate(this, components, args);
      }
      return this;
    }
  };

  return AJSRectangle;

})(AJSBaseActor);

AJSTriangle = (function(_super) {
  __extends(AJSTriangle, _super);

  function AJSTriangle(options) {
    var scale;
    options = param.required(options);
    this._base = param.required(options.base);
    this._height = param.required(options.height);
    if (this._base <= 0) {
      throw "Base must be wider than 0";
    }
    if (this._height <= 0) {
      throw "Height must be greater than 0";
    }
    scale = AJS.getAutoScale();
    this._base *= scale.x;
    this._height *= scale.y;
    this._rebuildVerts();
    AJSTriangle.__super__.constructor.call(this, this._verts, options.mass, options.friction, options.elasticity);
    if (options.color instanceof AJSColor3) {
      this.setColor(options.color);
    } else if (options.color !== void 0 && options.color.r !== void 0) {
      this.setColor(new AJSColor3(options.color.r, options.color.g, options.color.b));
    }
    if (options.position instanceof AJSVector2) {
      this.setPosition(options.position);
    } else if (options.position !== void 0 && options.position.x !== void 0) {
      this.setPosition(new AJSVector2(options.position.x, options.position.y));
    }
    if (typeof options.rotation === "number") {
      this.setRotation(options.rotation);
    }
    if (options.psyx) {
      this.enablePsyx();
    }
  }

  AJSTriangle.prototype.interfaceActorCreate = function() {
    AJS.info("Creating triangle actor...");
    return window.AdefyRE.Actors().createRawActor(JSON.stringify(this._verts));
  };

  AJSTriangle.prototype.getBase = function() {
    this._fetchVertices();
    return this._base = this._verts[4] * 2;
  };

  AJSTriangle.prototype.getHeight = function() {
    this._fetchVertices();
    return this._height = this._verts[3] * 2;
  };

  AJSTriangle.prototype._rebuildVerts = function() {
    var hB, hH;
    hB = this._base / 2.0;
    hH = this._height / 2.0;
    this._verts = [8];
    this._verts[0] = -hB;
    this._verts[1] = -hH;
    this._verts[2] = 0;
    this._verts[3] = hH;
    this._verts[4] = hB;
    this._verts[5] = -hH;
    this._verts[6] = -hB;
    return this._verts[7] = -hH;
  };

  AJSTriangle.prototype.setHeight = function(h) {
    param.required(h);
    if (h <= 0) {
      throw new Error("New height must be >0 !");
    }
    h *= AJS.getAutoScale().y;
    this._height = h;
    this._rebuildVerts();
    this._updateVertices();
    return this;
  };

  AJSTriangle.prototype.setBase = function(b) {
    param.required(b);
    if (b <= 0) {
      throw new Error("New base must be >0 !");
    }
    b *= AJS.getAutoScale().x;
    this._base = b;
    this._rebuildVerts();
    this._updateVertices();
    return this;
  };

  AJSTriangle.prototype.mapAnimation = function(property, options) {
    var JSONopts, anim, bezValues, delay, prefixVal, scale, sum, val, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;
    param.required(property);
    param.required(options);
    scale = AJS.getAutoScale();
    anim = {};
    prefixVal = function(val) {
      if (val === 0) {
        val = ".";
      } else if (val >= 0) {
        val = "+" + val;
      } else {
        val = "" + val;
      }
      return val;
    };
    if (property[0] === "height") {
      options.startVal /= 2;
      options.endVal /= 2;
      options.startVal *= scale.y;
      options.endVal *= scale.y;
      JSONopts = JSON.stringify(options);
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      sum = Number(bezValues.values[0]);
      _ref = bezValues.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        val = Number(val);
        val -= sum;
        sum += val;
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.deltas.push([".", prefixVal(-val), ".", prefixVal(val), ".", prefixVal(-val), ".", prefixVal(-val)]);
          options.udata.push(val);
          options.delays.push(delay);
        }
      }
      options.cbStep = function(height) {
        return _this._height += height * 2;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else if (property[0] === "base") {
      options.startVal /= 2;
      options.endVal /= 2;
      options.startVal *= scale.x;
      options.endVal *= scale.x;
      JSONopts = JSON.stringify(options);
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      sum = Number(bezValues.values[0]);
      _ref1 = bezValues.values;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        val = _ref1[_j];
        val = Number(val);
        val -= sum;
        sum += val;
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.deltas.push([prefixVal(-val), ".", ".", ".", prefixVal(val), ".", prefixVal(-val), "."]);
          options.udata.push(val);
          options.delays.push(delay);
        }
      }
      options.cbStep = function(base) {
        return _this._base += base * 2;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else {
      return AJSTriangle.__super__.mapAnimation.call(this, property, options);
    }
    return anim;
  };

  AJSTriangle.prototype.canMapAnimation = function(property) {
    if (property[0] === "base" || property[0] === "height") {
      return true;
    } else {
      return false;
    }
  };

  AJSTriangle.prototype.absoluteMapping = function(property) {
    return false;
  };

  AJSTriangle.prototype.resize = function(endB, endH, startB, startH, duration, start, cp) {
    var args, components, scale;
    endB = param.optional(endB, null);
    endH = param.optional(endH, null);
    if (duration === void 0) {
      if (endB !== null) {
        this.setBase(endB);
      }
      if (endH !== null) {
        this.setHeight(endH);
      }
      return this;
    } else {
      if (start === void 0) {
        start = 0;
      }
      if (cp === void 0) {
        cp = [];
      }
      scale = AJS.getAutoScale();
      endB *= scale.x;
      endH *= scale.y;
      startB *= scale.x;
      startH *= scale.y;
      components = [];
      args = [];
      if (endB !== null) {
        param.required(startB);
        components.push(["base"]);
        args.push({
          endVal: endB,
          startVal: startB,
          controlPoints: cp,
          duration: duration,
          start: start,
          property: "base"
        });
      }
      if (endH !== null) {
        param.required(startH);
        components.push(["height"]);
        args.push({
          endVal: endH,
          startVal: startH,
          controlPoints: cp,
          duration: duration,
          start: start,
          property: "height"
        });
      }
      if (components.length > 0) {
        AJS.animate(this, components, args);
      }
      return this;
    }
  };

  return AJSTriangle;

})(AJSBaseActor);

AJSPolygon = (function(_super) {
  __extends(AJSPolygon, _super);

  function AJSPolygon(options) {
    var scale;
    param.required(options);
    this._radius = param.required(options.radius);
    this._segments = param.required(options.segments);
    options.psyx = param.optional(options.psyx, false);
    if (this._radius <= 0) {
      throw "Radius must be larger than 0";
    }
    if (this._segments < 3) {
      throw "Shape must consist of at least 3 segments";
    }
    scale = AJS.getAutoScale();
    this.radius *= Math.min(scale.x, scale.y);
    this._rebuildVerts(true);
    AJSPolygon.__super__.constructor.call(this, this._verts, options.mass, options.friction, options.elasticity);
    if (options.color instanceof AJSColor3) {
      this.setColor(options.color);
    } else if (options.color !== void 0 && options.color.r !== void 0) {
      this.setColor(new AJSColor3(options.color.r, options.color.g, options.color.b));
    }
    if (options.position instanceof AJSVector2) {
      this.setPosition(options.position);
    } else if (options.position !== void 0 && options.position.x !== void 0) {
      this.setPosition(new AJSVector2(options.position.x, options.position.y));
    }
    if (typeof options.rotation === "number") {
      this.setRotation(options.rotation);
    }
    if (options.psyx) {
      this.enablePsyx();
    }
    this._setPhysicsVertices(this._verts.slice(0, this._verts.length - 2));
    this._setRenderMode(1);
  }

  AJSPolygon.prototype.interfaceActorCreate = function() {
    AJS.info("Creating polygon actor (" + this._verts.length + " verts)");
    return window.AdefyRE.Actors().createPolygonActor(JSON.stringify(this._verts));
  };

  AJSPolygon.prototype._rebuildVerts = function(ignorePsyx, sim, segments, radius) {
    var i, index, radFactor, tanFactor, theta, tx, ty, verts, x, y, _i, _j, _ref, _tv, _tv1, _tv2;
    ignorePsyx = param.optional(ignorePsyx, false);
    sim = param.optional(sim, false);
    segments = param.optional(segments, this._segments);
    radius = param.optional(radius, this._radius);
    x = radius;
    y = 0;
    theta = (2.0 * 3.1415926) / segments;
    tanFactor = Math.tan(theta);
    radFactor = Math.cos(theta);
    verts = [];
    for (i = _i = 0; 0 <= segments ? _i < segments : _i > segments; i = 0 <= segments ? ++_i : --_i) {
      index = i * 2;
      verts[index] = x;
      verts[index + 1] = y;
      tx = -y;
      ty = x;
      x += tx * tanFactor;
      y += ty * tanFactor;
      x *= radFactor;
      y *= radFactor;
    }
    verts.push(verts[0]);
    verts.push(verts[1]);
    _tv = [];
    for (i = _j = 0, _ref = verts.length; _j < _ref; i = _j += 2) {
      _tv1 = verts[verts.length - 2 - i];
      _tv2 = verts[verts.length - 1 - i];
      if (sim) {
        _tv.push("`" + _tv1);
      } else {
        _tv.push(_tv1);
      }
      if (sim) {
        _tv.push("`" + _tv2);
      } else {
        _tv.push(_tv2);
      }
    }
    verts = _tv;
    if (!ignorePsyx && !sim) {
      this._setPhysicsVertices(verts);
    }
    if (sim) {
      verts.push("`0");
    } else {
      verts.push(0);
    }
    if (sim) {
      verts.push("`0");
    } else {
      verts.push(0);
    }
    if (sim) {
      return verts;
    } else {
      return this._verts = verts;
    }
  };

  AJSPolygon.prototype.setRadius = function(r) {
    param.required(r);
    if (r <= 0) {
      throw new Error("New radius must be >0 !");
    }
    this._radius = r;
    this._rebuildVerts();
    this._updateVertices();
    return this;
  };

  AJSPolygon.prototype.setSegments = function(s) {
    param.required(s);
    if (s < 3) {
      throw new Error("New segment count must be >=3 !");
    }
    this._segments = s;
    this._rebuildVerts();
    this._updateVertices();
    return this;
  };

  AJSPolygon.prototype.getRadius = function() {
    return this._radius;
  };

  AJSPolygon.prototype.getSegments = function() {
    return this._segments;
  };

  AJSPolygon.prototype.mapAnimation = function(property, options) {
    var JSONopts, anim, bezValues, delay, prefixVal, val, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;
    param.required(property);
    param.required(options);
    anim = {};
    this._fetchVertices();
    prefixVal = function(val) {
      if (val === 0) {
        val = ".";
      } else if (val >= 0) {
        val = "+" + val;
      } else {
        val = "" + val;
      }
      return val;
    };
    JSONopts = JSON.stringify(options);
    if (property[0] === "radius") {
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      _ref = bezValues.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        val = Number(val);
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.udata.push(val);
          options.deltas.push(this._rebuildVerts(true, true, this._segments, val));
          options.delays.push(delay);
        }
      }
      options.cbStep = function(radius) {
        return _this._radius = radius;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else if (property[0] === "sides") {
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      _ref1 = bezValues.values;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        val = _ref1[_j];
        val = Number(val);
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.udata.push(val);
          options.deltas.push(this._rebuildVerts(true, true, val, this._radius));
          options.delays.push(delay);
        }
      }
      options.cbStep = function(segments) {
        return _this._segments = segments;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else {
      return AJSPolygon.__super__.mapAnimation.call(this, property, options);
    }
    return anim;
  };

  AJSPolygon.prototype.canMapAnimation = function(property) {
    if (property[0] === "sides" || property[0] === "radius") {
      return true;
    } else {
      return false;
    }
  };

  AJSPolygon.prototype.absoluteMapping = function(property) {
    return true;
  };

  return AJSPolygon;

})(AJSBaseActor);

AJSCircle = (function(_super) {
  __extends(AJSCircle, _super);

  function AJSCircle(options) {
    var scale;
    options = param.required(options);
    this._radius = param.required(options.radius);
    if (this._radius <= 0) {
      throw new Error("Radius must be greater than 0");
    }
    scale = AJS.getAutoScale();
    this._radius *= (scale.x + scale.y) / 2;
    this._rebuildVerts();
    AJSCircle.__super__.constructor.call(this, this._verts, options.mass, options.friction, options.elasticity);
    if (options.color instanceof AJSColor3) {
      this.setColor(options.color);
    } else if (options.color !== void 0 && options.color.r !== void 0) {
      this.setColor(new AJSColor3(options.color.r, options.color.g, options.color.b));
    }
    if (options.position instanceof AJSVector2) {
      this.setPosition(options.position);
    } else if (options.position !== void 0 && options.position.x !== void 0) {
      this.setPosition(new AJSVector2(options.position.x, options.position.y));
    }
    if (typeof options.rotation === "number") {
      this.setRotation(options.rotation);
    }
    if (options.psyx) {
      this.enablePsyx();
    }
    this._setRenderMode(1);
  }

  AJSCircle.prototype.interfaceActorCreate = function() {
    AJS.info("Creating circle actor [" + this._radius + "]");
    return window.AdefyRE.Actors().createCircleActor(this._radius, JSON.stringify(this._verts));
  };

  AJSCircle.prototype._rebuildVerts = function(sim, radius) {
    var i, ignorePsyx, index, radFactor, segments, tanFactor, theta, tx, ty, verts, x, y, _i, _j, _ref, _tv, _tv1, _tv2;
    ignorePsyx = param.optional(ignorePsyx, false);
    sim = param.optional(sim, false);
    radius = param.optional(radius, this._radius);
    segments = 32;
    x = radius;
    y = 0;
    theta = (2.0 * 3.1415926) / segments;
    tanFactor = Math.tan(theta);
    radFactor = Math.cos(theta);
    verts = [];
    for (i = _i = 0; 0 <= segments ? _i < segments : _i > segments; i = 0 <= segments ? ++_i : --_i) {
      index = i * 2;
      verts[index] = x;
      verts[index + 1] = y;
      tx = -y;
      ty = x;
      x += tx * tanFactor;
      y += ty * tanFactor;
      x *= radFactor;
      y *= radFactor;
    }
    verts.push(verts[0]);
    verts.push(verts[1]);
    _tv = [];
    for (i = _j = 0, _ref = verts.length; _j < _ref; i = _j += 2) {
      _tv1 = verts[verts.length - 2 - i];
      _tv2 = verts[verts.length - 1 - i];
      if (sim) {
        _tv.push("`" + _tv1);
      } else {
        _tv.push(_tv1);
      }
      if (sim) {
        _tv.push("`" + _tv2);
      } else {
        _tv.push(_tv2);
      }
    }
    verts = _tv;
    if (sim) {
      verts.push("`0");
    } else {
      verts.push(0);
    }
    if (sim) {
      verts.push("`0");
    } else {
      verts.push(0);
    }
    if (sim) {
      return verts;
    } else {
      return this._verts = verts;
    }
  };

  AJSCircle.prototype.getRadius = function() {
    AJS.info("Fetching actor (" + this._id + ") radius...");
    return this._radius = window.AdefyRE.Actors().getCircleActorRadius(this._id);
  };

  AJSCircle.prototype.setRadius = function(radius) {
    param.required(radius);
    if (radius <= 0) {
      throw new Error("New radius must be >0 !");
    }
    AJS.info("Setting actor (" + this._id + ") radius [" + radius + "]...");
    this._radius = radius;
    this._rebuildVerts();
    this._updateVertices();
    window.AdefyRE.Actors().setCircleActorRadius(this._id, radius);
    return this;
  };

  AJSCircle.prototype.mapAnimation = function(property, options) {
    var anim, bezValues, delay, prefixVal, val, _i, _len, _ref,
      _this = this;
    param.required(property);
    param.required(options);
    anim = {};
    prefixVal = function(val) {
      if (val === 0) {
        val = ".";
      } else if (val >= 0) {
        val = "+" + val;
      } else {
        val = "" + val;
      }
      return val;
    };
    if (property[0] === "radius") {
      AJS.info("Pre-calculating Bezier animation values for " + JSONopts);
      bezValues = window.AdefyRE.Animations().preCalculateBez(JSONopts);
      bezValues = JSON.parse(bezValues);
      delay = 0;
      options.deltas = [];
      options.delays = [];
      options.udata = [];
      _ref = bezValues.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        val = Number(val);
        delay += Number(bezValues.stepTime);
        if (val !== 0) {
          options.udata.push(val);
          options.deltas.push(this._rebuildVerts(true, val));
          options.delays.push(delay);
        }
      }
      options.cbStep = function(radius) {
        return _this._radius = radius;
      };
      anim.property = ["vertices"];
      anim.options = options;
    } else {
      return AJSCircle.__super__.mapAnimation.call(this, property, options);
    }
    return anim;
  };

  AJSCircle.prototype.canMapAnimation = function(property) {
    if (property[0] === "radius") {
      return true;
    } else {
      return false;
    }
  };

  AJSCircle.prototype.absoluteMapping = function(property) {
    return false;
  };

  return AJSCircle;

})(AJSBaseActor);

AJS = (function() {
  AJS.Version = {
    MAJOR: 1,
    MINOR: 0,
    PATCH: 9,
    BUILD: null,
    STRING: "1.0.9"
  };

  AJS._engine = null;

  AJS._initialized = false;

  AJS._logLevel = 2;

  AJS._scaleX = 1;

  AJS._scaleY = 1;

  function AJS() {
    throw new Error("AJS shouldn't be instantiated!");
  }

  AJS.setAutoScale = function(scaleX, scaleY) {
    AJS._scaleX = scaleX;
    return AJS._scaleY = scaleY;
  };

  AJS.getAutoScale = function() {
    return {
      x: AJS._scaleX,
      y: AJS._scaleY
    };
  };

  AJS.init = function(ad, width, height, canvasID) {
    var i, lastTimeout, _i;
    param.required(ad);
    param.required(width);
    param.required(height);
    if (AJS._initialized) {
      return this.error("AJS can only be initialized once");
    } else {
      AJS._initialized = true;
    }
    lastTimeout = setTimeout((function() {}), 1);
    for (i = _i = 0; 0 <= lastTimeout ? _i < lastTimeout : _i > lastTimeout; i = 0 <= lastTimeout ? ++_i : --_i) {
      clearTimeout(i);
    }
    this._engine = window.AdefyRE.Engine();
    if (this._engine.setRendererMode !== void 0) {
      if (!window.WebGLRenderingContext) {
        this._engine.setRendererMode(1);
        this.info("Dropping to canvas render mode");
      } else {
        this._engine.setRendererMode(2);
        this.info("Proceeding with WebGL render mode");
      }
    }
    this._engine.initialize(width, height, (function(agl) {
      return ad(agl);
    }), 2, canvasID);
    return this.info("Initialized AJS");
  };

  AJS.setLogLevel = function(level) {
    param.required(level, [0, 1, 2, 3, 4]);
    this.info("Setting log level to " + level);
    window.AdefyRE.Engine().setLogLevel(level);
    this._logLevel = level;
    return this;
  };

  AJS.log = function(level, message, prefix) {
    if (prefix === void 0) {
      prefix = "";
    }
    if (level > this._logLevel || level === 0 || this._logLevel === 0) {
      return;
    }
    if (level === 1 && console.error !== void 0) {
      if (console.error) {
        return console.error("" + prefix + message);
      } else {
        return console.log("" + prefix + message);
      }
    } else if (level === 2 && console.warn !== void 0) {
      if (console.warn) {
        return console.warn("" + prefix + message);
      } else {
        return console.log("" + prefix + message);
      }
    } else if (level === 3 && console.debug !== void 0) {
      if (console.debug) {
        return console.debug("" + prefix + message);
      } else {
        return console.log("" + prefix + message);
      }
    } else if (level === 4 && console.info !== void 0) {
      if (console.info) {
        return console.info("" + prefix + message);
      } else {
        return console.log("" + prefix + message);
      }
    } else if (level > 4 && me.tags[level] !== void 0) {
      return console.log("" + prefix + message);
    } else {
      return console.log(message);
    }
  };

  AJS.warning = function(message) {
    this.log(2, message, "[WARNING] ");
    return this;
  };

  AJS.error = function(message) {
    this.log(1, message, "[ERROR] ");
    return this;
  };

  AJS.info = function(message) {
    this.log(4, message, "[INFO] ");
    return this;
  };

  AJS.debug = function(message) {
    this.log(3, message, "[DEBUG] ");
    return this;
  };

  AJS.setCameraPosition = function(x, y) {
    param.required(x);
    param.required(y);
    this.info("Setting camera position (" + x + ", " + y + ")");
    x *= AJS._scaleX;
    y *= AJS._scaleY;
    window.AdefyRE.Engine().setCameraPosition(x, y);
    return this;
  };

  AJS.getCameraPosition = function() {
    var pos;
    this.info("Fetching camera position...");
    pos = JSON.parse(window.AdefyRE.Engine().getCameraPosition());
    pos.x /= AJS._scaleX;
    pos.y /= AJS.scaleY;
    return pos;
  };

  AJS.setClearColor = function(r, g, b) {
    param.required(r);
    param.required(g);
    param.required(b);
    this.info("Setting clear color to (" + r + ", " + g + ", " + b + ")");
    return window.AdefyRE.Engine().setClearColor(r, g, b);
  };

  AJS.getClearColor = function() {
    var col;
    this.info("Fetching clear color...");
    col = JSON.parse(window.AdefyRE.Engine().getClearColor());
    return new AJSColor3(col.r, col.g, col.b);
  };

  AJS._syntheticMap = {
    "width": ""
  };

  AJS.animate = function(actor, properties, options, start, fps) {
    var Animations, i, result, timeout, _i, _ref, _registerDelayedMap, _results;
    param.required(actor);
    param.required(properties);
    param.required(options);
    start = param.optional(start, 0);
    fps = param.optional(fps, 30);
    Animations = window.AdefyRE.Animations();
    _registerDelayedMap = function(actor, property, options, time) {
      return setTimeout(function() {
        var result;
        result = AJS.mapAnimation(actor, property, options);
        property = JSON.stringify(result.property);
        options = JSON.stringify(result.options);
        return Animations.animate(actor.getId(), property, options);
      }, time);
    };
    _results = [];
    for (i = _i = 0, _ref = properties.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (options[i].fps === void 0) {
        options[i].fps = fps;
      }
      if (options[i].start === void 0) {
        options[i].start = start;
      }
      if (!Animations.canAnimate(properties[i][0])) {
        if (!actor.canMapAnimation(properties[i])) {
          throw new Error("Unrecognized property! " + properties[i]);
        }
        if (actor.absoluteMapping(properties[i])) {
          timeout = options[i].start;
          options[i].start = -1;
          _results.push(_registerDelayedMap(actor, properties[i], options[i], timeout));
        } else {
          result = AJS.mapAnimation(actor, properties[i], options[i]);
          properties[i] = JSON.stringify(result.property);
          options[i] = JSON.stringify(result.options);
          _results.push(Animations.animate(actor.getId(), properties[i], options[i]));
        }
      } else {
        options[i] = JSON.stringify(options[i]);
        properties[i] = JSON.stringify(properties[i]);
        _results.push(Animations.animate(actor.getId(), properties[i], options[i]));
      }
    }
    return _results;
  };

  AJS.mapAnimation = function(actor, property, options) {
    param.required(actor);
    param.required(property);
    param.required(options);
    return actor.mapAnimation(property, options);
  };

  AJS.loadManifest = function(json, cb) {
    param.required(json);
    if (typeof json !== "string") {
      json = JSON.stringify(json);
    }
    cb = param.optional(cb, function() {});
    this.info("Loading manifest " + (JSON.stringify(json)));
    return window.AdefyRE.Engine().loadManifest(json, cb);
  };

  AJS.createRectangleActor = function(x, y, w, h, r, g, b, extraOptions) {
    var key, options, val;
    param.required(x);
    param.required(y);
    param.required(w);
    param.required(h);
    options = {
      position: {
        x: x,
        y: y
      },
      color: {
        r: r,
        g: g,
        b: b
      },
      w: w,
      h: h
    };
    for (key in extraOptions) {
      val = extraOptions[key];
      options[key] = val;
    }
    return new AJSRectangle(options);
  };

  AJS.createSquareActor = function(x, y, l, r, g, b, extraOptions) {
    param.required(x);
    param.required(y);
    param.required(l);
    return AJS.createRectangleActor(x, y, l, l, r, g, b);
  };

  AJS.createCircleActor = function(x, y, radius, r, g, b, extraOptions) {
    var key, options, val;
    param.required(x);
    param.required(y);
    param.required(radius);
    options = {
      position: {
        x: x,
        y: y
      },
      color: {
        r: r,
        g: g,
        b: b
      },
      radius: radius
    };
    for (key in extraOptions) {
      val = extraOptions[key];
      options[key] = val;
    }
    return new AJSCircle(options);
  };

  AJS.createPolygonActor = function(x, y, radius, segments, r, g, b, extraOptions) {
    var key, options, val;
    param.required(x);
    param.required(y);
    param.required(radius);
    param.required(segments);
    options = {
      position: {
        x: x,
        y: y
      },
      color: {
        r: r,
        g: g,
        b: b
      },
      radius: radius,
      segments: segments
    };
    for (key in extraOptions) {
      val = extraOptions[key];
      options[key] = val;
    }
    return new AJSPolygon(options);
  };

  AJS.createTriangleActor = function(x, y, base, height, r, g, b, extraOptions) {
    var key, options, val;
    param.required(x);
    param.required(y);
    param.required(base);
    param.required(height);
    if (r === void 0) {
      r = Math.floor(Math.random() * 255);
    }
    if (g === void 0) {
      g = Math.floor(Math.random() * 255);
    }
    if (b === void 0) {
      b = Math.floor(Math.random() * 255);
    }
    options = {
      position: {
        x: x,
        y: y
      },
      color: {
        r: r,
        g: g,
        b: b
      },
      base: base,
      height: height
    };
    for (key in extraOptions) {
      val = extraOptions[key];
      options[key] = val;
    }
    return new AJSTriangle(options);
  };

  AJS.getTextureSize = function(name) {
    param.required(name);
    this.info("Fetching texture size by name (" + name + ")");
    return window.AdefyRE.Engine().getTextureSize(name);
  };

  AJS.setRemindMeLaterButton = function(x, y, w, h) {
    return window.AdefyRE.Engine().setRemindMeButton(x, y, w, h);
  };

  return AJS;

})();

/*
//@ sourceMappingURL=ajs.js.map
*/