require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'sinatra/content_for'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

# save our answers in a session
before do
  session[:answers] ||= []
end

helpers do
  def answers_correct?(id, ham_scale, exer_scale, age)
    message = []
    if !(1..5).cover? id.size
      message << 'Id must be between 1 and 5 characters'
    end

    if !('1'..'10').include? ham_scale.to_s
      message << 'Your score must be between 1 and 10 (Hamburger)'
    end

    if session[:answers].any? { |answer| answer[:id] == id }
      message << 'The user with your ID has already submitted his answers'
    end

    if !('1'..'10').include? exer_scale.to_s
      message << 'Your score must be between 1 and 10 characters (Exercise)'
    end

    if !('18'..'35').include? age.to_s
      message << 'Only people aged 18 to 35 are allowed to participate'
    end

    if !message.empty?
      message
    end
  end
end

# start page
get '/' do
  erb :start_survey
end

# log the answers
post '/survey/create' do
  id = params[:id]
  ham_scale = params[:ham_scale].to_s
  exer_scale = params[:exer_scale]
  age = params[:age]

  error = answers_correct?(id, ham_scale, exer_scale, age)

  if error
    session[:error] = error
    erb :start_survey
  else
    session[:message] = 'Your answers have been added'
    session[:answers] <<
      {
        id: id, ham_scale: ham_scale,
        exer_scale: exer_scale, age: age
      }
    redirect '/logged_answers'
  end
end

# view the logged answers
get '/logged_answers' do
  @answers = session[:answers]
  erb :logged_answers
end

# clear the answer hash
get '/clear_answers' do
  session[:answers].clear
  redirect '/'
end
