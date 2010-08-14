class ThreadPostsController < ApplicationController
  before_filter :require_user, :except => [:index, :show]
  
  def index
    @thread_posts = ThreadPost.parent_post.all
  end

  def show
    @thread_post = ThreadPost.find(params[:id])
    @thread_children = @thread_post.children
  end

  def new
    @thread_post = ThreadPost.new
  end

  def create
    @thread_post = ThreadPost.new(params[:thread_post])
    if @thread_post.save
      flash[:notice] = "Successfully created thread post."
      redirect_to @thread_post.parent.nil? ? @thread_post : @thread_post.parent
    else
      render :action => 'new'
    end
  end

  def edit
    @thread_post = ThreadPost.find(params[:id])
  end

  def update
    @thread_post = ThreadPost.find(params[:id])
    if @thread_post.update_attributes(params[:thread_post])
      flash[:notice] = "Successfully updated thread post."
      redirect_to @thread_post
    else
      render :action => 'edit'
    end
  end

  def destroy
    @thread_post = ThreadPost.find(params[:id])
    @thread_post.destroy
    flash[:notice] = "Successfully destroyed thread post."
    redirect_to thread_posts_url
  end
end
