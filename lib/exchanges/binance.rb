module Exchanges
  module Binance
    extend self

    def exchange_name
      "binance"
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

    def configured?
      !!(settings["api_key"] && settings["api_secret"])
    end

    def client
      raise "Binance not configured in config/exchanges.yml" unless configured?
      require 'binance'
      @binance ||= ::Binance::Client::REST.new(api_key: settings["api_key"], secret_key: settings["api_secret"])
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    end

    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def large_balances all_wallets
      all_wallets.select{ |w| w.balance_usd >= (settings["small_balance"] || SMALL_BALANCE_THRESHOLD) }
    end

    def wallets
      return [] unless configured?
      large_balances(adapt_wallets client.account_info["balances"])
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |w|
        available = w["free"].to_f
        pending = w["locked"].to_f
        balance = available + pending
        Wallet.new self, w["asset"], balance, available, pending
      end
    end

  end
end
