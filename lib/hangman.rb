class Hangman
    require 'json'

    def initialize
        
        puts "Welcome to hangman!  If you've never played before, please see"
        puts "https://www.wikiwand.com/en/Hangman_(game)"
        puts
        
        # initialize instance variables
        if load_game?
            # instance variables will be initialized in the load_game_from_file method
            print "Which file would you like to load? "
            load_game_from_file sanitize_text(gets)
        else
            dictionary = load_dictionary  # only load dictionary if the user decides to begin a new game
            @solution = select_word(dictionary) until @solution.to_s.length >= 5 && @solution.to_s.length <= 12  # ensure that the randomly chosed word is an appropriate length
            @previous_guesses = []
            @guesses_remaining = 6  # default number of guesses based on wikipedia rules.  may allow player to later decide how many guesses permitted
        end

        until winner? || @guesses_remaining <= 0
            check_guess(get_user_input)
            show_guesses
            unless @guesses_remaining <= 0 || winner?
                print "\nYou have #{@guesses_remaining} #{@guesses_remaining > 1 ? "guesses" : "guess"} remaining!  Would you like to save your game?  " 
                save_game if save_game?  # give player option to save their game after every guess.  not the best UX, may add option to #get_user_input method later
            end 
        end

        if winner?
            puts "\nCongratulations!  You managed to guess the secret word!"
        else
            print "\nSorry, you lost! The solution was \"#{@solution}\"\n"
        end
    end

    def check_guess guess
        unless @solution.include? guess
            @guesses_remaining -= 1
        end
        @previous_guesses.push(guess)  # add guess to array of previous guesses.  used to prevent user from repeating guesses
    end


    def get_user_input
        
        # this can be refactored later into a single get_user_input method
        print "\nPlease choose a letter: "
        input = sanitize_text(gets)
        # check that the user provides a single, alphabetical character that has not been guessed yet
        until input.length == 1 && !@previous_guesses.include?(input) && input.match?(/^[A-Za-z]+$/)
            if input.length != 1
                print "\nPlease choose only one character: "
            elsif @previous_guesses.include?(input)
                print "\n\"#{input}\" has already been chosen.  Please try again: "
            elsif !input.match?(/^[A-Za-z]+$/)
                print "\nOnly alphabetical characters are allowed.  Please try again: "
            else
                print "\nI could not recognize your input.  Please try again: "
            end
            input = sanitize_text(gets)
        end
        return input
    end

    def load_dictionary
        File.readlines("5desk.txt").map { |line| sanitize_text(line) }
    end

    def load_game_from_file filename
        data = JSON.load File.read(filename)
        @solution = data["solution"]
        @previous_guesses = data["previous_guesses"]
        @guesses_remaining = data["guesses_remaining"]
    end

    def load_game?
        print "Would you like to load a game from file? [yes / no]: "

        # this can be refactored later into a single get_user_input method
        # input = gets.chomp.downcase until ["yes", "no"].include? input
        input = sanitize_text(gets)
        until ["yes", "no"].include? input
            print "Please type \"yes\" or \"no\": "
            input = sanitize_text(gets)
        end
        puts
        input == "yes" ? true : false
    end

    def sanitize_text text
        sanitize_text = text.chomp.downcase
    end

    def save_game
        saved_game = JSON.dump ({
                        :solution => @solution,
                        :previous_guesses => @previous_guesses,
                        :guesses_remaining => @guesses_remaining
                     })
        print "\nPlease choose a name for your saved game: "
        File.open("#{gets.chomp.downcase}.json", "w") { |file| file.print saved_game }  # saves game state as JSON file
        exit  # exits program
    end

    def save_game?
        input = gets.chomp.downcase until ["yes", "no"].include? input  #  needs to provide feedback to the user when provided with input other than "yes" or "no"
        {"yes" => true, "no" => false}[input]
    end

    def select_word dictionary
        @solution = dictionary.sample
    end

    def show_guesses
        visual = @solution.split("").map.with_index { |letter, index| @previous_guesses.include?(letter) ? letter : "_" }
        print "\n" + visual.join(" ") + "       " + @previous_guesses.to_s + "\n"
    end

    def winner?
        @solution.split("").all? { |letter| @previous_guesses.include? letter }
    end
end

Hangman.new