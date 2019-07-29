# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__
require 'jwt'

def has_status_200
	expect(last_response.status).to eq(200)
end

def has_status_201
	expect(last_response.status).to eq(201)
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

def contains_protected_video_attributes(hash)
	expect(hash.key? "id").to eq(true)
	expect(hash.key? "title").to eq(true)
	expect(hash.key? "video_url").to eq(false)
	expect(hash.key? "pro").to eq(true)
	expect(hash.key? "created_at").to eq(true)
	expect(hash.key? "thumbnail").to eq(true)
end

def protected_json_hash_matches_object?(hash, video_obj)
	contains_protected_video_attributes(hash)
	expect(hash["id"]).to eq(video_obj.id)
	expect(hash["title"]).to eq(video_obj.title)
	expect(hash["pro"]).to eq(video_obj.pro)
	expect(hash["thumbnail"]).to eq(video_obj.thumbnail)
end


def contains_video_attributes(hash)
	expect(hash.key? "id").to eq(true)
	expect(hash.key? "title").to eq(true)
	expect(hash.key? "video_url").to eq(true)
	expect(hash.key? "pro").to eq(true)
	expect(hash.key? "created_at").to eq(true)
	expect(hash.key? "embed_code").to eq(true)
	expect(hash.key? "thumbnail").to eq(true)
end

def json_hash_matches_object?(hash, video_obj)
	contains_video_attributes(hash)
	expect(hash["id"]).to eq(video_obj.id)
	expect(hash["title"]).to eq(video_obj.title)
	expect(hash["video_url"]).to eq(video_obj.video_url)
	expect(hash["pro"]).to eq(video_obj.pro)
	expect(hash["embed_code"]).to eq(video_obj.embed_code)
	expect(hash["thumbnail"]).to eq(video_obj.thumbnail)

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
  	@p.title = "Sample video"
  	@p.video_url = "https://via.placeholder.com/1080.jpg"
  	@p.save

  	@p = Video.new
  	@p.title = "Sample video"
  	@p.video_url = "https://via.placeholder.com/1080.jpg"
  	@p.save
  end

  it "should have two users in test database" do 
  	expect(User.all.count).to eq(2)
  end

  it "should not allow creating a video" do
  	post '/api/videos?title=sweet&video_url=https://via.placeholder.com/1080.jpg'
  	has_status_unauthorized
	end
	
	it "should not allow reading a single video" do
  	get "/api/videos/#{@p.id}"
  	has_status_unauthorized
	end
	
	it "should not allow reading all videos" do
  	get "/api/videos"
  	has_status_unauthorized
	end
	
  it "should not allow deleting a video" do
  	p = Video.last
  	delete "/api/videos/#{@p.id}"
  	has_status_unauthorized
  end
end

describe "With valid USER token, API" do
	before(:all) do
		get "/api/login?username=p1@p1.com&password=p1"
	  	has_status_200	
	  	@token = JSON.parse(last_response.body)["token"]
		  header "AUTHORIZATION", "bearer #{@token}"
		  @u = User.first(email: "p1@p1.com")
	end

	it "should allow accessing all videos" do
		get "/api/videos"
		#puts last_response.status
		# Rspec 2.x
		has_status_200
	  end
	
	  it "should include all FREE videos on /api/videos" do
		get "/api/videos"
		json_response = last_response.body
		videos = JSON.parse(json_response)
	
		video_ids = []
	
		videos.each do |p|
		  video_ids << p["id"]
		  video_obj = Video.get(p["id"])
		  contains_protected_video_attributes(p)
		  protected_json_hash_matches_object?(p, video_obj)
		end
	
		master_videos = Video.all(pro: false)
		master_video_ids = []
	
		master_videos.each do |p|
		  master_video_ids << p.id
		end
	
		expect((video_ids - master_video_ids).empty?).to eq(true)
	  end
	
	  it "should include data for video with id 1 on /api/videos/1" do
		get "/api/videos/1"
		video_json = last_response.body
		video_hash = JSON.parse(video_json)
		video = Video.get(1)
	
		has_status_200
		json_hash_matches_object?(video_hash, video)
	  end
	
	  it "should allow accessing a specific video" do
		  p = Video.last
		  get "/api/videos/#{p.id}"
		  has_status_200
		  video_json = last_response.body
		  video_hash = JSON.parse(video_json)
		  json_hash_matches_object?(video_hash, p)
	  end
	
	  it "should 404 for non-existent video" do
		  p = Video.last
		  get "/api/videos/#{p.id + 200}"
		  has_status_404
	  end
end

describe "With valid ADMIN token, API" do
	before(:all) do
        @admin = User.new
        @admin.email = "a@a.com"
        @admin.password = "a"
        @admin.role_id = 2
        @admin.save

		get "/api/login?username=a@a.com&password=a"

		has_status_200	

	  	@token = JSON.parse(last_response.body)["token"]
		header "AUTHORIZATION", "bearer #{@token}"
		@u = User.first(email: "administrator@administrator.com")
	end
	
	it "should allow creating a video" do
        post "/api/videos", title: "cool image", video_url: "https://www.youtube.com/watch?v=Fthm8G4NbJc", description: "test desc"
        has_status_201
        @p = Video.last
        expect(@p.video_url).to eq("https://www.youtube.com/watch?v=Fthm8G4NbJc")
        expect(@p.title).to eq("cool image")
    end

    it "should allow updating a video" do
        @p = Video.last
        patch "/api/videos/#{@p.id}", title: "sinatra4lyfe"
        has_status_200
        expect(@p.video_url).to eq("https://www.youtube.com/watch?v=Fthm8G4NbJc")
        expect(@p.title).to eq("sinatra4lyfe")
    end

    it "should allow deleting a video" do
        p = Video.last
        delete "/api/videos/#{p.id}"
        expect(Video.get(p.id)).to be_nil
    end
end