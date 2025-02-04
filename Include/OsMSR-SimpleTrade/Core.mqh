//+------------------------------------------------------------------+
//|                                                         Core.mqh |
//|                                     Copyright 2025, Geon-Hee Lee |
//|                                    https://github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Geon-Hee Lee"
#property link      "https://github.com/TF-polygon"
#property strict

#define ZERO                  0
#define ZERO_FLOAT            0.0f
#define MAX_TRADING_SIZE      100
#define LOT_UNIT              10000
#define LONG                  1
#define SHORT                 2
#define TEMP_SLIPPAGE         5
#define PIVOTPOINT_RANGE      5

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

struct Position {
private:
// Trading Option
   int      m_Op;
// Ticket number
   int      m_Ticket;
// Entry Price
   double   m_Bep;
// Lot size
   double   m_Lot;
   
public:
// Initialize the order
   void init(void) {
      m_Op     = NULL;
      m_Ticket = NULL;
      m_Bep    = NULL;
      m_Lot    = NULL;
   }
// Open the order
   void open(int op, int ticket, double bep, double lot) {
      m_Op     = op;
      m_Ticket = ticket;
      m_Bep    = bep;
      m_Lot    = lot;
   }

public:      
   inline int     get_Op(void)         { return m_Op; }
   inline double  get_Lot(void)        { return m_Lot; }
   inline double  get_Bep(void)        { return m_Bep; }
   inline int     get_Ticket(void)     { return m_Ticket; }
};