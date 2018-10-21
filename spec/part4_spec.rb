# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe "My application" do

  before(:all) do
  	    @u = User.new
	    @u.email = "user@user.com"
	    @u.password = "user"
	    @u.save

	    @admin = User.new
	    @admin.email = "administrator@administrator.com"
	    @admin.password = "admin"
	    @admin.administrator = true
	    @admin.save

	    #make free videos
	    v=Video.new
	    v.title="Video1"
	    v.description="Description1"
	    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
	    v.save

	    v=Video.new
	    v.title="Video2"
	    v.description="Description2"
	    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
	    v.save

	    #make pro videos
	    v=Video.new
	    v.title="Video3"
	    v.description="Description3"
	    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
	    v.pro = true
	    v.save

	    v=Video.new
	    v.title="Video4"
	    v.description="Description4"
	    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
	    v.pro = true
	    v.save
  end

  it "should allow requests to /pay by users who are not admins or pro" do
  	page.set_rack_session(user_id: @u.id)
  	visit '/pay'
    expect(page).to have_current_path("/pay")
  end

  it "should not allow requests to /pay for non-signed in users" do
  	page.set_rack_session(user_id: nil)
  	visit '/pay'
    expect(page).not_to have_current_path("/pay")
  end

  it "should not allow requests to /pay for admins" do
  	page.set_rack_session(user_id: @admin.id)
  	visit '/pay'
    expect(page).not_to have_current_path("/pay")
  end

  it "should allow free user to upgrade to pro by paying money" do
  	page.set_rack_session(user_id: @u.id)
  	visit '/pay'
  	#fill in form
  	#submit
  	#should be pro in db
  	u = User.get(@u.id)
  	expect(u.pro).to eq(true)
  end

end