require 'csv'

class Hangman
  def initialize
    @line1 = ["     ", "A", "B", "C", "D", "E", "F", "G", "H", "I"]
    @line2 = ["     ", "J", "K", "L", "M", "N", "O", "P", "Q", "R"]
    @line3 = ["     ", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    @word = File.read('5desk.txt').lines.select {|l| (5..12).cover?(l.strip.size)}.sample.strip.upcase.chars
    @display = []
    @word.length.times do; @display.push("_"); end
    @man_hung = 0
  end

  def turn
    puts @line1.join(" ")
    puts @line2.join(" ")
    puts @line3.join(" ")
    puts @display.join(" ")
    puts "\nGuess a letter:"
    guess
  end

  private

  def guess
    letter = gets.chomp.upcase
    if letter.downcase == "save"
      save_game
    elsif letter.downcase == "reload"
      reload
    else
      slash(letter)
      if @word.include? letter
        display_word(letter)
      else
        loser(letter)
      end
    end
  end

  def display_word(letter = nil)
    @word.each_with_index { |val, index|
      @display[index] = letter if val == letter
    }
    if @display.include? "_"
      turn
    else
      puts "#{@word.join}\nCongratulations, you win!"
    end
  end

  def slash(letter)
    if @line1.include? letter
      location = @line1.index(letter)
      @line1[location] = "/"
    elsif @line2.include? letter
      location = @line2.index(letter)
      @line2[location] = "/"
    elsif @line3.include? letter
      location = @line3.index(letter)
      @line3[location] = "/"
    else
      puts "You must guess one letter you have not already guessed."
      @man_hung -= 1 unless @display.include? letter
    end
  end

  def loser(letter)
    @man_hung += 1
    case @man_hung
    when 0
      turn
    when 1
      @line1[0] = " o   "; turn
    when 2
      @line2[0] = " |   "; turn
    when 3
      @line2[0] = "/|   "; turn
    when 4
      @line2[0] = "/|\\  "; turn
    when 5
      @line3[0] = "/    "; turn
    when 6
      @line3[0] = "/ \\  "; turn
    when 7
      puts "You lose. Word was: #{@word.join}."
    end
  end

  def save_game
    puts "Name your game:"
    name = gets.chomp
    File.open("saved_games.csv",'a') do |file|
      file.puts "#{name},#{@line1.join("+")},#{@line2.join("+")},#{@line3.join("+")},#{@word.join(" ")},#{@display.join(" ")},#{@man_hung}"
    end
    puts "Game saved."
    exit
  end

  def reload
    puts "What name is your game saved under?"
    i = 65
    contents = CSV.read "saved_games.csv", headers: true
    contents.each do |row|
      puts "(#{i.chr}) #{row["name"]} (#{row["@display"]})"
      i += 1
    end
    row = gets.chomp.upcase.ord-65
    begin
      @line1 = contents[row]["@line1"].split("+")
      @line2 = contents[row]["@line2"].split("+")
      @line3 = contents[row]["@line3"].split("+")
      @word = contents[row]["@word"].split(" ")
      @display = contents[row]["@display"].split(" ")
      @man_hung = contents[row]["@man_hung"].to_i
      turn
    rescue
      puts "Invalid input."
    end
  end
end

puts "Welcome to hangman! Try to guess the secret word before you've hung the man. Type save or reload at any time."
Hangman.new.turn
