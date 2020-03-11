# hangman_reloaded.rb

require 'sinatra'
require 'sinatra/reloader'
require './lib/hangman.rb'

hangman = Hangman.new()

get '/' do
    erb :index, :locals => {:game_name => Hangman.whoami?,
                            :unguessed_word => hangman.show_guesses(),
                            :solution => hangman.solution,
                            :guesses_remaining => hangman.guesses_remaining,
                            :filename => hangman.saved_filename
                        }
end

get '/replay' do
    hangman = Hangman.new()
    redirect to('/')
end

post '/save' do
    filename = params["filename"]
    hangman.save_game(filename)
    redirect to('/')
end

post '/letter' do
    guess = params["guess_letter"]
    hangman.check_letter_guess(guess)
    if hangman.guesses_remaining == 0
        erb :loser
    else
        redirect back
    end
end

post '/solution' do
    guess = params["guess_solution"]
    if hangman.check_solution_guess(guess)
        erb :winner
    else
        redirect back
    end
end

post '/load' do
    filename = params["filename"] + ".json"
    hangman.load_game_from_file(filename)
    redirect to('/')
end