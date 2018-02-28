module Exchanges
  module Gdax
    extend self

    def exchange_name
      "gdax"
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

    def configured?
      !!(settings["api_key"] && settings["api_secret"] && settings["api_passphrase"])
    end

    def client
      raise "GDAX not configured in config/exchanges.yml" unless configured?
      require 'coinbase/exchange'
      @gdax ||= ::Coinbase::Exchange::Client.new(settings["api_key"], settings["api_secret"], settings["api_passphrase"])
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    end

    def usd_pair symbol
      pairs.detect{ |p| p.target == "USD" && p.base == symbol }
    end

    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def wallets
      return [] unless configured?
      adapt_wallets client.accounts
    end

    def adapt_wallets data
      return [] if data.nil?

      data.map do |a|
        currency = a.currency
        balance = a.balance.to_f
        available = a.available.to_f
        pending = a.hold.to_f
        Wallet.new self, currency, balance, available, pending
      end
    end
  end
end
