class TopicsController < ApplicationController
  before_action :set_course
  before_action :set_topic, only: %i[ show edit update destroy ]

  # GET /topics or /topics.json
  def index
    @topics = @course.topics.all
    # render :layout
  end

  # GET /topics/1 or /topics/1.json
  def show
    @topics = @course.topics
    # render :layout
  end


  # GET /topics/new
  def new
    @topic = @course.topics.new
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics or /topics.json
  def create
    @topic = @course.topics.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        flash[:notice] =  "Topic was successfully created."
        format.html { redirect_to course_topic_path(@course, @topic), notice: "Topic was successfully created." }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1 or /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        flash[:notice] =  "Topic was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to course_topic_path(@course, @topic), notice: "Topic was successfully updated." }
        format.json { render :show, status: :ok, location: @topic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1 or /topics/1.json
  def destroy
    @topic.destroy!

    respond_to do |format|
      format.html { redirect_to topics_path, status: :see_other, notice: "Topic was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_course
      @course = Course.friendly.find(params[:course_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = @course.topics.friendly.find(params.expect(:id))
    end

    def set_selected_topic
      @selected_topic = @technology.topics.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def topic_params
      params.expect(topic: [ :heading, :technology_id, :content ])
    end
end
