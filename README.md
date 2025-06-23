# MetaTrader-PolygonEAs-Storage
This repository is to save my works of EA. I will distribute EAs implemented in my own way, from simple trading strategy steps to application steps. And I will briefly explain what strategy each EA was implemented based on, what logic it was implemented with, and what purpose it was implemented with.

The version update status of each EA is listed in descending order starting from the latest version.
The EA operating platform is MT4 (Meta Trader 4), and most EAs are implemented in MQL4 (Meta Quotes Language 4). In the future, we will switch to EAs with the same logic to run on MT5, and we will slowly prepare and distribute two EAs for both versions. 
Some EAs don't deploy ex and mql files for commercial purposes. If you would like to run it directly in your environment by reading the description of the EA, please prepare copy trading and subscription through the link below.

📌 We are not responsible for any loss that may arise from applying the EAs included herein to your account.

### 3. Zone-Recovery (filename: HegdeStrategy.mq4)
Used indicators: Freely developed or EMA<br>
Property: Risk, Distance (pip), R2R <br>
Recommended Symbol: GBPUSD, USDJPY, XAUUSD <br>
Max Drawdown: 12.57% in XAUUSD <br>
<p>
    <img src="https://github.com/user-attachments/assets/67e5ff60-35d6-4c47-91f9-208d298ae87c", width="400" height="200">
    <img src="https://github.com/user-attachments/assets/6589a8ab-610c-496f-bd59-ee32fb2bac5d", width="400" height="200">
</p>

**Reference**: https://youtu.be/NGBPq_CSha8?si=KJIkaGI3BpyYyzi4 <br>

#### Release note
- 2025-02-11: Released first

### 2. OsMSR-Averaging
Used indicators: OsMA or [Pine]MACD Histogram, RSI, Stochastic, EMA <br>
Property: Martingale, Average price(Take profit-%), Distance of grid <br>
Recommended symbol: EURUSD, GBPUSD, USDCAD, XAUUSD, USDJPY <br>
Max Drawdown: 42.95% in EURUSD <br>
<p>
    <img src="https://github.com/user-attachments/assets/38a1c823-0894-4dd1-ac2a-fedfe9de0bd3" width="400" height="200">
    <img src="https://github.com/user-attachments/assets/7953c344-f115-4bc9-a4b5-ef1cb97210c8" width="400" height="200">
</p>
Description: Grid strategy, also known as averaging, is a technique that has been used in financial market for a long time. It aims to adjust the average price by placing buy and sell orders at regular intervals using price volatility, thereby profiting from the natural flucuations of the market. The basic principle of grid trading is to generate profit by repeatly executing buy and sell orders at pre-set price intervals when the market flucuatate within a certain range. This approache focuses on price volatility rather than directional predictions and can be particularly effective in sideways or volatile markets. That's why GBPUSD and XAUUSD, which are among the most volatile major currency pairs, are included in the Recommended symbol.

#### Release note
- 2025-02-11: Refactoring
- 2025-02-06: Fixed errors of operator
- 2025-02-05: Released first

### 1. OsMSR-SimpleTrade
Used indicators: OsMA or [Pine]MACD Histogram, RSI, Stochastic, EMA <br>
Property: Martingale, Take profit(TP) & Stop loss(SL) value settings, input settings each indicators <br>
Recommended symbol: EURUSD, USDCAD, NZDUSD, USDJPY <br>
Maximal Drawdown: 33.14% in EURUSD <br>
<p>
    <img src="https://github.com/user-attachments/assets/3b7a43a2-318c-4070-9962-91f39346cc4e" width="400" height="175">
    <img src="https://github.com/user-attachments/assets/2df9e1f1-d73a-422e-b2a5-73ae096898a4" width="400" height="175">
</p>
Description: OsMSR-SimpleTrade make an entry signal using each signal of indicators and open and close the order through the signal. The user can set values both TP and SL in the system trading property. And this is one of the trading strategies that has a risk ratio for each open position, not a grid strategy. A new position can be opened only when the open position is closed. Therefore, it is important to set the risk ratio appropriately according to the volatility range of each Symbol. While it is common to include GBPUSD as a recommended symbol, I personally don't think GBPUSD is suitable for users looking to leverage martingale properties in their trading due to its volatility range. <br>

#### Release note
- 2025-02-11: Refactoring
- 2025-02-04: Converted 'class' to 'struct' due to some memory issues
- 2025-01-31: Released first

### Custom Indicators
#### [Pine]MACD Histogram
This indicator is same as Oscillator MACD (OsMA) but has distinguishable colors standard by zero line. If the value of this indicator exceeds zero, the color becomes red, and if it is less than zero, the color becomes lime green.

#### Release note
- 2025-06-23: Memory Optimization

### Link for Subscription
preparing..

