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
  session[:bet] ||= []
end

helpers do
  def guess_correct?(random_number, guess)
    if random_number.to_i == guess.to_i
      "You have guessed the correct number"
    end
  end

  def validate_bet(bet, budget)
    if (bet.to_i > budget.to_i) || (bet.to_i < 1)
      "Bets must be between 1 and #{budget}"
    end
  end
end

# start page
get '/' do
  erb :start_game
end

get '/game' do
  # This is a gaurd clause to redirect to the "broke" page if the user is broke
  @budget = session[:bet][:player_cash]
  if @budget <= 0
    redirect '/broke'
  end
  erb :place_bet
end

post '/place_bet' do
  # This is a guard clause to validate the bet
  bet_amount = params[:bet]
  max_amount = session[:bet][:player_cash]
  bet_message = validate_bet(bet_amount, max_amount)
  if bet_message
    session[:message] = bet_message
    redirect '/game'
  end

  guess = params[:guess1] || params[:guess2] || params[:guess3]
  correct_number = session[:bet][:number]
  result = guess_correct?(correct_number, guess)
  if result
    session[:message] = result
    session[:bet][:number] = rand(1..3)
    session[:bet][:player_cash] += bet_amount.to_i
    redirect '/game'
  else
    session[:message] = "You guessed #{guess}, but the number was #{correct_number}"
    session[:bet][:number] = rand(1..3)
    session[:bet][:player_cash] -= bet_amount.to_i
    redirect '/game'
  end
end

get '/start_game' do
  session[:bet] = { number: rand(1..3), player_cash: 100 }
  redirect '/game'
end

get '/broke' do
  erb :broke
end
