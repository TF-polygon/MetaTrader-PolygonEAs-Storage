//+------------------------------------------------------------------+
//|                                                         Core.mqh |
//|                           Copyright 2025, CVPR Lab. Geon-Hee Lee |
//|                                https://www.github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, CVPR Lab. Geon-Hee Lee"
#property link      "https://www.github.com/TF-polygon"
#property strict

#define MAX_TRADING_SIZE                  100
#define LOT_UNIT                          10000
#define INDEX_INIT_VAL                    -1
#define LONG                              1
#define SHORT                             2
#define TEMP_SLIPPAGE                     5
#define ZERO_FLOAT                        0.0f
#define ZERO                              0

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

// --- Trading variables

int      Long_Idx;
int      Long_Ticket[];
double   Long_EntryPrice[];
double   Long_Lot[];

int      Short_Idx;
int      Short_Ticket[];
double   Short_EntryPrice[];
double   Short_Lot[];

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
   ArrayResize(Long_Ticket, TRADING_SIZE);
   ArrayResize(Long_EntryPrice, TRADING_SIZE);
   ArrayResize(Long_Lot, TRADING_SIZE);
   
   Short_Idx = INDEX_INIT_VAL;
   ArrayResize(Short_Ticket, TRADING_SIZE);
   ArrayResize(Short_EntryPrice, TRADING_SIZE);
   ArrayResize(Short_Lot, TRADING_SIZE);
}

inline double pip(double val) { return val * 0.0001; }
inline double rev(double val) { return val / 0.0001; }.0001; }