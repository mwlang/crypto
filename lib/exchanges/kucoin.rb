module Exchanges
  module Kucoin
    extend ExchangeMethods
    extend self

    def configured?
      !!(settings["api_key"] && settings["api_secret"])
    end

    def client
      raise "Kucoin not configured in config/exchanges.yml" unless configured?
      require 'kucoin/api'
      ::Kucoin::Api::REST.new(
        api_key: settings["api_key"], 
        api_secret: settings["api_secret"], 
        api_passphrase: settings["api_passphrase"]
      )
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    rescue NameError
      []
    end

    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def wallets
      return [] unless configured?
      result = client.user.accounts.list
      large_balances adapt_wallets(result)
    end

    # {
    #   "balance"=>"0.05524851", 
    #   "available"=>"0.05524851", 
    #   "holds"=>"0", 
    #   "currency"=>"BTC", 
    #   "id"=>"5c6a4fc299a1d81b25d4f18f", 
    #   "type"=>"trade"
    # }
    def adapt_wallets data
      return [] if data.nil?
      data.map do |w|
        balance = w["balance"].to_f
        available = w["available"].to_f
        pending = balance - available
        Wallet.new self, w["currency"], balance, available, pending
      end
    end

  end
end
