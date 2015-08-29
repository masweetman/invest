require 'weakref'

class TransientCache < Hash
  class AmbivalentRef < WeakRef
    def __getobj__
      super rescue nil
    end
  end
  
  def []= key, object
    super(key, AmbivalentRef.new(object))
  end
  
  def [] key
    ref = super(key)
    self.delete(key) if !ref.weakref_alive?
    ref
  end
  
end