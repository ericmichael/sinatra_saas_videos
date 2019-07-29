# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__
require 'jwt'

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

def has_status_created
	expect(last_response.status).to eq(201)
end

def valid_json?(json)
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
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

  	@p = Video.new
  	@p.title = "Sample post"
    @p.video_url = "https://via.placeholder.com/1080.jpg"
    @p.pro = false
  	@p.save
  end

  it "should have two users in test database" do 
  	expect(User.all.count).to eq(2)
  end

#   get “/my_account”
#   Response Status: 2xx OK
#   Response Body: JSON representing the user that is currently logged in
#   Status: 404 if user not found

  it "should not allow access to GET /my_account" do
	get "/api/my_account"
	has_status_unauthorized
  end
  
end

describe "With valid token, API" do
	before(:all) do
		get "/api/login?username=p1@p1.com&password=p1"
	  	has_status_200	
	  	@token = JSON.parse(last_response.body)["token"]
		header "AUTHORIZATION", "bearer #{@token}"
		@u = User.first(email: "p1@p1.com")
  end

#   get “/my_account”
#   Response Status: 2xx OK
#   Response Body: JSON representing the user that is currently logged in
#   Status: 404 if user not found
    it "should give JSON representing the currently logged in user on GET /my_account" do
			get "/api/my_account"
			expect(valid_json?(last_response.body))
			ujson = JSON.parse(last_response.body)
			expect(ujson.has_key?("id")).to eq(true)
			expect(ujson.has_key?("email")).to eq(true)
			expect(ujson.has_key?("password")).to eq(false)
            expect(ujson.has_key?("created_at")).to eq(true)
			expect(ujson.has_key?("role_id")).to eq(true)

			expect(ujson["id"]).to eq(@u.id)
            expect(ujson["email"]).to eq(@u.email)
            expect(ujson["role_id"]).to eq(@u.role_id)
    end
end