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
