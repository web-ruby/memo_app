# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'pg'

class Memo
  def self.connection
    PG.connect dbname: 'memo_app', user: 'user', password: ''
  end

  def self.all
    memos = Memo.connection.exec("SELECT * FROM memo_list ORDER BY id;").field_values("id")
  end

  def self.create(title, body)
    new_id = 0
    Memo.all.each do |memo|
      new_id = memo.to_i + 1 if new_id <= memo.to_i
    end
    Memo.connection.exec "INSERT INTO memo_list(id, title, body)
    VALUES ('#{new_id}', '#{title}', '#{body}');"
  end

  def delete(id)
    Memo.all.each do |memo_id|
      if memo_id == id
        Memo.connection.exec "DELETE from memo_list where id = '#{id}';"
      end
    end
  end

  def self.find(id)
    memo = {}
    results = Memo.connection.exec("SELECT * FROM memo_list WHERE id ='#{id}';")
    results.each do |result|
      memo[:id]    = result['id']
      memo[:title] = result['title']
      memo[:body]  = result['body']
    end
    memo
  end

  def update(id, title, body)
    Memo.all.each do |memo_id|
      if memo_id == id
        Memo.connection.exec "UPDATE memo_list
        SET title = '#{title}', body = '#{body}' where id = '#{id}';"
      end
    end
  end
end

get '/' do
  @memos = Memo.all.map { |id| Memo.find(id) }
  erb :index
end

get '/memo/:id' do
  @memo = Memo.find(params[:id])
  erb :show_memo
end

get '/memo/edit/:id' do
  @memo = Memo.find(params[:id])
  erb :edit
end

patch '/memo/edit/:id' do
  memo = Memo.new
  memo.update(params[:id], params[:title], params[:body])
  redirect '/'
  erb :index
end

delete '/memo/delete/:id' do
  memo = Memo.new
  memo.delete(params[:id])
  redirect '/'
  erb :index
end

get '/new' do
  @memos = Memo.all
  erb :new
end

post '/create' do
  Memo.create(params[:title], params[:body])
  redirect '/'
  erb :index
end
