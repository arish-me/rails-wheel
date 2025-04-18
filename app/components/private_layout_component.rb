# frozen_string_literal: true

class PrivateLayoutComponent < ViewComponent::Base
  attr_reader :current_user

  def initialize(current_user:, current_path:)
    @current_user = current_user
    @current_path = current_path
  end

  def call
    content_tag :div, class: "private-layout" do
      safe_join([
        render(TopNavigationComponent.new(current_user: current_user, current_path: @current_path)),
        render(SidebarNavigationComponent.new(current_user: current_user, current_path: @current_path)),
        content_wrapper
      ])
    end
  end

  private

  def content_wrapper
    content_tag :div, class: "p-4 sm:ml-64" do
      content_tag :div, class: "p-4 mt-14 bg-white dark:bg-gray-900 rounded-lg shadow-sm" do
        safe_join([
          impersonation_session,
          yield_settings_tab,
          yield_user_management_tab,
          content,
          turbo_frames
        ].compact)
      end
    end
  end

  def impersonation_session
    helpers.render(partial: "shared/impersonation_session") if helpers.impersonating?
  end

  def yield_settings_tab
    helpers.content_for(:settings_tab) if helpers.content_for?(:settings_tab)
  end

  def yield_user_management_tab
    helpers.content_for(:user_management_tab) if helpers.content_for?(:user_management_tab)
  end

  def turbo_frames
    safe_join([
      helpers.turbo_frame_tag("modal"),
      helpers.turbo_frame_tag("drawer"),
      helpers.render("shared/confirm_modal")
    ])
  end
end
