require 'spec_helper'

describe 'Trailblazer Basics' do
  User = Struct.new(:signed_in) do
    def signed_in?
      signed_in
    end
  end

  class BlogPost

  end

  class BlogPost::Create < Trailblazer::Operation
    step :do_everything!

    def do_everything!(options, params:, current_user:, **)
      return unless current_user.signed_in?

      model = BlogPost.new
      model.update_attributes(params[:blog_post])

      model.save && BlogPost::Notification.(current_user, model)
    end
  end

  let (:anonymous) { User.new(false) }
  let (:signed_in) { User.new(true) }
  let (:pass_params) { { blog_post: { title: "Puns: Ode to Joy" } } }

  it "fails with anonymous" do
    result = BlogPost::Create.(pass_params, "current_user" => anonymous)

    expect(result).to be_failure

    allow(BlogPost).to receive(:last) {nil}
    expect(BlogPost.last).to be_nil
  end
end