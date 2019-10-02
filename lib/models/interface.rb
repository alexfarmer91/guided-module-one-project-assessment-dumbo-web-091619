class Interface
    attr_accessor :user
    attr_reader :prompt

    def initialize
        @prompt = TTY::Prompt.new
    end

    def welcome
        puts "Hello, welcome to Polonius!"

        new_or_returning = self.prompt.select("Are you a new or returning user?") do |menu|
            menu.choice "New User"
            menu.choice "Returning User"
        end

        case new_or_returning
        when "New User"
            borrower_or_lender = self.prompt.select("Would you like to borrow books or lend them?") do |menu|
                menu.choice "Borrower"
                menu.choice "Lender"
            end
            
            case borrower_or_lender
            when "Borrower"
                Borrower.handle_new_user
            when "Lender"
                Lender.handle_new_user
            end
        
        when "Returning User"
            borrower_or_lender = self.prompt.select("Are you a borrower or a lender?") do |menu|
                menu.choice "Borrower"
                menu.choice "Lender"
            end

            case borrower_or_lender
            when "Borrower"
                Borrower.handle_returning_user
            when "Lender"
                Lender.handle_returning_user
            end
        end
    end

end

