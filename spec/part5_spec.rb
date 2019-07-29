# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe "My application" do
  before(:all) do 
    @u = User.new
    @u.email = "abc@abc.com"
    @u.password = "abc"
    @u.save

    @admin = User.new
    @admin.email = "administrator@administrator.com"
    @admin.password = "administrator"
    @admin.role_id = 2
    @admin.save
  end

  it "should allow accessing the home page" do
    get '/'
    # Rspec 2.x
    expect(last_response).to be_ok
  end

  it "should not be signed in by default" do
    visit '/'
    expect{ page.get_rack_session_key('user_id')}.to raise_error(KeyError)
  end

  it "should allow signing up for accounts" do
    visit '/sign_up'
    fill_in 'email', with: "test@test.com"
    fill_in 'password', with: "test"

    click_on 'Register'

    u = User.last
    expect(u).not_to be_nil
    expect(u.email).to eq("test@test.com")
    expect(u.password).to eq("test")
    expect(u.role_id).to eq(0)
  end

  it "should allow logging in" do
    visit '/login'
    fill_in 'email', with: "abc@abc.com"
    fill_in 'password', with: "abc"
    click_on 'Login'

    expect(page.get_rack_session_key('user_id')).to eq(@u.id)
  end

  it "should allow signing out" do
    visit '/'
    page.set_rack_session(user_id: @u.id)
    expect(page.get_rack_session_key('user_id')).to eq(@u.id)
    visit '/logout'
    expect{ page.get_rack_session_key('user_id')}.to raise_error(KeyError)
  end

end