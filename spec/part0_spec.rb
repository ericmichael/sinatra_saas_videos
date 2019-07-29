require File.expand_path '../spec_helper.rb', __FILE__

describe User do
    it { should have_property           :id }
    it { should have_property           :email }
    it { should have_property           :password }
    it { should have_property           :role_id }
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
  