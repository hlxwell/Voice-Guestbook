module ApplicationHelper
  include ActsAsTaggableOn::TagsHelper

  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end
  
  def post_actions(post)
    if post.user == current_user
      raw "| #{link_to("delete", post, :method => :delete)}"
    end
  end
end
