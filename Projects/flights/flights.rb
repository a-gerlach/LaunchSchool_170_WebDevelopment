require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'sinatra/content_for'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do
  session[:flights] ||= []
end

helpers do
  def flight_correct?(airline, flight_num, destination, dep_time)
    message = []
    if !(1..100).cover? airline.size
      message << 'Airline must be between 1 and 100 characters'
    end

    if !(1..100).cover? flight_num.size
      message << 'Flight Number must be between 1 and 100 characters'
    end

    if session[:flights].any? { |flight| flight[:destination] == destination }
      message << "You can only enter each destination once"
    end

    if !(1..100).cover? destination.size
      message << 'Destination must be between 1 and 100 characters'
    end

    if !(1..100).cover? dep_time.size
      message << 'Depatrue Time must be between 1 and 100 characters'
    end

    if message.size > 0
      message
    else
      nil
    end
  end
end

get '/' do
  @flights = session[:flights]
  erb :flight_start
end

post '/flight/create' do
  airline = params[:airline]
  flight_num = params[:flight_num]
  destination = params[:destination]
  departure_time = params[:dep_time]

  error = flight_correct?(airline, flight_num, destination, departure_time)

  if error
    session[:error] = error
    erb :flight_start
  else
    session[:message] = 'Your flight has been added'
    session[:flights] << 
      {
        airline: airline, flight_num: flight_num,
        destination: destination, departure_time: departure_time
    }
    redirect '/logged_flights'
  end
end

get '/logged_flights' do
  @flights = session[:flights]
  erb :logged_flights
end

get '/clear_flights' do
  session[:flights].clear
  redirect "/"
end