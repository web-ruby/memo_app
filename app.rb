# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'

$json_file_path = 'views/memos.json'
$json = open($json_file_path) do |io|
  JSON.load(io)
end
$memos = $json['memos']

def memo(memo_id)
  w_memo = ''
  $memos.each do |memo|
    w_memo = memo if memo['id'].to_s == memo_id.to_s
  end
  w_memo
end

def rewrite_json
  File.open('views/memos.json', 'w') do |file|
    JSON.dump($json, file)
  end
end

get '/' do
  @memos = $memos
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
  edit_memo = {
    'id' => params[:id].to_s,
    'title' => params[:title],
    'body' => params[:body]
  }
  num = 0
  $memos.each do |memo|
    if memo['id'].to_s == params[:id].to_s
      $json['memos'][num]['title'] = edit_memo['title']
      $json['memos'][num]['body'] = edit_memo['body']
    end
    num += 1
  end
  rewrite_json
  redirect '/'
  erb :index
end

delete '/memo/delete/:id' do
  num = 0
  $memos.each do |memo|
    $json['memos'].delete_at(num) if memo['id'].to_s == params[:id].to_s
    num += 1
  end
  rewrite_json
  redirect '/'
  erb :index
end

get '/create' do
  @memos = $memos
  erb :create
end

post '/new' do
  new_id = 0
  $memos.each do |memo|
    new_id = memo['id'].to_i + 1 if new_id <= memo['id'].to_i
  end
  new_memo = {
    'id' => new_id.to_s,
    'title' => params[:title],
    'body' => params[:body]
  }
  $json['memos'].push(new_memo)
  rewrite_json
  redirect '/'
  erb :index
end
