class Borrower < ActiveRecord::Base 
    has_many :checkouts
    has_many :books, through: :checkouts
    @@prompt = TTY::Prompt.new

    


def self.handle_new_user
    puts "What is your name?"
    name = gets.chomp
    password = @@prompt.mask("Enter a password:")
    Borrower.create(name: name, password: password, bio: "Insert bio here")
    
end

def self.handle_returning_user
    puts "Welcome back! What is your name?"
    name = gets.chomp
    password = @@prompt.mask("Enter your password:")
    Borrower.find_by(name: name, password: password)
end

def main_menu
    self.reload
    system "clear"
    puts "Welcome, #{self.name}!"

    @@prompt.select("What would you like to do today?") do |menu|
        menu.choice "See All Books", -> {display_all_books}
        menu.choice "See Available Books", -> {display_available_books}
        menu.choice "See My Books", -> {display_my_books}
        menu.choice "Borrow a Book", -> {borrow_book}
        menu.choice "Return A Book", -> {return_book}
        menu.choice "Use as Lender", -> {become_lender}
        menu.choice "Change Name", -> {change_name}
        menu.choice "Update Password", -> {change_password}
        menu.choice "Edit Bio", -> {change_bio}
        menu.choice "Delete Account", -> {delete_account}
        menu.choice "Quit", -> {exit}
    end
end

def display_all_books
    @all_books = Book.pluck(:title)
    @clean_books = @all_books.uniq

if Lender.find_by(name: self.name) != nil
    my_books = Lender.find_by(name: self.name).books.pluck(:title)
    my_books.each { |title| @clean_books.delete(title) }

end
    
    selected_book = @@prompt.select("Books", @clean_books) 
    chosen_book = Book.find_by(title: selected_book)
    puts chosen_book.description
    
    sleep 1

    @@prompt.select ("What would you like to do now?") do |menu|
        menu.choice "Back to All Books", -> {display_all_books}
        menu.choice "See Available Books", -> {display_available_books}
        menu.choice "Return to the Main Menu", -> {main_menu}
    end
end

def display_available_books
    all_checkout_book_ids = Checkout.pluck(:book_id)
    all_book_ids = Book.pluck(:id)
    available_book_ids = (all_checkout_book_ids - all_book_ids) | (all_book_ids - all_checkout_book_ids)
    available_books = Book.where(id: available_book_ids)
    @available_books_list = available_books.map do |book|
        book.title
    end

    if Lender.find_by(name: self.name) != nil
        my_books = Lender.find_by(name: self.name).books.pluck(:title)
        my_books.each { |title| @available_books_list.delete(title) }
    
    end

    selected_book = @@prompt.select("Books", @available_books_list) 
    chosen_book = Book.find_by(title: selected_book)
    puts chosen_book.description
    
    sleep 1
    @@prompt.select ("What would you like to do now?") do |menu|
        menu.choice "Borrow This Book", -> {borrow_book_by_title(selected_book) }
        menu.choice "Back to Available Books", -> {display_available_books}
        menu.choice "See All Books", -> {display_all_books}
        menu.choice "Return to the Main Menu", -> {main_menu}
    end
end

def find_my_checkouts
    my_id = self.id
    puts Checkout.where(borrower_id: my_id)
    sleep 3
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
        menu.choice "Return to the Main Menu", -> {main_menu}
    end
end


def change_name
    puts "Please enter your new name here:"
    new_name = gets.chomp
    self.update_attribute(:name, new_name)
    puts "Your name has been updated."
    sleep 2
    main_menu
end

def change_password
    puts "Please enter your new password here:"
    new_password = gets.chomp
    self.update_attribute(:password, new_password)
    puts "Your password has been updated."
    sleep 2
    main_menu
end

def change_bio
    puts "Please enter your updated bio here:"
    new_bio = gets.chomp
    self.update_attribute(:bio, new_bio)
    puts "Your bio has been updated."
    sleep 2
    main_menu
end


def borrow_book
<<<<<<< HEAD
    puts "Please enter the id of the book you'd like to check out."
    selected_book_id = gets.chomp.to_i
    selected_book_title = Book.find_by(id: selected_book_id).title
=======
    puts "Please enter the title of the book you'd like to check out."
    selected_book = gets.chomp
    selected_book_instance = Book.find_by(title: selected_book)
    selected_book_id = selected_book_instance.id
>>>>>>> f1c245ed7a4d620c781f4dc2a0dff03ba45134b8
    if Checkout.pluck(:book_id).include?(selected_book_id)
        puts "I'm sorry, that book is already checked out."
        sleep 1
        @@prompt.select ("Would you like to buy it?") do |menu|
            menu.choice "Yes", -> {open_google_if_not_exists(selected_book_title)}
            menu.choice "No, I'll wait"
        end

    else
        Checkout.create(borrower_id: self.id, book_id: selected_book_id)
        puts @@enjoy_your_book
    end
    sleep 23
    main_menu
end

def borrow_book_by_title(book_title)    
    selected_book_instance = Book.find_by(title: book_title)
    selected_book_id = selected_book_instance.id
    Checkout.create(borrower_id: self.id, book_id: selected_book_id)
    puts @@enjoy_your_book
    sleep 3
    main_menu
end

def return_book
    puts "Which book would you like to return? Please enter a title."
    selected_book = gets.chomp
    selected_book_instance = Book.find_by(title: selected_book)
    selected_book_id = selected_book_instance.id
    Checkout.where(book_id: selected_book_id).destroy_all
    puts "Thank you for returning your book!"
    sleep 2
    main_menu
end

def delete_account
    puts "Delete Account"
    self.destroy
    puts "Your account has been deleted!"
    sleep 2
end

def become_lender
    if Lender.pluck(:name).include?(self.name)
      loggedInUser = Lender.find_by(name: self.name)
      loggedInUser.main_menu
    else 
     Lender.create(name: self.name, password: self.password, bio: self.bio)
     loggedInUser = Lender.find_by(name: self.name)
     loggedInUser.main_menu
    end 
  end 

<<<<<<< HEAD




private

  def open_google_if_not_exists(title_query)
    response_string = RestClient.get("https://www.googleapis.com/books/v1/volumes?q=#{title_query}")
    response_hash = JSON.parse(response_string)

    creation_hash = {:title => response_hash["items"][0]["volumeInfo"]["title"], 
    :author => response_hash["items"][0]["volumeInfo"]["authors"][0], 
    :isbn => response_hash["items"][0]["volumeInfo"]["industryIdentifiers"][0]["identifier"],
    :genre => response_hash["items"][0]["volumeInfo"]["categories"][0],
    :description => response_hash["items"][0]["volumeInfo"]["description"]
   }

   my_lender_id = get_lender_id

   Book.create(lender_id: my_lender_id, 
   title: creation_hash[:title], 
   author: creation_hash[:author], 
   isbn: creation_hash[:isbn], 
   genre: creation_hash[:genre], 
   description: creation_hash[:description])

 if response_hash["items"][0]["saleInfo"]["saleability"] != "NOT_FOR_SALE"
   Launchy.open(response_hash["items"][0]["saleInfo"]["buyLink"])
 end 

   @@prompt.say("Congrats on your new book!", color: :red)
   sleep 1
   @@prompt.select ("How would you like to continue?") do |menu|
       menu.choice "Continue as Borrower", -> {main_menu}
       menu.choice "Switch to Lender Mode", -> {become_lender}
   end

  end 
=======
  ############
  ## ASCII ##
  ##########


  @@enjoy_your_book = <<-ASCII
       __..._   _...__
  _..-"      `Y`      "-._
  \   Enjoy   |  once      /
  \\   Your   |  upon a  //
  \\\  Book!  |  time...///
   \\\ _..---.|.---.._ ///
    \\`_..---.Y.---.._`// 
     '`               `'
     ASCII
>>>>>>> f1c245ed7a4d620c781f4dc2a0dff03ba45134b8


  def get_lender_id
    if Lender.pluck(:name).include?(self.name)
      Lender.find_by(name: self.name).id
    else 
     Lender.create(name: self.name, password: self.password, bio: self.bio)
     Lender.find_by(name: self.name).id
    end 
  end 



end