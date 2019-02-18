require 'open-uri'
require 'json'
require 'time'

class GamesController < ApplicationController
  def index
  end

  def new
    @num_letters = params[:size]
    @letters = generate_grid(@num_letters)
    @start_time = Time.now
  end

  def score
    try = params[:try]
    letters = params[:letters].gsub(/\[|\]|\"|\s/, '').split(',')
    start_time = params[:start_time]
    end_time = Time.now
    run_game(try, letters, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    # generate grid using grid size do define nuber of time thar random from a to z run
    (0...grid_size.to_i).map { ('A'..'Z').to_a[rand(26)] }
  end

  def correct_letters?(try, grid)
    # create empty hash to receive letter and number of each char
    chars = {}
    # for each letter in grid, add to grid_chars hash the letter and nr of times
    grid.each { |char| chars.key?(char) ? chars[char] += 1 : chars[char] = 1 }
    # upcase input from user, split in letters and for each do something
    try.upcase.split('').each do |char|
      # if letter exists in the grid_chars hash and if the number in grid_char is positive
      return false if !chars.key?(char) || !chars[char].positive?

      # subtract one unit from the available quantity in the grid_chars hash
      chars[char] -= 1
    end
  end

  def compare_words?(try)
    # define the url using the attempt word appended to the link
    url = "https://wagon-dictionary.herokuapp.com/#{try.downcase}"
    # open the url and store data in variable
    user_serialized = open(url).read
    # create an hash with the output from site
    check = JSON.parse(user_serialized)
    # output true or fals if word is or not an English Word
    check['found']
  end

  def run_game(try, letters, start_time, end_time)
    invalid = "can't be built out of #{letters.join(', ')}."
    no_word = 'is not a valid English word.'
    valid = 'is valid according to the grid and is an English word.'
    time = (end_time - Time.parse(start_time)).to_f
    response = valid
    response = no_word unless compare_words?(try)
    response = invalid unless correct_letters?(try, letters)
    response == valid ? score_value = try.length**10 / time : score_value = 0
    @params = {
      state: response == valid,
      try: try,
      time: time,
      score: score_value,
      message: response
    }
  end
end
