class Candidates::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate

  def index
    @profiles = @candidate.profiles if @candidate.respond_to?(:profiles)
  end

  def show
    @profile = @candidate.profile if @candidate.respond_to?(:profile)
  end

  private

  def set_candidate
    @candidate = current_user.candidate
  end
end