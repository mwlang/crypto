module Exchanges
  module Cryptoid
    extend self

    def exchange_name
      "cryptoid"
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

    def configured?
      !!settings["addresses"]
    end

    def configured?
      !!settings["addresses"]
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    rescue NameError
      []
    end

    def ticker symbol
      %w{bittrex binance gdax kucoin cryptopia}.each do |exch|
        market = Cryptoexchange::Models::MarketPair.new market: exch, base: symbol.upcase, target: 'BTC'
        begin
          Cryptoexchange::Client.new.ticker(market)
          return market
        rescue NoMethodError
          # NOP
        end
      end
    end

    def btc_pair symbol
      ticker symbol
    end

    def large_balances all_wallets
      all_wallets.select{ |w| w.balance_usd >= (settings["small_balance"] || 0.0) }
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
