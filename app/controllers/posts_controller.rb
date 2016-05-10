class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def ipnnotification
    #if we receive a hook notification
    #check if completed
    #then verify the token with paypal
    #if valid, we mark the purchase as successfully
    #and we flash the user and redirect the user's session
  end

  def buy
    @post = Post.find(params[:id])
    #initiate payment for that order
    #if successful, send user to payment page
    #send user to index page
    #flash the details of the payment, and say the payment will be confirmed in a few moments

  end

  def new
    @post = Post.new
  end

  def create
    @post  = Post.create post_params
    redirect_to posts_path
  end

  def show
    @post = Post.find(params[:id])
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to post_path @post
  end

  def destroy
    @post = Post.find(params[:id])
    @post.delete
    flash[:notice] = "Post successfully deleted"
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:caption, :image)
  end

end
