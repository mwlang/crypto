module Exchanges
  module Bittrex
    extend self

    def exchange_name
      "bittrex"
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

    def configured?
      !!(settings["api_key"] && settings["api_secret"])
    end

    def configure!
      raise "Bittrex not configured in config/exchanges.yml" unless configured?
      require 'bittrex'
      ::Bittrex.config do |c|
        c.key = settings["api_key"]
        c.secret = settings["api_secret"]
      end
    end

    def order_histories
      configure!
      ::Bittrex::Order.history
    end

    def open_orders
      configure!
      ::Bittrex::Order.open
    end

    def withdrawals
      configure!
      ::Bittrex::Withdrawal.all
    end

    def deposits
      configure!
      ::Bittrex::Deposit.all
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    end

    def btc_pair symbol
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol }
    end

    def pair base, target
      pairs.detect{ |p| p.target == target && p.base == base }
    end

    def wallets
      return [] unless configured?
      configure!
      adapt_wallets ::Bittrex::Wallet.all.sort_by{|sb| sb.currency}
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |w|
        Wallet.new self, w.currency, w.balance, w.available, w.pending
      end
    end

  end
end
