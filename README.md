## Introduction

The goal in this assignment is to learn how to make a modern Software as a Service (SaaS) product. The goal is walk the student through the process of incrementally developing each feature. Students will learn how to make simple application features protected by authentication (signing in) and authorization (only seeing what you're allowed to). 

App is preconfigured with Stripe to allow customers to make purchases and have those purchases trigger application code. This HW will be based on the idea of making a commercial online video platform. Similar examples include: Netflix, Hulu, Art of Jiu-Jitsu Online, Yoga for BJJ, Udemy, and more.



## The Task

Make an online video API where people must sign-in to view the videos on the platform. Users who are *pro* users are allowed to view *pro* videos. Users become *pro* by paying money to upgrade their membership. Admins are allowed to see all the videos. Admins are also allowed to add, update, and delete videos.



## Getting Started

* Clone project

* Navigate to directory in command line

* Install required gems: `bundle install --without production`

* Run server with: `bundle exec ruby app.rb`

  ​



## Part 0 and 1 - Model the Data Correctly

For part 1 your job is to add to the Video and User classes such that they have all the properties we need.

Run tests with: `bundle exec rspec spec/part0_spec.rb`
Run tests with: `bundle exec rspec spec/part1_spec.rb`

#### Video

* should have property **id**

* should have property **title**, for ex: Schweller Kills Guy in Tournament

* should have property **description**, for ex: Guy didn't stand a chance

* should have property **video_url**, for ex: https://www.youtube.com/watch?v=e7-v0wymn-g

* should have *boolean* property **pro** which defaults to *false*, signifies whether a video is a *pro* video or not

  ​

#### User

* should have property **id**
* should have property **email**, for ex: eric@eric.com
* should have property **password**, for ex: eric123
* should have property **pro**, which defaults to false, signifies whether the user has paid for upgraded privileges. for ex: *false*
* should have an integer property **role_id**, which defaults to *0*, and signifieds whether the user is a free user, pro user, or admin.


## Part 2 - Check your own account

The goal here is to add a Sinatra route that listens on GET requests to `/my_account` and returns JSON corresponding to the user account whose token was passed in.

Run tests with: `bundle exec rspec spec/part2_spec.rb`


## Part 3 - Make Basic Endpoints for Videos

The goal here is to make the basic CRUD endpoints for videos.

Run tests with: `bundle exec rspec spec/part3_spec.rb`

## Part 4 - Hide information from Unpaid Customers

The goal here is to make sure that unpaid customers don't see the PRO videos.

Make sure paid customers can see FREE and PRO videos.

Run tests with: `bundle exec rspec spec/part4_spec.rb`

## Part 5, 6, 7 - Done for you! Yayyy!

Parts 5, 6, and 7 check the web UI functionality and makes sure it is running correctly.

Run tests with: `bundle exec rspec spec/part5_spec.rb`
Run tests with: `bundle exec rspec spec/part6_spec.rb`
Run tests with: `bundle exec rspec spec/part7_spec.rb`



#### Running Part 7 tests:

* Install PhantomJS via instructions here: https://github.com/teampoltergeist/poltergeist

* You need PhantomJS for the poltergeist gem (to properly test Stripe)

* Run: `bundle exec rspec spec/part7_spec.rb`

* Note: These tests take about 1 minute to run

  ​



## Submitting

#### Submit to Github Classroom

Do the normal thing, add all your changes, commit, and push.

#### Deploy to Heroku (Submit link on Blackboard)

1. Do these ONCE only per project
   1. Create a Heroku server: `heroku create`
   2. Create a database for your server: `heroku addons:create heroku-postgresql:hobby-dev`
2. Add all your changes on git and commit those changes
3. Push the code to Heroku: `git push heroku master`
4. I preconfigured the necessary files for this to work.
5. Verify all is working and submit your links (github and heroku) to me.