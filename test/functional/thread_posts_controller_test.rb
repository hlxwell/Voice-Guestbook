require 'test_helper'

class ThreadPostsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => ThreadPost.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    ThreadPost.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    ThreadPost.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to thread_post_url(assigns(:thread_post))
  end
  
  def test_edit
    get :edit, :id => ThreadPost.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    ThreadPost.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ThreadPost.first
    assert_template 'edit'
  end
  
  def test_update_valid
    ThreadPost.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ThreadPost.first
    assert_redirected_to thread_post_url(assigns(:thread_post))
  end
  
  def test_destroy
    thread_post = ThreadPost.first
    delete :destroy, :id => thread_post
    assert_redirected_to thread_posts_url
    assert !ThreadPost.exists?(thread_post.id)
  end
end
