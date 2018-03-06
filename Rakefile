require_relative 'lib/crypto'
require 'faraday'

task :environment do
  # NOP
end

def satoshi value
  "%12.12s" % ("%0.8f" % value) rescue ''
end

def market_usd_exchange_rate market
  return 1.0 unless Exchanges::Coinbase.exchange_rates.keys.include? market
  Exchanges::Coinbase.exchange_rates[market].to_f
end

def fmt_usd value
  "$%10.10s" % ("%0.2f" % value)
end

def usd market, value
  "$%10.10s" % ((1 / market_usd_exchange_rate(market)) * value)
end

def rjust value
  "%8.8s" % ("%0.2f" % value)
end

def current_price symbol
  target, base = symbol.split("-")
  pair = Exchanges::Bittrex.pair(base, target)
  ticker = Config.market.ticker(pair)
  ticker ? ticker.last : 1.0
end

desc "Shows open orders"
task :open_orders => [:environment] do
  t = Terminal::Table.new
  t << %w(Order Symbol Cost Quantity Remaining Ask Current USD Gap)
  t << :separator
  Exchanges::Bittrex.open_orders.sort_by{|sb| sb.exchange}.each do |h|
    market, symbol = h.exchange.split("-")
    ask = h.limit
    current = current_price(h.exchange)
    pc = ((ask - current) / ask) * 100
    t << [
      (h.type == "Limit_buy" ? "BUY" : "SELL"),
      (h.exchange =~ /^BTC/ ? h.exchange.split("-")[1] : h.exchange),
      usd(market, h.quantity * h.limit),
      rjust(h.quantity),
      rjust(h.remaining),
      satoshi(h.limit),
      satoshi(current_price(h.exchange)),
      usd(market, current_price(h.exchange)),
      "%0.2f%" % pc
    ]
  end
  puts t
end
task oo: :open_orders

desc "Shows closed order history"
task :closed_orders => [:environment] do
  t = Terminal::Table.new
  t << %w(Order Symbol Cost Quantity Remaining Limit Total Commission Executed)
  t << :separator
  Exchanges::Bittrex.order_histories.each do |h|
    market, symbol = h.exchange.split("-")
    t << [
      (h.type == "Limit_buy" ? "BUY" : "SELL"),
      (h.exchange =~ /^BTC/ ? h.exchange.split("-")[1] : h.exchange),
      usd(market, h.quantity * h.limit),
      rjust(h.quantity),
      rjust(h.remaining),
      satoshi(h.limit),
      satoshi(h.limit * h.quantity),
      satoshi(h.raw['Commission']),
      h.executed_at.strftime("%a %m/%d %H:%M %p")
    ]
  end
  puts t
end
task co: :closed_orders

desc "Shows withdrawals"
task :withdrawals => [:environment] do
  txs = Exchanges::Bittrex.withdrawals
  t = Terminal::Table.new
  t << %w(Currency Qty Auth Pending Canceled TxCost Date)
  t << :separator
  txs.sort_by{|sb| [sb.currency, sb.executed_at]}.each do |tx|
    t << [
      tx.currency,
      satoshi(tx.quantity),
      tx.authorized,
      tx.pending,
      tx.canceled,
      tx.transaction_cost,
      tx.executed_at.strftime("%a %m/%d %H:%M %p")
    ]
  end
  puts t
end
task wd: :withdrawals

desc "Shows deposits"
task :deposits => [:environment] do
  txs = Exchanges::Bittrex.deposits
  t = Terminal::Table.new
  t << %w(Currency Qty Confirms Date)
  t << :separator
  txs.sort_by{|sb| [sb.currency, sb.executed_at]}.each do |tx|
    t << [
      tx.currency,
      satoshi(tx.quantity),
      tx.confirmations,
      tx.executed_at.strftime("%a %m/%d %H:%M %p")
    ]
  end
  puts t
end
task d: :deposits

def wallet_table t, wallets
  return t, 0.0, 0.0 if wallets.all?{ |w| w.empty? }

  exchange_name = wallets.first.exchange_name.upcase
  t << [exchange_name] + %w(Quantity Available Pending USD BTC)
  t << :separator

  usd_total = 0.0
  btc_total = 0.0

  wallets.each do |w|
    next if w.balance_usd.zero?

    usd_total += w.balance_usd
    btc_total += w.balance_btc

    t << [
      w.symbol,
      satoshi(w.balance),
      satoshi(w.available),
      satoshi(w.pending),
      fmt_usd(w.balance_usd),
      satoshi(w.balance_btc),
    ]
  end

  t << :separator
  t << [
    nil,
    nil,
    exchange_name,
    'TOTAL',
    fmt_usd(usd_total),
    satoshi(btc_total),
  ]
  t << :separator

  return t, usd_total, btc_total
end

desc "Lists wallets with a balance"
task :wallets, [:exchange_name] => [:environment] do |t, args|
  ex = args[:exchange_name]

  btc_total = 0.0
  usd_total = 0.0

  t = Terminal::Table.new

  EXCHANGES.select{|s| ex.nil? || s.exchange_name == ex}.each do |exchange|
    t, usd_sub_total, btc_sub_total = wallet_table(t, exchange.wallets)
    btc_total += btc_sub_total
    usd_total += usd_sub_total
  end

  t << [
    nil,
    nil,
    "OVERALL",
    'TOTAL',
    fmt_usd(usd_total),
    satoshi(btc_total),
  ]
  puts t
end
task w: :wallets

desc "Retrieves current rates"
task :rates => [:environment] do
  t = Terminal::Table.new
  t << ["Exchange", "Rate"]
  t << :separator

  t << ["BTC/USD", fmt_usd(1 / Exchanges::Coinbase.exchange_rates["BTC"].to_f)]
  t << ["ETH/USD", fmt_usd(1 / Exchanges::Coinbase.exchange_rates["ETH"].to_f)]
  t << ["LTC/USD", fmt_usd(1 / Exchanges::Coinbase.exchange_rates["LTC"].to_f)]
  t << ["BCH/USD", fmt_usd(1 / Exchanges::Coinbase.exchange_rates["BCH"].to_f)]
  puts t
end
task r: :rates

desc "Given Bitcoin amount, returns USD"
task :btcusd, [:btc] => [:environment] do |t, args|
  if btc = args[:btc].to_f
    puts "BTC:      #{satoshi(btc)}"
    puts "USD: #{usd('BTC', btc)}"
  else
    puts "BTC amount not supplied!"
  end
end

desc "Given USD amount, returns BTC"
task :usdbtc, [:usd] => [:environment] do |t, args|
  if usd = args[:usd].to_f
    amount = btc(usd)
    puts "BTC:      #{satoshi(amount)}"
    puts "USD: #{usd('USD', usd)}"
  else
    puts "USD amount not supplied!"
  end
end

desc "runs full stack orders, wallets, etc."
task :run => [:environment, :closed_orders, :open_orders, :wallets, :rates]

task default: :run

task :t => [:environment] do
  p Exchanges::Kucoin.wallets
end
