class GameController < ApplicationController
  def generate_grid
    grid = (0...50).map { ('a'..'z').to_a[rand(26)] }
    grid = grid.shuffle!
    grid = grid.take(9)
    return grid
  end

  def game
    @grid = generate_grid
    @start_time = Time.now
  end

  def check_attempt(attempt, grid)
    grid_hash = Hash.new(0)
    grid.each do |x|
    if grid_hash[x].nil?
      grid_hash[x] = 1
    else
      grid_hash[x] += 1
    end
  end

    attempt_hash = Hash.new(0)
    attempt = attempt.split(//)
    attempt.each do |x|
    if attempt_hash[x].nil?
      attempt_hash[x] = 1
    else
      attempt_hash[x] += 1
    end
  end
  # byebug
    !attempt_hash.all?  { |k, v| v <= grid_hash[k] }

   end



  def user_points(time, attempt)
    (1000.0 * attempt.length) - time
  end

  def calculate_score(attempt, grid, start_time, end_time)
      @result = {
        time: nil,
        translation: nil,
        score: nil,
        message: nil
      }
      attempt.upcase!
      words = File.read('/usr/share/dict/words').upcase.split("\n")
      if words.include?(attempt) == false
        @result[:message] = 'Not an english word'
        @result[:score] = 0
        # byebug
      elsif check_attempt(attempt, grid) == false
        @result[:time] = end_time - start_time
        @result[:score] = user_points(@result[:time], attempt)
        # @result[:translation] = attempt_translation(attempt).downcase
        @result[:message] = 'Well done'
      else
        @result[:score] = 0
        @result[:message] = 'Not in the grid'
      end
      return @result
  end

  def score
    @attempt = params[:attempt]
    @game_grid = params[:grid].upcase!.scan /\w/
    # @time = (Time.now - params[:start_time].to_time).to_i
    @time = (Time.now - params[:start_time].to_time).to_i
    calculate_score(@attempt, @game_grid, params[:start_time].to_time, Time.now)
  end
end
