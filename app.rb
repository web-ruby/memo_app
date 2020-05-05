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
    memos = Memo.connection.exec 'SELECT * FROM memo_list ORDER BY id;'
    memos.map { |memo| { id: memo['id'], title: memo['title'], body: memo['body'] } }
  end

  def self.create(title, body)
    Memo.all.each do |memo|
      @new_id = memo[:id].to_i + 1 if @new_id <= memo[:id].to_i
    end
    Memo.connection.exec "INSERT INTO memo_list(id, title, body)
    VALUES ('#{@new_id}', '#{title}', '#{body}');"
  end

  def delete(id)
    Memo.all.each do |memo|
      if memo[:id] == id
        Memo.connection.exec "DELETE from memo_list where id = '#{id}';"
      end
    end
  end

  def self.find(id)
    Memo.all.find {|memo| memo[:id] == id }
  end

  def update(id, title, body)
    Memo.all.each do |memo|
      if memo[:id] == id
        Memo.connection.exec "UPDATE memo_list
        SET title = '#{title}', body = '#{body}' where id = '#{id}';"
      end
    end
  end
end

get '/' do
  @memos = Memo.all
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

get '/create' do
  @memos = Memo.all
  erb :create
end

post '/new' do
  Memo.create(params[:title], params[:body])
  redirect '/'
  erb :index
end
