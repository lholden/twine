module Twine
  class Child
    include ChildMixin

    def initialize(&bl)
      if bl.nil?
        raise ArgumentError, "a block must be provided"
      end
      @_twine_child_block = bl
    end

  protected
    def run
      @_twine_child_block.call 
    end
  end
end
