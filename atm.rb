require "csv"
require './user_atm.rb'
require './abstract_atm_core.rb'


class ATM < User
    # Khởi tạo chương trình

   include AbstractAtmCore
     
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
       if check_keyword_withdraw(amount) == false
          return show_menu
       else
          check_amount_withdraw(amount)
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
        if check_deposit_keyword(amount) == false
            return show_menu
        else 
            @current_account.balance += amount.to_i
            save_accounts_to_csv
            puts "Thank you! Your money has been deposited."
            puts "Your new balance is $#{@current_account.balance}"
            show_menu
        end
    end

    # Chuyển tiền cho người khác
    def transfer
        puts 'Enter the account number to transfer to (press q to exit): '
        account_number = gets.chomp
        if check_transfer_keyword(account_number) == false
            return show_menu
        else
            check_transfer_account_number(account_number)
        end
    end
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
