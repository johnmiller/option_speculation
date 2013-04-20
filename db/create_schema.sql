CREATE TABLE daily_options (
  -- CSV Columns
  underlying varchar(10),
  underlying_last numeric(18,2),
  exchange varchar(10),
  option_symbol varchar(30),
  blank varchar(1),
  option_type varchar(4),
  expiration_date date,
  quote_date timestamp,
  strike numeric(18,2),
  last numeric(18,2),
  bid numeric(18,2),
  ask numeric(18,2),
  volume bigint,
  open_interest integer,
  implied_volatility numeric(10, 5),
  delta numeric(10, 5),
  gamma numeric(10,5),
  theta numeric(10, 5),
  vega numeric(10, 5),
  alias varchar(20),

  -- Custom Columns
  current boolean default false
);

CREATE TABLE daily_stocks (
  -- CSV Columns
  symbol varchar(10),
  date date,
  open numeric(18,2),
  high numeric(18,2),
  low numeric(18,2),
  close numeric(18,2),
  volume bigint,
  twenty_day_mov_avg numeric(18,2),
  twenty_day_stand_dev_times_two numeric(18,2),
  upper_band numeric(18,2),
  lower_band numeric(18,2),

  -- Custom Columns
  current boolean default false
);

CREATE TABLE daily_volatility (
  -- CSV Columns
  symbol varchar(10),
  date date,
  call_iv numeric(10,5),
  put_iv numeric(10,5),
  mean_iv numeric(10,5),
  call_vol integer,
  put_vol integer,
  call_oi integer,
  put_oi integer,

  -- Custom Columns
  current boolean default false
);

CREATE OR REPLACE FUNCTION mark_current() RETURNS void AS $$
DECLARE
  max_date date := null;
BEGIN
  SELECT MAX(date) INTO max_date FROM daily_stocks;

  UPDATE daily_stocks SET current = false WHERE current = true;
  UPDATE daily_options SET current = false WHERE current = true;
  UPDATE daily_volatility SET current = false WHERE current = true;
  
  UPDATE daily_stocks SET current = true WHERE date = max_date;
  UPDATE daily_options SET current = true WHERE quote_date = max_date;
  UPDATE daily_volatility SET current = true WHERE date = max_date;

  RAISE NOTICE 'Current date set to: %', max_date;
END
$$ LANGUAGE plpgsql
