require './config/environment'
require 'pry'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'fwitter'
  end

  helpers do
    def logged_in?
      session[:user_id]
    end

    def current_user
      current_user = User.find(session[:user_id])
    end

    def error
      session[:error]
    end
  end

  get '/' do
    if logged_in?
      @tweets = Tweet.all
      @user = current_user
      erb :index
    else
      redirect '/sign-in'
    end
  end

  get '/tweet' do
    @user = current_user
    erb :tweet
  end

  post '/tweet' do
    Tweet.create(:user_id => params[:user_id], :status => params[:status])
    redirect '/'
  end

  get '/users' do
    @users = User.all
    erb :users
  end

  post '/sign-up' do
    @user = User.new(:username => params[:username], :email => params[:email])
    @user.save
    session[:user_id] = @user.id 
    redirect '/'
  end

  get '/sign-in' do 
    @signin_page = true
    erb :signin
  end

  post '/sign-in' do
    @user = User.find_by(:username => params[:username])
    if @user
      session[:user_id] = @user.id
      redirect '/tweet'
    else
      redirect '/signin'
    end
  end

  get '/sign-out' do
    session.clear
    redirect '/'
  end

end
