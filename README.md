# Sinatra Fwitter 6 -  APIs

## Outline
 1. Explain how APIs can be used to extend the functionality of our programs. 
 2. Add instructions for signing up for Twilio.
 3. Include the `twilio-ruby` gem into the Gemfile. 
 4. Use Twilio to send a text message when the user submits their form. 

## Objectives

1. Explain what an API is and why we use them
2. Read API documentation
3. Incorporate APIs into Sinatra Applications

## Overview

APIs, or Application Programming Interfaces, allow us to programatically interact with other Applications. Ever see a live Twitter timeline on a different website? How about login to an app using your Facebook or Google account? All of this is possible because of APIs. 

Today, we'll be using the [Twilio](https://www.twilio.com/) API to allow our Fwitter uses to text their messages to a friend. 

## Instructions

### Setup

Fork and clone this repository to get started! 


### Setting Up The API

First, you'll need to sign up for a Twilio account [here](https://www.twilio.com/try-twilio). It's free to sign up for a test account - to get the full features, you'll need to pay. For example, you'll only be able to send text messages to yourself using the demo account. 

Many APIs have Ruby wrappers that we can use, and Twilio is no exception. Add the gem `twilio-ruby` to your Gemfile and run `bundle install`. 

Every API functions a little bit differnetly, so it's important to get used to reading the documenation. Some APIs are very well documented, others are not. In any case, someone wrote this code for you to use - be grateful for them! If you find bugs or errors in the documentation, you can raise an issue or submit a pull request! 

Check out the documenation for the `twilio-ruby` gem [here](https://github.com/twilio/twilio-ruby/blob/master/README.md). 

We'll need to create a new instance of the Twilio::REST::Client using our account_sid and auth_token. You can find your information [here](https://www.twilio.com/user/account/developer-tools/api-explorer/message-create). Since we don't want to include that information on Github, we're using a get called `dotenv` to hide that information. Create a file called `.env` in the root of your project and define two constants: `ACCOUNT_SID` and `AUTH_TOKEN`. 

```bash
ACCOUNT_SID = YOUR_ACCOUNT_SID_HERE 
AUTH_TOKEN = YOUR_AUTH_TOKEN_HERE

```

Set They'll get loaded automatically in your application controller without being checked into git. 

### Updating our Form

Let's add an optional field to our new tweet form called "phone_number". If a user fills it out, we'll text that message to whatever number they entered. In the `tweet.erb` file, add a text field with a name of `phone_number`

```ERB
  <h2>Add a tweet</h2>
  <form action="/tweet" method="POST">
  <p><strong>Status:</strong> <input type="text" name="status"></p>
  <p><strong>Phone Number (Optional - just type in 10 digits ie 1234567890): </strong> <input type="text" name="phone_number"></p>
  <input class="btn btn-primary" type="submit">
  </form>
```

### Updating our Controller

Now, in our application_controller, we'll check to see if the user entered anything into that form by comparing it to an empty string.

```ruby
  post '/tweet' do
    tweet = Tweet.new(:user => current_user, :status => params[:status])
    tweet.save
    if params[:phone_number] != ""
		# we'll send the tweet here!
    end
    redirect '/'
  end
```

If they typed in a phone number, we'll create a new instance of the Twilio Client using the ACCOUNT_SID and AUTH_TOKEN information you entered into your `.env` file.

```ruby
  post '/tweet' do
    tweet = Tweet.new(:user => current_user, :status => params[:status])
    tweet.save
    if params[:phone_number] != ""
		@client = Twilio::REST::Client.new(ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"])
		
    end
    redirect '/'
  end
```

We'll also help our user by adding a "+1" to the begninning of the phone number. 

```ruby
  post '/tweet' do
    tweet = Tweet.new(:user => current_user, :status => params[:status])
    tweet.save
    if params[:phone_number] != ""
		@client = Twilio::REST::Client.new(ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"])
		number = "+1#{params[:phone_number]}"
    end
    redirect '/'
  end
```

Lastly, we'll actually send the message. We'll also append " - sent by taylorswift13 from Fwitter" to the end of the message.

```ruby
  post '/tweet' do
    tweet = Tweet.new(:user => current_user, :status => params[:status])
    tweet.save
    if params[:phone_number] != ""
		@client = Twilio::REST::Client.new(ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"])
		number = "+1#{params[:phone_number]}"
		@client.messages.create(
        from: #YOUR TWILIO NUMBER HERE! ,
        to: number,
        body: params[:status] + "\n - sent by #{current_user.username} from Fwitter"
      )
    end
    redirect '/'
  end
```

And that's it! Test out your application using your phone number. As a bonus, you can add error handling in case the user types in something other than a valid phone number. You can now incorporate APIs into your Sinatra applications!