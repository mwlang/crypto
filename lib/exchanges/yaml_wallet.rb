module Exchanges
  class YamlWallet
    include ExchangeMethods
    attr_reader :exchange_name

    def initialize exchange_name
      @exchange_name = exchange_name
    end

    def configured?
      !!settings["coins"]
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
