//+------------------------------------------------------------------+
//|                                              OsMSR-Averaging.mq4 |
//|                           Copyright 2025, CVPR Lab. Geon-Hee Lee |
//|                                https://www.github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, CVPR Lab. Geon-Hee Lee"
#property link      "https://www.github.com/TF-polygon"
#property version   "1.00"
#property strict

#include <OsMSR-Averaging/Core.mqh>

int OnInit() {

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
            Long_Ticket[++Long_Idx] = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
            if (Long_Ticket[Long_Idx] > 0) {
               Long_EntryPrice[Long_Idx] = Ask;
               Long_Lot[Long_Idx] = _proportional_lotsize;
            }
         }
         else if (_short_stoch && _rsi < 50 && _macd < 0) {
            Short_Ticket[++Short_Idx] = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
            if (Short_Ticket[Short_Idx] > 0) {
               Short_EntryPrice[Short_Idx] = Bid;
               Short_Lot[Short_Idx] = _proportional_lotsize;
            }
         }
         
      }
      else {
         _ema = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 0);
         if (_ema <= Ask) {
            Long_Ticket[++Long_Idx] = OrderSend(NULL, OP_BUY, _proportional_lotsize, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
            if (Long_Ticket[Long_Idx] > 0) {
               Long_EntryPrice[Long_Idx] = Ask;
               Long_Lot[Long_Idx] = _proportional_lotsize;
            }
         }
         else if (_ema >= Bid) {
            Short_Ticket[++Short_Idx] = OrderSend(NULL, OP_SELL, _proportional_lotsize, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
            if (Short_Ticket[Short_Idx] > 0) {
               Short_EntryPrice[Short_Idx] = Bid;
               Short_Lot[Short_Idx] = _proportional_lotsize;
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
      if (Long_Idx > INDEX_INIT_VAL && Long_Idx < TRADING_SIZE - 1 && pip(Long_EntryPrice[Long_Idx] - Ask) >= dist) {
         lot = Is_onMartingaleMode ? Long_Lot[Long_Idx] * martin_mult : _proportional_lotsize;
         Long_Ticket[++Long_Idx] = OrderSend(NULL, OP_BUY, lot, Ask, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrBlue);
         if (Long_Ticket[Long_Idx] > 0) {
            Long_EntryPrice[Long_Idx] = Ask;
            Long_Lot[Long_Idx] = lot;
         }
      }
      break;
   case OP_SELL:
      if (Short_Idx > INDEX_INIT_VAL && Short_Idx < TRADING_SIZE - 1 && pip(Bid - Short_EntryPrice[Short_Idx]) >= dist) {
         lot = Is_onMartingaleMode ? Long_Lot[Long_Idx] * martin_mult : _proportional_lotsize;
         Short_Ticket[++Short_Idx] = OrderSend(NULL, OP_SELL, lot, Bid, TEMP_SLIPPAGE, 0, 0, NULL, magic_number, 0, clrRed);
         if (Short_Ticket[Short_Idx] > 0) {
            Short_EntryPrice[Short_Idx] = Bid;
            Short_Lot[Short_Idx] = lot;
         }
      }
      break;
   }
}

void CLOSE(const int op) {
   if (OrdersTotal() == 0) return;
   
   double ave_profit = ZERO_FLOAT;
   
   switch (op) {
   case OP_BUY:
      for (int i = Long_Idx; i >= 0; i--)
         ave_profit += Long_EntryPrice[i];
      ave_profit /= (Long_Idx - 1);
      if (Bid >= ave_profit * (1 + take_profit / 100)) {
         for (int i = Long_Idx; i >= 0; i--, Long_Idx--) {
            int closed_ticket = OrderClose(Long_Ticket[i], Long_Lot[i], Bid, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket) {
               Long_Ticket[i] = ZERO;
               Long_EntryPrice[i] = ZERO_FLOAT;
               Long_Lot[i] = ZERO_FLOAT;
            }
         }
      }
      return;
   
   case OP_SELL:
      for (int i = Short_Idx; i >= 0; i--)
         ave_profit += Short_EntryPrice[i];
      ave_profit /= (Short_Idx - 1);
      if (Ask <= ave_profit * (1 - take_profit / 100)) {
         for (int i = Short_Idx; i >= 0; i--, Short_Idx--) {
            int closed_ticket = OrderClose(Short_Ticket[i], Short_Lot[i], Ask, TEMP_SLIPPAGE, clrOrange);
            if (closed_ticket) {
               Short_Ticket[i] = ZERO;
               Short_EntryPrice[i] = ZERO_FLOAT;
               Short_Lot[i] = ZERO_FLOAT; 
            }
         }
      }
      return;
   }
}

bool Is_empty(void) {
   return(Long_Idx == INDEX_INIT_VAL && Short_Idx == INDEX_INIT_VAL);
}