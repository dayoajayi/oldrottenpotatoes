class MoviesController < ApplicationController
  
  def initialize
    @all_ratings = Movie.all_ratings
    @ratings = @all_ratings
    @sort_by = :id
    super
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect = false
    
    if params["sort_by"]
      @sort_by = params["sort_by"]
    elsif session[:sort_by]
      @sort_by = session[:sort_by]
      redirect = true
    else
      @sort_by = :id
      redirect = true
    end
    
    if params["ratings"]
      @ratings= params["ratings"]
    elsif session[:ratings]
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = {}
      @all_ratings.each do |rating|
        @ratings[rating] = "yes"
      end
      redirect = true
    end
    
    if redirect
      redirect_to movies_path(:sort_by=>@sort_by, :ratings=>@ratings)
    end
    
    all_movies = Movie.order(@sort_by)
    
    @movies = []
    
    all_movies.each do |movie|
      if @ratings.keys.include?(movie["rating"])
        @movies << movie
      end
    end
    
    flash[:sort_by] = @sort_by
    flash[:ratings] = @ratings
    session[:sort_by] = @sort_by
    session[:ratings] = @ratings
    
    #@movies = Movie.all
    #@movies = Movie.find(:all, :order => 'title') if params[:sort] == 'title'
    #@movies = Movie.find(:all, :order => 'release_date') if params[:sort] == 'release'
  end

  def new
    # default: render 'new' template
    @all_ratings = Movie.find(:all,:select=>"rating",:group =>"rating").map(&:rating)
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
