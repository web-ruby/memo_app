# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'pg'

class Memo
  def self.all
    all = []
    conection = PG.connect dbname: 'memo_app', user: 'user', password: ''
    memos = conection.exec 'SELECT * FROM memo_list ORDER BY id;'
    memos.map do |memo|
      all.push({ id: memo['id'], title: memo['title'], body: memo['body'] })
    end
    all
  end

  def self.create(title, body)
    conection = PG.connect dbname: 'memo_app', user: 'user', password: ''
    @new_id = 0
    Memo.all.each do |memo|
      @new_id = memo[:id].to_i + 1 if @new_id <= memo[:id].to_i
    end
    conection.exec "INSERT INTO memo_list(id, title, body)
    VALUES ('#{@new_id}', '#{title}', '#{body}');"
  end

  def delete(id)
    # delete = []
    conection = PG.connect dbname: 'memo_app', user: 'user', password: ''
    Memo.all.each do |memo|
      if memo[:id].to_s == id.to_s
        conection.exec "DELETE from memo_list where id = '#{id}';"
      end
    end
  end

  def self.find(id)
    w_memo = ''
    Memo.all.each do |memo|
      w_memo = memo if memo[:id].to_s == id.to_s
    end
    w_memo
  end

  def update(id, title, body)
    conection = PG.connect dbname: 'memo_app', user: 'user', password: ''
    Memo.all.each do |memo|
      if memo[:id].to_s == id.to_s
        conection.exec "UPDATE memo_list
        SET title = '#{title}', body = '#{body}' where id = '#{id}';"
      end
    end
    memos = conection.exec 'SELECT * FROM memo_list'
    memos.map(&:update)
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
