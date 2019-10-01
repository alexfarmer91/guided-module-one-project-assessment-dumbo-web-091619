require_relative '../config/environment'

interface = Interface.new
loggedInUser = interface.welcome()

while loggedInUser.nil?
    loggedInUser = interface.welcome()
end

interface.borrower = loggedInUser
interface.borrower.main_menu

binding.pry


