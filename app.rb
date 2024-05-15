require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def db_connect
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def is_barber_exists? db, name
  db.execute('select * from barber where name=?', [name]).length > 0
end
def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'insert into barber (name) values (?)', [barber]
    end
  end
end

configure do
  db = db_connect
  db.execute 'CREATE TABLE IF NOT EXISTS
  "user" (
	"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
	"name"	text NOT NULL DEFAULT "Noname",
	"phone"	TEXT NOT NULL,
	"date_stamp"	TEXT DEFAULT CURRENT_TIMESTAMP,
	"barber"	TEXT NOT NULL DEFAULT "no_one",
	"color"	TEXT NOT NULL DEFAULT "#ffffff"
  );'
  db.execute 'CREATE TABLE IF NOT EXISTS
  "barber" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
)'

  seed_db db, ['Barov Suchka', 'Shmara Lulya', 'Soska Deep', 'Orange Stink', 'Borov Kurme']
end



get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/book' do

  # Loading list of barbers from database
  db = db_connect
  db.results_as_hash = true
  @barber_list = db.execute 'select * from barber order by name asc'

  erb :book
end
# Book POST
post '/book' do

  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @dresser = params[:dresser]
  @color = params[:colorpicker]

  # Created hash for each param error
  hh = {username: 'Enter Name', phone: 'Enter phone', datetime: 'Enter time', dresser: 'Enter Dresser'}

  # Creating a loop
  hh.each_key do |key|
    # Checking if params[] have an empty value
    # if yes, assign error variable a message from the hash
    if params[key] == ''
      @error = hh[key]
      # And return back to same page
      return erb :book
    end
  end

  # Inserting into table user
  # Using ???? to protect from SQL Injection
  db_connect.execute "insert into user (name, phone, date_stamp, barber, color)
values (?, ?, ?, ?, ?)", [@username, @phone, @datetime, @dresser, @color]

  erb "<b>Thank you for registration,</b>  <h4>#{@username}</h4> #{@phone}<br /> #{@datetime}<br /> Dresser - #{@dresser}<br /> color is #{@color}"
end


get '/customers' do

  db = db_connect
  db.results_as_hash = true
  @users = db.execute 'select * from user order by id desc'
  erb :customers

end
