require "sinatra"
require "sinatra/namespace"
require_relative "authentication.rb"
require_relative "api_authentication.rb"
require "stripe"

def api_admin_only!
	api_authenticate!
	if !current_user.admin?
		halt 401, {"message"=>"Error: Not Authorized"}.to_json
	end
end

def placeholder
	halt 501, {message: "Not Implemented"}.to_json
end

namespace '/api' do

	# Make sure they are signed in
	# Gives back current user's account information as JSON
	# EXCLUDE their password from the JSON
	get "/my_account" do
		placeholder
	end

	# Make sure they are signed in
	# Gives back JSON array representing every
	# video in database
	# EXCLUDE: video_url
	# INCLUDE: result of thumbnail method
	get "/videos" do
		placeholder
	end

	# Make sure they are signed in
	# Give back JSON object representing the video with
	# the provided ID
	# INCLUDE: thumbnail, embed_code
	# Authorization: only pro users or admins
	# 404 if not found
	get "/videos/:id" do
		placeholder
	end

	# Creates a video from the parameters provided
	# Gives back 201 - Created and JSON representation of the created video
	# Required parameters: title, video_url, description
	# Optional parameters: pro
	# If missing required parameters, give back status 422 - Unprocessable
	# Authorization: only admins
	post "/videos" do
		placeholder
	end

	# Updates the video with the provided ID
	# Optional parameters: title, description, video_url, pro
	# Gives back 200 - OK  and JSON representing updated video
	# 404 if not found
	# Authorization: only admins
	patch "/videos/:id" do
		placeholder
	end

	# Deletes the video with the provided ID
	# 404 if not found
	# Authorization: only admins
	delete "/videos/:id" do
		placeholder
	end
end

# DO NOT TOUCH BELOW THIS LINE
# WEB UI CODE

set :publishable_key, ENV["STRIPE_PUBLISHABLE_KEY"]
set :secret_key, ENV["STRIPE_SECRET_KEY"]

Stripe.api_key = settings.secret_key

def admin_only!
	authenticate!
	redirect "/" unless current_user.admin?
end

get "/" do
	erb :index
end

get "/videos" do
	@videos = Video.all

	erb :videos
end

get "/videos/new" do
	admin_only!
	erb :new_video
end

get "/videos/:id" do
	authenticate!
	@video = Video.get(params["id"])
	if @video.nil?
		redirect "/videos"
	elsif @video.pro && !current_user.pro_user? && !current_user.admin?
		redirect "/upgrade"
	else
		erb :show_video
	end
end

post "/videos/create" do
	admin_only!
	if params["title"] && params["video_url"]
		v = Video.new
		v.title = params["title"]
		v.description = params["description"]
		v.video_url = params["video_url"]
		v.pro = true if params["pro"] == "on"
		v.save
	end
end


get "/upgrade" do
	authenticate!
	redirect "/" if current_user.pro_user? || current_user.admin?

	erb :upgrade
end

post "/charge" do
    authenticate!
	redirect "/" if current_user.pro_user? || current_user.admin?

	begin 
    @amount = 500
    customer = Stripe::Customer.create(
        :email => 'customer@example.com',
        :source  => params[:stripeToken]
    )
    
    charge = Stripe::Charge.create(
        :amount      => @amount,
        :description => 'Sinatra Charge',
        :currency    => 'usd',
        :customer    => customer.id
    )
    current_user.role_id = 2
    current_user.save
	erb :payment_successful

	rescue Stripe::CardError 
		erb :payment_failed
	end

end