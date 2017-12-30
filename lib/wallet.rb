class Wallet
  attr_reader :exchange, :symbol, :balance, :available, :pending

  def initialize exchange, symbol, balance, available, pending, bal_usd = nil, bal_btc = nil
    @exchange = exchange
    @symbol = symbol
    @balance = balance
    @available = available
    @pending = pending
    @pending = nil if @pending.to_f.zero?
    @balance_usd = bal_usd unless bal_usd.nil?
    @balance_btc = bal_btc unless bal_btc.nil?
  end

  def exchange_name
    exchange.exchange_name
  end

  def empty?
    balance.round(2).zero?
  end

  def usd_rate
    return 1.0 if symbol == "USD"
    Config.btcusd_rate
  end

  def balance_usd
    return 0.0 if balance.zero?
    return @balance_usd if @balance_usd
    @balance_usd ||= usd_rate * balance_btc
  end

  def btc_rate
    return 1.0 if symbol == "BTC"
    return 0.0 unless pair = exchange.btc_pair(symbol)
    return 0.0 unless ticker = Config.market.ticker(pair)
    ticker.last
  end

  def balance_btc
    return 0.0 if balance.zero?
    return @balance_btc if @balance_btc
    @balance_btc ||= btc_rate * balance
  end
end
