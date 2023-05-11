//+------------------------------------------------------------------+
//|                                                       Projectj50 |
//|                   Copyright 2023, Your Name                        |
//|                             https://www.yourwebsite.com            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// define input parameters
extern double lotsize = 0.5;
extern int stoploss = 50;
extern int takeprofit = 100;
extern double sar_step = 0.02;
extern double sar_maximum = 0.2;
extern double adx_threshold = 25;

// define variables
int buy_order;
int sell_order;

void OnTick()
{
    double ema8 = iMA(NULL, 0, 8, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema14 = iMA(NULL, 0, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema21 = iMA(NULL, 0, 21, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema100 = iMA(NULL, 0, 100, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema200 = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
    double adx = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, 1);
    double di_minus = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, 1);
    double di_plus = iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, 1);
    double sar = iSAR(NULL, 0, sar_step, sar_maximum, 1);
    
    double   heikinOpen  =  iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 4, 1);
    double   heikinHigh  =  iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 5, 1);
    double   heikinLow   =  iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 6, 1);
    double   heikinClose =  iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 7, 1);
    
    double   heikinHighSL = iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 5, 3);
    double   heikinLowSL   =  iCustom(Symbol(), Period(), "\\Market\\Heikin Ashi Premium", false, 6, 3);
    
    // GETTING LAST FRACTAL UP
    double fractal_up = 0; 
    
    int bars = iBars(NULL, 0);
    
    int idx = 0;
    
    while (fractal_up == 0) {
         
         double fractal_up_temp = iFractals(NULL, 0, MODE_UPPER, idx);
         idx++;
         if (fractal_up_temp != 0) {
               fractal_up = fractal_up_temp;
               idx = 0;
         }
    }
    
    // GETTING LAST FRACTAL DOWN
    double fractal_down = 0;
    
    
    
    while (fractal_down == 0) {
    
         double fractal_down_temp = iFractals(NULL, 0, MODE_LOWER, idx);
         idx++;
         if (fractal_down_temp != 0) {
               fractal_down = fractal_down_temp;
         }
    }
    
   

    //---
    Alert("Fractal Up Value: " + fractal_up + "\n" + "Fractal Down Value: " + fractal_down + "\n" + "ema 200 " + ema200 + "\n" + "ema 100 " + ema100 + "\n" + "ema 50 " + ema50 + "\n" + "ema 21 " + ema21 + "\n" + "ema 14 " + ema14 + "\n" + "ema 8 " + ema8 + "\n" + "adx " + adx + "\n" + "di munis " + di_minus + "\n" + "di plus " + di_plus + "\n" + "sar " + sar + "\n" + "Heiken open " + heikinOpen + "\n" + "Heiken close " + heikinClose + "\n" + "Heiken low " + heikinLow + "\n" + "Heiken high " + heikinHigh + "\n" + "Heiken High 2 behind " + heikinHighSL + "\n" + "Heiken Low 2 behind " + heikinLowSL);

    // check for buy conditions
    if (adx > adx_threshold && di_minus < adx_threshold && heikinOpen > sar && heikinClose > heikinOpen && heikinClose > fractal_up)
    {
        // check if there is no existing buy order
        if (buy_order == 0)
        {
            // open buy order
      
            buy_order = OrderSend(Symbol(), OP_BUY, lotsize, Ask, 0, heikinLowSL, 0, "Buy", 0, 0, Blue);
        } else {
            OrderSelect(buy_order, SELECT_BY_TICKET);
            Alert(OrderStopLoss());
            OrderModify(buy_order, Ask, heikinLowSL, 0, Blue);
        }
    }
    else
    {
        // check if there is an existing buy order
        if (buy_order != 0)
        {
            // close buy order
            OrderClose(buy_order, lotsize, Bid, 0, Green);
            buy_order = 0;
        }
    }

    // check for sell conditions
    if (adx > adx_threshold && di_plus < adx_threshold && heikinClose < sar && heikinClose < heikinOpen && heikinClose < fractal_down)
    {
        // check if there is no existing sell order
        if (sell_order == 0)
        {
            // open sell order
            sell_order = OrderSend(Symbol(), OP_SELL, lotsize, Bid, 0, heikinHighSL, 0, "Sell", 0, 0, Red);
        } else {
            OrderSelect(sell_order, SELECT_BY_TICKET);
            Alert(OrderStopLoss());
            OrderModify(sell_order, Ask, heikinHighSL, 0, Red);
        }
    }
    else
    {
        // check if there is an existing sell order
        if (sell_order != 0)
        {
            // close buy order
            OrderClose(sell_order, lotsize, Bid, 0, Yellow);
            sell_order = 0;
        }
    }
    //buy_order = OrderSend(Symbol(), OP_BUY, lotsize, Ask, 0, heikinLowSL, 0, "Buy", 0, 0, Blue);
}
