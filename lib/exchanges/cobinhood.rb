module Exchanges
  module Cobinhood
    extend ExchangeMethods
    extend self

    def configured?
      !!settings["api_key"]
    end

    def client
      raise "Cobinhood not configured in config/exchanges.yml" unless configured?
      require 'cobinhood'
      ::Cobinhood::Client::REST.new api_key: settings["api_key"]
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
      result = client.balances
      return [] unless result["success"]
      large_balances adapt_wallets(result["result"]["balances"])
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |w|
        symbol = w["currency"]

        balance = w["total"].to_f
        pending = w["on_order"].to_f
        available = balance - pending

        bal_usd = w["usd_value"].to_f
        bal_btc = w["btc_value"].to_f
        Wallet.new(self, symbol, balance, available, pending, bal_usd, bal_btc)
      end
    end

  end
end
