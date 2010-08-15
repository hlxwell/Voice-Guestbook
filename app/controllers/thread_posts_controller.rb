class ThreadPostsController < ApplicationController
  before_filter :require_user, :except => [:index, :show]

  def index
    @thread_posts = ThreadPost.parent_post.paginate :page => params[:page], :per_page => 10
  end

  def with_tag
    @tag_name = "with tag: <span class='quiet'>\"#{params[:id]}\"</span>"
    @thread_posts = ThreadPost.tagged_with(params[:id]).by_date_desc.paginate :page => params[:page], :per_page => 10
    render :file => "thread_posts/index"
  end

  def show
    @thread_post = ThreadPost.find(params[:id])
    @thread_children = @thread_post.children
  end

  def new
    @thread_post = ThreadPost.new
    @voice_file_name = "voice_file_#{Time.now.to_i}_#{rand(10000)}"
  end

  def create
    @thread_post = ThreadPost.new(params[:thread_post])

    if Rails.env == "development" or File.exist?("/opt/adobe/fms/applications/voice_guestbook/streams/_definst_/#{params[:voice_file_name]}.flv")
      @thread_post.media_filename = params[:voice_file_name]
    end

    if @thread_post.save
      flash[:notice] = "Successfully created thread post."
      redirect_to(@thread_post.parent||@thread_post)
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
      redirect_to(@thread_post.parent||@thread_post)
    else
      render :action => 'edit'
    end
  end

  def destroy
    parent = nil
    @thread_post = ThreadPost.find(params[:id])
    parent = @thread_post.parent
    @thread_post.destroy
    flash[:notice] = "Successfully destroyed thread post."

    redirect_to parent.nil? ? thread_posts_url : thread_post_path(parent)
  end
end
