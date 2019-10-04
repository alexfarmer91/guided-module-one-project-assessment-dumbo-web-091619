class Borrower < ActiveRecord::Base 
    has_many :checkouts
    has_many :books, through: :checkouts
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
        Borrower.create(name: name, password: password, bio: "Insert bio here")
        
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
        Borrower.find_by(name: name, password: password)
    end


    def main_menu
        self.reload
        system "clear"
        puts "Welcome, " + self.name.titleize + "!"
        @@prompt.select("What would you like to do today?".colorize(:cyan)) do |menu|
            menu.choice "See All Books", -> {display_all_books}
            menu.choice "See Available Books", -> {display_available_books}
            menu.choice "See My Borrowed Books", -> {display_my_books}
            menu.choice "Borrow a Book", -> {borrow_book}
            menu.choice "Return A Book", -> {return_book}
            menu.choice "Use as Lender", -> {become_lender}
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

def display_all_books
    @all_books = Book.pluck(:title)
    @clean_books = @all_books.uniq

    if Lender.find_by(name: self.name) != nil
        my_books = Lender.find_by(name: self.name).books.pluck(:title)
        my_books.each { |title| @clean_books.delete(title) }
    end

    selected_book = @@prompt.select("Books".colorize(:light_cyan).underline, @clean_books)  
    chosen_book = Book.find_by(title: selected_book)
    puts chosen_book.description
    
    sleep 2

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
    
    sleep 4
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
    if self.books.length < 1
        puts "You haven't borrowed any books yet!".colorize(:red)
        @@prompt.select ("What would you like to do?") do |menu|
            menu.choice "See Available Books", -> {display_available_books}
            menu.choice "Return to the Main Menu", -> {main_menu}
        end
    else
        @all_my_books = self.books.pluck(:title)
        @clean_books = @all_my_books.uniq
  
        @selected_book = @@prompt.select("Books", @clean_books) 
        @chosen_book = Book.find_by(title: @selected_book)
        puts @chosen_book.description
    ascii = <<-ASCII
         __..._   _...__
    _..-"      `Y`      "-._
    \ Once upon |           /
    \\  a time..|          //
    \\\         |         ///
     \\\ _..---.|.---.._ ///
      \\`_..---.Y.---.._`//
       '`               `'
    
    ASCII
        puts ascii
        sleep 3
        @@prompt.select ("What would you like to do now?") do |menu|
            menu.choice "Back to My Books", -> {display_my_books}
            menu.choice "Return to the Main Menu", -> {main_menu}
        end
    end
end

def change_name
    puts "Please enter your new name here:"
    new_name = gets.chomp
    if Lender.find_by(name: self.name) != nil 
     me_as_lender = Lender.find_by(name: self.name)
     me_as_lender.name = new_name
     me_as_lender.save
     self.update_attribute(:name, new_name)
    else 
    self.update_attribute(:name, new_name)
    end 

    puts "Your name has been updated.".colorize(:green)
    sleep 2
    main_menu
end

def change_password
    puts "Please enter your new password here:"
    new_password = @@prompt.mask("Enter a new password:")
    if Lender.find_by(name: self.name) != nil 
      me_as_lender = Lender.find_by(name: self.name)
      me_as_lender.password = new_password
      me_as_lender.save
      self.update_attribute(:password, new_password)
     else 
     self.update_attribute(:password, new_password)
     end 
    puts "Your password has been updated.".colorize(:green)
    sleep 2
    main_menu
end

def change_bio
    puts "Please enter your updated bio here:"
    new_bio = gets.chomp
    if Lender.find_by(name: self.name) != nil 
      me_as_lender = Lender.find_by(name: self.name)
      me_as_lender.bio = new_bio
      me_as_lender.save
      self.update_attribute(:bio, new_bio)
     else 
      self.update_attribute(:bio, new_bio)
     end 
    puts "Your bio has been updated.".colorize(:green)
    sleep 2
    main_menu
end


def borrow_book
    puts "Please enter the title of the book you'd like to check out."
    selected_book = gets.chomp
    if !Book.find_by(title: selected_book)
        puts "I'm sorry, no one is lending out that book".colorize(:red)
        @@prompt.select ("Would you like to buy it?") do |menu|
            menu.choice "Yes", -> {open_google_if_not_exists(selected_book)}
            menu.choice "No, I'll wait"
        end
    else
    selected_book_instance = Book.find_by(title: selected_book)
    selected_book_id = selected_book_instance.id
    if Checkout.pluck(:book_id).include?(selected_book_id)
        puts "I'm sorry, that book is already checked out.".colorize(:red)
        sleep 1
        @@prompt.select ("Would you like to buy it?") do |menu|
            menu.choice "Yes", -> {open_google_if_not_exists(selected_book_instance.title)}
            menu.choice "No, I'll wait"
        end
    else
        Checkout.create(borrower_id: self.id, book_id: selected_book_id)
        puts "Enjoy your book!".colorize(:green)

        ascii = <<-ASCII
        _   _                           ____                _ _               _ 
        | | | | __ _ _ __  _ __  _   _  |  _ \ ___  __ _  __| (_)_ __   __ _  | |
        | |_| |/ _` | '_ \| '_ \| | | | | |_) / _ \/ _` |/ _` | | '_ \ / _` | | |
        |  _  | (_| | |_) | |_) | |_| | |  _ <  __/ (_| | (_| | | | | | (_| | |_|
        |_| |_|\__,_| .__/| .__/ \__, | |_| \_\___|\__,_|\__,_|_|_| |_|\__, | (_)
                    |_|   |_|    |___/                                 |___/     
               
    ASCII
    @@prompt.say(ascii, color: :green)
    end
end
    sleep 3
    main_menu
end

def borrow_book_by_title(book_title)    
    selected_book_instance = Book.find_by(title: book_title)
    selected_book_id = selected_book_instance.id
    Checkout.create(borrower_id: self.id, book_id: selected_book_id)
    puts "Enjoy your book!"
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
  @@prompt.select("Are you sure?") do |menu|
    menu.choice "No", -> {main_menu}
    menu.choice "Yes", -> {multi_delete}
    end
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

   @@prompt.say("Congrats on your new book!", color: :green)
   sleep 1
   @@prompt.select ("How would you like to continue?") do |menu|
       menu.choice "Continue as Borrower", -> {main_menu}
       menu.choice "Switch to Lender Mode", -> {become_lender}
   end

  end 


  def get_lender_id
    if Lender.pluck(:name).include?(self.name)
      Lender.find_by(name: self.name).id
    else 
     Lender.create(name: self.name, password: self.password, bio: self.bio)
     Lender.find_by(name: self.name).id
    end 
  end 

  def multi_delete
    if Lender.find_by(name: self.name) != nil
     me_as_lender = Lender.find_by(name: self.name)
     me_as_lender.destroy
     self.destroy
    else 
     self.destroy
   end 
 
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


end