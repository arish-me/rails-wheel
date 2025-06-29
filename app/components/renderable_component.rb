class RenderableComponent < ViewComponent::Base
  attr_reader :classes

  def initialize(classes = nil)
    @classes = classes
  end

  def render?
    content.present?
  end
end
