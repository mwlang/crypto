module Exchanges
  module Kucoin
    extend self

    def exchange_name
      "kucoin"
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

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
    end

    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def large_balances all_wallets
      all_wallets.select{ |w| w.balance_usd >= (settings["small_balance"] || 0.0) }
    end

    def wallets
      return [] unless configured?
      result = client.balance
      return [] unless result["success"]
      large_balances adapt_wallets(result["data"])
    end

    {
      "coinType"=>"ONION",
      "balanceStr"=>"0.9548241",
      "freezeBalance"=>60.7872,
      "balance"=>0.9548241,
      "freezeBalanceStr"=>"60.7872"
    }
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
