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
  @barber_list = db.execute 'select * from barber'

  erb :book
end

get '/customers' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
