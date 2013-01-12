/************ Covered Calls **************/
select underlying, underlying_last, expiration_date, strike, last, bid, ask, 
 round((bid+ask)/2, 2) as bid_ask_avg, 
 round(last/underlying_last, 2) as last_profit_perc, 
 round((strike - underlying_last) + last, 2) as last_max_profit, 
 round(((strike - underlying_last) + last) / underlying_last, 2) as last_max_profit_perc, 
 volume, 
 open_interest, 
 implied_volatility, 
 delta, 
 exchange
from daily_options
where option_type='call'
and exchange != 'N'
and underlying_last >= 1.0
and last > 0.0
and volume > 0.0
and strike > underlying_last
and (((bid+ask) / 2) / underlying_last) > .05
and expiration_date < '2013-03-05'
--and underlying in ('CAT','NOV','BAC','DLB','AIG','CVX','SAN','AAPL','KKPNY','WDC')
--order by expiration_date
order by underlying
--order by last/underlying_last desc
--order by volume desc
--limit 100


/********** CALL Credit Spreads ************/
-- leg1 = outer (sell)
-- leg2 = inner (purchase)
-- CALL

select leg1.underlying, 
 leg1.underlying_last, 
 leg1.expiration_date,
 leg1.exchange as leg1_exchange,
 leg1.bid as leg1_bid, 
 leg1.ask as leg1_ask, 
 leg1.last as leg1_last,
 leg1.strike as leg1_strike, 
 leg1.delta as leg1_delta,
 leg2.exchange as leg2_exchange,
 leg2.bid as leg2_bid,
 leg2.ask as leg2_ask, 
 leg2.last as leg2_last,
 leg2.strike as leg2_strike, 
 leg2.delta as leg2_delta,
 (leg2.ask - leg1.bid) as bid_ask_spread, 
 (leg1.strike - leg2.strike) as strike_spread,
 ((leg1.strike - leg2.strike) - (leg2.ask - leg1.bid)) * 100 as max_loss,
 (leg2.ask - leg1.bid) * 100 as max_profit,
 round(((leg2.ask - leg1.bid) / ((leg1.strike - leg2.strike) - (leg2.ask - leg1.bid))), 2) as max_profit_perc
from daily_options leg1
inner join daily_options leg2 
 on leg1.underlying = leg2.underlying
 and leg2.option_symbol ~ leg2.underlying
 and leg1.expiration_date = leg2.expiration_date
 and leg2.option_type = 'call'
 and leg2.exchange in ('*','G','W','Q','P')
 and leg1.strike > leg2.strike
 and leg2.delta <= .15
 and leg2.last > 0.0
 and leg2.volume > 0.0
 and leg2.strike > leg2.underlying_last
 and ((leg2.ask - leg1.bid) / ((leg1.strike - leg2.strike) - (leg2.ask - leg1.bid))) > .10
where 
leg1.option_symbol ~ leg1.underlying
and leg1.option_type = 'call'
and leg1.exchange in ('*','G','W','Q','P')
and leg1.delta <= .15
and leg1.last > 0.0
and leg1.volume > 0.0
and leg1.expiration_date < '2013-03-05'
and leg1.strike > leg1.underlying_last
--order by underlying
order by ((leg2.ask - leg1.bid) / ((leg1.strike - leg2.strike) - (leg2.ask - leg1.bid))) desc
limit 1000



