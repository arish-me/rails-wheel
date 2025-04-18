# frozen_string_literal: true

class TabComponent < ViewComponent::Base
  renders_many :tab_items
  renders_one :tab_content

  def initialize(id: nil, active_index: 0)
    @id = id || SecureRandom.hex(8)
    @active_index = active_index.to_i
  end

  def tab_id(index)
    "tab-#{@id}-#{index}"
  end

  def panel_id(index)
    "panel-#{@id}-#{index}"
  end
end