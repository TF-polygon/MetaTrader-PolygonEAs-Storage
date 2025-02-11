//+------------------------------------------------------------------+
//|                                              OsMSR-Averaging.mq4 |
//|                           Copyright 2025, CVPR Lab. Geon-Hee Lee |
//|                                https://www.github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, CVPR Lab. Geon-Hee Lee"
#property link      "https://www.github.com/TF-polygon"
#property version   "1.00"
#property strict

#include <Position.mqh>

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
input double      max_spread           = 5.0f;   // Spread (pip)

extern string     _______MAIN_SETTINGS_______ = "";

input int         TRADING_SIZE         = 15;     // Trading Size
input double      risk                 = 0.1f;

input bool        Is_onMartingaleMode  = false;  // Martingale
input double      martin_mult          = 2.0f;   // Mult
input int         martin_begin         = 3;      // Starting point

input bool        Is_onEntryIndicators = false;  // Use Indicators

extern string     ______TRADING_SETTINGS______ = "";

input Degree      close_degree         = PIP;
input double      dist                 = 25.0f; // Distance
input double      take_profit          = 2.0f; // TP (%)

// --- Global variables

const int      _secret_code = NULL;
datetime       _prevBar, _currBar;
double         _proportional_lotsize;
double         _pip;
double         _spread;

// --- Indicator variables
bool        _long_stoch;
bool        _short_stoch;
bool        _long_stoch_overflag;
bool        _short_stoch_overflag;
double      _rsi;
double      _macd;
bool        _ema;

// --- Trading variabels
int Long_Idx;
Position *Long[];

int Short_Idx;
Position *Short[];

void Init(void) {
   _prevBar = NULL;
   _currBar = NULL;
   _proportional_lotsize = NULL;
   _long_stoch = false;
   _short_stoch = false;
   _long_stoch_overflag = false;
   _short_stoch_overflag = false;
   _ema = ZERO_FLOAT;
   _spread = ZERO_FLOAT;
   _pip = symbol == EURUSD ? 0.0001 : 0.01;  
   
   Long_Idx = INDEX_INIT_VAL;
   ArrayResize(Long, TRADING_SIZE);
   
   Short_Idx = INDEX_INIT_VAL;
   ArrayResize(Short, TRADING_SIZE);
}

inline double pip(double val) { return val * _pip; }
inline double rev(double val) { return val / _pip; }

int OnInit() {
   Init();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { }

void OnTick() {
   START();
   
   ADD(OP_BUY);
   ADD(OP_SELL);
   
   CLOSE(OP_BUY);
   CLOSE(OP_SELL);
}

void update(void) {
   _proportional_lotsize = AccountBalance() * risk * _pip / Ask < 0.01 ? 0.01 : AccountBalance() * risk * _pip / Ask;
   _currBar = iTime(NULL, 0, 0);
   _spread  = MarketInfo(NULL, MODE_SPREAD);
}

void START(void) {
   update();
   if (_spread > max_spread || OrdersTotal() != 0) return;
   if (OrdersTotal() == 0 && Is_empty()) {
      if (Is_onEntryIndicators) {
         _long_stoch = iStochastic(NULL, 0, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0) < 80;
         _short_stoch = iStochastic(NULL, 0, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, 0) > 20;
         _rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
         _macd = iOsMA(NULL, 0, 12, 26, 9, PRICE_CLOSE, 0);
         if (_long_stoch && _rsi > 50 && _macd > 0) {
            int ticket = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
            if (ticket > 0) {
               Long[++Long_Idx] = new Position(OP_BUY, ticket, Ask, _proportional_lotsize);
            }
         }
         else if (_short_stoch && _rsi < 50 && _macd < 0) {
            int ticket = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
            if (ticket > 0) {
               Short[++Short_Idx] = new Position(OP_SELL, ticket, Bid, _proportional_lotsize);
            }
         }
         
      }
      else {
         _ema = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);
         if (_ema <= Ask) {
            int ticket = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
            if (ticket > 0) {
               Long[++Long_Idx] = new Position(OP_BUY, ticket, Ask, _proportional_lotsize);
            }
         }
         else if (_ema >= Bid) {
            int ticket = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
            if (ticket > 0) {
               Short[++Short_Idx] = new Position(OP_SELL, ticket, Bid, _proportional_lotsize);
            }
         }
      }
   }
}

void ADD(const int op) {
   update();
   if (_spread > max_spread || OrdersTotal() == 0) return;
   double lot;
   switch (op) {
   case OP_BUY:
      if (Long_Idx > INDEX_INIT_VAL && Long_Idx < TRADING_SIZE - 1 && rev(Long[Long_Idx].get_Bep() - Ask) >= dist) {
         lot = Is_onMartingaleMode && Long_Idx >= martin_begin - 1 ? Long[Long_Idx].get_Lot() * martin_mult : _proportional_lotsize;
         int ticket = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
         if (ticket > 0) {
            Long[++Long_Idx] = new Position(OP_BUY, ticket, Ask, _proportional_lotsize);
         }
      }
      break;
   case OP_SELL:
      if (Short_Idx > INDEX_INIT_VAL && Short_Idx < TRADING_SIZE - 1 && rev(Short[Short_Idx].get_Bep() - Bid) <= -dist) {
         lot = Is_onMartingaleMode && Short_Idx >= martin_begin - 1 ? Short[Short_Idx].get_Lot() * martin_mult : _proportional_lotsize;
         int ticket = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
         if (ticket > 0) {
            Short[++Short_Idx] = new Position(OP_SELL, ticket, Bid, _proportional_lotsize);
         }
      }
      break;
   }
}

void CLOSE(const int op) {
   if (OrdersTotal() == 0) return;
   
   double pip_sum = ZERO_FLOAT;
   
   
   switch (op) {
   case OP_BUY:
      if (Long_Idx == 0) {
         if (rev(Bid - Long[Long_Idx].get_Bep()) >= dist) {
            int closed_ticket = OrderClose(Long[Long_Idx].get_Ticket(), Long[Long_Idx].get_Lot(), Bid, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket) {
               delete Long[Long_Idx--];               
            }
         }
      }
      else if (Long_Idx != INDEX_INIT_VAL) {
         for (int i = Long_Idx; i >= 0; i--)
            pip_sum += rev(Bid - Long[i].get_Bep());
         
         if (pip_sum >= 15 * (Long_Idx + 1)) {
            for (int i = Long_Idx; i >= 0; i--, Long_Idx--) {
               int closed_ticket = OrderClose(Long[i].get_Ticket(), Long[i].get_Lot(), Bid, TEMP_SLIPPAGE, clrOrange);
               if (closed_ticket) {
                  delete Long[i];               
               }
            }
         }
      }
      return;
   
   case OP_SELL:
      if (Short_Idx == 0) {
         if (rev(Short[Short_Idx].get_Bep() - Ask) >= dist) {
            int closed_ticket = OrderClose(Short[Short_Idx].get_Ticket(), Short[Short_Idx].get_Lot(), Ask, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket) {
               delete Short[Short_Idx--];
            }
         }
      }
      else if (Short_Idx != INDEX_INIT_VAL) {
         for (int i = Short_Idx; i >= 0; i--)
            pip_sum += rev(Short[i].get_Bep() - Ask);
         
         if (pip_sum >= 15 * (Short_Idx + 1)) {
            for (int i = Short_Idx; i >= 0; i--, Short_Idx--) {
               int closed_ticket = OrderClose(Short[i].get_Ticket(), Short[i].get_Lot(), Ask, TEMP_SLIPPAGE, clrOrange);
               if (closed_ticket) {
                  delete Short[i];
               }
            }
         }
      }
      return;
   }
}

bool Is_empty(void) {
   return(Long_Idx == INDEX_INIT_VAL && Short_Idx == INDEX_INIT_VAL);
}