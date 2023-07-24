require "csv"
require './user.rb'



class ATM
    # Khởi tao chương trình
    def initialize
       @accounts = load_accounts_from_csv
       @current_account = []
    end
     
    # Bắt đầu chương trình
    def start
        puts '=== ATM ==='
        login
        show_menu
        process_menu_choice until @current_account.nil?
        puts 'Thank you for using the ATM. Goodbye!'
    end

    # Đăng nhập vào hệ thống
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

     # Menu hiển thị khi đăng nhập thành công
    def show_menu
        puts '=== Menu ==='
        puts '1. Withdraw'
        puts '2. Check Balance'
        puts '3. Deposit'
        puts '4. Transfer'
        puts '5. Exit'
    end

    # Xử lý lựa chọn của người dùng
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

    # Rút tiền
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
            check_choice1
        else
            @current_account.balance -= amount
            save_accounts_to_csv
            puts "Thank you! Here's your money: $#{amount}"
            puts "Your new balance is $#{@current_account.balance}"
            show_menu
        end
    end

    # Kiểm tra số dư
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
            puts 'Are you sure want to exit? (y/n)'
            choice = gets.chomp.downcase
            if choice == 'y'
                log_out
            else
                show_menu
            end
        end
    end

    # Nạp tiền vào tài khoản
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
        puts "Thank you! Your money has been deposited."
        puts "Your new balance is $#{@current_account.balance}"
        show_menu
    end

    # Chuyển tiền cho người khác
    def transfer
        puts 'Enter the account number to transfer to (press q to exit): '
        account_number = gets.chomp
        if account_number == 'q'
            return show_menu
        elsif account_number.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(account_number)
            puts 'Invalid account number.'
            return transfer
        elsif account_number.to_i == @current_account.card_number
            puts 'You cannot transfer to your own account.'
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

    # Thoát khỏi chương trình
    def log_out
        @current_account = nil
    end

    # Tải dữ liệu từ file CSV
    def load_accounts_from_csv
        load_account = []
        if (File.file?('./accounts.csv') && !File.zero?('./accounts.csv'))
                CSV.foreach('./accounts.csv', headers: true, col_sep: ";") do |row|
                    owner = row["owner"]
                    balance = row["balance"].to_i
                    card_number = row["card_number"].to_i
                    password = row["password"].to_i
                    load_account << User.new(owner, balance, card_number, password)
                end
          return load_account
        elsif File.zero?('./accounts.csv') || !File.file?('./accounts.csv')
            File.new("./accounts.csv", 'w')   
        end
    end

    # lưu dữ liệu vào file CSV
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

# Khởi động chương trình
  atm = ATM.new
  if File.zero?('./accounts.csv') || !File.file?('./accounts.csv')
    puts "Invalid data. Please try again."
  else
    atm.start
  end