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
-- inner_call = sell
-- outer_call = purchases
with call_options as (
	select * from daily_options
	where option_type = 'call'
	and exchange in ('*','G','W','Q','P')
	and delta <= .15
	and last > 0.0
	and volume > 0.0
	and expiration_date < '2013-03-05'
)
select 
	inner_call.underlying, 
	inner_call.underlying_last, 
	inner_call.expiration_date,
	inner_call.exchange as inner_call_exchange,
	inner_call.bid as inner_call_bid, 
	inner_call.ask as inner_call_ask, 
	inner_call.last as inner_call_last,
	inner_call.strike as inner_call_strike, 
	inner_call.delta as inner_call_delta,
	outer_call.exchange as outer_call_exchange,
	outer_call.bid as outer_call_bid,
	outer_call.ask as outer_call_ask, 
	outer_call.last as outer_call_last,
	outer_call.strike as outer_call_strike, 
	outer_call.delta as outer_call_delta,
	(outer_call.ask - inner_call.bid) as bid_ask_spread, 
	(inner_call.strike - outer_call.strike) as strike_spread,
	((inner_call.strike - outer_call.strike) - (outer_call.last - inner_call.last)) * 100 as max_loss,
	(outer_call.last - inner_call.last) * 100 as max_profit,
	round(((outer_call.last - inner_call.last) / ((inner_call.strike - outer_call.strike) - (outer_call.last - inner_call.last))), 2) as max_profit_perc
from call_options inner_call
inner join call_options outer_call 
	on inner_call.underlying = outer_call.underlying
	and outer_call.option_symbol ~ outer_call.underlying
	and inner_call.expiration_date = outer_call.expiration_date
	and inner_call.strike > outer_call.strike
	and outer_call.strike > outer_call.underlying_last
	--and outer_call.ask > inner_call.bid
	and ((outer_call.last - inner_call.last) / ((inner_call.strike - outer_call.strike) - (outer_call.last - inner_call.last))) > .10
	--and ((inner_call.strike - outer_call.strike) - (outer_call.ask - inner_call.bid)) <= 0
where 
	inner_call.option_symbol ~ inner_call.underlying
	and inner_call.strike > inner_call.underlying_last
--order by underlying
--order by ((outer_call.ask - inner_call.bid) / ((inner_call.strike - outer_call.strike) - (outer_call.ask - inner_call.bid))) desc


/********** Long PUT ************/
select underlying_last, expiration_date, strike, last, bid, ask, volume, open_interest, delta 
from daily_options
where option_type = 'put'
and exchange in ('*','G','W','Q','P')
and underlying = 'NOV'
--and expiration_date < '2013-03-05'
order by expiration_date, strike