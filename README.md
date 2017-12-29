This little Crypto Tool is for command-line (presently).  It allows you to quickly take a peek at your wallet and orders (open and close).

I got tired of always keying 2FA to login and check things out as well as doing the Math to determine USD value of balances.

Since I also like to place SELL orders with a LIMIT, I like to know how far away an order is from potentially filling.

That's the start of this little tool, which I expect will grow in features over time.

Presently, this tool is wired only to Bittrex and Coinbase for most commands.  You must have both configured to
use this tool without errors.

NOTE: Recently added: Balances now supported for Coinbase, GDAX, Bittrex, and Binance.

CAUTION:  THERE MAY BE BUGS!  Report bugs in the issue tracker or send me a PR with the bug already fixed!

## To Install

To install this tool, clone the repository from github:

~~~
git clone git@github.com:mwlang/crypto.git
~~~

Change to the crypto folder and install necessary gems (the Ruby language is required and assumed already installed!)

~~~
cd crypto
bundle install
~~~
NOTE:  The "bittrex API ruby gem" has bugs.  I've forked and fixed those bugs and submitted PR.

Set your API keys for Bittrex and Coinbase (the only supported exchanges at the moment) by changing to crypto folder and copy config/exchanges.yml.example to config/exchanges.yml and add your API key and API Secret to the file.  You'll need both to successfully use this tool to see BTC and USD.  Errors will likely occur without the file and keys in place.

~~~YAML
bittrex:
  api_key: d1d433126b129f2805218888888
  api_secret: 123448146894902804664fd88888888
coinbase:
  api_key: CdQbcdePEmm6HfWa
  api_secret: cmkWiSwAjDqaPix58ASBCDPFEEPiM6AmL
gdax:
  api_passphrase: 3naiz23vq7fb
  api_key: 2930a03cd65a14d3bea7d5beb55922b
  api_secret: +sBHp944s18bufRlSRFTiktIqwkVfvUvcevRbzHktXf0UPfIT3hLMQESuwouFaMFZO70+JOw==
binance:
  api_key: V8ldzlNLA5G0tlGYarRdU2sDjRnLjbF1QpIHgL62MjD7mOH12
  api_secret: gkFkZ4Zpt8XJocxL8MP1qulLVK5hgDZ4a9m1yAs5RROIbFKynk8YA
~~~

NOTE:  You must have at least bittrex and coinbase configured to avoid errors.  Accepting PR's to remove this limitation!

## Usage

To see all commands available:

~~~
>> rake -T
rake closed_orders # Shows closed order history
rake open_orders   # Shows open orders
rake rates         # Retrieves current rates
rake run           # runs full stack orders, wallets, etc
rake wallets       # Lists wallets with a balance
~~~

### Aliases

Several commands have short aliases for them:

* oo => open_orders
* co => closed_orders
* r => rates
* w => wallets

~~~
>> rake w
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| Exchange | Symbol | Quantity     | Available    | Pending      | USD         | BTC          |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| coinbase | BCH    |   0.21900365 |              |              | $     563.2 |   0.03773433 |
| coinbase | ETH    |   0.25346310 |              |              | $    188.32 |   0.01261739 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| coinbase |        |              |              | TOTAL        | $    751.52 |   0.05035172 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| bittrex  | BTC    |   0.00000018 |   0.00000018 |   0.00000000 | $       0.0 |   0.00000000 |
| bittrex  | BTG    |   0.00084696 |   0.00084696 |   0.00000000 | $      0.22 |   0.00001465 |
| bittrex  | RCN    | 1250.0000000 | 1250.0000000 |   0.00000000 | $    534.14 |   0.03578750 |
| bittrex  | VOX    | 672.74221614 |   0.00000000 |   0.00000000 | $    499.03 |   0.03343529 |
| bittrex  | XRP    |  44.18959189 |  44.18959189 |   0.00000000 | $      61.0 |   0.00408710 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| bittrex  |        |              |              | TOTAL        | $   1094.39 |   0.07332454 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| binance  | BTC    |   0.00000204 |   0.00000204 |   0.00000000 | $      0.03 |   0.00000000 |
| binance  | GAS    |   0.00590000 |   0.00590000 |   0.00000000 | $      0.17 |   0.00001133 |
| binance  | BCC    |   0.00079616 |   0.00079616 |   0.00000000 | $      2.04 |   0.00013640 |
| binance  | OMG    |   0.00964320 |   0.00964320 |   0.00000000 | $      0.15 |   0.00001004 |
| binance  | XVG    |   0.74900000 |   0.74900000 |   0.00000000 | $      0.13 |   0.00000843 |
| binance  | ZEC    |   0.00007450 |   0.00007450 |   0.00000000 | $      0.04 |   0.00000247 |
| binance  | SBTC   |   0.00395635 |   0.00395635 |   0.00000000 | $       0.0 |   0.00000000 |
| binance  | BCX    |  39.56350000 |  39.56350000 |   0.00000000 | $       0.0 |   0.00000000 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| binance  |        |              |              | TOTAL        | $      2.56 |   0.00016867 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| OVERALL  |        |              |              | TOTAL        | $   1848.47 |   0.12384493 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
~~~

To see Coinbase rates:
~~~
>> rake rates
+----------+-----------+
| Exchange | Rate      |
+----------+-----------+
| BTC/USD  | $ 4291.85 |
| ETH/USD  | $  290.99 |
| LTC/USD  | $   52.04 |
+----------+-----------+
~~~

See the balance on every non-zero balance wallet.
~~~
>> rake wallets
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| Exchange | Symbol | Quantity     | Available    | Pending      | USD         | BTC          |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| coinbase | BCH    |   0.21900365 |              |              | $     563.2 |   0.03773433 |
| coinbase | ETH    |   0.25346310 |              |              | $    188.32 |   0.01261739 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| coinbase |        |              |              | TOTAL        | $    751.52 |   0.05035172 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| bittrex  | BTC    |   0.00000018 |   0.00000018 |   0.00000000 | $       0.0 |   0.00000000 |
| bittrex  | BTG    |   0.00084696 |   0.00084696 |   0.00000000 | $      0.22 |   0.00001465 |
| bittrex  | RCN    | 1250.0000000 | 1250.0000000 |   0.00000000 | $    534.14 |   0.03578750 |
| bittrex  | VOX    | 672.74221614 |   0.00000000 |   0.00000000 | $    499.03 |   0.03343529 |
| bittrex  | XRP    |  44.18959189 |  44.18959189 |   0.00000000 | $      61.0 |   0.00408710 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| bittrex  |        |              |              | TOTAL        | $   1094.39 |   0.07332454 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| binance  | BTC    |   0.00000204 |   0.00000204 |   0.00000000 | $      0.03 |   0.00000000 |
| binance  | GAS    |   0.00590000 |   0.00590000 |   0.00000000 | $      0.17 |   0.00001133 |
| binance  | BCC    |   0.00079616 |   0.00079616 |   0.00000000 | $      2.04 |   0.00013640 |
| binance  | OMG    |   0.00964320 |   0.00964320 |   0.00000000 | $      0.15 |   0.00001004 |
| binance  | XVG    |   0.74900000 |   0.74900000 |   0.00000000 | $      0.13 |   0.00000843 |
| binance  | ZEC    |   0.00007450 |   0.00007450 |   0.00000000 | $      0.04 |   0.00000247 |
| binance  | SBTC   |   0.00395635 |   0.00395635 |   0.00000000 | $       0.0 |   0.00000000 |
| binance  | BCX    |  39.56350000 |  39.56350000 |   0.00000000 | $       0.0 |   0.00000000 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| binance  |        |              |              | TOTAL        | $      2.56 |   0.00016867 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
| OVERALL  |        |              |              | TOTAL        | $   1848.47 |   0.12384493 |
+----------+--------+--------------+--------------+--------------+-------------+--------------+
~~~

See the orders that are currently open.

The difference between Ask and Current is expressed as a percentage in the Gap column so you can see how close you are to a SELL order potentially filling.

~~~
>> rake open_orders
+-------+--------+-------------+----------+-----------+--------------+--------------+--------+
| Order | Symbol | Cost        | Quantity | Remaining | Ask          | Current      | Gap    |
+-------+--------+-------------+----------+-----------+--------------+--------------+--------+
| SELL  | OMG    | $   3710.11 |   227.23 |   227.23  |   0.00380425 |   0.00208500 | 45.19% |
| SELL  | MTL    | $    331.86 |    31.44 |    31.44  |   0.00245900 |   0.00189600 | 22.90% |
| SELL  | XRP    | $   1184.55 |  5000.00 |  5000.00  |   0.00005520 |   0.00004714 | 14.60% |
| SELL  | PAY    | $   2098.09 |   388.12 |   388.12  |   0.00125956 |   0.00053079 | 57.86% |
| SELL  | DOGE   | $    321.89 | 250000.0 | 250000.0  |   0.00000030 |   0.00000024 | 20.00% |
|                                             . . .                                          |
+-------+--------+-------------+----------+-----------+--------------+--------------+--------+
~~~

See the last 30 days of orders that have closed
~~~
>> rake closed_orders
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------+--------------------+
| Order | Symbol  | Cost        | Quantity | Remaining | Limit        | Total        | Commission   | Executed           |
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------+--------------------+
| SELL  | ETH     | $    543.27 |     1.88 |     0.00  |   0.06804991 |   0.12821286 |   0.00032053 | Wed 10/04 02:16 AM |
| BUY   | ETH-NEO | $   2221.07 |    67.67 |     0.00  |   0.11199993 |   7.57860809 |   0.01891429 | Sun 10/01 07:25 AM |
| BUY   | QTUM    | $    709.03 |    69.79 |     0.00  |   0.00239774 |   0.16733218 |   0.00041774 | Sat 09/30 05:28 AM |
| BUY   | QTUM    | $    584.92 |    58.00 |     0.00  |   0.00238001 |   0.13804058 |   0.00034510 | Sat 09/30 05:23 AM |
| SELL  | QTUM    | $     34.34 |    22.51 |     0.00  |   0.00036000 |   0.00810397 |   0.00013499 | Fri 09/29 19:36 PM | |                                                    . . .                                                               |
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------|--------------------+
~~~

Get USD amount for given BTC amount and vice versa

~~~
>> rake usdbtc[24.3196]
BTC:        0.00420729
USD: $     24.32

>> rake btcusd[0.0640625]
BTC:        0.06406250
USD: $    374.63
~~~
