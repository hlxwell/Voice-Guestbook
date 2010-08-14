require 'spec_helper'

describe Tabletastic::TableBuilder do

  before do
    reset_output_buffer!
    mock_everything
    ::Post.stub!(:content_columns).and_return([mock('column', :name => 'title'), mock('column', :name => 'body'), mock('column', :name => 'created_at')])
    @post.stub!(:title).and_return("The title of the post")
    @post.stub!(:body).and_return("Lorem ipsum")
    @post.stub!(:created_at).and_return(Time.now)
    @post.stub!(:id).and_return(2)
    @posts = [@post]
  end

  context "without a block" do
    context "with no other arguments" do
      before do
        concat(table_for(@posts) { |t| t.data })
      end

      it "should output table with id of the class of the collection" do
        output_buffer.should have_tag("table#posts")
      end

      it "should output head" do
        output_buffer.should have_table_with_tag("thead")
      end

      it "should have a <th> for each attribute" do
        # title and body
        output_buffer.should have_table_with_tag("th", :count => 2)
      end

      it "should include header for Title" do
        output_buffer.should have_table_with_tag("th", "Title")
      end

      it "should include header for Body" do
        output_buffer.should have_table_with_tag("th", "Body")
      end

      it "should output body" do
        output_buffer.should have_table_with_tag("tbody")
      end

      it "should include a row for each record" do
        output_buffer.should have_table_with_tag("tbody") do |tbody|
          tbody.should have_tag("tr", :count => 1)
        end
      end

      it "should have data for each field" do
        output_buffer.should have_table_with_tag("td", "The title of the post")
        output_buffer.should have_table_with_tag("td", "Lorem ipsum")
      end

      it "should include the id for the <tr> for each record" do
        output_buffer.should have_table_with_tag("tr#post_#{@post.id}")
      end

      it "should cycle row classes" do
        reset_output_buffer!
        @posts = [@post, @post]
        concat(
          table_for(@posts) do |t|
            concat(t.data)
          end)
        output_buffer.should have_table_with_tag("tr.odd")
        output_buffer.should have_table_with_tag("tr.even")
      end

      context "when collection has associations" do
        it "should handle belongs_to associations" do
          ::Post.stub!(:reflect_on_all_associations).with(:belongs_to).and_return([@mock_reflection_belongs_to_author])
          @posts = [@freds_post]
          concat table_for(@posts) { |t| t.data }
          output_buffer.should have_table_with_tag("th", "Author")
          output_buffer.should have_table_with_tag("td", "Fred Smith")
        end

        it "should handle has_one associations" do
          ::Author.stub!(:reflect_on_all_associations).with(:has_one).and_return([@mock_reflection_has_one_profile])
          concat table_for([@fred]) { |t| t.data }
          output_buffer.should have_table_with_tag("th", "Profile")
        end
      end
    end

    context "with options[:actions]" do
      it "includes path to post for :show" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :show)
        end)
        output_buffer.should have_table_with_tag("a[@href=\"/posts/#{@post.id}\"]")
        output_buffer.should have_table_with_tag("th", "")
      end

      it "should have a cell with default class 'actions' and the action name" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :show)
        end)
        output_buffer.should have_tag("td.actions.show_link") do |td|
          td.should have_tag("a")
        end
      end

      it "includes path to post for :edit" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :edit)
        end)
        output_buffer.should have_tag("a[@href=\"/posts/#{@post.id}/edit\"]", "Edit")
      end

      it "includes path to post for :destroy" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :destroy)
        end)
        output_buffer.should have_table_with_tag("a[@href=\"/posts/#{@post.id}\"]")
        output_buffer.should have_table_with_tag("th", "")
      end

      it "includes path to post for :show and :edit" do
        concat(table_for(@posts) do |t|
          t.data(:actions => [:show, :edit])
        end)
        output_buffer.should have_tag("td:nth-child(3) a[@href=\"/posts/#{@post.id}\"]", "Show")
        output_buffer.should have_tag("td:nth-child(4) a[@href=\"/posts/#{@post.id}/edit\"]", "Edit")
      end

      it "includes path to post for :all" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :all)
        end)
        output_buffer.should have_tag("td:nth-child(3) a[@href=\"/posts/#{@post.id}\"]", "Show")
        output_buffer.should have_tag("td:nth-child(4) a[@href=\"/posts/#{@post.id}/edit\"]", "Edit")
        output_buffer.should have_tag("td:nth-child(5) a[@href=\"/posts/#{@post.id}\"]", "Destroy")
      end

      context "with options[:actions_prefix]" do
        it "includes path to admin post for :show" do
          concat(table_for(@posts) do |t|
            t.data(:actions => :show, :action_prefix => :admin)
          end)
          output_buffer.should have_tag("td:nth-child(3) a[@href=\"/admin/posts/#{@post.id}\"]", "Show")
        end

        it "includes path to admin post for :edit" do
          concat(table_for(@posts) do |t|
            t.data(:actions => :edit, :action_prefix => :admin)
          end)
          output_buffer.should have_tag("td:nth-child(3) a[@href=\"/admin/posts/#{@post.id}/edit\"]", "Edit")
        end

        it "includes path to admin post for :destroy" do
          concat(table_for(@posts) do |t|
            t.data(:actions => :destroy, :action_prefix => :admin)
          end)
          output_buffer.should have_tag("td:nth-child(3) a[@href=\"/admin/posts/#{@post.id}\"]", "Destroy")
        end

        it "includes path to admin for all actions" do
          concat(table_for(@posts) do |t|
            concat(t.data(:actions => :all, :action_prefix => :admin))
          end)
          output_buffer.should have_tag("td:nth-child(3) a[@href=\"/admin/posts/#{@post.id}\"]", "Show")
          output_buffer.should have_tag("td:nth-child(4) a[@href=\"/admin/posts/#{@post.id}/edit\"]", "Edit")
          output_buffer.should have_tag("td:nth-child(5) a[@href=\"/admin/posts/#{@post.id}\"]", "Destroy")
        end
      end
    end

    context "with a list of attributes" do
      before do
        concat(table_for(@posts) do |t|
          t.data(:title, :created_at)
        end)
      end

      it "should call each method passed in, and only those methods" do
        output_buffer.should have_table_with_tag("th", "Title")
        output_buffer.should have_table_with_tag("th", "Created at")
        output_buffer.should_not have_table_with_tag("th", "Body")
      end
    end

    context "with a list of attributes and options[:actions]" do
      it "includes path to post for :show" do
        concat(table_for(@posts) do |t|
          concat(t.data(:title, :created_at, :actions => :show))
        end)
        output_buffer.should have_tag("th:nth-child(1)", "Title")
        output_buffer.should have_tag("th:nth-child(2)", "Created at")
        output_buffer.should have_tag("th:nth-child(3)", "")
        output_buffer.should_not have_tag("th", "Body")

        output_buffer.should have_tag("td:nth-child(3) a[@href=\"/posts/#{@post.id}\"]")
      end
    end
  end

  context "with a block" do
    context "and normal columns" do
      before do
        concat(table_for(@posts) do |t|
          t.data do
            t.cell(:title)
            t.cell(:body)
          end
        end)
      end

      it "should include the data for the fields passed in" do
        output_buffer.should have_table_with_tag("th", "Title")
        output_buffer.should have_tag("td", "The title of the post")
        output_buffer.should have_tag("td", "Lorem ipsum")
      end
    end

    context "with custom cell options" do
      before do
        concat(table_for(@posts) do |t|
          t.data do
            t.cell(:title, :heading => "FooBar")
            t.cell(:body, :cell_html => {:class => "batquux"})
          end
        end)
      end

      it "should change the heading label for :heading option" do
        output_buffer.should have_table_with_tag("th", "FooBar")
        output_buffer.should have_table_with_tag("th", "Body")
      end

      it "should pass :cell_html to the cell" do
        output_buffer.should have_table_with_tag("td.batquux")
      end
    end

    context "with custom cell options" do
      before do
        concat(table_for(@posts) do |t|
          t.data do
            t.cell(:title) {|p| link_to p.title, "/" }
            t.cell(:body, :heading => "Content") {|p| p.body }
          end
        end)
      end

      it "accepts a block as a lazy attribute" do
        output_buffer.should have_table_with_tag("th:nth-child(1)", "Title")
        output_buffer.should have_table_with_tag("td:nth-child(1)") do |td|
          td.should have_tag("a", "The title of the post")
        end
      end

      it "accepts a block as a lazy attribute (2)" do
        output_buffer.should have_table_with_tag("th:nth-child(2)", "Content")
        output_buffer.should have_table_with_tag("td:nth-child(2)", "Lorem ipsum")
      end
    end

    context "with options[:actions]" do
      it "includes path to post for :show" do
        concat(table_for(@posts) do |t|
          t.data(:actions => :show) do
            t.cell(:title)
            t.cell(:body)
          end
        end)
        output_buffer.should have_table_with_tag("td:nth-child(3) a[@href=\"/posts/#{@post.id}\"]")
      end
    end

    context "and normal/association columns" do
      before do
        ::Post.stub!(:reflect_on_all_associations).with(:belongs_to).and_return([@mock_reflection_belongs_to_author])
        @posts = [@freds_post]
        concat(table_for(@posts) do |t|
          t.data do
            t.cell(:title)
            t.cell(:author)
          end
        end)
      end

      it "should include normal columns" do
        output_buffer.should have_table_with_tag("th:nth-child(1)", "Title")
        output_buffer.should have_table_with_tag("td:nth-child(1)", "Fred's Post")
      end

      it "should include belongs_to associations" do
        output_buffer.should have_table_with_tag("th:nth-child(2)", "Author")
        output_buffer.should have_table_with_tag("td:nth-child(2)", "Fred Smith")
      end
    end
  end

  context "using human_attribute_names" do
    it "should work" do
      ::Post.stub!(:human_attribute_name).with('body').and_return("Blah blue")

      concat(table_for(@posts) do |t|
        t.data do
          t.cell(:title)
          t.cell(:body)
        end
      end)

      output_buffer.should have_table_with_tag("th", "Blah blue")
    end
  end

  context "when table_for is not passed a block" do
    it "the data should use the default option" do
      Tabletastic.default_table_block = lambda {|table| table.data}
      concat( table_for(@posts) )
      output_buffer.should have_table_with_tag("td", "The title of the post")
    end
  end
end
