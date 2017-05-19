require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'sinatra/content_for'

configure do 
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

helpers do
  def monthly_exp(month)
    month[:expenses].inject(:+)
  end

  def total_expenses(months)
    result = 0
    months.each do |month|
      result += monthly_exp(month) if monthly_exp(month)
    end
    result
  end

  def in_budget?(expenses, budget)
    budget = budget.to_i
    if expenses > budget
      'You are spending too much money!'
    elsif budget > expenses
      'You are withing your budget!'
    elsif budget == expenses
      'Right on the budget.'
    end
  end

  def error_for_month(name)
    months = ['January', 'February', 'March', 'April']
    if !(1..100).cover? name.size
      'List name must be between 1 and 100 characters.'
    elsif session[:months].any? { |month| month[:name] == name }
      'Month name must be unique.'
    elsif !months.include?(name)
      'The month must be an official month name!'
    end
  end

  def budget_correct?(budget)
    if budget.to_i > 200
      'You dont have that much money!'
    elsif !(1..100).cover? budget.size
      'You have to enter something'
    end
  end

  def expense_correct?(expense)
    if !(1..100).cover? expense.size
      'You have to enter something'
    elsif expense.to_i > 30
      'No single expense can be over 30€'
    end
  end
end

before do
  session[:months] ||= []
end

# page where you see an overview of all months
get '/' do
  @months = session[:months]
  erb :start
end

# form to enter a new month
get '/new_month' do
  erb :new_month
end

# This site with the budget form
get '/enter_budget' do
  erb :budget
end

# Enter a yearly budget
post '/add_budget' do
  budget = params[:budget].strip
  error = budget_correct?(budget)
  if error
    session[:error] = error
    erb :budget
  else
    session[:budget] = params[:budget]
    session[:success] = 'The Budget has been approved'
    redirect '/'
  end
end

# add a new month
post '/new_month' do
  month_name = params[:month_name].strip

  error = error_for_month(month_name)
  if error
    session[:error] = error
    erb :new_month
  else
    session[:months] << { name: month_name, expenses: [] }
    redirect '/'
  end
end

# look at a single month
get '/months/:month_id' do
  @id = params[:month_id].to_i
  @month = session[:months][@id]
  erb :month
end

# delete a month
post '/months/:month_id/destroy' do
  @id = params[:month_id].to_i

  session[:months].delete_at(@id)
  redirect '/'
end

# add a new expense Item to a month
post '/:month_id/new_expense' do
  @id = params[:month_id].to_i
  @month = session[:months][@id]
  expense = params[:expense].to_i

  error = expense_correct?(expense)
  if error
    session[:error] = error
    erb :month
  elsif @month[:expenses].size + 1 == 3
    session[:error] = 'You can only add two expenses to every month'
    erb :month
  else
    @month[:expenses] << expense
    @month[:expenses].inject(:+)
    redirect '/months/#{@id}'
  end
end
