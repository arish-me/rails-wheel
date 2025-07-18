class ExperiencesController < ApplicationController
  before_action :set_candidate
  def index
  end
  def show
  end
  def edit
  end
  def destroy
  end
  def update
  end

  private
   def set_candidate
    @candidate = current_user.candidate
   end
end
