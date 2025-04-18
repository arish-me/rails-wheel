# frozen_string_literal: true

class TabComponent < ViewComponent::Base
  attr_reader :tabs, :current_path

  def initialize(tabs:, current_path:)
    @tabs = tabs
    @current_path = current_path
  end

  def tab_class(path)
    base_class = "inline-block p-4 border-b-2 rounded-t-lg"
    if path == current_path
      "#{base_class} text-blue-600 border-blue-600 dark:text-white dark:border-gray-600"
    else
      "#{base_class} hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300"
    end
  end

  def is_current?(path)
    path == current_path
  end
end
