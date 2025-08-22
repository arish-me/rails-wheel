class SpecialtiesComponent < ViewComponent::Base
  private attr_reader :specialties, :title

  def initialize(specialties, title)
    @specialties = specialties
    @title = title
  end
end
