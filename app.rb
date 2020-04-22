# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'

class Memo
  def json_file
    open('views/memos.json') do |io|
      JSON.load(io)
    end
  end

  def find(id)
    @w_memo = ''
    json_file['memos'].each do |memo|
      @w_memo = memo if memo['id'].to_s == id.to_s
    end
    @w_memo
  end

  def new(title, body)
    new_id = 0
    @json = json_file
    @json['memos'].each do |memo|
      new_id = memo['id'].to_i + 1 if new_id <= memo['id'].to_i
    end
    add = {
      'id' => new_id.to_s,
      'title' => title,
      'body' => body
    }
    @json['memos'].push(add)
    File.open('views/memos.json', 'w') { |file| JSON.dump(@json, file) }
  end

  def delete(id)
    num = 0
    @json = json_file
    @json['memos'].each do |memo|
      @json['memos'].delete_at(num) if memo['id'].to_s == id.to_s
      num += 1
    end
    File.open('views/memos.json', 'w') { |file| JSON.dump(@json, file) }
  end

  def update(id, title, body)
    num = 0
    @json = json_file
    @json['memos'].each do |memo|
      if memo['id'].to_s == id
        @json['memos'][num]['title'] = title
        @json['memos'][num]['body'] = body
      end
      num += 1
    end
    File.open('views/memos.json', 'w') { |file| JSON.dump(@json, file) }
  end
end

get '/' do
  memo = Memo.new
  @memos = memo.json_file['memos']
  erb :index
end

get '/memo/:id' do
  memo = Memo.new
  @memo = memo.find(params[:id])
  erb :show_memo
end

get '/memo/edit/:id' do
  memo = Memo.new
  @memo = memo.find(params[:id])
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
  memo = Memo.new
  @memos = memo.json_file['memos']
  erb :create
end

post '/new' do
  memo = Memo.new
  memo.new(params[:title], params[:body])
  redirect '/'
  erb :index
end
