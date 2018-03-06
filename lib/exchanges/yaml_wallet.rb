module Exchanges
  class YamlWallet
    attr_reader :exchange_name

    def initialize exchange_name
      @exchange_name = exchange_name
    end

    def settings
      Config.settings.fetch(exchange_name, {})
    end

    def configured?
      !!settings["coins"]
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
      pairs.detect{ |p| p.target == "BTC" && p.base == symbol.upcase } || ticker(symbol)
    end

    def wallets
      return [] unless configured?
      adapt_wallets data
    end

    def data
      settings["coins"]
    end

    def adapt_wallets data
      wallets = []
      data.each do |w|
        symbol = w[0].upcase
        balance, available = w[1].to_f
        pending = nil
        wallets << Wallet.new(self, symbol, balance, balance, nil)
      end
      return wallets
    end

  end
end
