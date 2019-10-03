
class Lender < ActiveRecord::Base 
    has_many :books
    has_many :checkouts, through: :books
    @@prompt = TTY::Prompt.new

    def self.handle_new_user
        puts "What is your name?"
        name = gets.chomp
          while name == "" do
            system "clear"
            puts "You must enter a name!".colorize(:red)
            puts "What is your name?"
            name = gets.chomp
          end
        
        password = @@prompt.mask("Enter a password:")
          while password == nil do
            system "clear"
            puts "You must enter a password!".colorize(:red)
            password = @@prompt.mask("Enter a password:")
          end
        Lender.create(name: name, password: password, bio: "Insert bio here")
        
    end
    
    def self.handle_returning_user
        puts "Welcome back! What is your name?"
        name = gets.chomp
          while name == "" do
            system "clear"
            puts "You must enter a name!".colorize(:red)
            puts "What is your name?"
            name = gets.chomp
          end
        password = @@prompt.mask("Enter your password:")
          while password == nil do
            system "clear"
            puts "You must enter a password!".colorize(:red)
            password = @@prompt.mask("Enter a password:")
          end
        Lender.find_by(name: name, password: password)
    end

    def main_menu
      self.reload
      system "clear"
      puts "Welcome, " + self.name.titleize + "!"
      @@prompt.select("What would you like to do today?".colorize(:cyan)) do |menu|
          menu.choice "Buy a Book 💸", -> {buy_book}
          menu.choice "See My Books", -> {display_my_books}
          menu.choice "See My Checked-Out Books", -> {display_checked_out_books}
          menu.choice "Use as Borrower", -> {become_borrower}
          menu.choice "Change Name", -> {change_name}
          menu.choice "Update Password", -> {change_password}
          menu.choice "Edit Bio", -> {change_bio}
          menu.choice "Delete Account ❌".colorize(:red), -> {delete_account}
          menu.choice "Quit", -> {exit}


          ascii = <<-ASCII


      )  (
        (   ) )
         ) ( (
       _______)_
    .-'---------|  
   ( C|/\/\/\/\/|
    '-./\/\/\/\/|
      '_________'
       '-------'

       ASCII
       puts ascii


      end


      
      
  end
 
def buy_book
  puts "Please enter the Title or ISBN that you'd like to search for."
    query = gets.chomp
    get_attr(query) 
    sleep 2
    main_menu
end

def display_my_books
  @all_my_books = self.books.pluck(:title)
  @clean_books = @all_my_books.uniq

  @selected_book = @@prompt.select("Books", @clean_books) 
  @chosen_book = Book.find_by(title: @selected_book)
  puts @chosen_book.description
  sleep 2

  @@prompt.select ("What would you like to do now?") do |menu|
      menu.choice "Back to My Books", -> {display_my_books}
      menu.choice "See My Checked-Out Books", -> {display_checked_out_books}
      menu.choice "Return to the Main Menu", -> {main_menu}
  end
end

def display_checked_out_books
  all_my_book_ids = self.books.pluck(:id)
  all_checkout_book_ids = Checkout.pluck(:book_id)
  
  my_checked_out_book_ids = all_my_book_ids & all_checkout_book_ids
  my_checked_out_books = Book.where(id: my_checked_out_book_ids)
  my_checked_out_book_titles = my_checked_out_books.map do |book|
      book.title
  end
  
  selected_book = @@prompt.select("My Checked-Out Books", my_checked_out_book_titles) 
  chosen_book = Book.find_by(title: selected_book)
  chosen_book_id = chosen_book.id
  chosen_book_checkout = Checkout.find_by(book_id: chosen_book_id)
  chosen_book_borrower = Borrower.find_by(id: chosen_book_checkout.borrower_id)
  puts "Checked Out By: #{chosen_book_borrower.name}"
 
  sleep 4
  @@prompt.select ("What would you like to do now?") do |menu|
      menu.choice "Back to My Checked-Out Books", -> {display_checked_out_books}
      menu.choice "See All My Books", -> {display_my_books}
      menu.choice "Return to the Main Menu", -> {main_menu}
  end
end

def become_borrower
  if Borrower.pluck(:name).include?(self.name)
    loggedInUser = Borrower.find_by(name: self.name)
    loggedInUser.main_menu
  else 
   Borrower.create(name: self.name, password: self.password, bio: self.bio)
   loggedInUser = Borrower.find_by(name: self.name)
   loggedInUser.main_menu
  end 
end 

def change_name
  puts "Please enter your new name here:"
  new_name = gets.chomp
  self.update_attribute(:name, new_name)
  puts "Your name has been updated.".colorize(:green)
  sleep 2
    main_menu
end

def change_password
  puts "Please enter your new password here:"
  new_password = gets.chomp
  self.update_attribute(:password, new_password)
  puts "Your password has been updated.".colorize(:green)
  sleep 2
    main_menu
end

def change_bio
  puts "Please enter your updated bio here:"
  new_bio = gets.chomp
  self.update_attribute(:bio, new_bio)
  puts "Your bio has been updated.".colorize(:green)
  sleep 2
    main_menu
end

def delete_account
  puts "Delete Account"
  self.destroy
  puts "Your account has been deleted!".colorize(:red)
  ascii = <<-ASCII


    ,     ,
    (\____/)
     (_oo_)
       (O)
     __||__    \)
  []/______\[] /
  / \______/ \/
 /    /__\
(\   /____\



    ASCII
    puts ascii
end

def get_attr(query)

    response_string = RestClient.get("https://www.googleapis.com/books/v1/volumes?q=#{query}")
    response_hash = JSON.parse(response_string)
    output_hash = {:title => response_hash["items"][0]["volumeInfo"]["title"], 
    :author => response_hash["items"][0]["volumeInfo"]["authors"][0], 
    :isbn => response_hash["items"][0]["volumeInfo"]["industryIdentifiers"][0]["identifier"],
    :genre => response_hash["items"][0]["volumeInfo"]["categories"][0],
    :description => response_hash["items"][0]["volumeInfo"]["description"]
   }   
   Book.create(lender_id: self.id, title: output_hash[:title], author: output_hash[:author], isbn: output_hash[:isbn], genre: output_hash[:genre], description: output_hash[:description])
   ascii = <<-ASCII
                                                    
                                         ,--.         
   ,---.,---.,--,--, ,---.,--.--.,--,--,-'  '-.,---.  
  | .--| .-. |      | .-. |  .--' ,-.  '-.  .-(  .-'  
  \ `--' '-' |  ||  ' '-' |  |  \ '-'  | |  | .-'  `) 
   `---'`---'`--''--.`-  /`--'   `--`--' `--' `----'  
                    `---'                             
   ASCII
   @@prompt.say(ascii, color: :red)
   sleep(2)
  end


  # def search_or_buy_by_title(title_query)
  #   if Book.pluck(:title).include?(title_query) == false
  #     open_google_if_not_exists(title_query)
  #   else 
     
  #   end 
  
  #  end 

  # def open_google_if_not_exists(title_query)
  #   response_string = RestClient.get("https://www.googleapis.com/books/v1/volumes?q=#{title_query}")
  #   response_hash = JSON.parse(response_string)
  #   Launchy.open(response_hash["items"][0]["saleInfo"]["buyLink"])
  # end 

end 