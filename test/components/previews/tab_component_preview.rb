# frozen_string_literal: true

class TabComponentPreview < ViewComponent::Preview
  # @param active_index [Integer] the index of the initially active tab
  def default(active_index: 0)
    render(TabComponent.new(active_index: active_index)) do |component|
      component.with_tab_item do
        "Dashboard"
      end
      
      component.with_tab_item do
        "Profile"
      end
      
      component.with_tab_item do
        "Settings"
      end
      
      component.with_tab_content do
        tag.div(class: "mt-4 p-3 bg-gray-100 dark:bg-gray-800 rounded-lg") do
          tag.p("This is additional content below the tabs.", class: "text-sm text-gray-500 dark:text-gray-400")
        end
      end
    end
  end
  
  # @param active_index [Integer] the index of the initially active tab
  def with_custom_content(active_index: 0)
    render(TabComponent.new(active_index: active_index)) do |component|
      component.with_tab_item do
        "Dashboard"
      end
      
      component.with_tab_item do
        "Profile"
      end
      
      component.with_tab_item do
        "Settings"
      end
      
      # Set the content for each tab panel
      component.with_tab_content do
        case active_index
        when 0
          tag.div(class: "p-4 bg-white dark:bg-gray-700 rounded-lg") do
            tag.h3("Dashboard Content", class: "text-lg font-medium mb-2") +
            tag.p("This is the dashboard tab content.", class: "text-gray-600 dark:text-gray-300")
          end
        when 1
          tag.div(class: "p-4 bg-white dark:bg-gray-700 rounded-lg") do
            tag.h3("Profile Content", class: "text-lg font-medium mb-2") +
            tag.p("This is the profile tab content.", class: "text-gray-600 dark:text-gray-300")
          end
        when 2
          tag.div(class: "p-4 bg-white dark:bg-gray-700 rounded-lg") do
            tag.h3("Settings Content", class: "text-lg font-medium mb-2") +
            tag.p("This is the settings tab content.", class: "text-gray-600 dark:text-gray-300")
          end
        end
      end
    end
  end
end 