class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.distinct.pluck(:rating).sort
    # determine ratings to show (params override session)
    @ratings_to_show = if params[:ratings]
                         params[:ratings].keys
                       elsif session[:ratings]
                         session[:ratings]
                       else
                         @all_ratings
                       end

    @sort_by = params[:sort_by] || session[:sort_by]

    # keep session in sync or redirect to RESTful URL if needed
    if params[:ratings] || params[:sort_by]
      session[:ratings] = @ratings_to_show
      session[:sort_by] = @sort_by
    elsif session[:ratings] || session[:sort_by]
      redirect_to movies_path(ratings: Hash[session[:ratings].map { |r| [r, 1] }], sort_by: session[:sort_by]) and return
    end

    @movies = Movie.where(rating: @ratings_to_show)
    @movies = @movies.order(@sort_by) if @sort_by.present?
  end
  

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end