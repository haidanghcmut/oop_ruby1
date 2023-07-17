require "csv"

class User
    attr_accessor :owner, :balance, :card_number, :password
    def initialize(owner, balance, card_number, password)
        @owner = owner
        @card_number = card_number
        @password = password
        @balance = balance
    end

    def to_hash
        {
            owner: @owner,
            balance: @balance,
            card_number: @card_number,
            password: @password
        }
    end
end


class ATM
    def initialize
       @accounts = load_accounts_from_csv
       @current_account = []
    end
     
    def start
        puts '=== ATM ==='
        login
        show_menu
        process_menu_choice until @current_account.nil?
        puts 'Thank you for using the ATM. Goodbye!'
    end

    def login
        puts 'Please enter your card number:'
        card_number_enter = gets.chomp
        puts 'Please enter your password:'
        password_enter = gets.chomp
        @accounts.each do |account|
            if account.card_number == card_number_enter.to_i && account.password == password_enter.to_i
                @current_account = account
            end
        end
        if @current_account.nil?
            puts 'Invalid card number or password. Please try again.'
            login
        else
            puts "Welcome, #{@current_account.owner}!"
            puts "Your balance: $#{@current_account.balance}"
        end
    end

    def show_menu
        puts '=== Menu ==='
        puts '1. Withdraw'
        puts '2. Check Balance'
        puts '3. Deposit'
        puts '4. Transfer'
        puts '5. Exit'
    end

    def process_menu_choice
        choice = gets.chomp.to_i
        case choice
        when 1
            withdraw
        when 2
            check_balance
        when 3
            deposit
        when 4
            transfer   
        when 5
            @current_account = nil
        else
            puts 'Invalid choice. Please try again.'
        end
    end

    def withdraw
        puts 'How much would you like to withdraw?'
        amount = gets.chomp.to_i
        if amount > @current_account.balance
            puts 'Insufficient funds.'
        else
            @current_account.balance -= amount
            save_accounts_to_csv
            puts "Your new balance is $#{@current_account.balance}"
        end
    end

    def check_balance
        puts "Your balance is $#{@current_account.balance}"
    end

    def deposit
        puts 'How much would you like to deposit?'
        amount = gets.chomp.to_i
        @current_account.balance += amount
        save_accounts_to_csv
        puts "Your new balance is $#{@current_account.balance}"
    end

    def transfer
      puts 'Enter the account number to transfer to:'
        account_number = gets.chomp
       puts 'Enter the money to transfer:'
        recipient_account = @accounts.find { |account| account.card_number == account_number.to_i }
        if recipient_account.nil?
            puts 'Invalid account number.'
            return transfer
        else 
            amount = gets.chomp.to_i
            if amount > @current_account.balance
                puts 'Insufficient funds.'
                return transfer
            else
                @current_account.balance -= amount
                recipient_account.balance += amount
                save_accounts_to_csv
                puts "Your new balance is $#{@current_account.balance}"
                return transfer
            end
        end
    end

    def log_out
        @current_account = nil
    end
    # load file CSV
    def load_accounts_from_csv
        accountt = []
        if (File.file?('./accounts.csv') && !File.zero?('./accounts.csv'))
            # tables = CSV.parse(File.read('./accounts.csv'))
            # tables.each do |row|
            #     table = row[0].split(';')
            #     owner = row[0].split(';').first               
            #     balance = table[1].to_i
            #     card_number = table[2].to_i
            #     password = table[3].to_i
            #     accountt << User.new(owner, balance, card_number, password)
            CSV.foreach('./accounts.csv', headers: true, col_sep: ";") do |row|
                owner = row["owner"]
                balance = row["balance"].to_i
                card_number = row["card_number"].to_i
                password = row["password"].to_i
                accountt << User.new(owner, balance, card_number, password)
            end
            return accountt
        else 
            File.new("./accounts.csv", 'w')   
        end
    end

# save file CSV 

    def save_accounts_to_csv
        data = CSV.read('accounts.csv', headers: true, col_sep: ";")
        CSV.open('accounts.csv', 'w', col_sep: ";") do |csv|
            csv << data.headers
          @accounts.each do |account|
            csv << [account.owner, account.balance, account.card_number, account.password]
          end
    end
   end
end


atm = ATM.new
atm.start