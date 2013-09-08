# This class implements some helper methods for function param enforcement
# It simply serves to standardize error messages for missing/incomplete
# parameters, and set them to default values if such values are provided.
#
# Since it can be used in every method of every class, it is created static
# and attached to the window object as 'param'
class AWGLUtilParam

  # Defines an argument as required. Ensures it is defined and valid
  #
  # @param [Object] p parameter to check
  # @param [Array] valid optional array of valid values the param can have
  # @param [Boolean] canBeNull true if the value can be null
  # @return [Object] p
  @required: (p, valid, canBeNull) ->

    if p == null and canBeNull != true then p = undefined
    if p == undefined then throw new Error "Required argument missing!"

    # Check for validity if required
    if valid instanceof Array
      if valid.length > 0
        isValid = false
        for v in valid
          if p == v
            isValid = true
            break
        if not isValid
          throw new Error "Required argument is not of a valid value!"

    # Ship
    p

  # Defines an argument as optional. Sets a default value if it is not
  # supplied, and ensures validity (post-default application)
  #
  # @param [Object] p parameter to check
  # @param [Object] def default value to use if necessary
  # @param [Array] valid optional array of valid values the param can have
  # @param [Boolean] canBeNull true if the value can be null
  # @return [Object] p
  @optional: (p, def, valid, canBeNull) ->

    if p == null and canBeNull != true then p = undefined
    if p == undefined then p = def

    # Check for validity if required
    if valid instanceof Array
      if valid.length > 0
        isValid = false
        for v in valid
          if p == v
            isValid = true
            break
        if not isValid
          throw new Error "Required argument is not of a valid value!"

    p

window.param = AWGLUtilParam

# Color class, holds r/g/b components
#
# Serves to provide a consistent structure for defining colors, and offers
# useful float to int (0.0-1.0 to 0-255) conversion functions
class AWGLColor3

  # Sets component values
  #
  # @param [Number] r red component
  # @param [Number] g green component
  # @param [Number] b blue component
  constructor: (colOrR, g, b) ->
    colOrR = param.optional colOrR, 0
    g = param.optional g, 0
    b = param.optional b, 0

    if colOrR instanceof AWGLColor3
      @_r = colOrR.getR()
      @_g = colOrR.getG()
      @_b = colOrR.getB()
    else
      @setR colOrR
      @setG g
      @setB b

  # Returns the red component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] red
  getR: (asFloat) ->
    if asFloat != true then return @_r
    @_r / 255

  # Returns the green component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] green
  getG: (asFloat) ->
    if asFloat != true then return @_g
    @_g / 255

  # Returns the blue component as either an int or float
  #
  # @param [Boolean] float true if a float is requested
  # @return [Number] blue
  getB: (asFloat) ->
    if asFloat != true then return @_b
    @_b / 255

  # Set red component, takes a value between 0-255
  #
  # @param [Number] c
  setR: (c) ->
    c = Number(c)
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_r = c

  # Set green component, takes a value between 0-255
  #
  # @param [Number] c
  setG: (c) ->
    c = Number(c)
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_g = c

  # Set blue component, takes a value between 0-255
  #
  # @param [Number] c
  setB: (c) ->
    c = Number(c)
    if c < 0 then c = 0
    if c > 255 then c = 255
    @_b = c

  # Returns the value as a triple
  #
  # @return [String] triple in the form (r, g, b)
  toString: -> "(#{@_r}, #{@_g}, #{@_b})"

# Shader class
class AWGLShader

  # Doesn't do much except auto-build the shader if requested
  #
  # @param [String] vertSrc vertex shader source
  # @param [String] fragSrc fragment shader source
  # @param [Object] gl gl object if building
  # @param [Boolean] build if true, builds the shader now
  constructor: (@_vertSrc, @_fragSrc, @_gl, build) ->

    param.required @_vertSrc
    param.required @_fragSrc
    param.required @_gl
    build = param.optional build, false

    # errors generated errors are pushed into this
    @errors = []

    @_prog = null
    @_vertShader = null
    @_fragShader = null
    @_handles = null

    if build == true
      _success = @build @_gl

      if _success == false
        throw new Error "Failed to build shader! #{JSON.stringify(@errors)}"

  # Builds the shader using the vert/frag sources supplied
  #
  # @param [Object] gl gl object to build shaders with/into
  # @return [Boolean] success false implies an error stored in @errors
  build: (@_gl) ->
    param.required @_gl

    gl = @_gl
    @errors = [] # Clear errors

    # Sanity
    if gl == undefined or gl == null
      throw new Error "Need a valid gl object to build a shader!"

    # Create the shaders
    @_vertShader = gl.createShader gl.VERTEX_SHADER
    @_fragShader = gl.createShader gl.FRAGMENT_SHADER

    # Attach sources
    gl.shaderSource @_vertShader, @_vertSrc
    gl.shaderSource @_fragShader, @_fragSrc

    # Compile
    gl.compileShader @_vertShader
    gl.compileShader @_fragShader

    # Check for errors
    if !gl.getShaderParameter((@_vertShader), gl.COMPILE_STATUS)
      @errors.push gl.getShaderInfoLog(@_vertShader)

    if !gl.getShaderParameter((@_fragShader), gl.COMPILE_STATUS)
      @errors.push gl.getShaderInfoLog(@_fragShader)

    # Link
    @_prog = gl.createProgram()
    gl.attachShader @_prog, @_vertShader
    gl.attachShader @_prog, @_fragShader
    gl.linkProgram @_prog

    # Check for errors
    if !gl.getProgramParameter(@_prog, gl.LINK_STATUS)
      @errors.push "Failed to link!"

    if @errors.length > 0 then return false
    true

  # Really neat helper function, breaks out and supplies handles to all
  # variables. Really the meat of this class
  #
  # @return [Boolean] success fails if handles have already been generated
  generateHandles: ->

    if @_prog == null
      AWGLEngine.getLog().error "Build program before generating handles"
      return false

    if @_handles != null
      AWGLEngine.getLog().warn "Refusing to re-generate handles!"
      return false

    @_handles = {}

    # type 1 == uniform, 2 == attribute
    _makeHandle = (l, type, me) ->
      l = l.split " "
      name = l[l.length - 1].replace(";", "")

      if type == 1
        ret =
          n: name
          h: me._gl.getUniformLocation me._prog, name

        if typeof ret.h != "object"
          throw new Error "Failed to get handle for uniform #{name} [#{ret.h}]"

        return ret
      else if type == 2
        ret =
          n: name
          h: me._gl.getAttribLocation me._prog, name

        #if typeof ret.h != "object"
        #  throw new Error "Failed to get handle for attrib #{name} [#{ret.h}]"

        return ret

      throw new Error "Type not 1 or 2, WTF, internal error"

    # Go through the source, and pull out uniforms and attributes
    # Note that if a duplicate is found, it is simply skipped!
    for src in [ @_vertSrc, @_fragSrc ]

      src = src.split ";"
      for l in src

        if l.indexOf("main()") != -1
          break # Break at the start of the main function
        else if l.indexOf("attribute") != -1
          h = _makeHandle l, 2, @
          @_handles[h.n] = h.h
        else if l.indexOf("uniform") != -1
          h = _makeHandle l, 1, @
          @_handles[h.n] = h.h

    true

  # Get generated handles
  #
  # @return [Object] handles
  getHandles: -> @_handles

  # Get generated program (null by default)
  #
  # @return [Object] program
  getProgram: -> @_prog

# AWGLRenderer
#
# @depend objects/AWGLColor3.coffee
# @depend objects/AWGLShader.coffee
#
# Keeps track of and renders objects, manages textures, and replicates all the
# necessary functionality from the AdefyLib renderer
class AWGLRenderer

  @_nextID: 0

  # GL Context
  @_gl: null

  # Physics pixel-per-meter ratio
  @_PPM: 128

  # Returns PPM ratio
  # @return [Number] ppm pixels-per-meter
  @getPPM: -> AWGLRenderer._PPM

  # Returns MPP ratio
  # @return [Number] mpp meters-per-pixel
  @getMPP: -> 1.0 / AWGLRenderer._PPM

  # Converts screen coords to world coords
  #
  # @param [B2Vec2] v vector in x, y form
  # @return [B2Vec2] ret v in world coords
  @screenToWorld: (v) ->
    ret = new cp.v
    ret.x = v.x / AWGLRenderer._PPM
    ret.y = v.y / AWGLRenderer._PPM
    ret

  # Converts world coords to screen coords
  #
  # @param [B2Vec2] v vector in x, y form
  # @return [B2Vec2] ret v in screen coords
  @worldToScreen: (v) ->
    ret = new cp.v
    ret.x = v.x * AWGLRenderer._PPM
    ret.y = v.y * AWGLRenderer._PPM
    ret

  # @property [Array<Object>] actors for rendering
  @actors: []

  # This is a tad ugly, but it works well. We need to be able to create
  # instance objects in the constructor, and provide one resulting object
  # to any class that asks for it, without an instance avaliable. @me is set
  # in the constructor, and an error is thrown if it is not already null.
  #
  # @property [AWGLRenderer] instance reference, enforced const in constructor
  @me: null

  # Sets up the renderer, using either an existing canvas or creating a new one
  # If a canvasId is provided but the element is not a canvas, it is treated
  # as a parent. If it is a canvas, it is adopted as our canvas.
  #
  # Bails early if the GL context could not be created
  #
  # @param [String] id canvas id or parent selector
  # @param [Number] width canvas width
  # @param [Number] height canvas height
  # @return [Boolean] success
  constructor: (canvasId, @_width, @_height) ->
    canvasId = param.optional canvasId, ""

    @_defaultShader = null  # Default shader used for drawing actors
    @_canvas = null         # HTML <canvas> element
    @_ctx = null            # Drawing context

    @_pickRenderRequested = false   # When true, triggers a pick render

    # Pick render parameters
    @_pickRenderBuff = null
    @_pickRenderCB = null

    # defined if there was an error during initialization
    @initError = undefined

    # Treat empty canvasId as undefined
    if canvasId.length == 0 then canvasId = undefined

    # Two renderers cannot exist at the same time, or else we lose track of
    # the default shaders actor-side. Specifically, we grab the default shader
    # from the @me object, and if it ever changes, future actors will switch
    # to the new @me, without any warning. Blegh.
    #
    # TODO: fugly
    if AWGLRenderer.me != null
      throw new Error "Only one instance of AWGLRenderer can be created!"
    else
      AWGLRenderer.me = @

    gl = null

    @_width = param.optional @_width, 800
    @_height = param.optional @_height, 600

    if @_width <= 1 or @_height <= 1
      throw new Error "Canvas must be at least 2x2 in size"

    # Helper method
    _createCanvas = (parent, id, w, h) ->
      _c = AWGLRenderer.me._canvas = document.createElement "canvas"
      _c.width = w
      _c.height = h
      _c.id = "awgl_canvas"

      # TODO: Refactor this, it's terrible
      if parent == "body"
        document.getElementsByTagName(parent)[0].appendChild _c
      else
        document.getElementById(parent).appendChild _c

    # Create a new canvas if no id is supplied
    if canvasId == undefined or canvasId == null

      _createCanvas "body", "awgl_canvas", @_width, @_height
      AWGLLog.info "Creating canvas #awgl_canvas [#{@_width}x#{@_height}]"

    else
      @_canvas = document.getElementById canvasId

      # Create canvas on the body with id canvasId
      if @_canvas == null
        _createCanvas "body", canvasId, @_width, @_height
        AWGLLog.info "Creating canvas ##{canvasId} [#{@_width}x#{@_height}]"
      else

        # Element exists, see if it is a canvas
        if @_canvas.nodeName.toLowerCase() == "canvas"
          AWGLLog.warn "Canvas exists, ignoring supplied dimensions"
          @_width = @_canvas.width
          @_height = @_canvas.height
          AWGLLog.info "Using canvas ##{canvasId} [#{@_width}x#{@_height}]"
        else

          # Create canvas using element as a parent
          _createCanvas canvasId, "awgl_canvas", @_width, @_height
          AWGLLog.info "Creating canvas #awgl_canvas [#{@_width}x#{@_height}]"

    # Initialize GL context
    gl = @_canvas.getContext("webgl")

    # If null, use experimental-webgl
    if gl is null
      AWGLLog.warn "Continuing with experimental webgl support"
      gl = @_canvas.getContext("experimental-webgl")

    # If still null, FOL
    if gl is null
      alert "Your browser does not support WebGL!"
      @initError = "Your browser does not support WebGL!"
      return

    AWGLRenderer._gl = gl
    @_ctx = @_canvas.getContext "2d"

    AWGLLog.info "Created WebGL context"

    # Perform rendering setup
    gl.enable gl.DEPTH_TEST
    gl.depthFunc gl.LEQUAL

    AWGLLog.info "Renderer initialized"

    ## Shaders
    vertSrc = "" +
      "attribute vec2 Position;" +
      "uniform mat4 Projection;" +
      "uniform mat4 ModelView;" +
      "void main() {" +
      "  mat4 mvp = Projection * ModelView;" +
      "  gl_Position = mvp * vec4(Position, 1, 1);" +
      "}\n"

    fragSrc = "" +
      "precision mediump float;" +
      "uniform vec4 Color;" +
      "void main() {" +
      "  gl_FragColor = Color;" +
      "}\n"

    @_defaultShader = new AWGLShader vertSrc, fragSrc, gl, true
    @_defaultShader.generateHandles()
    handles = @_defaultShader.getHandles()

    # Use program
    gl.useProgram @_defaultShader.getProgram()

    gl.enableVertexAttribArray AWGLRenderer.attrVertPosition
    gl.enableVertexAttribArray AWGLRenderer.attrVertColor

    # Set up projection
    ortho = makeOrtho(0, @_width, 0, @_height, -10, 10).flatten()
    gl.uniformMatrix4fv handles["Projection"], false, ortho

    AWGLLog.info "Initialized shaders"

    # Start out with black
    @setClearColor 0, 0, 0

  # Returns instance (only one may exist, enforced in constructor)
  #
  # @return [AWGLRenderer] me
  @getMe: -> AWGLRenderer.me

  # Returns the internal default shader
  #
  # @return [AWGLShader] shader default shader
  getDefaultShader: -> @_defaultShader

  # Returns canvas element
  #
  # @return [Object] canvas
  getCanvas: -> @_canvas

  # Returns canvas rendering context
  #
  # @return [Object] ctx
  getContext: -> @_ctx

  # Returns static gl object
  #
  # @return [Object] gl
  @getGL: -> AWGLRenderer._gl

  # Returns canvas width
  #
  # @return [Number] width
  getWidth: -> @_width

  # Returns canvas height
  #
  # @return [Number] height
  getHeight: -> @_height

  # Returns the clear color
  #
  # @return [AWGLColor3] clearCol
  getClearColor: -> @_clearColor

  # Sets the clear color
  #
  # @overload setClearCol(col)
  #   Set using an AWGLColor3 object
  #   @param [AWGLColor3] col
  #
  # @overload setClearCol(r, g, b)
  #   Set using component values (0.0-1.0 or 0-255)
  #   @param [Number] r red component
  #   @param [Number] g green component
  #   @param [Number] b blue component
  setClearColor: (colOrR, g, b) ->

    if @_clearColor == undefined then @_clearColor = new AWGLColor3

    if colOrR instanceof AWGLColor3
      @_clearColor = colOrR
    else

      # Sanity checks
      if colOrR == undefined or colOrR == null then colOrR = 0
      if g == undefined or g == null then g = 0
      if b == undefined or b == null then b = 0

      @_clearColor.setR colOrR
      @_clearColor.setG g
      @_clearColor.setB b

    # Serves to apply bounds checks automatically
    colOrR = @_clearColor.getR true
    g = @_clearColor.getG true
    b = @_clearColor.getB true

    # Actually set the color if possible
    if AWGLRenderer._gl != null and AWGLRenderer._gl != undefined
      AWGLRenderer._gl.clearColor colOrR, g, b, 1.0
    else
      AWGLLog.error "Can't set clear color, AWGLRenderer._gl not valid!"

  # Request a frame to be rendered for scene picking.
  #
  # @param [FrameBuffer] buffer
  # @param [Method] cb cb to call post-render
  requestPickingRender: (buffer, cb) ->
    param.required buffer
    param.required cb

    if @_pickRenderRequested
      AWGLLog.warn "Pick render already requested! No request queue"
      return

    @_pickRenderBuff = buffer
    @_pickRenderCB = cb
    @_pickRenderRequested = true

  # Draws a frame
  render: ->

    gl = AWGLRenderer._gl # Code asthetics

    # Probably unecessary, but better to be safe
    if gl == undefined or gl == null then return

    # Render to an off-screen buffer for screen picking if requested to do so.
    # The resulting render is used to pick visible objects. We render in a
    # special manner, by overriding object colors. Every object is rendered
    # with a special blue component value, followed by red and green values
    # denoting its position in our actor array. Not that this is NOT its' id!
    #
    # Since picking relies upon predictable colors, we render without textures
    if @_pickRenderRequested
      gl.bindFramebuffer gl.FRAMEBUFFER, @_pickRenderBuff

    # Clear the screen
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

    # Draw everything!
    for a in AWGLRenderer.actors

      if @_pickRenderRequested

        # If rendering for picking, we need to temporarily change the color
        # of the actor. Blue key is 248
        _savedColor = a.getColor()

        _id = a.getId() - (Math.floor(a.getId() / 255) * 255)
        _idSector = Math.floor(a.getId() / 255)

        # Recover id with (_idSector * 255) + _id
        a.setColor _id, _idSector, 248
        a.draw gl
        a.setColor _savedColor

      else
        a.draw gl

    # Switch back to a normal rendering mode, and immediately re-render to the
    # actual screen
    if @_pickRenderRequested

      # Call cb
      @_pickRenderCB()

      # Unset vars
      @_pickRenderRequested = false
      @_pickRenderBuff = null
      @_pickRenderCB = null

      # Switch back to normal framebuffer, re-render
      gl.bindFramebuffer gl.FRAMEBUFFER, null
      @render()

  # Returns a unique id, used by actors
  # @return [Number] id unique id
  @getNextId: -> AWGLRenderer._nextID++

# Chipmunk-js wrapper
class AWGLPhysics

  # @property [Number] velocity iterations
  @velIterations: 6

  # @property [Number] position iterations
  @posIterations: 2

  # @property [Number] time to step for
  @frameTime: 1.0 / 60.0

  @_gravity: new cp.v 0, -1
  @_stepIntervalId: null
  @_world: null

  @_densityRatio: 1 / 10000

  @bodyCount: 0

  # Constructor, should never be called
  # AWGLPhysics should only ever be accessed as static
  constructor: -> throw new Error "Physics constructor called"

  # Starts the world step loop if not already running
  @startStepping: ->

    if @_stepIntervalId != null then return

    @_world = new cp.Space
    @_world.gravity = @_gravity
    @_world.iterations = 60
    @_world.collisionSlop = 0.5
    @_world.sleepTimeThreshold = 0.5

    me = @
    AWGLLog.info "Starting world update loop"

    @_stepIntervalId = setInterval ->
      me._world.step me.frameTime
    , @frameTime

  # Halt the world step loop if running
  @stopStepping: ->
    if @_stepIntervalId == null then return
    AWGLLog.info "Halting world update loop"
    clearInterval @_stepIntervalId
    @_stepIntervalId = null
    @_world = null

  # Get the internal chipmunk world
  #
  # @return [Object] world
  @getWorld: -> @_world

  # Get object density ratio number thing (keeps it constant)
  #
  # @return [Number] densityRatio
  @getDensityRatio: -> @_densityRatio

  # Get gravity
  #
  # @return [cp.v] gravity
  @getGravity: -> @_gravity

  # Set gravity
  #
  # @param [cp.v] gravity
  @setGravity: (v) ->

    if v !instanceof cp.Vect
      throw new Error "You need to set space gravity using cp.v!"

    @_gravity = v

    if @_world != null and @_world != undefined
      @_world.gravity = v

# Tiny logging class created to be able to selectively
# silence all logging in production, or by level. Also supports tags
# similar to the 'spew' npm module
#
# There are 4 default levels, with 0 always turning off all logging
#
# 1 - Error
# 2 - Warning
# 3 - Debug
# 4 - Info
class AWGLLog

  # @property [Array<String>] tags, editable by the user
  @tags: [
    "",
    "[Error]> ",
    "[Warning]> ",
    "[Debug]> ",
    "[Info]> "
  ]

  # @property [Number] logging level
  @level: 4

  # Generic logging function
  #
  # @param [Number] level logging level to log on
  # @param [String] str log message
  @w: (level, str) ->

    me = AWGLLog

    # Return early if not at a suiteable level, or level is 0
    if level > me.level or level == 0 or me.level == 0 then return

    # Specialized console output
    if level == 1 and console.error != undefined
      console.error "#{me.tags[level]}#{str}"
      return
    else if level == 2 and console.warn != undefined
      console.warn "#{me.tags[level]}#{str}"
      return
    else if level == 3 and console.debug != undefined
      console.debug "#{me.tags[level]}#{str}"
      return
    else if level == 4 and console.info != undefined
      console.info "#{me.tags[level]}#{str}"
      return

    if level > 4 and me.tags[level] != undefined
      console.log "#{me.tags[level]}#{str}"
    else
      console.log str
    return

  # Specialized, sets level to error directly
  #
  # @param [String] str log message
  @error: (str) -> @w 1, str

  # Specialized, sets level to warning directly
  #
  # @param [String] str log message
  @warn: (str) -> @w 2, str

  # Specialized, sets level to debug directly
  #
  # @param [String] str log message
  @debug: (str) -> @w 3, str

  # Specialized, sets level to info directly
  #
  # @param [String] str log message
  @info: (str) -> @w 4, str

# AJAX utility class, wrapper around microAjax that adds queueing
class AWGLAjax

  # Set up an empty queue
  constructor: ->

    # true if currently processing a request
    @busy = false

    # queue array, holds objects containing urls and cbs
    @queue = []

  # Request method, either passes through directly to microAjax or
  # queues the request
  #
  # @param [String] url
  # @param [Method] cb
  # @return [Boolean] executed false if queued
  r: (url, cb) ->
    param.required url

    me = @

    # If busy, directly enqueue
    if @busy
      @queue.push
        url: url
        cb: cb
      return false

    # Pass directly to _callMjax
    if @queue.length == 0
      @busy = true
      @_callMjax url, cb
      return true

    # Reaching this point means the queue is not empty, but we are not busy
    # either. This should never happen, but just in case...
    throw new Error "[AWGLAjax] Queue length non-zero and busy flag not set!"

  # Internal function that actually calls microAjax
  # Passes the url, and calls the cb() inside an own callback, after
  # recursing if necessary
  #
  # @param [String] url
  # @param [Method] cb
  _callMjax: (url, cb) ->

    me = @

    # Call mjax
    window.microAjax url, (res) ->

      # If the queue is not empty, recurse back to _callMjax with next request
      if me.queue.length > 0
        next = me.queue.pop()
        me._callMjax next.url, next.cb
      else
        # No requests left, set busy to false
        me.busy = false

      # Pass result to intended callback
      if typeof cb == "function" then cb res

# Actor interface class
class AWGLActorInterface

  # Fails with null
  _findActor: (id) ->
    param.required id

    for a in AWGLRenderer.actors
      if a.getId() == id then return a
    return null

  # Create actor using the supplied vertices, passed in as a JSON
  # representation of a flat array
  #
  # @param [String] verts
  # @return [Number] id created actor handle
  createActor: (verts) ->
    param.required verts
    verts = JSON.parse verts

    a = new AWGLActor verts
    return a.getId()

  # Refresh actor vertices, passed in as a JSON representation of a flat array
  #
  # @param [String] verts
  # @param [Number] id actor id
  # @return [Boolean] success
  updateVertices: (verts, id) ->
    param.required verts
    param.required id

    if (a = @_findActor(id)) != null
      a.updateVertices JSON.parse verts
      return true

    false

  # Clears stored information about the actor in question. This includes the
  # rendered and physics bodies
  #
  # @param [Numer] id actor id
  # @return [Boolean] success
  destroyActor: (id) ->
    param.required id

    for a, i in AWGLRenderer.actors
      if a.getId() == id
        a.destroyPhysicsBody()
        AWGLRenderer.actors.splice i, 1
        a = undefined
        return true

    false

  # Supply an alternate set of vertices for the physics body of an actor. This
  # is necessary for triangle-fan shapes, since the center point must be
  # removed when building the physics body. If a physics body already exists,
  # this rebuilds it!
  #
  # @param [String] verts
  # @param [Number] id actor id
  # @return [Boolean] success
  setPhysicsVertices: (verts, id) ->
    param.required verts
    param.required id

    if (a = @_findActor(id)) != null
      a.setPhysicsVertices JSON.parse verts
      return true

    false

  # Change actors' render mode, currently only options are avaliable
  #   1 == TRIANGLE_STRIP
  #   2 == TRIANGLE_FAN
  #
  # @param [Number] mode
  # @param [Number] id actor id
  # @return [Boolean] success
  setRenderMode: (mode, id) ->
    mode = param.required mode, [1, 2]
    param.required id

    if (a = @_findActor(id)) != null
      a.setRenderMode mode
      return true

    false

  # Set actor position using handle, fails with false
  #
  # @param [Number] x x coordinate
  # @param [Number] y y coordinate
  # @param [Number] id
  # @return [Boolean] success
  setActorPosition: (x, y, id) ->
    param.required x
    param.required y
    param.required id

    if (a = @_findActor(id)) != null
      a.setPosition new cp.v x, y
      return true

    false

  # Get actor position using handle, fails with null
  # Returns position as a JSON representation of a primitive (x, y) object!
  #
  # @param [Number] id
  # @return [Object] position
  getActorPosition: (id) ->
    param.required id

    if (a = @_findActor(id)) != null
      pos = a.getPosition()

      return JSON.stringify
        x: pos.x
        y: pos.y

    null

  # Set actor rotation using handle, fails with false
  #
  # @param [Number] angle in degrees or radians
  # @param [Number] id
  # @param [Boolean] radians defaults to false
  # @return [Boolean] success
  setActorRotation: (angle, id, radians) ->
    param.required angle
    param.required id
    radians = param.optional radians, false

    if (a = @_findActor(id)) != null
      a.setRotation angle, radians
      return true

    false

  # Get actor rotation using handle, fails with -1
  #
  # @param [Number] id
  # @param [Boolean] radians defaults to false
  # @return [Number] angle in degrees or radians
  getActorRotation: (id, radians) ->
    param.required id
    radians = param.optional radians, false

    if (a = @_findActor(id)) != null then return a.getRotation radians
    -1

  # Set actor color using handle, fails with false
  #
  # @param [Number] r red component
  # @param [Number] g green component
  # @param [Number] b blue component
  # @param [Number] id
  # @return [Boolean] success
  setActorColor: (r, g, b, id) ->
    param.required r
    param.required g
    param.required b
    param.required id

    if (a = @_findActor(id)) != null
      a.setColor new AWGLColor3 r, g, b
      return true

    false

  # Returns actor color as a JSON triple, in 0-255 range
  # Uses id, fails with null
  #
  # @param [Number] id
  # @return [AWGLColor3] col
  getActorColor: (id) ->
    param.required id

    if (a = @_findActor(id)) != null
      return JSON.stringify
        r: a.getColor().getR()
        g: a.getColor().getG()
        b: a.getColor().getB()

    null

  # Creates the internal physics body, if one does not already exist
  # Fails with false
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - 1.0
  # @param [Number] elasticity 0.0 - 1.0
  # @param [Number] id
  # @return [Boolean] success
  enableActorPhysics: (mass, friction, elasticity, id) ->
    param.required id
    param.required mass
    param.required friction
    param.required elasticity

    if (a = @_findActor(id)) != null
      a.createPhysicsBody mass, friction, elasticity
      return true

    false

  # Destroys the physics body if one exists, fails with false
  #
  # @param [Number] id
  # @return [Boolean] success
  destroyPhysicsBody: (id) ->
    param.required id

    if (a = @_findActor(id)) != null
      a.destroyPhysicsBody()
      true

    false

# Engine interface, used by the ads themselves, serves as an API
#
# @depend AWGLActorInterface.coffee
class AWGLInterface

  # Instantiates sub-interfaces
  constructor: -> @_Actors = new AWGLActorInterface()

  # Sub-interfaces are broken out through accessors to prevent modification

  # Get actor sub-interface
  # @return [AWGLActorInterface] actors
  Actors: -> @_Actors

# AWGLEngine
#
# @depend AWGLRenderer.coffee
# @depend AWGLPhysics.coffee
# @depend util/AWGLLog.coffee
# @depend util/AWGLAjax.coffee
# @depend interface/AWGLInterface.coffee
#
# Takes a path to a directory containing an Adefy ad and runs it
#
# Intended useage is from the Ad editor, but it doesn't expect anything from
# its environment besides WebGL support
#
# Creating a new instance of this engine will launch the ad directly, creating
# a renderer and loading up the scenes as required
#
# Requires the ajax library from https://code.google.com/p/microajax/ and
# expects the ajax object to be bound to the window as window.ajax
#
# Requires Underscore.js fromhttp://documentcloud.github.io/underscore
#
# Requires Chipmunk-js https://github.com/josephg/Chipmunk-js
#
# AWGLLog is used for all logging throughout the application
class AWGLEngine

  # Constructor, takes a path to the root of the ad intended to be displayed
  # An attempt is made to load and parse a package.json. If a url is not
  # provided, the engine is initialized and cb is called with ourselves as an
  # argument.
  #
  # Checks for dependencies and bails early if all are not found.
  #
  # @Example Load from Adefy servers
  #   new AWGLEngine "https://static.adefy.eu/Y7eqYy6rTNDwBjwD/"
  #
  # @param [String] url ad location
  # @param [Number] logLevel level to start AWGLLog at, defaults to 4
  # @param [Method] cb callback to execute when finished initializing
  # @param [String] canvas optional canvas selector to initalize the renderer
  # @param [Number] width optional width to pass to the canvas
  # @param [Number] height optional height to pass to the canvas
  # @return [Boolean] success
  constructor: (@url, logLevel, cb, canvas, width, height) ->

    # Treat null url as undefined
    if @url == null then @url = undefined

    @url = param.optional @url, ""
    logLevel = param.optional logLevel, 4
    canvas = param.optional canvas, ""

    # Holds fetched package.json
    @package = null

    # Initialized to a new instance of AWGLAjax
    @ajax = null

    # Initialized after Ad package is downloaded and verified
    @_renderer = null

    # Holds a handle on the render loop interval
    @_renderIntervalId = null

    # Framerate for renderer, defaults to 60FPS
    @_framerate = 1.0 / 60.0

    # Defined if there was an error during initialization
    @initError = undefined

    AWGLLog.level = logLevel

    # Ensure https://code.google.com/p/microajax/ is loaded
    if window.ajax is null or window.ajax is undefined
      AWGLLog.error "Ajax library is not present!"
      @initSuccess = "Ajax library is not present!"
      return

    # Ensure Underscore.js is loaded
    if window._ is null or window._ is undefined
      AWGLLog.error "Underscore.js is not present!"
      @initSuccess = "Underscore.js is not present!"
      return

    # Ensure Chipmunk-js is loaded
    if window.cp is undefined or window.cp is null
      AWGLLog.error "Chipmunk-js is not present!"
      @initSuccess = "Chipmunk-js is not present!"
      return

    # If a url was passed in, load things up
    if @url.length > 0

      # Create an instance of AWGLAjax
      @ajax = new AWGLAjax

      # Store instance for callbacks
      me = @

      # [ASYNC] Grab the package.json
      @ajax.r "#{@url}/package.json", (res) ->
        AWGLLog.info "...fetched package.json"
        me.package = JSON.parse res

        # [ASYNC] Package.json is valid, continue
        validStructure = me.verifyPackage me.package, (sourcesObj) ->

          AWGLLog.info "...downloaded. Creating Renderer"
          me._renderer = new AWGLRenderer canvas, width, height

          ##
          # At this point, we have a renderer instance ready to go, and we can
          # load up the scenes one at a time and execute them. We create
          # an instance of AWGLInterface on the window, so our middleware
          # can interface with AWGL.
          #
          # Scenes create a window.currentScene object, which we run with
          # window.currentScene();
          ##

          me.startRendering()
          AWGLPhysics.startStepping()

          # Break out interface
          window.AdefyGLI = new AWGLInterface

          if cb != null and cb != undefined then cb @

        if validStructure
          AWGLLog.info "package.json valid, downloading assets..."
        else
          AWGLLog.error "Invalid package.json"
          @initSuccess = "Invalid package.json"
          return

      AWGLLog.info "Engine initialized, awaiting package.json..."

    else if cb != undefined

      # No url, just start things up and call the cb
      # Note that we do NOT start the renderer
      @_renderer = new AWGLRenderer canvas, width, height
      window.AdefyGLI = new AWGLInterface

      AWGLLog.info "Engine initialized, executing cb"
      cb @

    else
      AWGLLog.error "Engine can't initialize, no url or cb was passed in!"

  # Verifies the validity of the package.json file, ensuring we can actually
  # use it. Checks for existence of required fields, and if all is well
  # continues to check for files and pull them down. Once done, it calls
  # the cb with the data
  #
  # @param [Object] Object created from package.json
  # @param [Method] cb callback to provide data to
  # @return [Boolean] validity
  verifyPackage: (obj, cb) ->

    # Build definition of valid package.json
    validPackage =
      company: ""     # Owner
      apikey: ""      # APIKey
      load: ""        # Load function to prepare for scene execution
      scenes: {}      # Object containing numbered scenes

    # Ensure required fields are present
    for k of validPackage
      if obj[k] == undefined
        AWGLLog.error "package.json invalid, missing key #{k}"
        return false

    # Ensure at least one scene is provided
    if obj.scenes.length == 0
      AWGLLog.warning ".json does not specify any scenes, can't continue"
      return false

    # Container for downloaded files
    packageFiles =
      load: null
      scenes: {}

    toDownload = 1 + _.size obj.scenes
    me = @

    _postAjax = (name, res) ->

      # Save result as needed
      if name == "load"
        packageFiles.load = res
      else
        packageFiles.scenes[name] = res

      # Call the cb if done
      toDownload--
      if toDownload == 0
        cb packageFiles

    _fetchScene = (name, path) ->

      # Perform ajax request
      me.ajax.r "#{me.url}#{path}", (res) ->
        _postAjax name, res

    # [ASYNC] Verify existence of the files
    # Start with the load function, then the scenes
    @ajax.r "#{@url}#{obj.load}", (res) -> _postAjax "load", res

    # Load up scenes, delegate to _fetchScene
    for s of obj.scenes
      _fetchScene s, obj.scenes[s]

    # Returns before files are downloaded, mearly to guarantee file validity
    true

  # Set framerate as an FPS figure
  # @param [Number] fps
  setFPS: (fps) -> @_framerate = 1.0 / fps

  # Start render loop if it isn't already running
  startRendering: ->
    if @_renderIntervalId != null then return

    me = @
    AWGLLog.info "Starting render loop"

    @_renderIntervalId = setInterval ->
      me._renderer.render()
    , @_framerate

  # Halt render loop if it's running
  stopRendering: ->
    if @_renderIntervalId == null then return
    AWGLLog.info "Halting render loop"
    clearInterval @_renderIntervalId
    @_renderIntervalId = null

  # Return our internal renderer width, returns -1 if we don't have a renderer
  #
  # @return [Number] width
  getWidth: ->
    if @_renderer == null or @_renderer == undefined
      return -1
    else
      return @_renderer.getWidth()

  # Return our internal renderer height
  #
  # @return [Number] height
  getHeight: ->
    if @_renderer == null or @_renderer == undefined
      return -1
    else
      return @_renderer.getHeight()

  # Request a pick render, passed straight to the renderer
  #
  # @param [FrameBuffer] buffer
  # @param [Method] cb cb to call post-render
  requestPickingRender: (buffer, cb) ->
    if @_renderer == null or @_renderer == undefined
      AWGLLog.warn "Can't request a pick render, renderer not instantiated!"
    else
      @_renderer.requestPickingRender buffer, cb

  # Get our renderer's gl object
  #
  # @return [Object] gl
  getGL: ->
    if AWGLRenderer._gl == null
      AWGLLog.warn "No gl object to get, render not instantiated!"
      return null
    else
      return AWGLRenderer._gl
# Actor class, skeleton for now
class AWGLActor

  # Default physical properties
  @defaultFriction: 0.3
  @defaultMass: 10
  @defaultElasticity: 0.2

  # Null offset, used when creating dynamic bodies
  @_nullV: new cp.v 0, 0

  # Adds the actor to the renderer actor list, gets a unique id from the
  # renderer, and builds our vert buffer
  #
  # @param [Array<Number>] vertices flat array of vertices (x1, y1, x2, ...)
  constructor: (verts) ->
    param.required verts

    @_gl = AWGLRenderer._gl
    if @_gl == undefined or @_gl == null
      throw new Error "GL context is required for actor initialization!"

    # Color used for drawing, colArray is pre-computed for the render routine
    @_color = null
    @_colArray = null

    @lit = false
    @visible = true

    @_id = -1
    @_position = new cp.v 0, 0
    @_rotation = 0 # Radians, but set in degrees by default

    # Vectors and matrices used for drawing
    @_rotV = null
    @_transV = null
    @_modelM = null

    # Chipmunk-js values
    @_shape = null
    @_body = null
    @_friction = null
    @_mass = null
    @_elasticity = null

    # Our actual vertex lists. Note that we will optionally use a different
    # set of vertices for the physical body!
    @_vertices = []
    @_psyxVertices = []

    # Vertice containers
    @_vertBuffer = null
    @_vertBufferFloats = null # Float32Array

    # Shader handles, for now there are only three
    # TODO: Make this dynamic
    @_sh_modelview = null
    @_sh_position = null
    @_sh_color = null

    # Render modes decide how the vertices are treated.
    #   1 == TRIANGLE_STRIP
    #   2 == TRIANGLE_FAN
    @_renderMode = 1

    @_id = AWGLRenderer._nextID++

    AWGLRenderer.actors.push @

    # Sets up our vert buffer, also validates the vertex array (length)
    @updateVertices verts

    @setColor new AWGLColor3 255, 255, 255

    # Initialize our rendering objects
    @_rotV = $V([0, 0, 1])
    @_transV = $V([0, 0, 1])
    @_modelM = Matrix.I 4

    # Grab default shader from the renderer
    @setShader AWGLRenderer.getMe().getDefaultShader()

  # Set shader used to draw actor. For the time being, the routine mearly
  # pulls out handles for the ModelView, Color, and Position structures
  #
  # @param [AWGLShader] shader
  setShader: (shader) ->
    param.required shader

    # Ensure shader is built, and generate handles if not already done
    if shader.getProgram() == null
      throw new Error "Shader has to be built before it can be used!"

    if shader.getHandles() == null
      shader.generateHandles()

    handles = shader.getHandles()

    @_sh_modelview = handles["ModelView"]
    @_sh_position = handles["Position"]
    @_sh_color = handles["Color"]

  # Creates the internal physics body, if one does not already exist
  #
  # @param [Number] mass 0.0 - unbound
  # @param [Number] friction 0.0 - unbound
  # @param [Number] elasticity 0.0 - unbound
  createPhysicsBody: (@_mass, @_friction, @_elasticity) ->

    # Start the world stepping if not already doing so
    if AWGLPhysics.getWorld() == null or AWGLPhysics.getWorld() == undefined
      AWGLPhysics.startStepping()

    if @_shape == not null then return

    if AWGLPhysics.bodyCount == 0 then AWGLPhysics.startStepping()

    AWGLPhysics.bodyCount++

    # Sanity checks
    if @_mass == undefined or @_mass == null then @_mass = 0
    if @_mass < 0 then @_mass = 0

    if @_friction == undefined
      @_friction = AWGLActor.defaultFriction
    else if @_friction < 0 then @_friction = 0

    if @_elasticity == undefined
      @_elasticity = AWGLActor.defaultElasticity
    else if @_elasticity < 0 then @_elasticity = 0

    # Convert vertices
    verts = []
    vertIndex = 0

    # If we have alternate vertices, use those, otherwise go with the std ones
    origVerts = null
    if @_psyxVertices.length > 6 then origVerts = @_psyxVertices
    else origVerts = @_vertices

    for i in [0...origVerts.length - 1] by 2

      # Actual coord system conversion
      verts.push origVerts[i] / AWGLRenderer.getPPM()
      verts.push origVerts[i + 1] / AWGLRenderer.getPPM()

      # Rotate vert if mass is 0, since we can't set static body angle
      if @_mass == 0
        x = verts[verts.length - 2]
        y = verts[verts.length - 1]
        a = @_rotation

        verts[verts.length - 2] = x * Math.cos(a) - (y * Math.sin(a))
        verts[verts.length - 1] = x * Math.sin(a) + (y * Math.cos(a))

    # Grab world handle to shorten future calls
    space = AWGLPhysics.getWorld()
    pos = AWGLRenderer.screenToWorld @_position

    if @_mass == 0
      @_shape = space.addShape new cp.PolyShape space.staticBody, verts, pos
      @_body = null
    else

      moment = cp.momentForPoly @_mass, verts, AWGLActor._nullV
      @_body = space.addBody new cp.Body @_mass, moment
      @_body.setPos pos
      @_body.setAngle @_rotation

      @_shape = space.addShape new cp.PolyShape @_body, verts, AWGLActor._nullV

    @_shape.setFriction @_friction
    @_shape.setElasticity @_elasticity

  # Destroys the physics body if one exists
  destroyPhysicsBody: ->
    if AWGLPhysics.bodyCount == 0 then return
    if @_shape == null then return

    AWGLPhysics.bodyCount--

    AWGLPhysics.getWorld().removeShape @_shape
    if @_body then AWGLPhysics.getWorld().removeBody @_body

    @_shape = null
    @_body = null

    if AWGLPhysics.bodyCount == 0
      AWGLPhysics.stopStepping()
    else if AWGLPhysics.bodyCount < 0
      throw new Error "Body count is negative!"

  # Update our vertices, causing a rebuild of the physics body, if it doesn't
  # have its' own set of verts. Note that for large actors this is expensive.
  #
  # @param [Array<Number>] verts flat array of vertices
  updateVertices: (verts) ->
    @_vertices = param.required verts

    if @_vertices.length < 6
      throw new Error "At least 3 vertices make up an actor"

    @_vertBuffer = @_gl.createBuffer()
    @_vertBufferFloats = new Float32Array(@_vertices)

    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_vertBuffer
    @_gl.bufferData @_gl.ARRAY_BUFFER, @_vertBufferFloats, @_gl.STATIC_DRAW
    @_gl.bindBuffer @_gl.ARRAY_BUFFER, null

  # Set an alternate vertex array for our physics object. Note that this also
  # triggers a rebuild! If less than 6 vertices are provided, the normal
  # set of vertices is used
  #
  # @param [Array<Number>] verts flat array of vertices
  setPhysicsVertices: (verts) ->
    @_psyxVertices = param.required verts

    if @_body != null
      @destroyPhysicsBody()
      @createPhysicsBody @_mass, @_friction, @_elasticity

  # Renders the actor
  #
  # @param [Object] gl gl context
  draw: (gl) ->
    param.required gl

    if not @visible then return

    # @_body is null for static bodies!
    if @_body != null
      @_position = AWGLRenderer.worldToScreen @_body.getPos()
      @_rotation = @_body.a

    # Prep our vectors and matrices
    @_modelM = Matrix.I 4
    @_transV.elements[0] = @_position.x
    @_transV.elements[1] = @_position.y

    @_modelM = @_modelM.x (Matrix.Translation(@_transV).ensure4x4())
    @_modelM = @_modelM.x (Matrix.Rotation(@_rotation, @_rotV).ensure4x4())

    flatMV = new Float32Array(@_modelM.flatten())

    gl.bindBuffer gl.ARRAY_BUFFER, @_vertBuffer
    gl.vertexAttribPointer @_sh_position, 2, gl.FLOAT, false, 0, 0

    gl.uniform4f @_sh_color, @_colArray[0], @_colArray[1], @_colArray[2], 1
    gl.uniformMatrix4fv @_sh_modelview, false, flatMV

    if @_renderMode == 1
      gl.drawArrays gl.TRIANGLE_STRIP, 0, @_vertices.length / 2
    else if @_renderMode == 2
      gl.drawArrays gl.TRIANGLE_FAN, 0, @_vertices.length / 2
    else throw new Error "Invalid render mode! #{@_renderMode}"

  # Set actor render mode, decides how the vertices are perceived
  #   1 == TRIANGLE_STRIP
  #   2 == TRIANGLE_FAN
  #
  # @paran [Number] mode
  setRenderMode: (mode) -> @_renderMode = param.required mode, [1, 2]

  # Set actor position, effects either the actor or the body directly if one
  # exists
  #
  # @param [Object] position x, y
  setPosition: (position) ->
    param.required position

    if @_shape == null
      if position instanceof cp.v
        @_position = position
      else
        @_position = new cp.v Number(position.x), Number(position.y)
    else if @_body != null
      @_body.setPos AWGLRenderer.screenToWorld position

  # Set actor rotation, affects either the actor or the body directly if one
  # exists
  #
  # @param [Number] rotation angle
  # @param [Number] radians true if angle is in radians
  setRotation: (rotation, radians) ->
    param.required rotation
    radians = param.optional radians, false

    if radians == false then rotation = Number(rotation) * 0.0174532925

    if @_shape == null
      @_rotation = rotation
    else if @_body != null
      @_body.SetAngle @_rotation

  # Returns the actor position as an object with x and y properties
  #
  # @return [Object] position x, y
  getPosition: -> @_position

  # Returns actor rotation as an angle in degrees
  #
  # @param [Boolean] radians true to return in radians
  # @return [Number] angle rotation in degrees on z axis
  getRotation: (radians) ->
    radians = param.optional radians, false
    if radians == false
      return @_rotation * 57.2957795
    else
      return @_rotation

  # Get array of vertices
  #
  # @return [Array<Object>] vertices
  getVertices: -> @_vertices

  # Get body id
  #
  # @return [Number] id
  getId: -> @_id

  # Get color
  #
  # @return [AWGLColor3] color
  getColor: -> new AWGLColor3 @_color

  # Set color
  #
  # @overload setColor(col)
  #   Sets the color using an AWGLColor3 instance
  #   @param [AWGLColor3] color
  #
  # @overload setColor(r, g, b)
  #   Sets the color using component values
  #   @param [Integer] r red component
  #   @param [Integer] g green component
  #   @param [Integer] b blue component
  setColor: (colOrR, g, b) ->
    param.required colOrR

    if @_color == undefined or @_color == null then @_color = new AWGLColor3

    if colOrR instanceof AWGLColor3
      @_color = colOrR

      @_colArray = [
        colOrR.getR true
        colOrR.getG true
        colOrR.getB true
      ]

    else
      param.required g
      param.required b

      @_color.setR Number(colOrR)
      @_color.setG Number(g)
      @_color.setB Number(b)

      @_colArray = [
        @_color.getR true
        @_color.getG true
        @_color.getB true
      ]

# Top-level file, used by concat_in_order
#
# As part of the build process, grunt concats all of our coffee sources in a
# dependency-aware manner. Deps are described at the top of each file, with
# this essentially serving as the root node in the dep tree.
#
# @depend util/AWGLUtilParam.coffee
# @depend AWGLEngine.coffee
# @depend objects/AWGLActor.coffee
