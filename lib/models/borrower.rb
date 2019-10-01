class Borrower < ActiveRecord::Base 
    has_many :checkouts
    has_many :books, through: :checkouts
    @@prompt = TTY::Prompt.new


def self.handle_new_user
    puts "What is your name?"
    name = gets.chomp
    puts "What is your password?"
    password = gets.chomp
    Borrower.create(name: name, password: password, bio: "Insert bio here")
    
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
        menu.choice "See My Checkouts", -> {find_my_checkouts}
        menu.choice "See My Books", -> {display_my_books}
        menu.choice "Change Name", -> {change_name}
        menu.choice "Update Password", -> {change_password}
        menu.choice "Edit Bio", -> {change_bio}
        menu.choice "Delete Account", -> {delete_account}
    end
end

def display_all_books
    @all_books = Book.pluck(:title)
    puts @all_books.uniq
end

def find_my_checkouts
    my_id = self.id
    puts Checkout.where(borrower_id: my_id)
end

def display_my_books
    
end
# SELECT books.title AS Title, books.author AS Author, FROM checkouts
# INNER JOIN books ON checkouts.book_id = books.id
# WHERE borrower_id = ?

def change_name
    puts "Please enter your new name here:"
    new_name = gets.chomp
    self.update_attribute(:name, new_name)
    puts "Your name has been update."
end

def change_password
    puts "Please enter your new password here:"
    new_password = gets.chomp
    self.update_attribute(:password, new_password)
    puts "Your password has been updated."
end

def change_bio
    puts "Please enter your updated bio here:"
    new_bio = gets.chomp
    self.update_attribute(:bio, new_bio)
    puts "Your bio has been updated."
end

def delete_account
    puts "Delete Account"
    self.destroy
    puts "Your account has been deleted!"
end

end