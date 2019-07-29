require "data_mapper"
require "active_support/core_ext/hash/except"
require "active_support/core_ext/string/filters"

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
    DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
  else
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
  end
  
  class User
    include DataMapper::Resource
    property :id, Serial
    property :email, Text
    property :password, Text
    property :created_at, DateTime
    property :role_id, Integer, default: 0
    
    def login(password)
    	return self.password == password
    end

    def free_user?
        return role_id == 0
    end

    def pro_user?
        return role_id == 1
    end

    def admin?
        return role_id == 2
    end
end

  class Video
      include DataMapper::Resource
  
      property :id, Serial
      property :title, Text
      property :description, Text
      property :video_url, Text
      property :pro, Boolean, default: false
      property :created_at, DateTime

      def embed_code
        youtube_url = video_url
        if youtube_url[/youtu\.be\/([^\?]*)/]
          youtube_id = $1
        else
          # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
          youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
          youtube_id = $5
        end
      
        %Q{<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
      end

      def thumbnail
        youtube_url = video_url
        if youtube_url[/youtu\.be\/([^\?]*)/]
          youtube_id = $1
        else
          # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
          youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
          youtube_id = $5
        end
        return "http://img.youtube.com/vi/#{ youtube_id }/0.jpg"
      end
  end
  
  DataMapper.finalize
  User.auto_upgrade!
  Video.auto_upgrade!
  
  #make an admin user if one doesn't exist!
  if User.all(role_id: 2).count == 0
      u = User.new
      u.email = "admin@admin.com"
      u.password = "admin"
      u.role_id = 2
      u.save

      u = User.new
      u.email = "test@test.com"
      u.password = "test"
      u.role_id = 0
      u.save
  end

  if Video.all.count == 0
    v = Video.new
    v.title = "Killer Klowns from Outer Space"
    v.description = "When teenagers Mike (Grant Cramer) and Debbie (Suzanne Snyder) see a comet crash outside their sleepy small town, they investigate and discover a pack of murderous aliens who look very much like circus clowns. They try to warn the local authorities, but everyone assumes their story is a prank."
    v.video_url = "https://www.youtube.com/watch?v=Mq6h0hr82Zw"
    v.save 

    v = Video.new
    v.title = "Hackers"
    v.description = "A teenage hacker finds himself framed for the theft of millions of dollars from a major corporation. Master hacker Dade Murphy, aka Zero Cool, aka Crash Override, has been banned from touching a keyboard for seven years after crashing over 1,500 Wall Street computers at the age of 11."
    v.video_url = "https://www.youtube.com/watch?v=5T_CqqjOPDc"
    v.pro = true
    v.save

    v = Video.new
    v.title = "The Care Bears Movie"
    v.description = "This animated movie, featuring the popular children's characters, begins with orphanage manager Mr. Cherrywood (Mickey Rooney) telling a story about the Care Bears. In it, a young magician's assistant falls prey to an evil spirit (Jackie Burroughs) intent on destroying all happiness in the world."
    v.video_url = "https://www.youtube.com/watch?v=LTHlDeI2-bk"
    v.save

    v = Video.new
    v.title = "Kung-Fu Master"
    v.description = "A middle-aged divorcee (Jane Birkin) falls in love with a 14-year-old classmate (Mathieu Demy) of her daughter's (Charlotte Gainsbourg)."
    v.video_url = "https://www.youtube.com/watch?v=nwe3V69Kon8"
    v.save

    v = Video.new
    v.title = "Arthur's Missing Pal"
    v.description = "After Pal escapes from the house, Arthur (Carr Thompson) enlists the aid of his friends to help find his missing dog."
    v.video_url = "https://www.youtube.com/watch?v=SXYlAoVC80w"
    v.pro = true
    v.save

    v = Video.new
    v.title = "Sea Level"
    v.description = "Pup sees human poachers stealing eggs from his reef, and he follows them into the human world."
    v.video_url = "https://www.youtube.com/watch?v=UlubUGHZ0bg"
    v.save

  end