
module AbstractAtmCore  

    def initialize
        @accounts = load_accounts_from_csv
        @current_account = []
     end
    # Kiểm tra tài khoản tồn tại hay không 
    def check_account(card_number_press, password_enter_press)
        @accounts.each do |account|
            if account.card_number == card_number_press.to_i && account.password == password_enter_press.to_i
                @current_account = account
                break
            else
                @current_account = nil
            end 
          end
    end

    # Hiển thị kết quả đăng nhập
    def display_result
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

    # Kiểm tra ký tự hợp lệ khi rút tiền
    def check_keyword_withdraw(keyword)
        if keyword == 'q'
            return false
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid amount.'
            return false
        else
            keyword = keyword.to_i
        end
    end

    # Kiểm tra số tiền hợp lệ để rút
    def check_amount_withdraw(keyword)
        if keyword.to_i > @current_account.balance
            puts 'Insufficient funds.'
            return withdraw
        else
            @current_account.balance -= keyword.to_i
            save_accounts_to_csv
            puts "Thank you! Here's your money: $#{keyword.to_i}"
            puts "Your new balance is $#{@current_account.balance}"
            show_menu
        end
    end

    # Hiển thị menu
    def show_menu
        puts '=== Menu ==='
        puts '1. Withdraw'
        puts '2. Check Balance'
        puts '3. Deposit'
        puts '4. Transfer'
        puts '5. Exit'
    end

    # Kiểm tra ký tư hợp lệ khi kiểm tra số dư
    def check_balance_keyword(keyword)
        if keyword == 'y'
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
            keyword = gets.chomp.downcase
            if keyword == 'y'
                log_out
            else
                show_menu
            end
        end
    end

    def choice(keyword)
        case keyword
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
    
    def log_out
        @current_account = nil
    end

    def check_deposit_keyword(keyword)
        if keyword == 'q'
            puts 'Exiting deposit...'
            return false
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid amount.'
            return false
        end
    end

#    Kiểm tra ký tự hợp lệ khi chuyển tiền
    def check_transfer_keyword(keyword)
        if keyword.to_s === 'q'
             puts 'Exiting transfer...'
             return false
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid account number.'
            return false
        elsif keyword.to_i == @current_account.card_number
            puts 'You cannot transfer to your own account.'
            return false
        end
    end

    # kiểm tra hợp lệ khi chuyển tiền
    def check_transfer_account_number(keyword)
        recipient_account = @accounts.find { |account| account.card_number == keyword.to_i }
        load_accounts_from_csv
        if recipient_account.nil?
            puts 'Invalid account number.'
            return show_menu
        else 
            puts 'Enter the money to transfer:'
            amount = gets.chomp
            if amount.to_i > @current_account.balance || amount.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(amount)
                puts 'Insufficient funds.'
                return show_menu
            else
                @current_account.balance -= amount.to_i
                recipient_account.balance += amount.to_i
                save_accounts_to_csv
                puts "Your new balance is $#{@current_account.balance}"
                return transfer
            end
        end
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

#    Lưu dữ liệu vào file CSV
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
