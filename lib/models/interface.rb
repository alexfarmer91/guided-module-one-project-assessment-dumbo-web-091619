class Interface
    attr_accessor :borrower
    attr_reader :prompt

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        puts "Hello, welcome to the Lending Library App!"

        @prompt.select("Are you a new or returning user?") do |menu|
            menu.choice "Returning User", -> {Borrower.handle_returning_user}
            menu.choice "New User", -> {Borrower.handle_new_user}
        end
    end

    def main_menu
        puts "Welcome #{self.borrower.name}!"
        @prompt.select("What would you like to do today?") do |menu|
            menu.choice "See All Books", -> {Book.all}
            # menu.choice "See My Books", -> {self.borrower.}
        end

    end

end

