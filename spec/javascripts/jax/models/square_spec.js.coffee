describe "Square", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Square()
      
  
  it "should instantiate without errors", ->
    expect(-> new Square()).not.toThrow()
  