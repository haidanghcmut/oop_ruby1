require "csv"

# class User
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
    # Initialize
    def initialize
       @accounts = load_accounts_from_csv
       @current_account = []
    end
     
    # Start
    def start
        puts '=== ATM ==='
        login
        show_menu
        process_menu_choice until @current_account.nil?
        puts 'Thank you for using the ATM. Goodbye!'
    end

    # Login
    def login
        puts 'Please enter your card number:'
        card_number_enter = gets.chomp
        puts 'Please enter your password:'
        password_enter = gets.chomp
        @accounts.each do |account|
            if account.card_number == card_number_enter.to_i && account.password == password_enter.to_i
                @current_account = account
                break
            else
                @current_account = nil
            end
        end

        if @current_account.nil? 
            puts 'Invalid card number or password. Please try again.'
            login
        else
            puts "Login successful!"
            puts "Welcome, #{@current_account.owner}!"
            puts "Your balance: $#{@current_account.balance}"
            puts @current_account.owner
        end
    end

#    Menu
    def show_menu
        puts '=== Menu ==='
        puts '1. Withdraw'
        puts '2. Check Balance'
        puts '3. Deposit'
        puts '4. Transfer'
        puts '5. Exit'
    end

    # Process menu choice
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

    # Withdraw money
    def withdraw
        puts 'How much would you like to withdraw (press q to exit)?'
        amount = gets.chomp
        if amount == 'q'
            return show_menu
        elsif amount.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(amount)
            puts 'Invalid amount.'
            return withdraw
        else
            amount = amount.to_i
        end

        if amount > @current_account.balance
            puts 'Insufficient funds.'
            puts 'Are you want to withdraw again? (y/n)'
            choice = gets.chomp.downcase
            if choice == 'y'
                withdraw
            elsif choice == 'n'
                show_menu
            end
        else
            @current_account.balance -= amount
            save_accounts_to_csv
            puts "Your new balance is $#{@current_account.balance}"
            puts 'Would you like to make another withdrawal? (y/n)'
            check_choice1
        end
    end

    # Check choice
    def check_choice1
        choice = gets.chomp.downcase
            if choice == 'y'
                withdraw
            elsif choice == 'n'
                show_menu
            else
                puts 'Invalid choice. Please try again.'
                check_choice1
            end
    end

    # Check balance
    def check_balance
        puts "Your balance is $#{@current_account.balance}"
        puts 'Would you like to make another transaction? (y/n)'
        choice = gets.chomp.downcase
        if choice == 'y'
            puts '=== Menu ==='
            puts '1. Withdraw'
            puts '2. Deposit'
            puts '3. Transfer'
            case gets.chomp.to_i
            when 1
                withdraw
            when 2
                deposit
            when 3
                transfer
            end
        else
            puts 'Are you sure you want to exit? (y/n)'
            choice = gets.chomp.downcase
            if choice == 'y'
                log_out
            else
                show_menu
            end
        end
    end


    # Deposit money
    def deposit
        puts 'How much would you like to deposit (press q to exit)?'
        amount = gets.chomp
        if amount == 'q'
            return show_menu
        elsif amount.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(amount)
            puts 'Invalid amount.'
            return deposit
        end
        @current_account.balance += amount.to_i
        save_accounts_to_csv
        puts "Your new balance is $#{@current_account.balance}"
        puts 'Would you like to make another deposit? (y/n)'
        check_choice2
    end

    # Check choice2
    def check_choice2
        choice = gets.chomp.downcase
        if choice == 'y'
            deposit
        elsif choice == 'n'
            show_menu
        else 
            puts 'Invalid choice. Please try again.'
            check_choice2
        end
    end


    # Transfer money
    def transfer
        puts 'Enter the account number to transfer to (press q to exit): '
        account_number = gets.chomp
        if account_number == 'q'
            return show_menu
        elsif account_number.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(account_number)
            puts 'Invalid account number.'
            return transfer
        end
        recipient_account = @accounts.find { |account| account.card_number == account_number.to_i }
        if recipient_account.nil?
            puts 'Invalid account number.'
            return transfer
        else 
            puts 'Enter the money to transfer:'
            amount = gets.chomp
            if amount.to_i > @current_account.balance || amount.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(amount)
                puts 'Insufficient funds.'
                return transfer
            else
                @current_account.balance -= amount.to_i
                recipient_account.balance += amount.to_i
                save_accounts_to_csv
                puts "Your new balance is $#{@current_account.balance}"
                return transfer
            end
        end
    end


    # log out
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