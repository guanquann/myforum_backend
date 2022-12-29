class PostsController < ApplicationController
  before_action :authorize_request, unless: -> { params[:public] == "true" }
  
  # GET /posts 
  def index
    @posts = Post.joins(:user).joins(:category).joins(:post_thread).select('posts.*, users.username, categories.cat, post_threads.title as thread').order(created_at: :desc).all()
    @posts = @posts.map do |post|
      # if current session is authenticated, find whether current user upvotes the post
      if params[:public] == "true"
        @merge_dict = { avatar: get_avatar(post) }
      else
        @merge_dict = { avatar: get_avatar(post), is_upvoted: get_is_upvoted(post) }
      end
      post = post.as_json.merge(@merge_dict)
    end
    render json: @posts
  end

  # GET /posts/{id}
  def show
    @post = Post.joins(:user).joins(:category).joins(:post_thread).select('posts.*, users.username, categories.cat, post_threads.title as thread').order(created_at: :desc).find(params[:id])
    if params[:public] == "true"
      @merge_dict = { avatar: get_avatar(@post) }
    else
      @merge_dict = { avatar: get_avatar(@post), is_upvoted: get_is_upvoted(@post) }
    end
    @post = @post.as_json.merge(@merge_dict)
    render json: @post
  end

  # POST /posts
  def create
    @post = Post.create(post_params)
    @post.user_id = @current_user.id
    @post.images.attach(params[:images])
    
    if @post.save
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end
  
  # PATCH /posts/{id}
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/{id}
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    render json: @post
  end

  private
    def post_params
      params.permit(:title, :description, :category_id, :post_thread_id, :public, images: [])
    end
end
