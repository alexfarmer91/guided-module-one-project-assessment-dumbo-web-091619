
class Lender < ActiveRecord::Base 
    has_many :books
    has_many :checkouts, through: :books
    @@prompt = TTY::Prompt.new

    def self.handle_new_user
        puts "What is your name?"
        name = gets.chomp
        password = @@prompt.mask("Enter a password:")
        Lender.create(name: name, password: password, bio: "Insert bio here")
        
    end
    
    def self.handle_returning_user
        puts "Welcome back! What is your name?"
        name = gets.chomp
        password = @@prompt.mask("Enter your password:")
        Lender.find_by(name: name, password: password)
    end

    def main_menu
      self.reload
      system "clear"
      puts "Welcome, #{self.name}!"
      @@prompt.select("What would you like to do today?") do |menu|
          menu.choice "Buy a Book", -> {buy_book}
          menu.choice "See My Books", -> {display_my_books}
          menu.choice "Change Name", -> {change_name}
          menu.choice "Update Password", -> {change_password}
          menu.choice "Edit Bio", -> {change_bio}
          menu.choice "Delete Account", -> {delete_account}
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
  puts @all_my_books
  sleep 2
    main_menu
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

def delete_account
  puts "Delete Account"
  self.destroy
  puts "Your account has been deleted!"
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