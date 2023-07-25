require "csv"
require './user.rb'
require './abstract.rb'


class ATM < Abstract
    # Khởi tạo chương trình
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
        check_account(card_number_enter, password_enter)
        display_result
    end
  

    # Xử lý lựa chọn của người dùng
    def process_menu_choice
        choice = gets.chomp.to_i
        choice(choice)
    end

    

    # Rút tiền
    def withdraw
        puts 'How much would you like to withdraw (press q to exit)?'
        amount = gets.chomp
        check_keyword_withdraw(amount)
        if amount.to_i > @current_account.balance
            puts 'Insufficient funds.'
            return withdraw
        else
            @current_account.balance -= amount.to_i
            save_accounts_to_csv
            puts "Thank you! Here's your money: $#{amount.to_i}"
            puts "Your new balance is $#{@current_account.balance}"
            show_menu
        end
    end

   

    # Kiểm tra số dư
    def check_balance
        puts "Your balance is $#{@current_account.balance}"
        puts 'Would you like to make another transaction? (y/n)'
        choice = gets.chomp.downcase
        check_balance_keyword(choice)
    end

    # Nạp tiền vào tài khoản
    def deposit
        puts 'How much would you like to deposit (press q to exit)?'
        amount = gets.chomp
        check_deposit_keyword(amount)
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
        check_transfer_keyword(account_number)
        recipient_account = @accounts.find { |account| account.card_number == account_number.to_i }
        if recipient_account.nil?
            puts 'Invalid account number.'
            return transfer
        else 
            puts 'Enter the money to transfer:'
            amount = gets.chomp
            check_transfer_amount_keyword(amount)
        end
    end

    # Tải dữ liệu từ file CSV
    

    # lưu dữ liệu vào file CSV
    
end

# Khởi động chương trình
class Start < ATM
  atm = ATM.new
  if atm.load_accounts_from_csv == []
    puts "Invalid data. Please try again."
  else
    atm.start
  end
end