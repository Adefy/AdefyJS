describe "AJSVector2", ->

  test1 = new AJSVector2()
  test2 = new AJSVector2 10, 25

  it "should initialize to (0, 0)", ->
    expect(test1.x).to.equal 0
    expect(test1.y).to.equal 0

  it "should return proper string representation", ->
    expect(test1.toString()).to.equal "(0, 0)"

  it "should return negative version of vector", ->
    expect(test2.negative().x).to.equal -10
    expect(test2.negative().y).to.equal -25

  it "should return sum of vector with another", ->
    _test = test2.add new AJSVector2 5, 2

    expect(_test.x).to.equal 15
    expect(_test.y).to.equal 27

  it "should return difference of vector with another", ->
    _test = test2.subtract new AJSVector2 5, 2

    expect(_test.x).to.equal 5
    expect(_test.y).to.equal 23

  it "should return product of vector with another", ->
    _test = test2.multiply new AJSVector2 5, 2

    expect(_test.x).to.equal 50
    expect(_test.y).to.equal 50

  it "should return quotient of vector with another", ->
    _test = test2.divide new AJSVector2 2, 5

    expect(_test.x).to.equal 5
    expect(_test.y).to.equal 5

  it "should return the sum of a vector and a scalar", ->
    _test = test2.add 7

    expect(_test.x).to.equal 17
    expect(_test.y).to.equal 32

  it "should return the difference between a vector and a scalar", ->
    _test = test2.subtract 4

    expect(_test.x).to.equal 6
    expect(_test.y).to.equal 21

  it "should return the product of a vector and a scalar", ->
    _test = test2.multiply 3

    expect(_test.x).to.equal 30
    expect(_test.y).to.equal 75

  it "should return the quotient of a vector and a scalar", ->
    _test = test2.divide 2

    expect(_test.x).to.equal 5
    expect(_test.y).to.equal 12.5

  it "should verify equality with another vector", ->
    expect(test1.equals(test2)).to.be.false
    expect(test1.equals(test1)).to.be.true

  it "should calculate the dot product with another vector", ->
    _test = new AJSVector2 4, 4

    expect(_test.dot(test2)).to.equal 140

  it "should calculate the cross product with another vector", ->
    _test = new AJSVector2 4, 4

    expect(_test.cross(test2)).to.equal 60

  it "should create a vector orthogonal to itself", ->
    _test = test2.ortho()

    expect(_test.x).to.equal test2.y
    expect(_test.y).to.equal -test2.x

  it "should return its length", ->
    expect(test2.length()).to.equal Math.sqrt(725)

  it "should return a normalized version of itself", ->
    _test = test2.normalize()

    expect(_test.x).to.equal 10 / Math.sqrt(725)
    expect(_test.y).to.equal 25 / Math.sqrt(725)
