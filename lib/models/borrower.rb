class Borrower < ActiveRecord::Base 
    has_many :checkouts
    has_many :books, through: :checkouts
    @@prompt = TTY::Prompt.new


def self.handle_new_user
    puts "What is your name"
    name = gets.chomp
    puts "What is your password?"
    password = gets.chomp
    Borrower.create(name: name, password: password, bio: "idk")
end

def self.handle_returning_user
    puts "Welcome back! What is your name?"
    name = gets.chomp
    puts "What is your password?"
    password = gets.chomp
    Borrower.find_by(name: name, password: password)
end

def main_menu
    self.reload
    system "clear"
    puts "Welcome, #{self.name}!"
    @@prompt.select("What would you like to do today?") do |menu|
        menu.choice "See All Books", -> {display_all_books}
    end
end

def display_all_books
    @all_books = Book.all
    puts @all_books
end



end