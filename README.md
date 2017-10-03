This little Crypto Tool is for command-line (presently).  It allows you to quickly take a peek at your wallet and orders (open and close).

I got tired of always keying 2FA to login and check things out as well as doing the Math to determine USD value of balances.

Since I also like to place SELL orders with a LIMIT, I like to know how far away an order is from potentially filling.

That's the start of this little tool, which I expect will grow in features over time.

Presently, this tool is wired only to Bittrex and Coinbase.  To set up for your own use, copy config/exchanges.yml.example to config/exchanges.yml and add your API key and secret to the file.

CAUTION:  THERE MAY BE BUGS!  Report bugs in the issue tracker or send me a PR with the bug already fixed!

See the balance on every non-zero balance wallet.
~~~
>> rake wallets
+--------+--------------+--------------+--------------+-------------+
| Symbol | Quantity     | Available    | Pending      | USD         |
+--------+--------------+--------------+--------------+-------------+
| BTC    |   0.00023420 |   0.00023420 |   0.00000000 | $      0.00 |
| DOGE   | 250000.00000 |   0.00000000 |   0.00000000 | $    257.51 |
| ETH    |   0.01295416 |   0.01295416 |   0.00000000 | $      3.78 |
| MTL    |  31.44483628 |   0.00000000 |   0.00000000 | $    255.88 |
| NEO    |   0.64118599 |   0.64118599 |   0.00000000 | $     21.60 |
| OMG    | 227.23392835 |   0.00000000 |   0.00000000 | $   2028.53 |
| PAY    | 388.11615012 |   0.00000000 |   0.00000000 | $    884.16 |
| XRP    | 5000.0000000 |   0.00000000 |   0.00000000 | $   1012.02 |
+--------+--------------+--------------+--------------+-------------+
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
+-------+--------+-------------+----------+-----------+--------------+--------------+--------+
~~~

See the last 30 days of orders that have closed
~~~
>> rake closed_orders
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------------+
| Order | Symbol  | Cost        | Quantity | Remaining | Limit        | Commission   | Executed           |
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------------+
| BUY   | ETH-NEO | $   2205.30 |    67.67 |     0.00  |   0.11199993 |   0.01891429 | Sun 10/01 07:25 AM |
| BUY   | QTUM    | $    718.16 |    69.79 |     0.00  |   0.00239774 |   0.00041774 | Sat 09/30 05:28 AM |
| BUY   | QTUM    | $    592.45 |    58.00 |     0.00  |   0.00238001 |   0.00034510 | Sat 09/30 05:23 AM |
| SELL  | QTUM    | $     34.78 |    22.51 |     0.00  |   0.00036000 |   0.00013499 | Fri 09/29 19:36 PM |
| SELL  | QTUM    | $   1076.40 |    99.90 |     0.00  |   0.00251053 |   0.00062700 | Tue 09/26 04:34 AM |
+-------+---------+-------------+----------+-----------+--------------+--------------+--------------------+
~~~
