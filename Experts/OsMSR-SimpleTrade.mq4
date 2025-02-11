//+------------------------------------------------------------------+
//|                                            OsMSR-SimpleTrade.mq4 |
//|                                     Copyright 2025, Geon-Hee Lee |
//|                                    https://github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Geon-Hee Lee"
#property link      "https://github.com/TF-polygon"
#property version   "1.00"
#property strict

#include <Position.mqh>

enum Syminfo {
   E = 0,   // EURUSD
   X = 1,   // XAUUSD
   U = 2    // USDJPY
};

extern string     ____CONSTANT_VARIABLES____ = "";

input int         input_secret_code    = NULL; // Secret code
input int         magic_number         = NULL; // Magic number
input Syminfo     symbol               = E;    // Symbol
input double      max_spread           = 5.0f;  // Spread (pip)

extern string     ______MAIN__SETTINGS______ = "";

input double      risk                 = 0.1f;

input bool        Is_onMartingaleMode  = false; // Martingale
input double      martin_val           = 2.0f;  // Mult
input int         martin_begin         = 3;     // Starting point

input double      take_profit          = 25;    // Take Profit(pip)
input double      stop_loss            = 20;    // Stop Loss(pip)

extern string     ___INDICATORS__SETTINGS___ = "";

input int         ema_length1          = 5; // EMA length (1)
input int         ema_length2          = 8; // EMA length (2)
input int         ema_length3          = 13; // EMA length (3)
// 136, 68, 34
input int         rsi_length           = 14; // RSI length

// extern string     ___STOCHASTIC__SETTINGS___ = ""; 

input int         stoch_length         = 3; // Stoch length
input int         stoch_k_period       = 14; // Stoch K period
input int         stoch_d_period       = 3; // Stoch D period

// extern string     ______MACD__SETTINGS______ = ""; // 

input int         macd_fast_length     = 12; // Fast MA length
input int         macd_slow_length     = 26; // Slow MA length
input int         macd_signal_length   = 9; // Signal line length

// --- Global variables
double      _proportional_lotsize;
double      _spread;
double      _pip;
int         _defeat_count;
double      _prev_lotsize;

// --- Indicator variables
bool        _long_stoch;
bool        _short_stoch;
bool        _long_stoch_overflag;
bool        _short_stoch_overflag;
double      _rsi;
double      _macd;
bool        _long_ema;
bool        _short_ema;

// --- Trading variables

s_Position pos;


void Init(void) {
   _proportional_lotsize = ZERO_FLOAT;
   _rsi = ZERO_FLOAT;
   _long_ema = false;
   _short_ema = false;
   _long_stoch = false;
   _short_stoch = false;
   _long_stoch_overflag = false;
   _short_stoch_overflag = false;
   _macd = ZERO_FLOAT;
   _spread = ZERO_FLOAT;
   _defeat_count = ZERO;
   _prev_lotsize = ZERO_FLOAT;
   _pip = symbol == E ? 0.0001 : symbol == X ? 0.01 : 0.01;
}

int OnInit() {
   Init();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { }

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
   _macd  = iOsMA(Symbol(), 0, 12, 26, 9, PRICE_CLOSE, 0);
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
            pos.open(OP_BUY, ticket, Ask, cur_lot);
            _prev_lotsize = pos.get_Lot();
         }
         else
            Print("Failed to order 'Long'");
      }
      
      else if (_macd < 0 && _rsi <= 50 && _short_stoch) {
         int ticket =  OrderSend(Symbol(), OP_SELL, cur_lot, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
         if (ticket != ZERO) {
            pos.open(OP_SELL, ticket, Bid, cur_lot);
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
      pos.init();
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
