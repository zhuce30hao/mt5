//+------------------------------------------------------------------+
//|                                                         list.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <hiiboy\drawtl.mqh>

CTrade trade;
CPositionInfo  m_position;                   // trade position object
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
int            prev_total;          // Количество позиций на прошлой проверке
double most_profit_point;
struct SDatas
  {
   CArrayLong        list_tickets;  // список тикетоа
   double            total_volume;  // Общий объём
   double            openprice;
   double            sl;
   double            tp;
   datetime          opentime;
   double            max_point;
   double            volume;//最近单子的手数
  };
struct SDataPositions
  {
   SDatas            Buy;           // Данные позиций Buy
   SDatas            Sell;          // Данные позиций Sell
  }
Data;
struct BuyInfo
{
   double point1,point2,point3;
   datetime point1t,point2t,point3t;
   string down_trend_name;
}
buyInfo;
TL tl;
TL_Points tlp;
ENUM_TIMEFRAMES period = PERIOD_CURRENT;
int handle;
double vol = 0.2;
bool break_down = false;

int OnInit()
  {
 //handle = iCustom(_Symbol,0,"Examples\\Fractals");
 //ChartIndicatorAdd(0,0,handle);  
 return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   
   double nowp = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(Data.Buy.volume == vol)
   {
      ulong ticket = Data.Buy.list_tickets.At(0);
      if(PositionSelectByTicket(ticket))
      {
         double openprice = Data.Buy.openprice;
         double max_point = Data.Buy.max_point;
         max_point = (nowp - openprice > max_point)?(nowp - openprice):max_point;
         Data.Buy.max_point = max_point;
         if(max_point > 300*_Point && openprice - m_position.StopLoss() > 30*_Point) 
         {
            trade.PositionModify(ticket,openprice+30*_Point,0);
            Data.Buy.sl = openprice+30*_Point;
         }
         //if(nowp - openprice > openprice - m_position.StopLoss() && Data.Buy.total_volume == vol) trade.PositionClosePartial(ticket,vol/2);
      }

   }else  Data.Buy.max_point = 0.0;
   
   if(Data.Sell.list_tickets.Total() > 0)
   {
      ulong ticket = Data.Sell.list_tickets.At(0);
      if(PositionSelectByTicket(ticket))
      {
         double openprice = Data.Sell.openprice;
         double max_point = Data.Sell.max_point;
         max_point = (openprice - nowp > max_point)?(openprice - nowp):max_point;
         Data.Sell.max_point = max_point;
         if(max_point > 300*_Point && m_position.StopLoss() - openprice > 30*_Point)
         {
            trade.PositionModify(ticket,openprice-30*_Point,m_position.TakeProfit());
            Data.Sell.sl = openprice-30*_Point;
         } 
         //if(nowp - openprice > openprice - m_position.StopLoss() && Data.Buy.total_volume == vol) trade.PositionClosePartial(ticket,vol/2);
      }

   }else  Data.Sell.max_point = 0.0;
   
   static int   prev_total;          // Количество позиций на прошлой проверке
   static double prev_volumes_buy;
   static double prev_volumes_sell;
   int positions_total=PositionsTotal();
   double now_volumes_buy = sum_vols(POSITION_TYPE_BUY);
   double now_volumes_sell = sum_vols(POSITION_TYPE_SELL);
   if(prev_total!=positions_total  || prev_volumes_buy != now_volumes_buy || prev_volumes_sell != now_volumes_sell)
   {
      if(FillingListTickets(positions_total))
      {
         prev_total=positions_total;
         if(prev_volumes_buy != now_volumes_buy) prev_volumes_buy = now_volumes_buy;
         if(prev_volumes_sell != now_volumes_sell) prev_volumes_sell = now_volumes_sell;
      }else return;
   }

   zig_data  Z;
   tl.cac_zig(period,Z);
   datetime t1 = tl.getTime(period,Z.pos1);
   datetime t2 = tl.getTime(period,Z.pos2);
   double z1 = Z.zig1;
   double z2 = Z.zig2;
   double sl = (MathAbs(z1 - z2) > 300*_Point)?MathAbs(z1 - z2):300*_Point;
   double sl_buy = nowp-sl;
   double sl_sell = nowp+sl;

   tl.draw_tl(tlp);
   

//   if(Data.Buy.max_point > 1500*_Point)
//   {
//      
//      double nowp = SymbolInfoDouble(_Symbol,SYMBOL_BID);
//      if(Data.Buy.volume == vol) close_half(POSITION_TYPE_BUY);
//      Data.Buy.max_point = 0;
//   }

   
   //if(ObjectFind(0,"po_up") < 0)
   //{
      for(int i = 0;i<tlp.up.Total() -1;i++)
      { 
         if(tl.isBreak(tlp,i,"up"))
         {
              if(ObjectFind(0,"po_up") < 0) ObjectCreate(0,"po_up",OBJ_ARROW_UP,0,TimeCurrent(),nowp);
              datetime t1 = tl.getTime(PERIOD_M1,tlp.up[i]+1);
              datetime t2 = ObjectGetInteger(0,"po_up",OBJPROP_CREATETIME,0);
              if(t1 > t2) ObjectDelete(0,"po_up");
//            buyInfo.point1t = tl.getTime(PERIOD_M1,tlp.up[i]+1);
//            buyInfo.point2t = tl.getTime(PERIOD_M1,tlp.up[i+1]+1);
//            buyInfo.point1 = tl.getLow(PERIOD_M1,tlp.up[i]+1);
//            buyInfo.point2 = tl.getLow(PERIOD_M1,tlp.up[i+1]+1);

//            //if(Data.Sell.total_volume == vol) close_half(POSITION_TYPE_SELL);
//            ObjectCreate(0,"po_up",OBJ_ARROW_UP,0,TimeCurrent(),nowp);
//
//            ObjectCreate(0,"point1",OBJ_ARROW_THUMB_UP,0,buyInfo.point1t,buyInfo.point1);
//            ObjectCreate(0,"point2",OBJ_ARROW_THUMB_UP,0,buyInfo.point2t,buyInfo.point2);
//            ObjectDelete(0,"po_down");  
//            ObjectDelete(0,"po_down_back");   
//            init_buy_info();   
            break;            
         }      
      }
    //}else  break_back("up");//没有突破的时候初始化突破的记号
    //if(Data.Buy.volume == vol)
    //{
      for(int i = 0;i<tlp.down.Total() -1;i++)
      {
        if(tl.isBreak(tlp,i,"down"))
         {
           if(ObjectFind(0,"po_down") < 0) ObjectCreate(0,"po_down",OBJ_ARROW_DOWN,0,TimeCurrent(),nowp);
           datetime t1 = tl.getTime(PERIOD_M1,tlp.down[i]+1);
           datetime t2 = ObjectGetInteger(0,"po_down",OBJPROP_CREATETIME,0);
           if(t1 > t2) ObjectDelete(0,"po_down");
         
            //if(Data.Sell.volume < 2*vol && Data.Buy.sl < Data.Buy.openprice) trade.Sell(2*vol,NULL,0,sl_sell,0,"easell"); //Data.Buy.sl+30*_Point       
            break;            
        }
      }  
    //}
    
     if(Data.Buy.total_volume == 0 || Data.Buy.volume == vol/2) 
     {
         if(ObjectFind(0,"po_up") >= 0  && tlp.up_wth[0] < 300*_Point)
         {
            datetime t2 = ObjectGetInteger(0,"po_up",OBJPROP_CREATETIME,0);
            if(TimeCurrent() - t2 < 5*60)
            {
               bool res = trade.Buy(vol,NULL,0,sl_buy,0,"eabuy");
               if(res) Data.Buy.max_point = 0;
            }

         }
     }
    
    if(Data.Sell.volume == 2*vol)
    {
      if(nowp < Data.Buy.sl+30*_Point)
      {
         ulong ticket = Data.Sell.list_tickets.At(0);
         if(PositionSelectByTicket(ticket))
         {
           bool res =  trade.PositionModify(ticket,Data.Sell.openprice-20*_Point,0);
           if(res)
           {
            close_half(POSITION_TYPE_SELL);
            Data.Sell.max_point = 0;
           } 
         }
      }
    }

  }
//+------------------------------------------------------------------+


void break_back(string dir)
{
   double nowp = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double value;
   datetime t1 = iTime(_Symbol,PERIOD_M1,0) - buyInfo.point1t;
   datetime t2 = iTime(_Symbol,PERIOD_M1,0) - buyInfo.point2t;
   double h1 = buyInfo.point1;
   double h2 = buyInfo.point2;
   if(t2 - t1 <=0) return;
   else value = (h1*t2 - h2*t1)/(t2 - t1);
   if(dir == "down" && nowp > value)
   {
      if(Data.Sell.total_volume > vol/2)
      {

         ulong ticket = Data.Sell.list_tickets.At(0);
         if(PositionSelectByTicket(ticket))
         {
            //if(TimeCurrent() - Data.Sell.opentime > 60*60)  trade.PositionClosePartial(ticket,vol/2);
         }

         //close_half(POSITION_TYPE_SELL);
      } 
      ObjectCreate(0,"po_down_back",OBJ_ARROW_DOWN,0,TimeCurrent(),nowp);
   } 
   if(dir == "up" && nowp < value)
   {
      if(Data.Buy.total_volume > vol/2)
      {
         ulong ticket = Data.Buy.list_tickets.At(0);
         if(PositionSelectByTicket(ticket))
         {
            //if(TimeCurrent() - Data.Buy.opentime > 60*60)  trade.PositionClosePartial(ticket,vol/2);
         }
      }
      // close_half(POSITION_TYPE_BUY);
      ObjectCreate(0,"po_up_back",OBJ_ARROW_UP,0,TimeCurrent(),nowp);
   } 

}


void close_buy_break_bigtl(int i)
{
 double nowp = SymbolInfoDouble(_Symbol,SYMBOL_BID);
 double value = ObjectGetValueByTime(0,"up"+i,TimeCurrent(),0);
 
 if(nowp < value)
 {
   close_half(POSITION_TYPE_BUY);
   //Print("i: ",i," value: ",value);
   //ExpertRemove();
 } 
 
}

void close_half(ENUM_POSITION_TYPE type)
{
   if(type == POSITION_TYPE_BUY)
   {
      if(Data.Buy.list_tickets.Total() > 0)
      {
         ulong ticket = Data.Buy.list_tickets.At(0);
         if(PositionSelectByTicket(ticket))
         {
            //double lots = formatlots(m_position.Volume()/2);
            bool res = trade.PositionClosePartial(ticket,m_position.Volume()/2);
            if(res) Data.Buy.volume = m_position.Volume();
         }
   
      }
   }
   if(type == POSITION_TYPE_SELL)
   {
      if(Data.Sell.list_tickets.Total() > 0)
      {
         ulong ticket = Data.Sell.list_tickets.At(0);
         if(PositionSelectByTicket(ticket))
         { 
            //double lots = formatlots(m_position.Volume()/2);
            bool res = trade.PositionClosePartial(ticket,m_position.Volume()/2);
            if(res) Data.Sell.volume =  m_position.Volume();
         }
   
      }
   }
}


void init_buy_info()
{
   buyInfo.point1 = 0;
   buyInfo.point1t = 0;
   buyInfo.point2 = 0;
   buyInfo.point2t = 0;
   ObjectDelete(0,"point1");
   ObjectDelete(0,"point2");
}

void close_buy()
{
     int position_num=PositionsTotal();
     ulong position_ticket;
     int position_i=position_num;
     while(position_i>0)
     {
        position_ticket=PositionGetTicket(position_i-1);//这是仓位的ticket
        m_position.SelectByTicket(position_ticket);
        if((m_position.Symbol()==_Symbol)&&(m_position.PositionType()==POSITION_TYPE_BUY))
        {
           trade.PositionClose(position_ticket);
        }
        position_i--;
     }
}

void close_sell()
{
     int position_num=PositionsTotal();
     ulong position_ticket;
     int position_i=position_num;
     while(position_i>0)
     {
        position_ticket=PositionGetTicket(position_i-1);//这是仓位的ticket
        m_position.SelectByTicket(position_ticket);
        if((m_position.Symbol()==_Symbol)&&(m_position.PositionType()==POSITION_TYPE_SELL))
        {
           trade.PositionClose(position_ticket);
        }
        position_i--;
     }
}

 bool FillingListTickets(const int positions_total)
  {
   Data.Buy.list_tickets.Clear();
   Data.Sell.list_tickets.Clear();
   Data.Buy.total_volume=0;
   Data.Sell.total_volume=0;
   Data.Buy.openprice  = 0;
   Data.Buy.opentime = 0;
   Data.Buy.sl = 0;
   Data.Buy.tp = 0;
   Data.Buy.volume = 0;
   Data.Sell.volume = 0;
   int total=positions_total;
   for(int i=total-1; i>WRONG_VALUE; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      //if(PositionGetInteger(POSITION_MAGIC)!=InpMagic)   continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol)       continue;
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double volume=PositionGetDouble(POSITION_VOLUME);
      if(type==POSITION_TYPE_BUY)
        {
         Data.Buy.list_tickets.Add(ticket);
         Data.Buy.total_volume+=volume;
        }
      if(type==POSITION_TYPE_SELL)
        {
         Data.Sell.list_tickets.Add(ticket);
         Data.Sell.total_volume+=volume;
        }
     }
     ulong ticket_buy = Data.Buy.list_tickets.At(0);
     ulong ticket_sell = Data.Sell.list_tickets.At(0);
     if(PositionSelectByTicket(ticket_buy))
     {
         Data.Buy.openprice  = m_position.PriceOpen();
         Data.Buy.opentime = m_position.Time();
         Data.Buy.sl = m_position.StopLoss();
         Data.Buy.tp = m_position.TakeProfit();
         Data.Buy.volume = m_position.Volume();
     }
     if(PositionSelectByTicket(ticket_sell))
     {
         Data.Sell.openprice  = m_position.PriceOpen();
         Data.Sell.opentime = m_position.Time();
         Data.Sell.sl = m_position.StopLoss();
         Data.Sell.tp = m_position.TakeProfit();
         Data.Sell.volume = m_position.Volume();
     }
   return true;
  }
  
  double sum_vols(ENUM_POSITION_TYPE order_type)
{
     int position_num=PositionsTotal();
     ulong position_ticket;
     int position_i=position_num;
     double volumes=0;
     while(position_i>0)
     {
        position_ticket=PositionGetTicket(position_i-1);//这是仓位的ticket
        m_position.SelectByTicket(position_ticket);
        if((m_position.Symbol()==_Symbol)&&(m_position.PositionType()== order_type))
        {
            volumes+= m_position.Volume();
        }
        position_i--;
     }
      return volumes;
}

double formatlots(double lots)
   {
     double a=0;
     double minilots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
     double steplots=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
     if(lots<minilots) return(0);
     else
      {
        double a1=MathFloor(lots/minilots)*minilots;
        a=a1+MathFloor((lots-a1)/steplots)*steplots;
      }
     return(a);
   }