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
  session[:cards] ||= []
end

get '/' do
  erb :start
end

helpers do
  def card_correct?(first_name, last_name, card_number, exp_date, ccv)
    message = []
    if !(1..100).cover? first_name.size
      message << 'First name must be between 1 and 100 characters'
    end

    if !(1..100).cover? last_name.size
      message << 'Last name must be between 1 and 100 characters'
    end

    if card_number.size != 16
      message << 'Card number must be 16 characters'
    end

    if !(1..100).cover? exp_date.size
      message << 'Expiration date must be between 1 and 100 characters'
    end

    if !(1..100).cover? ccv.size
      message << 'CCV must be between 1 and 100 characters'
    end

    if message.size > 0
      message
    end
  end
end

post '/payments/create' do
  first_name = params[:first_name]
  last_name = params[:last_name]
  card_number = params[:card_number]
  exp_date = params[:exp_date]
  ccv = params[:ccv]

  error = card_correct?(first_name, last_name, card_number, exp_date, ccv)

  if error
    session[:error] = error
    erb :start
  else
    session[:success] = 'Thank you for your payment'
    session[:cards] <<
      {
        first_name: first_name, last_name: last_name,
        card_number: card_number, exp_date: exp_date,
        ccv: ccv, time: Time.new
      }
    redirect '/success'
  end
end

get '/success' do
  @cards = session[:cards]
  erb :success
end

get '/clear_payments' do
  session[:cards].clear
  redirect '/'
end
