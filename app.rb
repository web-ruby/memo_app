# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'

def json_file
  open('views/memos.json') do |io|
    JSON.load(io)
  end
end

def memo(memo_id)
  w_memo = ''
  json_file['memos'].each do |memo|
    w_memo = memo if memo['id'].to_s == memo_id.to_s
  end
  w_memo
end

def new_memo
  add_memo
  json = json_file
  json['memos'].push(add_memo)
  File.open('views/memos.json', 'w') { |file| JSON.dump(json, file) }
end

def add_memo
  new_id = 0
  json = json_file
  json['memos'].each do |memo|
    new_id = memo['id'].to_i + 1 if new_id <= memo['id'].to_i
  end
  {
    'id' => new_id.to_s,
    'title' => params[:title],
    'body' => params[:body]
  }
end

def edit_memo
  {
    'id' => params[:id].to_s,
    'title' => params[:title],
    'body' => params[:body]
  }
end

def delete_memo
  num = 0
  json = json_file
  json['memos'].each do |memo|
    json['memos'].delete_at(num) if memo['id'].to_s == params[:id].to_s
    num += 1
  end
  File.open('views/memos.json', 'w') { |file| JSON.dump(json, file) }
end

def rewrite_memo(edit_memo)
  num = 0
  json = json_file
  json['memos'].each do |memo|
    if memo['id'].to_s == params[:id].to_s
      json['memos'][num]['title'] = edit_memo['title']
      json['memos'][num]['body'] = edit_memo['body']
    end
    num += 1
  end
  File.open('views/memos.json', 'w') { |file| JSON.dump(json, file) }
end

get '/' do
  @memos = json_file['memos']
  erb :index
end

get '/memo/:id' do
  @memo = memo(params[:id])
  erb :show_memo
end

get '/memo/edit/:id' do
  @memo = memo(params[:id])
  erb :edit
end

patch '/memo/edit/:id' do
  edit_memo
  rewrite_memo(edit_memo)
  redirect '/'
  erb :index
end

delete '/memo/delete/:id' do
  delete_memo
  redirect '/'
  erb :index
end

get '/create' do
  @memos = json_file['memos']
  erb :create
end

post '/new' do
  new_memo
  redirect '/'
  erb :index
end
