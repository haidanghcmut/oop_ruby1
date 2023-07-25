
class Abstract
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

    def check_keyword_withdraw(keyword)
        if keyword == 'q'
            return show_menu
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid amount.'
            exit
        else
            keyword = keyword.to_i
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
            return show_menu
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid amount.'
            exit
        end
    end

    def check_transfer_keyword(keyword)
        if keyword.to_s === 'q'
             show_menu
        elsif keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Invalid account number.'
            exit
        elsif keyword.to_i == @current_account.card_number
            puts 'You cannot transfer to your own account.'
            return transfer
        end
    end

    def check_transfer_amount_keyword(keyword)
        if keyword.to_i > @current_account.balance || keyword.to_i < 0 || /^[a-zA-Z[:punct:]]+$/.match(keyword)
            puts 'Insufficient funds.'
            exit
        else
            @current_account.balance -= keyword.to_i
            recipient_account.balance += keyword.to_i
            save_accounts_to_csv
            puts "Your new balance is $#{@current_account.balance}"
            return transfer
        end
    end

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
