# Returns a fake model class.
class Ion::Wrapper
  attr_reader :name

  def initialize(name)
    @name = name
    extend Ion::Entity::ClassMethods
  end

  def ion
  end

  def [](id)
    { :id => id }
  end
end
