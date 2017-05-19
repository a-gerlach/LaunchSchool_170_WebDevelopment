require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "sinatra/content_for"

configure do 
  enable :sessions
  set :session_secret, "secret"
  set :erb, :escape_html => true
end

before do
  session[:teams] ||= []
end

before do
  def team_name_correct?(name)
    message = []
    if !(1..100).cover? name.size
      message << 'Team name must be between 1 and 100 characters'
    end

    if message.size > 0
      message
    end 
  end
end

get "/" do
  erb :start
end

post '/teams/create' do
  team_name = params[:team_name]

  error = team_name_correct?(team_name)

  if error
    session[:error] = error
    erb :start
  else
    session[:success] = "The team has been created"
    session[:teams] << 
      {
        name: team_name, players: [], sport: []
      }
    redirect "/teams/view"
  end
end

# view all teams
get '/teams/view' do
  @teams = session[:teams]
  erb :view_teams
end

# view a specific team
get '/teams/view/:team_id' do
  @team_id = params[:team_id].to_i
  @team = session[:teams][@team_id]
  erb :view_team
end

# create a player
post '/player/create/:team_id' do
  @id = params[:team_id].to_i
  player = params[:player_name]
  @team = session[:teams][@id]
  session[:success] = "You have added a player."
  @team[:players] << { name: player }
  redirect "/teams/view/#{@id}"
end

# clear the teams
get '/clear' do
  session[:teams].clear
  redirect "/"
end

# set the team sport
post '/teams/sport/:team_id' do
  @team_id = params[:team_id].to_i
  @team = session[:teams][@team_id]
  sport = params[:sport_name]

  session[:success] = "You have added what sport this team plays."
  @team[:sport] = sport
  redirect "/teams/view/#{@team_id}"
end

# delete a player from a team
get '/delete/:team_id/:player_index' do
  @team_id = params[:team_id].to_i
  @team = session[:teams][@team_id]
  player_index = params[:player_index].to_i
  @team[:players].delete_at(player_index)
  redirect "/teams/view/#{@team_id}"
end