module Exchanges
  module Cryptoid
    extend ExchangeMethods
    extend self

    def configured?
      !!settings["addresses"]
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    rescue NameError
      []
    end

    def btc_pair symbol
      ticker symbol
    end

    def addresses
      settings["addresses"]
    end

    def fetch_balance coin, address
      response = Faraday.get("https://chainz.cryptoid.info/#{coin}/api.dws?q=getbalance&a=#{address}")
      response = Faraday.get(response.headers["location"]) if response.status == 302
      response.status == 200 ? response.body.to_f : 0.0
    end

    def get_address_balances
      balances = {}
      addresses.each do |coin, address|
        balances[coin] = fetch_balance coin, address
      end
      return balances
    end

    def wallets
      return [] unless configured?
      large_balances adapt_wallets(get_address_balances)
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |coin, balance|
        available = balance
        pending = 0.0
        balance = available + pending
        Wallet.new self, coin.upcase, balance, available, pending
      end
    end

  end
end
