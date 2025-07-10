class Candidates::SocialLinksController < ApplicationController
  before_action :set_candidate
  before_action :set_social_link, only: [ :show, :update ]
  def show
    # if turbo_frame_request?
    #   render partial: 'candidates/social_links/form', layout: false
    # else
    #   render :show
    # end
  end

  def update
    respond_to do |format|
      if @social_link.update(social_link_params)
        flash[:notice] =  "Social Link were successfully updated."
        format.html { redirect_to candidate_social_link_path(@candidate) }
      else
        flash[:alert] = @social_link.errors.full_messages.join(", ")
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @social_link.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_social_link
    @social_link = @candidate.social_link || @candidate.build_social_link
  end

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

  def social_link_params
    params.require(:social_link).permit(
      :website, :github, :linked_in, :twitter
    )
  end
end
