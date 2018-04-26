module Exchanges
  module Coinbase
    extend ExchangeMethods
    extend self

    def configured?
      !!(settings["api_key"] && settings["api_secret"])
    end

    def client
      raise "Coinbase not configured in config/exchanges.yml" unless configured?
      require 'coinbase/wallet'
      @coinbase ||= ::Coinbase::Wallet::Client.new(api_key: settings["api_key"], api_secret: settings["api_secret"])
    end

    def exchange_rates
      @exchange_rates ||= client.exchange_rates["rates"]
    end

    def pairs
      @pairs ||= Config.market.pairs("gdax")
    end

    # [
    #   ["BTC", "ETH"],
    #   ["BTC", "LTC"],
    #
    #   ["USD", "BCH"],
    #   ["USD", "LTC"],
    #   ["USD", "ETH"],
    #   ["USD", "BTC"]
    # ]
    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def wallets
      return [] unless configured?
      large_balances adapt_wallets client.accounts
    end

    def adapt_wallets data
      return [] if data.nil?

      data.map do |w|
        balance = w["balance"]["amount"].to_f
        currency = w["currency"]
        available = balance
        pending = nil
        usd_balance = w["native_balance"]["amount"].to_f
        btc_balance = balance if currency == 'BTC'
        btc_balance ||= usd_balance / Config.btcusd_rate
        Wallet.new self, currency, balance, available, pending, usd_balance, btc_balance
      end
    end

  end
end
