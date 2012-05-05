describe "Level", ->
  model = null
  
  describe "defaults", ->
    beforeEach ->
      model = new Level()
      
  
  it "should instantiate without errors", ->
    expect(-> new Level()).not.toThrow()
  