require 'open-uri'
require 'json'

class GamesController < ApplicationController
  VOWELS = %w[A E I O U]

  def new
    @random_grid = generate_random_grid
  end

  def score
    @user_word = params[:user_word]
    @random_grid = params[:random_grid].split(',')
    start_time = Time.parse(params[:start_time])
    end_time = Time.now

    @result = calculate_result(@user_word, @random_grid, start_time, end_time)
  end

  def generate_random_grid
    vowels = %w[A E I O U]
    grid = vowels.sample(6) + (('A'..'Z').to_a - vowels).sample(4)
    grid.shuffle
  end

  def fetch_dictionary(word)
    url = "https://dictionary.lewagon.com/#{word}"
    response = URI.open(url).read
    JSON.parse(response)
  end

  def word_in_grid?(word, grid)
    grid_copy = grid.dup
    word.upcase.chars.all? do |letter|
      grid_copy.include?(letter) && grid_copy.delete_at(grid_copy.index(letter))
    end
  end

  def calculate_result(word, grid, start_time, end_time)
    dictionary = fetch_dictionary(word)
    in_grid = word_in_grid?(word, grid)
    time_taken = end_time - start_time

    calculate_score_and_message(dictionary, in_grid, word, time_taken)
  end

  def calculate_score_and_message(dictionary, in_grid, word, time_taken)
    score = 0
    message = ''

    if dictionary['found'] && in_grid
      score = word.length * (1.0 / time_taken)
      message = 'Well done!'
    elsif !dictionary['found']
      message = 'Not an English word'
    else
      message = 'Not in the grid'
    end

    { score: score, message: message, time: time_taken }
  end
end
