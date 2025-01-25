//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                         Copyright 2025, Jacob Cho & Geon-Hee Lee |
//|                                    https://github.com/TF-polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Jacob Cho & Geon-Hee Lee"
#property link      "https://github.com/TF-polygon"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_width2 2
#property indicator_width3 2

extern int fastMA_length = 12;
extern int slowMA_length = 26;
extern int signal_length = 9;

double ExtHistBuffer[], ExtHistBufferUp[], ExtHistBufferDn[], macdBuffer[];


int OnInit() {
   SetIndexBuffer(0, ExtHistBuffer);
   SetIndexBuffer(1, ExtHistBufferUp);
   SetIndexBuffer(2, ExtHistBufferDn);
   SetIndexBuffer(3, macdBuffer);
   
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_NONE);
   
   SetIndexLabel(0, "MACD Histogram");
   
   IndicatorShortName("[Pine]MACD Histogram ("+IntegerToString(fastMA_length)+","+IntegerToString(slowMA_length)+","+IntegerToString(signal_length)+")");
   
   ArraySetAsSeries(ExtHistBuffer, true);
   ArraySetAsSeries(ExtHistBufferUp, true);
   ArraySetAsSeries(ExtHistBufferDn, true);
   ArraySetAsSeries(macdBuffer, true);
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {   
   for (int i = 0; i < rates_total; i++)
      macdBuffer[i] = iMA(NULL, 0, fastMA_length, 0, MODE_EMA, PRICE_CLOSE, i) - iMA(NULL, 0, slowMA_length, 0, MODE_EMA, PRICE_CLOSE, i);
      
   for (int i = 0; i < rates_total; i++) {
      double hist = macdBuffer[i] - iMAOnArray(macdBuffer, 0, signal_length, 0, MODE_EMA, i);
      ExtHistBuffer[i] = hist;
      if (hist > 0) {
         ExtHistBufferUp[i] = hist;
         ExtHistBufferDn[i] = 0.0f;
      } else {
         ExtHistBufferUp[i] = 0.0f;
         ExtHistBufferDn[i] = hist;
      }      
   }
      
   return(rates_total);
}