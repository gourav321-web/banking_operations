# banking system 
require 'csv'

class Main
  def initialize
    @user={name:'', email:'', password:'', balance:0}
    check_file
  end

  def check_file
    unless File.exist?("User.csv")
      CSV.open("User.csv","w") do |csv|
        csv << ["name","email","password","balance"]
      end
    end
  end

  # Authentication logic
  def register
    @user[:email] = ''
    loop do
      print "Enter your Name : "
      @name = gets.chomp.strip
      if @name.empty?
        puts "please enter your name"
      elsif(!(/^[a-zA-Z]{3,}(?: [a-zA-Z]+){0,2}$/.match?(@name)))
        puts "Enter valid name"
      else
        break
      end
    end
    loop do
      print "Enter your Email : "
      @email = gets.chomp.downcase
      if @email.empty?
        puts "please enter Email"
      else
        @email.gsub!(/\s+/ , "")
        break
      end
    end
    loop do
      print "Enter Password : "
      @password = gets.chomp
      if @password.empty?
        puts "please enter Password"
      else
        break
      end
    end
    flag=false
    CSV.foreach("User.csv", headers:true) do |row|
      row_email = row["email"]
      if row["email"] == @email
        flag = true
        puts "Email already registered !"
        break
      end
    end
    return if flag
    if(!email_validate(@email))
      puts "please enter valid email"
      return
    end
    @new_user={name:@name,email:@email,password:@password,balance:0}
    CSV.open("User.csv","a") do |users|
      users << @new_user.values
    end
    puts "Registration successful."
  end

  def login
    loop do
      print "Enter your Email : "
      @email=gets.chomp.downcase
      if @email.empty?
        puts "please enter Email"
      else
        @email.gsub!(/\s+/ , "")
        break
      end
    end
    loop do
      print "Enter Password : "
      @password=gets.chomp
      if @password.empty?
        puts "please enter Password"
      else
        break
      end
    end
    found=false
    CSV.foreach("User.csv",headers:true) do |row|
      if row["email"]==@email && row["password"]==@password
        found=true
        @user[:name] = row["name"]
        @user[:email]=row["email"]
        @user[:password] = row["password"]
        @user[:balance]=row["balance"].to_i
        puts "Login Successful."
        break
      end
    end
    puts "Invalid Email or Password!" unless found
  end

  def email_validate(email)
    return /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match?(email)
  end

  def update_balance
    rows = CSV.read("User.csv",headers:true)
    rows.each do |row|
      if row["email"] == @user[:email]
        row["balance"] = @user[:balance].to_s
      end
    end
    CSV.open("User.csv","w") do |csv|
      csv << rows.headers
      rows.each do |row|
        csv << row
      end
    end
  end

  #  banking logicc
  def deposit(amount)
    if @user[:email].empty?
      puts "User not logged in!"
      return
    end
    if amount < 0.1
      puts "please enter valid amount"
      return
    end
    @user[:balance] += amount
    update_balance
    puts "after deposit #{amount}, balance is #{@user[:balance]}"
  end

  def Withdraw(amount)
    if @user[:email].empty?
      puts "User not logged in!"
      return
    end
    if amount < 0.1 || amount > @user[:balance]
      puts "please enter valid amount"
      return
    end
    @user[:balance] -= amount
    update_balance
    puts "balance after Withdraw #{amount} is #{@user[:balance]}"
  end

  def balance
    if @user[:email].empty?
      puts "user not logged in"
      return
    end
    puts "balance : #{@user[:balance]}"
  end

  def logout
    if @user[:email].empty?
      puts "user already logged out !"
      return
    end
    @user[:email]=""
    puts "User logged out successfully"
  end

  def choice
    loop do
      puts "1. Register"
      puts "2. Login"
      puts "3. Deposit"
      puts "4. Withdraw"
      puts "5. Balance"
      puts "6. Logout"
      puts "7. Exit"

      print "Enter your choice : "
      choice = gets.chomp.to_i
      case choice
        when 1
          register
        when 2
          login
        when 3
          print "Enter amount to deposit: "
          amt=gets.chomp.to_f.round(2)
          deposit(amt)
        when 4
          print "Enter amount to withdraw: "
          amt=gets.chomp.to_f.round(2)
          Withdraw(amt)
        when 5
          balance
        when 6
          logout
        when 7
          break
        else
          puts "invalid choice"
      end
    end
  end
end

user = Main.new
user.choice   
