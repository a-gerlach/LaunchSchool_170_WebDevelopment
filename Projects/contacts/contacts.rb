require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "sinatra/content_for"

# To do:
  # be able to enter a person: name and phone number
  # be able to delete contacts
  # add validations for these contacts
  # create a layout
  # assign these contacts to categories

configure do 
  enable :sessions
  set :session_secret, "secret"
  set :erb, :escape_html => true
end

before do
  session[:contacts] ||= []
  session[:category] ||= []
end

helpers do
  def sort_contacts(contacts)
    contacts.sort_by { |contact| contact[:categories] }
  end

  def category_contacts(contact, category)
    if contact[:categories].to_s == category
      contact[:name]
    end
  end

  def find_cat_index(array, category)
    array.find_index{ |item| item[:name] == category }
  end

  def correct_contact?(name, number, category)
    message = []
    if !(1..100).cover? name.size
      message << 'Contact name must be between 1 and 100 characters'
    end

    if number.size < 3
      message << 'The number must have at least three digits'
    end

    if !(1..5).cover? category.size
      message << 'Category must be between 1 and five chars'
    elsif !session[:category].any? { |cat| cat[:name]  == category }
      message << 'Please choose a category name 
                  that has already been created.'
    end

    unless message.empty? # can i use just unless message here?
      message.join('. ')
    end
  end
end



# home-site
get '/' do
  erb :start
end

# enter a new contatc
post '/new_name' do
  contact_name = params[:contact_name].strip
  contact_phone = params[:contact_phone]
  contact_category = params[:contact_cat]
  error = correct_contact?(contact_name, contact_phone, contact_category)
  if error
    session[:error] = error
    erb :start
  else
    session[:success] = 'The Contact has been created'
    session[:contacts] <<
      {
        name: contact_name, phone_number: contact_phone,
        categories: contact_category
      }
    redirect '/'
  end
end

# view a single contact
get '/contacts/:contact_id' do
  @contacts = session[:contacts]
  @contact_id = params[:contact_id].to_i
  @contact = @contacts[@contact_id]
  erb :contact
end

# delete a contact
post '/contacts/:contact_id/destroy' do
  @contacts = session[:contacts]
  @contact_id = params[:contact_id].to_i
  @contacts.delete_at(@contact_id)
  redirect '/'
end

# go to a category site
get '/cat/:category' do
  @category = params[:category].to_s
  @contacts = session[:contacts]
  @category_2 = session[:category]
  erb :family
end

# add a new category
post '/category/new' do
  cat_name = params[:cat_name].to_s
  session[:category] << { name: cat_name }
  redirect '/'
end

# delete a category
post '/categories/:cat_id/destroy' do
  @categories = session[:category]
  @categories.delete_at(params[:cat_id].to_i)
  redirect '/'
end

# delete all contacts
get '/delete_all' do
  session[:contacts].clear
  redirect '/'
end
