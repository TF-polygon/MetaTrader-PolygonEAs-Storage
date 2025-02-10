//+------------------------------------------------------------------+
//|                                                HedgeStrategy.mq4 |
//|                           Copyright 2025, CVPR Lab. Geon-Hee Lee |
//|                                https://www.github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, CVPR Lab. Geon-Hee Lee"
#property link      "https://www.github.com/TF-polygon"
#property version   "1.00"
#property strict

#include <Position.mqh>

//#define PREV

enum Syminfo {
   EURUSD = 0,
   USDJPY = 1
};

enum Degree {
   PIP = 0,
   PRICE = 1
};

extern string     _____CONSTANT_VARIABLES_____ = "";

input int         input_secret_code    = NULL;   // Secret code
input int         magic_number         = NULL;   // Magic number
input Syminfo     symbol               = EURUSD; // Symbol

extern string     _______MAIN_SETTINGS_______ = "";

input int         TRADING_SIZE         = 100;     // Trading Size
input double      risk                 = 0.1f;

extern string     ______TRADING_SETTINGS______ = "";

input double      dist                 = 15.0;  // Distance
input double      r2r                  = 3.0;      // R2R


// --- Global variables

const int      _secret_code = NULL;
double         _proportional_lotsize;
double         _pip;
double         _spread;

// --- Indicator variables
bool           _long_stoch;
bool           _short_stoch;
bool           _long_stoch_overflag;
bool           _short_stoch_overflag;
double         _rsi;
double         _macd;
bool           _ema;

int            _idx;
s_Position     _pos[];

void Init(void) {
   _proportional_lotsize = NULL;
   _long_stoch = false;
   _short_stoch = false;
   _long_stoch_overflag = false;
   _short_stoch_overflag = false;
   _ema = ZERO_FLOAT;
   _spread = ZERO_FLOAT;
   _pip = symbol == EURUSD ? 0.0001 : 0.01;
   _idx = INDEX_INIT_VAL;
   ArrayResize(_pos, TRADING_SIZE);
}

inline double pip(double val) { return symbol == EURUSD ? val * 0.0001 : val * 0.01; }
inline double rev(double val) { return symbol == EURUSD ? val / 0.0001 : val / 0.01; }

int OnInit() {
   Init();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

void OnTick() {
   Start();
   Add();
   close();
}

void Start(void) {
   update();
   if (_spread > 5.0f || OrdersTotal() != 0) return;
   
   if (_macd > 0 && _rsi >= 50 && _ema <= Ask && _long_stoch) {
      int ticket = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
      if (ticket > 0) {
         _pos[++_idx].open(OP_BUY, ticket, Ask, _proportional_lotsize);
      }
   }
   else if (_macd < 0 && _rsi <= 50 && _ema >= Bid && _short_stoch) {
      int ticket = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
      if (ticket > 0) {
         _pos[++_idx].open(OP_SELL, ticket, Bid, _proportional_lotsize);
      }
   }
}

double calc_nextLot(const int op) {
   double lln= ZERO_FLOAT;
   double lsn = ZERO_FLOAT;
   
   for (int i = _idx; i >= 0; i--) {
      if (_pos[i].get_Op() == OP_BUY)
         lln += _pos[i].get_Lot();
      else
         lsn += _pos[i].get_Lot();
   }
   
   return op == OP_BUY ? ((((r2r + 1.0) / r2r) * lsn) - lln) * 1.1 : ((((r2r + 1.0) / r2r) * lln) - lsn) * 1.1;
}

void Add(void) {
   if (OrdersTotal() == 0 || _idx >= TRADING_SIZE - 1) return;
   
   if (_pos[_idx].get_Op() == OP_BUY) {
      if (_pos[_idx].get_Bep() - pip(dist) > Bid) {
         double lot = _idx == 0 ? ((r2r + 1) / r2r) * _pos[_idx].get_Lot() * 1.1 : calc_nextLot(OP_SELL); // _lot[_idx] * martin_mult;
         //Print("calc_lot from Add() : ", lot, " --> (", r2r + 1, " / ", r2r, ") * ", _pos[_idx].get_Lot(), " * ", martin_mult);
         int ticket = OrderSend(NULL, OP_SELL, lot, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
         if (ticket > 0) {
            _pos[++_idx].open(OP_SELL, ticket, Bid, lot);
         }
      }
   }
   else {
      if (_pos[_idx].get_Bep() + pip(dist) < Ask) {
         double lot = _idx == 0 ? ((r2r + 1) / r2r) * _pos[_idx].get_Lot() * 1.1 : calc_nextLot(OP_BUY); // _lot[_idx] * martin_mult;
         //Print("calc_lot from Add() : ", lot, " --> (", r2r + 1, " / ", r2r, ") * ", _pos[_idx].get_Lot(), " * ", martin_mult);
         int ticket = OrderSend(NULL, OP_BUY, lot, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
         if (ticket > 0) {
            _pos[++_idx].open(OP_BUY, ticket, Ask, lot);
         }
      }
   }
}

void close(void) {
   if (_idx == INDEX_INIT_VAL) return;
   
   if (_pos[0].get_Op() == OP_BUY) {
      if (_pos[0].get_Bep() + pip(dist * r2r) < Bid || _pos[0].get_Bep() - pip((dist * r2r) + dist) > Bid) {
         int idx = _idx;
         for (int i = idx; i >= 0; i--, _idx--) {
            double price = _pos[i].get_Op() == OP_BUY ? Bid : Ask;
            int closed_ticket = OrderClose(_pos[i].get_Ticket(), _pos[i].get_Lot(), price, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket > 0) {
               _pos[i].init();
            }
         }
      }
   }
   else {
      if (_pos[0].get_Bep() - pip(dist * r2r) > Ask || _pos[0].get_Bep() + pip((dist * r2r) + dist) < Ask) {
         int idx = _idx;
         for (int i = idx; i >= 0; i--, _idx--) {
            double price = _pos[i].get_Op() == OP_BUY ? Bid : Ask;
            int closed_ticket = OrderClose(_pos[i].get_Ticket(), _pos[i].get_Lot(), price, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket > 0) {
               _pos[i].init();
            }
         }
      }
   }
}

void update(void) {
   RefreshRates();
   _proportional_lotsize = pip(AccountBalance() * risk) / Ask < 0.01 ? 0.01 : pip(AccountBalance() * risk) / Ask;
   _spread = MarketInfo(Symbol(), MODE_SPREAD);
   _macd = iOsMA(NULL, 0, 12, 26, 9, PRICE_CLOSE, 0);// iCustom(NULL, 0, "[Pine]MACD Histogram", 12, 26, 9, 0, 0);
   _rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   _long_stoch = MyStochastic(LONG);
   _short_stoch = MyStochastic(SHORT);
}

bool MyStochastic(const int op) {
   double stochK = iStochastic(NULL, 0, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
   double stochD = iStochastic(NULL, 0, 14, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
   switch (op) {
   case LONG:
      if (stochK > stochD)
         return stochK < 80;
   case SHORT:
      if (stochK < stochD)
         return stochK > 20;
   default: break;
   }
   return false;
}
