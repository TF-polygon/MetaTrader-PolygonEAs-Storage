//+------------------------------------------------------------------+
//|                                            OsMSR-SimpleTrade.mq4 |
//|                                     Copyright 2025, Geon-Hee Lee |
//|                                    https://github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Geon-Hee Lee"
#property link      "https://github.com/TF-polygon"
#property version   "1.00"
#property strict

#include <OsMSR-SimpleTrade/Core.mqh>

Position *pos;

int OnInit() {
   Init();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   delete pos;
}

void OnTick() {
   Start();
   Trade();
}

bool MyStochastic(const int dir) {
   double stochK = iStochastic(NULL, 0, stoch_k_period, stoch_d_period, stoch_length, MODE_SMA, 0, MODE_MAIN, 0);
   double stochD = iStochastic(NULL, 0, stoch_k_period, stoch_d_period, stoch_length, MODE_SMA, 0, MODE_SIGNAL, 0);
   _long_stoch_overflag = stochK < 20;
   _short_stoch_overflag = stochK > 80;
   
   switch (dir) {
   case LONG:
      if (stochK > stochD && !_long_stoch_overflag)
         return stochK < 80;
   case SHORT:
      if (stochK < stochD && !_short_stoch_overflag)
         return stochK > 20;
   default: break;
   }
   return false;
}

bool MyEma(const int dir) {
   double ema01 = iMA(NULL, 0, ema_length1, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema02 = iMA(NULL, 0, ema_length2, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ema03 = iMA(NULL, 0, ema_length3, 0, MODE_EMA, PRICE_CLOSE, 0);
   
   switch (dir) {
   case LONG:
      return ema01 < Ask && ema02 < Ask && ema03 < Ask;
   
   case SHORT:
      return ema01 > Bid && ema02 > Bid && ema03 > Bid;
      
   default: 
      break;
   }
   return false;
}

void Start(void) {
   _macd  = iCustom(NULL, 0, "[Pine]MACD Histogram", 12, 26, 9, 0, 0);
   _rsi   = iRSI(NULL, 0, rsi_length, PRICE_CLOSE, 0);
   // _long_ema = MyEma(LONG);
   // _short_ema = MyEma(SHORT);
   _long_stoch = MyStochastic(LONG);
   _short_stoch = MyStochastic(SHORT);
   update();
   if (max_spread < _spread) return;
   
   if (OrdersTotal() == 0) {
      double cur_lot = Is_onMartingaleMode && _defeat_count >= martin_begin ? _prev_lotsize * martin_val : _proportional_lotsize;      
      if (_macd > 0 && _rsi >= 50 && _long_stoch) {
         int ticket = OrderSend(Symbol(), OP_BUY, cur_lot, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
         if (ticket != ZERO) {
            pos = new Position(OP_BUY, ticket, Ask, cur_lot);
            _prev_lotsize = pos.get_Lot();
         }
         else
            Print("Failed to order 'Long'");
      }
      
      else if (_macd < 0 && _rsi <= 50 && _short_stoch) {
         int ticket =  OrderSend(Symbol(), OP_SELL, cur_lot, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
         if (ticket != ZERO) {
            pos = new Position(OP_SELL, ticket, Bid, cur_lot);
            _prev_lotsize = pos.get_Lot();
         }
         else
            Print("Failed to order 'Short'");
      }
   }
}

bool Is_close(void) {
   switch (pos.get_Op()) {
   case OP_BUY:
      if (pos.get_Bep() + pip(take_profit) <= Bid)
         return true;
      else if (pos.get_Bep() - pip(stop_loss) >= Bid)
         return true;
      break;
   
   case OP_SELL:
      if (pos.get_Bep() - pip(take_profit) >= Ask )
         return true;
      else if (pos.get_Bep() + pip(stop_loss) <= Ask)
         return true;
      break;
   }
   return false;
}

void close(void) {
   double price = pos.get_Op() == OP_BUY ? Bid : Ask;
   if (OrderClose(pos.get_Ticket(), pos.get_Lot(), price, TEMP_SLIPPAGE, clrOrange)) {
      Print("Closed the order successfully, Ticket No.", pos.get_Ticket(), "  ", pos.get_Op());
      switch (pos.get_Op()) {
      case OP_BUY:
         if (pos.get_Bep() > Bid) _defeat_count++;
         else _defeat_count = ZERO;
         break;
      case OP_SELL:
         if (pos.get_Bep() < Ask) _defeat_count++;
         else _defeat_count = ZERO;
         break;
      default:
         break;
      }
      delete pos;
   } 
   else
      Print("Failed to close the order, Ticket No.", pos.get_Ticket(), "  ", pos.get_Op());
   
}

void Trade(void) {
   if (OrdersTotal() != 0) {
      if (Is_close())
         close();
   }
}

void update(void) {
   RefreshRates();
   _proportional_lotsize = pip(AccountBalance() * risk) / Ask < 0.01 ? 0.01 : pip(AccountBalance() * risk) / Ask;
   _spread = MarketInfo(Symbol(), MODE_SPREAD);
}

inline double pip(double val)   { return val * 0.0001; }
inline double rev(double val)   { return val / 0.0001; }
