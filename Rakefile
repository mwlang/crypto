require 'yaml'
require 'bittrex'
require 'terminal-table'
require 'coinbase/wallet'
require 'coinbase/exchange'

def log(msg)
  indent = (msg =~ /\.\.\.|\!/ ? 0 : 1)
  puts "#{'    ' * indent}#{msg}"
end

def config_filename
  File.join(task_root_path, 'config', 'exchanges.yml')
end

def config
  @config ||= YAML.load_file(config_filename)
end

def coinbase
  @coinbase ||= Coinbase::Wallet::Client.new(api_key: config["coinbase"]["api_key"], api_secret: config["coinbase"]["api_secret"])
end

def gdax
  @gdax ||= Coinbase::Exchange::Client.new(config["gdax"]["api_key"], config["gdax"]["api_secret"], config["gdax"]["api_passphrase"])
end

def load_configurations
  unless File.exist?(config_filename) && (config)
    abort "The exchanges.yml file is missing or incorrect!"
  end
  Bittrex.config do |c|
    c.key = config["bittrex"]["api_key"]
    c.secret = config["bittrex"]["api_secret"]
  end
end

def task_root_path
  File.dirname(__FILE__)
end

def scripts_path
  File.join(task_root_path, 'scripts')
end

def log_path
  File.join(task_root_path, 'log')
end

task :environment do
  load_configurations
end

def satoshi value
  "%12.12s" % ("%0.8f" % value) rescue ''
end

def market_usd_exchange_rate market
  @exchange_rates ||= coinbase.exchange_rates
  return 1.0 unless @exchange_rates["rates"].keys.include? market
  @exchange_rates["rates"][market].to_f
end

def usd market, value
  "$%10.10s" % ("%0.2f" % ((1 / market_usd_exchange_rate(market)) * value))
end

def btc usd
  usd * coinbase.exchange_rates["rates"]["BTC"].to_f
end

def rjust value
  "%8.8s" % ("%0.2f" % value)
end

def current_price symbol
  quote = Bittrex::Quote.current(symbol)
  quote.last
end

def to_usd symbol, value
  rate = symbol == "BTC" ? coinbase.exchange_rates["rates"]["USD"].to_f : current_price("BTC-#{symbol}")
  usd "BTC", rate * value
end

def to_btc symbol, value
  rate = symbol == "BTC" ? value : current_price("BTC-#{symbol}")
  rate * value
end

desc "Shows open orders"
task :open_orders => [:environment] do
  orders = Bittrex::Order.open
  t = Terminal::Table.new
  t << %w(Order Symbol Cost Quantity Remaining Ask Current USD Gap)
  t << :separator
  orders.sort_by{|sb| sb.exchange}.each do |h|
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
  histories = Bittrex::Order.history
  t = Terminal::Table.new
  t << %w(Order Symbol Cost Quantity Remaining Limit Total Commission Executed)
  t << :separator
  histories.each do |h|
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
  txs = Bittrex::Withdrawal.all
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
  txs = Bittrex::Deposit.all
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

desc "Lists wallets with a balance"
task :wallets => [:environment] do
  wallets = Bittrex::Wallet.all
  t = Terminal::Table.new
  t << %w(Symbol Quantity Available Pending USD BTC)
  t << :separator
  wallets.sort_by{|sb| sb.currency}.each do |w|
    next if w.balance.zero?
    t << [
      w.currency,
      satoshi(w.balance),
      satoshi(w.available),
      satoshi(w.pending),
      to_usd(w.currency, w.balance),
      satoshi(to_btc(w.currency, w.balance)),
    ]
  end
  puts t
end
task w: :wallets

desc "Retrieves current rates"
task :rates => [:environment] do
  t = Terminal::Table.new
  t << ["Exchange", "Rate"]
  t << :separator

  t << ["BTC/USD", "$%8.8s" % ("%0.2f" % (1 / coinbase.exchange_rates["rates"]["BTC"].to_f))]
  t << ["ETH/USD", "$%8.8s" % ("%0.2f" % (1 / coinbase.exchange_rates["rates"]["ETH"].to_f))]
  t << ["LTC/USD", "$%8.8s" % ("%0.2f" % (1 / coinbase.exchange_rates["rates"]["LTC"].to_f))]
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

task :lt => [:environment] do
  gdax.accounts do |resp|
    resp.each do |account|
      p "#{account.id}: %.2f #{account.currency} available for trading" % account.available
    end
  end
end

desc "runs full stack orders, wallets, etc."
task :run => [:environment, :closed_orders, :open_orders, :wallets, :rates]

task default: :run
