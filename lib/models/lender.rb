
class Lender < ActiveRecord::Base 
    has_many :books
    has_many :checkouts, through: :books
    @@prompt = TTY::Prompt.new

    def self.handle_new_user
        @@prompt.say("What is your name?", color: :red)
        name = gets.chomp
        password = @@prompt.mask("Enter a password:")
        Lender.create(name: name, password: password, bio: "Insert bio here")
        
    end
    
    def self.handle_returning_user
        @@prompt.say("Welcome back! What is your name?", color: :red)
        name = gets.chomp
        password = @@prompt.mask("Enter your password:")
        Lender.find_by(name: name, password: password)
    end

    def main_menu
      self.reload
      system "clear"
      @@prompt.say"Welcome, #{self.name}!", color: :red)
      @@prompt.select("What would you like to do today?") do |menu|
          menu.choice "Buy a Book", -> {buy_book}
          menu.choice "Sell a Book", -> {sell_book}
          menu.choice "See My Books", -> {display_my_books}
          menu.choice "See My Checked-Out Books", -> {display_checked_out_books}
          menu.choice "Use as Borrower", -> {become_borrower}
          menu.choice "Change Name", -> {change_name}
          menu.choice "Update Password", -> {change_password}
          menu.choice "Edit Bio", -> {change_bio}
          menu.choice "Delete Account", -> {delete_account}
          menu.choice "Quit", -> {exit}
      end
  end
 
def buy_book
  @@prompt.say("Please enter the Title or ISBN that you'd like to search for.", color: :red)
    query = gets.chomp
    get_attr(query) 
    sleep 2
    main_menu
end

def display_my_books
  if self.books.length < 1
    @@prompt.say("You do not have any books!", color: :red)
    @@prompt.select ("Return to the main menu?") do |menu|
      menu.choice "Main Menu", ->{main_menu}
    end
  else
    @all_my_books = self.books.pluck(:title)
    @clean_books = @all_my_books.uniq
    @selected_book = @@prompt.select("Books", @clean_books) 
    @chosen_book = Book.find_by(title: @selected_book)
    @@prompt.say(@chosen_book.description, color: :red)
  end
  sleep 2

  @@prompt.select ("What would you like to do now?") do |menu|
      menu.choice "Back to My Books", -> {display_my_books}
      menu.choice "See My Checked-Out Books", -> {display_checked_out_books}
      menu.choice "Return to the Main Menu", -> {main_menu}
  end
end

def display_checked_out_books
  if self.checkouts.length < 1
    @@prompt.say("You do not have any checked out books!", color: :red)
      @@prompt.select ("Return to the main menu?") do |menu|
        menu.choice "Main Menu", ->{main_menu}
      end  
    else
    all_my_book_ids = self.books.pluck(:id)
    all_checkout_book_ids = Checkout.pluck(:book_id)
    my_checked_out_book_ids = all_my_book_ids & all_checkout_book_ids
    my_checked_out_books = Book.where(id: my_checked_out_book_ids)
    my_checked_out_book_titles = my_checked_out_books.map do |book|
      book.title
    end
  end
  
  selected_book = @@prompt.select("My Checked-Out Books", my_checked_out_book_titles) 
  chosen_book = Book.find_by(title: selected_book)
  chosen_book_id = chosen_book.id
  chosen_book_checkout = Checkout.find_by(book_id: chosen_book_id)
  chosen_book_borrower = Borrower.find_by(id: chosen_book_checkout.borrower_id)
  @@prompt.say("Checked Out By: #{chosen_book_borrower.name}", color: :red)
 
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
  @@prompt.say("Please enter your new name here:", color: :red)
  new_name = gets.chomp
  self.update_attribute(:name, new_name)
  @@prompt.say("Your name has been updated.", color: :red)
  sleep 2
    main_menu
end

def change_password
  @@prompt.say("Please enter your new password here:", color: :red)
  new_password = gets.chomp
  self.update_attribute(:password, new_password)
  @@prompt.say("Your password has been updated.", color: :red)
  sleep 2
    main_menu
end

def change_bio
  @@prompt.say("Please enter your updated bio here:", color: :red)
  new_bio = gets.chomp
  self.update_attribute(:bio, new_bio)
  @@prompt.say("Your bio has been updated.", color: :red)
  sleep 2
    main_menu
end

def delete_account
  @@prompt.say("Delete Account", color: :red)
  self.destroy
  @@prompt.say("Your account has been deleted!", color: :red)
end

def sell_book
  if self.books.length < 1
    @@prompt.say("You do not have any books to sell!", color: :red)
  else 
    selected_book = @@prompt.select("Books", self.books.pluck(:title))
    chosen_book = Book.find_by(title: selected_book, lender_id: self.id)
    @@prompt.select("Are you selling to another Polonius lender?") do |menu|
     menu.choice "Yes", -> {
      @@prompt.say("Please enter their lender ID", color: :red)
      new_owner_id = gets.chomp.to_i
      chosen_book.lender_id = new_owner_id
      chosen_book.save
      @@prompt.say("Money money!", color: :green)
    }
     menu.choice "No"
    end 
  end 
  sleep 1
 main_menu
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


end 