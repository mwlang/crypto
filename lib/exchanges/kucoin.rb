module Exchanges
  module Kucoin
    extend ExchangeMethods
    extend self

    def configured?
      !!(settings["api_key"] && settings["api_secret"])
    end

    def client
      raise "Kucoin not configured in config/exchanges.yml" unless configured?
      require 'kucoin_ruby'
      KucoinRuby::Net.config({api_key: settings["api_key"], api_secret: settings["api_secret"]})
      KucoinRuby::Operations
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
      result = client.balance
      return [] unless result["success"]
      large_balances adapt_wallets(result["data"])
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |w|
        available = w["balance"].to_f
        pending = w["freezeBalance"].to_f
        balance = available + pending
        Wallet.new self, w["coinType"], balance, available, pending
      end
    end

  end
end
