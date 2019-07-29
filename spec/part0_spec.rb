require File.expand_path '../spec_helper.rb', __FILE__

  describe User do
    it { should have_property           :id }
    it { should have_property           :email }
    it { should have_property           :password }
    it { should have_property           :role_id }
  end
  
  describe Video do
    it { should have_property           :id }
    it { should have_property           :title  }
    it { should have_property           :description  }
    it { should have_property           :video_url  }
    it { should have_property           :pro }
  end

  def has_status_200
      expect(last_response.status).to eq(200)
  end
  
  def has_status_404
      expect(last_response.status).to eq(404)
  end
  
  def has_status_unauthorized
      expect(last_response.status).to eq(401)
  end
  
  def has_status_unprocessable
      expect(last_response.status).to eq(422)
  end
  
  def has_status_bad_request
      expect(last_response.status).to eq(400)
  end
  
  def has_status_created
      expect(last_response.status).to eq(201)
  end
  
  def is_valid_token?(encoded_token)
      begin
      JWT.decode encoded_token, "lasjdflajsdlfkjasldkfjalksdjflk", true, { algorithm: 'HS256' }
      return true
      rescue
      return false
      end
  end
  
  def get_user_id_from_token(encoded_token)
      begin
      decoded = JWT.decode encoded_token, "lasjdflajsdlfkjasldkfjalksdjflk", true, { algorithm: 'HS256' }
      return decoded[0]["user_id"]
      rescue
      return nil
      end
  end
  
  describe "When not signed in, API" do
    before(:all) do 
        @u = User.new
        @u.email = "p1@p1.com"
        @u.password = "p1"
        @u.save
  
        @u2 = User.new
        @u2.email = "p2@p2.com"
        @u2.password = "p2"
        @u2.save
    end
  
    it "should have two users in test database" do 
        expect(User.all.count).to eq(2)
    end
  
    it "should get back valid token with valid sign-in" do
        get "/api/login?username=p1@p1.com&password=p1"
        has_status_200	
        token = JSON.parse(last_response.body)["token"]
        expect(is_valid_token?(token)).to eq(true)
        token_user_id = get_user_id_from_token(token)
        token_user = User.get(token_user_id) 
        expect(token_user.id).to eq(@u.id)
    end
  
    it "should give error with no token" do
      get "/api/login?username=p1@p1.com&password=p1"
      has_status_200	
      @token = JSON.parse(last_response.body)["token"]
      header "AUTHORIZATION", "bearer #{@token}"
    end
  
    it "should have status 401 with invalid token on /api/token_check" do
      header "AUTHORIZATION", "bearer NOTVALIDTOKEN"
      get "/api/token_check"
      has_status_unauthorized
    end
  
    it "should allow registering a new user" do
      post "/api/register?username=billy&password=bob"
      has_status_created
      u = User.last
      expect(u.email).to eq("billy")
      expect(u.password).to eq("bob")
    end
  
    it "should not allow registering a user when username is already in use" do
      post "/api/register?username=p1@p1.com&password=bob"
      has_status_unprocessable
    end
  
    it "should not allow registering a user when username is missing" do
      post "/api/register?password=bob"
      has_status_bad_request
    end
  
    it "should not allow registering a user when password is missing" do
      post "/api/register?username=billy"
      has_status_bad_request
    end
  end
  
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


describe "When User, my application" do

  before(:all) do
    #make user
    @u = User.new
    @u.email = "user@user.com"
    @u.password = "user"
    @u.save
    visit "/"
    page.set_rack_session(user_id: @u.id)

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

  it "should not allow requests to /videos/new (should redirect to '/')" do
    visit '/videos/new'
    expect(page).to have_current_path("/")
  end


  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should allow viewing of free video" do
    free_video = Video.first(pro: false)
    visit "/videos/#{free_video.id}"
    expect(page.body).to include(free_video.title)
  end

  it "should not allow viewing of pro video" do
    pro_video = Video.first(pro: true)
    visit "/videos/#{pro_video.id}"
    expect(page).to have_current_path("/upgrade")
  end
end

describe "When Pro User, my application" do
    before(:all) do
      #make user
      @u = User.new
      @u.email = "pro@pro.com"
      @u.password = "pro"
      @u.role_id = 1
      @u.save
      page.set_rack_session(user_id: @u.id)
    end

  it "should not allow requests to /videos/new (should redirect to '/')" do
    visit '/videos/new'
    expect(page).to have_current_path("/")
  end


  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should allow viewing of free video" do
    free_video = Video.first(pro: false)
    visit "/videos/#{free_video.id}"
    expect(page.body).to include(free_video.title)
  end

  it "should allow viewing of pro video" do
    pro_video = Video.first(pro: true)
    visit "/videos/#{pro_video.id}"
    expect(page.body).to include(pro_video.title)
  end
end

describe "When Admin, my application" do
  before(:all) do
    #make user
    @u = User.new
    @u.email = "admin@admin.com"
    @u.password = "admin"
    @u.role_id = 2
    @u.save
    page.set_rack_session(user_id: @u.id)

  end

  it "should allow admins to create videos" do
    visit '/videos/new'
    fill_in 'title', with: "TestTitle"
    fill_in 'description', with: "TestDescription"
    fill_in 'video_url', with: "https://www.youtube.com/watch?v=WwTpPd_efdM"
    check 'pro'
    click_on "Submit"

    v = Video.last
    expect(v.title).to eq("TestTitle")
    expect(v.description).to eq("TestDescription")
    expect(v.video_url).to eq("https://www.youtube.com/watch?v=WwTpPd_efdM")
    expect(v.pro).to eq(true)
  end

  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should allow viewing of free video" do
    free_video = Video.first(pro: false)
    visit "/videos/#{free_video.id}"
    expect(page.body).to include(free_video.title)
  end

  it "should allow viewing of pro video" do
    pro_video = Video.first(pro: true)
    visit "/videos/#{pro_video.id}"
    expect(page.body).to include(pro_video.title)
  end
end

describe "When not signed in, my application" do
  it "should not allow requests to /videos/new (should redirect to '/login')" do
    page.set_rack_session(user_id: nil)
    visit '/videos/new'
    expect(page).to have_current_path("/login").or have_current_path("/")
  end

  it "should not allow viewing of free video" do
    free_video = Video.first(pro: true)
    visit "/videos/#{free_video.id}"
    expect(page).to have_current_path("/login")
  end

  it "should not allow viewing of pro video" do
    pro_video = Video.first(pro: true)
    visit "/videos/#{pro_video.id}"
    expect(page).to have_current_path("/login")
  end
end

