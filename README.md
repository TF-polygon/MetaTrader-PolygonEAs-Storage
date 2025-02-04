# MetaTrader-PolygonEAs-Storage
This repository is to save my works of EA. I will distribute EAs implemented in my own way, from simple trading strategy steps to application steps. And I will briefly explain what strategy each EA was implemented based on, what logic it was implemented with, and what purpose it was implemented with.

The version update status of each EA is listed in descending order starting from the latest version.
The EA operating platform is MT4 (Meta Trader 4), and most EAs are implemented in MQL4 (Meta Quotes Language 4). In the future, we will switch to EAs with the same logic to run on MT5, and we will slowly prepare and distribute two EAs for both versions. 
Some EAs don't deploy ex and mql files for commercial purposes. If you would like to run it directly in your environment by reading the description of the EA, please prepare copy trading and subscription through the link below.

### 1. OsMSR-SimpleTrade
Used indicators: OsMA or [Pine]MACD Histogram, RSI, Stochastic, EMA <br>
Property: Martingale, Take profit(TP) & Stop loss(SL) value settings, input settings each indicators <br>
Recommended symbol: EURUSD, USDCAD, NZDUSD, USDJPY <br>
Maximal Drawdown: ff% in EURUSD <br>
<p>
    <img src="https://github.com/user-attachments/assets/3b7a43a2-318c-4070-9962-91f39346cc4e" width="400" height="200">
    <img src="https://github.com/user-attachments/assets/1e8d6c4c-caf5-479d-ae24-f28132a03592" width="400" height="200">
</p>
Description: OsMSR-SimpleTrade make an entry signal using each signal of indicators and open and close the order through the signal. The user can set values both TP and SL in the system trading property. And this is one of the trading strategies that has a risk ratio for each open position, not a grid strategy. A new position can be opened only when the open position is closed. Therefore, it is important to set the risk ratio appropriately according to the volatility range of each Symbol. While it is common to include GBPUSD as a recommended symbol, I personally don't think GBPUSD is suitable for users looking to leverage martingale properties in their trading due to its volatility range. <br>

#### Release note
- 2025-01-31: Released first

### Link for Subscription
preparing..

