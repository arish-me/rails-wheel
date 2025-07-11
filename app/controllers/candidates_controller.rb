class CandidatesController < ApplicationController
  before_action :set_candidate, only: %i[ show edit update ]

  def index
  end
  def show
  end
  def edit
  end

  def update
  end

  def set_candidate
    @candidate = current_user.candidate
  end
end