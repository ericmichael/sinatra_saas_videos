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



## Part 0 - Check if my code broke

Run tests with: `bundle exec rspec spec/part0_spec.rb`


## Part 1 - Check if your Stripe account is configured correctly

* Get a Stripe account and find your TEST API KEYS.

* Set your STRIPE_PUBLISHABLE_KEY environment variable.

* Set your STRIPE_SECRET_KEY environment variable.

### Setting Environment Variables

#### Windows Users:

Use the start menu to find where to Set Environment Variables for your Account.

#### Mac / Linux / Unix Users:

Edit your ~/.bash_profile and use the following example for what to add:
* `export STRIPE_PUBLISHABLE_KEY=whateverisinyourstripeaccount`
* `export STRIPE_SECRET_KEY=yourstripesecretkey`
* DUHHH OBVIOUSLY REPLACE WITH REAL VALUES

### Run tests

* Install PhantomJS via instructions here: https://github.com/teampoltergeist/poltergeist

* You need PhantomJS for the poltergeist gem (to properly test Stripe)

* Run: `bundle exec rspec spec/part1_spec.rb`

* Note: These tests take about 1 minute to run

## Part 2 - Add "My Account" Lookup

You should probably [read the API docs](https://documenter.getpostman.com/view/7032600/SVYkvM7n?version=latest).

The goal here is to add a Sinatra route that listens on GET requests to `/my_account` and returns JSON corresponding to the user account whose token was passed in.

Run tests with: `bundle exec rspec spec/part2_spec.rb`


## Part 3 - Make Basic Endpoints for Videos

You should probably [read the API docs](https://documenter.getpostman.com/view/7032600/SVYkvM7n?version=latest).

The goal here is to make the basic CRUD endpoints for videos.

Run tests with: `bundle exec rspec spec/part3_spec.rb`

## Part 4 - Hide information from Unpaid Customers

You should probably [read the API docs](https://documenter.getpostman.com/view/7032600/SVYkvM7n?version=latest).

The goal here is to make sure that unpaid customers don't see the PRO videos.

Make sure paid customers can see FREE and PRO videos.

Run tests with: `bundle exec rspec spec/part4_spec.rb`

## Hint 1 - Hiding properties from JSON and adding new info to JSON

Ok, so you ran into some trouble. How do you exclude information from `to_json` AND how do you include information?

Suppose you had the following Ruby class:

```ruby
class User
    include DataMapper::Resource
    property :id, Serial
    property :first_name, Text
    property :last_name, Text

    def full_name
        return first_name + " " + last_name
    end
end
```

Let's say you had to make an API to display a user's information but you wanted the JSON to have their full name instead of their first and last name.

Here is how you would do it.

```ruby
get "/api/users/:id" do
    u = User.get(params["id"])
    if !u.nil
        halt 200, u.to_json(exclude: [:first_name, :last_name], methods: [:full_name])
    else
        halt 404, {message: "User not found"}.to_json
    end
end
```

## Hint 2 - Use 200, 201, 404, and 422 when it makes sense

* If you are looking up an object by ID and it doesn't exist then halt 404
* If you just created something then halt 201
* If someone asks you to make something and doesn't hand you all the required params, halt 422
* If someone is not an administrator but they are trying to create, update, or delete  then halt 401
* If someone is unpaid and they are requesting the details of a paid video then halt 401
* If everything is gravy, then halt 200

## Submitting

#### Submit to Github Classroom

Do the normal thing, add all your changes, commit, and push.

#### Deploy to Heroku (Submit link on Blackboard)

1. Do these ONCE only per project
   1. Create a Heroku server: `heroku create`
   2. Create a database for your server: `heroku addons:create heroku-postgresql:hobby-dev`
2. Set your Stripe Environment Variables on Heroku
   1. `heroku config:set STRIPE_PUBLISHABLE_KEY=whatever`
   2. `heroku config:set STRIPE_SECRET_KEY=whatever`
3. Add all your changes on git and commit those changes
4. Push the code to Heroku: `git push heroku master`
5. I preconfigured the necessary files for this to work.
6. Verify all is working and submit your links (github and heroku) to me.