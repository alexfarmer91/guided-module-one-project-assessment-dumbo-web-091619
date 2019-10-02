5.times do
    Borrower.create(name: Faker::Name.name, password: "password", bio: Faker::Hacker.say_something_smart)
  end

 b1 = Borrower.first
 b2 = Borrower.second
 b3 = Borrower.third
 b4 = Borrower.fourth
 b5 = Borrower.fifth

 5.times do
  Lender.create(name: Faker::Name.name, password: "password", bio: Faker::Hacker.say_something_smart)
end

l1 = Lender.first
l2 = Lender.second
l3 = Lender.third
l4 = Lender.fourth
l5 = Lender.fifth

 5.times do
    Book.create(lender_id: rand(1..5), title: Faker::Book.title, author: Faker::Book.author, isbn: Faker::Code.isbn, genre: Faker::Book.genre, description: Faker::Lorem.sentence)
  end

book1 = Book.first
book2 = Book.second
book3 = Book.third
book4 = Book.fourth
book5 = Book.fifth

5.times do
    Checkout.create(borrower_id: rand(1..5), book_id: rand(1..5))
  end

  checkout1 = Checkout.first
  checkout2 = Checkout.second
  checkout3 = Checkout.third
  checkout4 = Checkout.fourth
  checkout5 = Checkout.fifth


  