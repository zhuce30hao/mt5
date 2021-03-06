#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"


input bool enable_A1=true;
input bool enable_A2=true;
input bool enable_B1=true;
input bool enable_B2=true;
input bool enable_B3=true;
input bool enable_B0=true;

input bool huangjin=false;
input bool yuanyou=false;
int init = 0;
int FirstBar=1;
int DeltaBar=12;
bool InsLine=true;
int DimMaxPos=150;
color  clrSup= 0xFF0000; 
color  clrRes= 0x0000FF; 


double vol_now;

color     ColorTL_U   =  clrBlue,
          ColorTL_D   =  clrRed,
          ColorCH_U   =  clrBlue,
          ColorCH_D   =  clrRed,
          ColorTR_U   =  clrGreen,
          ColorTR_D   =  clrViolet;
string    NameTL_U    =  "Up_", 
          NameTL_D    =  "Dn_",
          NameCH_U    =  "UpZ_", 
          NameCH_D    =  "DnZ_",
          NameTR_U    =  "UpTr_", 
          NameTR_D    =  "DnTr_";
int       last_bar    =  0,
          cntLine     =  1,       
          Line_U[100][2],      
          Line_D[100][2],     
          LineI_U[100][2],     
          LineI_D[100][2],      
          LineShow_U[100][4],   
          LineShow_D[100][4];
          //1 0记录位置，1在前，2记录bar2就是虚线通道连的点，3记录这个通道是否可用（刨除那种在中间不囊括后面K线的通道),0代表不可用
          
int       tlines_U=0,
          tlines_D=0;
string    zig="zig";
double deviation=5*_Point;
double    d_point=_Point;

double temp_High,temp_Low;
int HighP[200],LowP[200];
int Hnum_M1=0,Lnum_M1=0;
int LineHP_M1_1[200],LineHP_M1_2[200],LineLP_M1_1[200],LineLP_M1_2[200];

int Hnum_M5=0,Lnum_M5=0;
int LineHP_M5_1[100],LineHP_M5_2[100],LineLP_M5_1[100],LineLP_M5_2[100];

int Hnum_M15=0,Lnum_M15=0;
int LineHP_M15_1[50],LineHP_M15_2[50],LineLP_M15_1[50],LineLP_M15_2[50];

int Hnum_H1=0,Lnum_H1=0;
int LineHP_H1_1[50],LineHP_H1_2[50],LineLP_H1_1[50],LineLP_H1_2[50];

int    barsnum_M1;
int    barsnum_M5;
int    barsnum_M15;
int    barsnum_M30;
int    barsnum_H1;
int    barsnum_H4;
int    barsnum_D1;

double High_M1[1000000];
double Low_M1[1000000];
datetime Time_M1[1000000];

int ZigZagBuffer_num_M1;

double  ZigZagBuffer_M1[1000000];
double  HighMapBuffer_M1[1000000];
double  LowMapBuffer_M1[1000000];
int     ZigZagBuffer_pos_M1[100];

double High_M5[500000];
double Low_M5[500000];
double Open_M5[500000];
double Close_M5[500000];
datetime Time_M5[500000];

int ZigZagBuffer_num_M5;

double  ZigZagBuffer_M5[500000];
double  HighMapBuffer_M5[500000];
double  LowMapBuffer_M5[500000];
int     ZigZagBuffer_pos_M5[100];

double FRAH_M5[500000];
double FRAL_M5[500000];
int    FRAH_M5_pos[200];
int    FRAL_M5_pos[200];

double High_M15[200000];
double Low_M15[200000];
datetime Time_M15[200000];

int ZigZagBuffer_num_M15;

double  ZigZagBuffer_M15[200000];
double  HighMapBuffer_M15[200000];
double  LowMapBuffer_M15[200000];
int     ZigZagBuffer_pos_M15[100];

double High_M30[150000];
double Low_M30[150000];
datetime Time_M30[150000];

int ZigZagBuffer_num_M30;

double  ZigZagBuffer_M30[150000];
double  HighMapBuffer_M30[150000];
double  LowMapBuffer_M30[150000];
int     ZigZagBuffer_pos_M30[100];

double High_H1[100000];
double Low_H1[100000];
datetime Time_H1[100000];

int ZigZagBuffer_num_H1;

double  ZigZagBuffer_H1[100000];
double  HighMapBuffer_H1[100000];
double  LowMapBuffer_H1[100000];
int     ZigZagBuffer_pos_H1[100];

double High_H4[50000];
double Low_H4[50000];
datetime Time_H4[50000];

int ZigZagBuffer_num_H4;

double  ZigZagBuffer_H4[50000];
double  HighMapBuffer_H4[50000];
double  LowMapBuffer_H4[50000];
int     ZigZagBuffer_pos_H4[100];


double High_D1[10000];
double Low_D1[10000];
datetime Time_D1[10000];

int ZigZagBuffer_num_D1;

double  ZigZagBuffer_D1[10000];
double  HighMapBuffer_D1[10000];
double  LowMapBuffer_D1[10000];
int     ZigZagBuffer_pos_D1[100];


double UpFractal[500000];
double DnFractal[500000];


void copy()
{
     //datetime begin = TimeCurrent() - 60*60*24*60;
     barsnum_M1=Bars(_Symbol,PERIOD_M1);
     barsnum_M5=Bars(_Symbol,PERIOD_M5);
     barsnum_M15=Bars(_Symbol,PERIOD_M15);
     barsnum_M30=Bars(_Symbol,PERIOD_M30);
     barsnum_H1=Bars(_Symbol,PERIOD_H1);
     barsnum_H4=Bars(_Symbol,PERIOD_H4);
     barsnum_D1=Bars(_Symbol,PERIOD_D1);
     
     barsnum_M1= (barsnum_M1==0 || barsnum_M1 > 100000)?100000:barsnum_M1;
     barsnum_M5=(barsnum_M5==0|| barsnum_M5 > 100000)?100000:barsnum_M5;
     barsnum_M15=(barsnum_M15==0 || barsnum_M15 > 100000)?100000:barsnum_M15;
     barsnum_M30=(barsnum_M30==0 || barsnum_M30 > 100000)?100000:barsnum_M30;
     barsnum_H1=(barsnum_H1==0 || barsnum_H1 > 100000)?100000:barsnum_H1;
     barsnum_H4=(barsnum_H4==0 || barsnum_H4 > 50000)?50000:barsnum_H4;
     barsnum_D1=(barsnum_D1==0 || barsnum_D1 > 10000)?10000:barsnum_D1;
     //Print("多单symbol: ",_Symbol,"H4: ",barsnum_H4," D1 ",barsnum_D1," h1: ",barsnum_H1);
     
     CopyHigh(_Symbol,PERIOD_M1,0,barsnum_M1,High_M1);
     CopyLow(_Symbol,PERIOD_M1,0,barsnum_M1,Low_M1);
     CopyTime(_Symbol,PERIOD_M1,0,barsnum_M1,Time_M1);
     
     CopyHigh(_Symbol,PERIOD_M5,0,barsnum_M5,High_M5);
     CopyLow(_Symbol,PERIOD_M5,0,barsnum_M5,Low_M5);
     CopyTime(_Symbol,PERIOD_M5,0,barsnum_M5,Time_M5);
     CopyOpen(_Symbol,PERIOD_M5,0,barsnum_M5,Open_M5);
     CopyClose(_Symbol,PERIOD_M5,0,barsnum_M5,Close_M5);
     
     CopyHigh(_Symbol,PERIOD_M15,0,barsnum_M15,High_M15);
     CopyLow(_Symbol,PERIOD_M15,0,barsnum_M15,Low_M15);
     CopyTime(_Symbol,PERIOD_M15,0,barsnum_M15,Time_M15);
     
     CopyHigh(_Symbol,PERIOD_M30,0,barsnum_M30,High_M30);
     CopyLow(_Symbol,PERIOD_M30,0,barsnum_M30,Low_M30);
     CopyTime(_Symbol,PERIOD_M30,0,barsnum_M30,Time_M30);
     
     CopyHigh(_Symbol,PERIOD_H1,0,barsnum_H1,High_H1);
     CopyLow(_Symbol,PERIOD_H1,0,barsnum_H1,Low_H1);
     CopyTime(_Symbol,PERIOD_H1,0,barsnum_H1,Time_H1);
     
     CopyHigh(_Symbol,PERIOD_H4,0,barsnum_H4,High_H4);
     CopyLow(_Symbol,PERIOD_H4,0,barsnum_H4,Low_H4);
     CopyTime(_Symbol,PERIOD_H4,0,barsnum_H4,Time_H4);
     
     CopyHigh(_Symbol,PERIOD_D1,0,barsnum_D1,High_D1);
     CopyLow(_Symbol,PERIOD_D1,0,barsnum_D1,Low_D1);
     CopyTime(_Symbol,PERIOD_D1,0,barsnum_D1,Time_D1);
}

void advance(double &High[],double &Low[],int barsnum)
{
     int i;
     
     if(barsnum-300 <=0)
     {
      Print("advance: ",barsnum);
      return;
     }
     for(i=barsnum-300;i<barsnum;i++)
     {
         if(High[i]>temp_High) HighP[0]=i;
         else New_HighPoint();
         temp_High=High[i];
         if(Low[i]<temp_Low) LowP[0]=i;
         else New_LowPoint();
         temp_Low=Low[i];
     }
}

void trend(double &High[],double &Low[],datetime &Time[],
           int &LineHP_1[],int &LineHP_2[],
           int &LineLP_1[],int &LineLP_2[],
           int &Hnum,int &Lnum)
{
     int StartP_1,StartP_2;
     int P_1,P_2;
     int i;
     bool flag;
     int dis;
     double div,lineP;
     string sName;
     StartP_1=(3*DimMaxPos)/4;
     Hnum=0;
     ObjectsDeleteAll(0,0,OBJ_TREND);
     for(P_1=StartP_1;P_1>2;P_1--)
     {
         for(P_2=P_1-1;P_2>1;P_2--)
         {
             dis=HighP[P_2]-HighP[P_1];
             if(dis<=6)continue;
             div=High[HighP[P_2]]-High[HighP[P_1]];
             flag=true;
             StartP_2=(DimMaxPos+2*P_1)/3;
             for(i=StartP_2;i>1;i--)
             {
                 lineP=div*(HighP[i]-HighP[P_1])/dis+High[HighP[P_1]];
                 if(lineP<High[HighP[i]]){flag=false;break;}
             }
             if(flag)
             {
                if((HighP[P_1]!=LineHP_1[Hnum])||(HighP[P_2]!=LineHP_2[Hnum]))
                {
                   Hnum++;
                   LineHP_1[Hnum]=HighP[P_1];
                   LineHP_2[Hnum]=HighP[P_2];
                }
                /*sName="R"+IntegerToString(P_1,0,' ')+IntegerToString(P_2,0,' ');
                ObjectCreate(0,sName,OBJ_TREND,0,Time[HighP[P_1]],High[HighP[P_1]],Time[HighP[P_2]],High[HighP[P_2]]);
                ObjectSetInteger(0,sName,OBJPROP_RAY_RIGHT,true);
                ObjectSetInteger(0,sName,OBJPROP_COLOR,clrGreen);*/
             }
         }
     }
     Lnum=0;
     StartP_1=(3*DimMaxPos)/4;
     for(P_1=StartP_1;P_1>2;P_1--)
     {
         for(P_2=P_1-1;P_2>1;P_2--)
         {
             dis=LowP[P_2]-LowP[P_1];
             if(dis<10)continue;
             div=Low[LowP[P_2]]-Low[LowP[P_1]];
             flag=true;
             StartP_2=(DimMaxPos+2*P_1)/3;
             for(i=StartP_2;i>1;i--)
             {
                 lineP=div*(LowP[i]-LowP[P_1])/dis+Low[LowP[P_1]];
                 if(lineP>Low[LowP[i]]){flag=false;break;}
             }
             if(flag)
             {
                if((LowP[P_1]!=LineLP_1[Lnum])||(LowP[P_2]!=LineLP_2[Lnum]))
                {
                   Lnum++;
                   LineLP_1[Lnum]=LowP[P_1];
                   LineLP_2[Lnum]=LowP[P_2];
                }
                /*sName="R"+IntegerToString(P_1,0,' ')+IntegerToString(P_2,0,' ');
                ObjectCreate(0,sName,OBJ_TREND,0,Time[LowP[P_1]],Low[LowP[P_1]],Time[LowP[P_2]],Low[LowP[P_2]]);
                ObjectSetInteger(0,sName,OBJPROP_RAY_RIGHT,true);
                ObjectSetInteger(0,sName,OBJPROP_COLOR,clrPink);*/
             }
         }
     }
     
}

void New_HighPoint()
{
     int i;
     for(i=DimMaxPos;i>0;i--)
         HighP[i]=HighP[i-1];
}

void New_LowPoint()
{
     int i;
     for(i=DimMaxPos;i>0;i--)
         LowP[i]=LowP[i-1];
}

void Draw_TL()
{
     int i,j,
         MaxTL,Bar2;
     double Bar1_Value,
            Bar2_Value,
            Bar0_Value;
     //DeleteTrendLine( NameTL_U, 100);
     //DeleteTrendLine( NameTL_D, 100);
     //DeleteTrendLine( NameCH_U, 100);
     //DeleteTrendLine( NameCH_D, 100);
     //DeleteTrendLine( NameTR_U, 100);
     //DeleteTrendLine( NameTR_D, 100);
     int U_first=barsnum_M1-1,
         D_first=barsnum_M1-1;
     
     for(i=barsnum_M1-2;;i--)//蓝线起始尾部处理
     {
         if(Low_M1[i]>Low_M1[i-1])
         {
            U_first=i-1;
            break;
         }
     }
     /*for(i=U_first-1;;i--)
     {
         if(Low_M5[i]>Low_M5[i-1])
         {
            U_first=i-1;
            break;
         }
     }*/
     
     for(i=barsnum_M1-2;;i--)//红线起始尾部处理
     {
         if(High_M1[i]<High_M1[i-1])
         {
            D_first=i-1;
            break;
         }
     }
     /*
     for(i=D_first-1;;i--)//蓝线起始尾部处理
     {
         if(High_M5[i]<High_M5[i-1])
         {
            D_first=i-1;
            break;
         }
     }
     */
     Line_U[0][0]=U_first;
     Line_U[0][1]=FindPoint(Line_U[0][0],barsnum_M1-3000,1);
     Line_D[0][0]=D_first;
     Line_D[0][1]=FindPoint(Line_D[0][0],barsnum_M1-3000,-1);
     
     i=0;
     while((Line_U[i][1]<Line_U[i][0]))
     {
           i++;
           Line_U[i][0]=Line_U[i-1][1];
           Line_U[i][1]=FindPoint(Line_U[i][0],barsnum_M1-3000,1);
     }
     MaxTL=i-1;
     cntLine=0;
     j=0;
     int k;
     for(i=0;i<=MaxTL;i++)
     {
         if(Line_U[i][0]-Line_U[i][1]>=DeltaBar)
         {
            cntLine++;
            LineShow_U[j][0]=Line_U[i][0];
            LineShow_U[j][1]=Line_U[i][1];
            CreateLine(NameTL_U+cntLine,Time_M1[Line_U[i][1]],Low_M1[Line_U[i][1]],Time_M1[Line_U[i][0]],Low_M1[Line_U[i][0]],ColorTL_U,STYLE_SOLID);
            ObjectSetInteger(0,NameTL_U+cntLine,OBJPROP_RAY_RIGHT,true);
            Bar2=DrawLine(NameTL_U+cntLine,Line_U[i][1],Line_U[i][0],1);
            LineShow_U[j][2]=Bar2;
            Bar2_Value=ObjectGetValueByTime(0,NameTL_U+cntLine,Time_M1[Bar2],0);
            Bar0_Value=Low_M1[Line_U[i][0]]+(High_M1[Bar2]-Bar2_Value);
            Bar1_Value=Low_M1[Line_U[i][1]]+(High_M1[Bar2]-Bar2_Value);
            CreateLine(NameCH_U+cntLine,Time_M1[Line_U[i][1]],Bar1_Value,Time_M1[Line_U[i][0]],Bar0_Value,ColorCH_U,STYLE_DASH);
            //ObjectSetInteger(0,NameCH_U+cntLine,OBJPROP_RAY_RIGHT,true);
            for(k=Line_U[i][0]+1;k<barsnum_M1;k++)
            {
                Bar0_Value=ObjectGetValueByTime(0,NameTL_U+cntLine,Time_M1[k],0)+(High_M1[Bar2]-Bar2_Value);
                if(High_M1[k]>Bar0_Value)break;
            }
            if(k<barsnum_M1)LineShow_U[j][3]=0;
            else LineShow_U[j][3]=1;
            j++;
         }
     }
     tlines_U=cntLine;
     
     i=0;
     while((Line_D[i][1]<Line_D[i][0]))
     {
           i++;
           Line_D[i][0]=Line_D[i-1][1];
           Line_D[i][1]=FindPoint(Line_D[i][0],barsnum_M1-3000,-1);
     }
     MaxTL=i-1;
     cntLine=0;
     j=0;
     for(i=0;i<=MaxTL;i++)
     {
         if(Line_D[i][0]-Line_D[i][1]>=DeltaBar)
         {
            cntLine++;
            LineShow_D[j][0]=Line_D[i][0];
            LineShow_D[j][1]=Line_D[i][1];
            CreateLine(NameTL_D+cntLine,Time_M1[Line_D[i][1]],High_M1[Line_D[i][1]],Time_M1[Line_D[i][0]],High_M1[Line_D[i][0]],ColorTL_D,STYLE_SOLID);
            ObjectSetInteger(0,NameTL_D+cntLine,OBJPROP_RAY_RIGHT,true);
            Bar2=DrawLine(NameTL_D+cntLine,Line_D[i][1],Line_D[i][0],-1);
            LineShow_D[j][2]=Bar2;
            Bar2_Value=ObjectGetValueByTime(0,NameTL_D+cntLine,Time_M1[Bar2],0);
            Bar0_Value=High_M1[Line_D[i][0]]-(Bar2_Value-Low_M1[Bar2]);
            Bar1_Value=High_M1[Line_D[i][1]]-(Bar2_Value-Low_M1[Bar2]);
            CreateLine(NameCH_D+cntLine,Time_M1[Line_D[i][1]],Bar1_Value,Time_M1[Line_D[i][0]],Bar0_Value,ColorCH_D,STYLE_DASH);
            //ObjectSetInteger(0,NameCH_D+cntLine,OBJPROP_RAY_RIGHT,true);
            for(k=Line_D[i][0]+1;k<barsnum_M1;k++)
            {
                Bar0_Value=ObjectGetValueByTime(0,NameTL_D+cntLine,Time_M1[k],0)-(Bar2_Value-Low_M1[Bar2]);
                if(Low_M1[k]<Bar0_Value)break;
            }
            if(k<barsnum_M1)LineShow_D[j][3]=0;
            else LineShow_D[j][3]=1;
            j++;
         }
     }
     tlines_D=cntLine;
}

int DrawLine(string NameLine,int StartPoint,int FinPoint,int UpDown)
{
    int i,FinBar;
    double MaxValue=0,TekValue=0;
    FinBar=StartPoint;
    for(i=StartPoint;i<=FinPoint;i++)
    {
        if(UpDown==1)TekValue=High_M1[i]-ObjectGetValueByTime(0,NameLine,Time_M1[i],0);
        else TekValue=ObjectGetValueByTime(0,NameLine,Time_M1[i],0)-Low_M1[i];
        if(TekValue>MaxValue)
        {
           MaxValue=TekValue;
           FinBar=i;
        }
    }
    return(FinBar);
}

int FindPoint(int Bar_1,int Bar_Fin,int Trend)
{
    int Bar_2,
        i;
    double BarValue_1,
           BarValue_2,
           BarValue_i;
    Bar_2=Bar_1;
    for(i=Bar_1-1;i>Bar_Fin;i--)
    {
        if(Trend==1)
        {
           if(Low_M1[i]<Low_M1[Bar_1])
           {
              Bar_2=i;
              break;
           }
        }
        else
        {
            if(High_M1[i]>High_M1[Bar_1])
            {
               Bar_2=i;
               break;
            }
        }
    }
    if(Bar_2<Bar_1)
    {
       int MaxBar=Bar_2;
       double LineFirst;
       if(Trend==1)
       {
          LineFirst=(Low_M1[Bar_1]-Low_M1[Bar_2])/(Bar_1-Bar_2);
          for(i=MaxBar-1;i>0;i--)
          {
              if((Low_M1[Bar_1]-Low_M1[i])/(Bar_1-i)>LineFirst)
              {
                 Bar_2=i;
                 LineFirst=(Low_M1[Bar_1]-Low_M1[Bar_2])/(Bar_1-Bar_2);
              }
          }
       }
       else
       {
           LineFirst=(High_M1[Bar_2]-High_M1[Bar_1])/(Bar_1-Bar_2);
           for(i=MaxBar-1;i>0;i--)
           {
               if((High_M1[i]-High_M1[Bar_1])/(Bar_1-i)>LineFirst)
               {
                  Bar_2=i;
                  LineFirst=(High_M1[Bar_2]-High_M1[Bar_1])/(Bar_1-Bar_2);
               }
           }
       }
    }
    return(Bar_2);
}

bool CreateLine(string Name_Line,datetime X1,double Y1,datetime X2,double Y2,color Color_Line,int Style_Line)
{
     if(!ObjectCreate(0,Name_Line,OBJ_TREND,0,0,0,0,0))return(false);
     ObjectSetInteger(0,Name_Line,OBJPROP_COLOR,Color_Line);
     ObjectSetInteger(0,Name_Line,OBJPROP_STYLE,Style_Line);
     MoveLine(Name_Line,X1,Y1,X2,Y2);
     return(true);
}

void MoveLine(string NameLine,datetime X1,double Y1,datetime X2,double Y2)
{
     ObjectMove(0,NameLine,0,X1,Y1);
     ObjectMove(0,NameLine,1,X2,Y2);
     return;
}

//+------------------------------------------------------------------+
//|  寻找12根柱的最高点                                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[],int depth,int startPos)
{
    int index=startPos;
    if(startPos<0)
    {
       return 0;
    }
    int size=ArraySize(array);
    if(startPos-depth<0)depth=startPos;
    double max=array[startPos];
    int i;
    for(i=startPos;i>startPos-depth;i--)
    {
        if(array[i]>max)
        {
           index=i;
           max=array[i];
        }
    }
    return(index);
}

//+------------------------------------------------------------------+
//|  寻找12根柱的最低点                                              |
//+------------------------------------------------------------------+
int iLowest(const double &array[],int depth,int startPos)
{
    int index=startPos;
    if(startPos<0)
    {
       return 0;
    }
    int size=ArraySize(array);
    if(startPos-depth<0)depth=startPos;
    double min=array[startPos];
    int i;
    for(i=startPos;i>startPos-depth;i--)
    {
        if(array[i]<min)
        {
           index=i;
           min=array[i];
        }
    }
    return(index);
}

int caculate_zig(int start,int &ZigZagBuffer_num,
                 double &ZigZagBuffer[],
                 double &High[],double &Low[],datetime &Time[],
                 double &HighMapBuffer[],double &LowMapBuffer[],
                 int &ZigZagBuffer_pos[],int barsnum)
{
    int i=0,limit=barsnum-start,shift=0;
    
    if(limit <= 0)
    {
      Print("limit = br -start is: ",limit,"  barsum is: ",barsnum);
      return 0;
    }
    int counterZ=0;
    int level=3;
    int whatlookfor=0;
    int lasthighpos=0,lastlowpos=0;
    double curhigh=0,curlow=0,lasthigh=0,lastlow=0;
    double val=0,res=0;
    int back=0;
    /*if(x==0)
    {
       ArrayInitialize(ZigZagBuffer,0.0);
       ArrayInitialize(HighMapBuffer,0.0);
       ArrayInitialize(LowMapBuffer,0.0);
       limit=12;
    }
    if(x>0)//计算过
     {  
        i=barsnum-1;
        while((counterZ<level)&&(i>barsnum-100))
        {
              res=ZigZagBuffer[i];
              if(res!=0)counterZ++;
              i--;
        }
        i++;
        limit=i;
        
        if(LowMapBuffer[i]!=0)
        {
           curlow=LowMapBuffer[i];
           whatlookfor=1;
        }
        else
        {
            curhigh=HighMapBuffer[i];
            whatlookfor=-1;
        }
        
        for(i=limit+1;i<barsnum;i++)
        {
            ZigZagBuffer[i]=0.0;
            LowMapBuffer[i]=0.0;
            HighMapBuffer[i]=0.0;
        }
     }*/
     for(i=limit;i<barsnum;i++)
     {
            ZigZagBuffer[i]=0.0;
            LowMapBuffer[i]=0.0;
            HighMapBuffer[i]=0.0;
     }
     for(shift=limit;shift<barsnum;shift++)
     {
         //寻找低点
         val=Low[iLowest(Low,12,shift)];
         if(val==lastlow)val=0.0;
         else
         {
             lastlow=val;
             if(Low[shift]-val>deviation)val=0.0;
             else
             {
                 for(back=1;back<=3;back++)
                 {
                     int k = shift-back;
                     if(k<=0) return 0;
                     res=LowMapBuffer[k];
                     if((res!=0)&&(res>val))LowMapBuffer[k]=0.0;
                 }
             }
         }
         if(Low[shift]==val)LowMapBuffer[shift]=val;
         else LowMapBuffer[shift]=0.0;
         //寻找高点
         val=High[iHighest(High,12,shift)];
         if(val==lasthigh)val=0.0;
         else
         {
             lasthigh=val;
             if(val-High[shift]>deviation)val=0.0;
             else
             {
                 for(back=1;back<=3;back++)
                 {
                     int k = shift-back;
                     if(k<=0) return 0;
                     res=HighMapBuffer[k];
                     if((res!=0)&&(res<val))HighMapBuffer[k]=0.0;
                 }
             }
         } 
         if(High[shift]==val)HighMapBuffer[shift]=val;
         else HighMapBuffer[shift]=0.0;
     }
     if(whatlookfor==0)
     {
        lastlow=0;
        lasthigh=0;
     }
     else
     {
         lastlow=curlow;
         lasthigh=curhigh;
     }
     for(shift=limit;shift<barsnum;shift++)
     {
         res=0.0;
         switch(whatlookfor)
         {
                case 0:
                       if((lastlow==0)&&(lasthigh==0))
                       {
                          if(HighMapBuffer[shift]!=0)
                          {
                             lasthigh=High[shift];
                             lasthighpos=shift;
                             whatlookfor=-1;
                             ZigZagBuffer[shift]=lasthigh;
                             res=1;
                          }
                          if(LowMapBuffer[shift]!=0)
                          {
                             lastlow=Low[shift];
                             lastlowpos=shift;
                             whatlookfor=1;
                             ZigZagBuffer[shift]=lastlow;
                             res=1;
                          }
                       }
                       break;
                case 1:
                       if((LowMapBuffer[shift]!=0.0)&&(LowMapBuffer[shift]<lastlow)&&(HighMapBuffer[shift]==0.0))
                       {
                          ZigZagBuffer[lastlowpos]=0.0;
                          lastlowpos=shift;
                          lastlow=LowMapBuffer[shift];
                          ZigZagBuffer[shift]=lastlow;
                          res=1;
                       }
                       if((HighMapBuffer[shift]!=0.0)&&(LowMapBuffer[shift]==0.0))
                       {
                          lasthigh=HighMapBuffer[shift];
                          lasthighpos=shift;
                          ZigZagBuffer[shift]=lasthigh;
                          whatlookfor=-1;
                          res=1;
                       }
                       break;
                case -1:
                       if((HighMapBuffer[shift]!=0.0)&&(HighMapBuffer[shift]>lasthigh)&&(LowMapBuffer[shift]==0.0))
                       {
                          ZigZagBuffer[lasthighpos]=0.0;
                          lasthighpos=shift;
                          lasthigh=HighMapBuffer[shift];
                          ZigZagBuffer[shift]=lasthigh;
                          res=1;
                       }
                       if((LowMapBuffer[shift]!=0.0)&&(HighMapBuffer[shift]==0.0))
                       {
                          lastlow=LowMapBuffer[shift];
                          lastlowpos=shift;
                          ZigZagBuffer[shift]=lastlow;
                          whatlookfor=1;
                          res=1;
                       }
                       break;
                 default: return(0);
         }
         /*for(i=1;i<=ZigZagBuffer_num-1;i++)
         {
             ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
             ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrGold);
             ObjectMove(0,zig+i,0,Time[ZigZagBuffer_pos[i]],ZigZagBuffer[ZigZagBuffer_pos[i]]);
             ObjectMove(0,zig+i,1,Time[ZigZagBuffer_pos[i+1]],ZigZagBuffer[ZigZagBuffer_pos[i+1]]);
         }*/
     }
     ZigZagBuffer_num=0;
     int j = barsnum-start;
     j = (j>0)?j:0;
         for(i=barsnum-1;i>=j;i--)
         {
             if(ZigZagBuffer[i]!=0.0)
             {
                ZigZagBuffer_num++;
                ZigZagBuffer_pos[ZigZagBuffer_num]=i;
             }
         }
     return 0;
}


int FRA(int time_frame,double &HighBuffer[],double &LowBuffer[],double &High[],double &Low[],int &High_pos[],int &Low_pos[])
{
    int FRA_Handle=0;
    int barsnum=0;
    bool bFractalsUpper,bFractalsLower;
    int dir,PrevLowPos,PrevHighPos;
    int dir_=0,PrevLowPos_=0,PrevHighPos_=0;
    int limit,Fractals;
    switch(time_frame)
    {
           case 6:
                  FRA_Handle=iFractals(NULL,PERIOD_M5);
                  barsnum=Bars(_Symbol,PERIOD_M5);
                  break;
           case 5:
                  FRA_Handle=iFractals(NULL,PERIOD_M15);
                  barsnum=Bars(_Symbol,PERIOD_M15);
                  break;
    }
    limit=barsnum-2;
    PrevLowPos_=barsnum;
    PrevHighPos_=barsnum;
    dir_=0;
    CopyBuffer(FRA_Handle,0,0,barsnum,UpFractal);
    CopyBuffer(FRA_Handle,1,0,barsnum,DnFractal);
    dir=dir_;
    PrevLowPos=PrevLowPos_;
    PrevHighPos=PrevHighPos_;
    int bar;
    for(bar=limit; bar>=0 && !IsStopped(); bar--)
    {
        if(bar==4)
        {
           dir_=dir;
           PrevLowPos_=PrevLowPos;
           PrevHighPos_=PrevHighPos;
        }
        if(UpFractal[bar]!=EMPTY_VALUE&&UpFractal[bar]) bFractalsUpper=true; else bFractalsUpper=false;
        if(DnFractal[bar]!=EMPTY_VALUE&&DnFractal[bar]) bFractalsLower=true; else bFractalsLower=false;
        Fractals=bFractalsUpper*2+bFractalsLower;
        HighBuffer[bar]=0;
        LowBuffer[bar]=0;
        switch(Fractals)
        {
               case 3:
                      if(!dir)
                      {
                         HighBuffer[bar]=High[bar];
                         LowBuffer[bar]=Low[bar];
                         PrevHighPos=bar;
                         PrevLowPos=bar;
                      }
                      if(dir==1)
                      {
                         LowBuffer[bar]=Low[bar];
                         PrevLowPos=bar;
                         if(High[bar]>High[PrevHighPos])
                         {
                            HighBuffer[bar]=High[bar];
                            HighBuffer[PrevHighPos]=0;
                            PrevHighPos=bar;
                         }
                      }
                      if(dir==-1)
                      {
                         HighBuffer[bar]=High[bar];
                         PrevHighPos=bar;
                         if(Low[bar]<Low[PrevLowPos])
                         {
                            LowBuffer[bar]=Low[bar];
                            LowBuffer[PrevLowPos]=0;
                            PrevLowPos=bar;
                         }
                      }
                      dir*=-1;
                      break;
               case 2:
                      if(dir==1)
                      {
                         if(High[bar]>High[PrevHighPos])
                         {
                            HighBuffer[PrevHighPos]=0;
                            HighBuffer[bar]=High[bar];
                            PrevHighPos=bar;
                         }
                      }
                      else
                      {
                          HighBuffer[bar]=High[bar];
                          PrevHighPos=bar;
                          dir=1;
                      }
                      break;
               case 1:
                      if(dir==-1)
                      {
                         if(Low[bar]<Low[PrevLowPos])
                         {
                            LowBuffer[PrevLowPos]=0;
                            LowBuffer[bar]=Low[bar];
                            PrevLowPos=bar;
                         }
                      }
                      else
                      {
                          LowBuffer[bar]=Low[bar];
                          PrevLowPos=bar;
                          dir=-1;
                      }
                      break;
        }
    }
    int High_num=0,Low_num=0;
    for(bar=barsnum-1;bar>=barsnum-100;bar--)
    {
        if(HighBuffer[bar]!=0)
        {
           High_num++;
           High_pos[High_num]=bar;
        }
        if(LowBuffer[bar]!=0)
        {
           Low_num++;
           Low_pos[Low_num]=bar;
        }
    }
    return 0;
}
int big_TL=100,middle_TL=100;//找通道+画通道
void findtrend()
{
     int i,j;
     big_TL=100;
     middle_TL=100;
     if(ZigZagBuffer_pos_H4[2] <=0) return;
     //以下是1小时线Z字线向下
     if(ZigZagBuffer_H4[ZigZagBuffer_pos_H4[1]]<ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]])
     {
        for(i=tlines_D-1;i>=0;i--)//找大通道(第一种方法)
        {
            //if(LineShow_U[i][3]==0)continue;
            double temp=ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]]-ZigZagBuffer_H4[ZigZagBuffer_pos_H4[1]];
            if((High_M1[LineShow_D[i][1]]>ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]]-temp/6)&&(Time_M1[LineShow_D[i][1]]>Time_H4[ZigZagBuffer_pos_H4[2]-1]))
            {
               for(j=1;j<=2;j++)//判断更接近的大通道
               {
                   if(i-j<0)break;
                   if((High_M1[LineShow_D[i-j][1]]>ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]]-temp/6)&&(Time_M1[LineShow_D[i-j][1]]>Time_H4[ZigZagBuffer_pos_H4[2]-1]))
                   {
                      double s,s2;
                      s=ObjectGetValueByTime(0,NameTL_D+(i+1),Time_M1[barsnum_M1-1],0);
                      s2=ObjectGetValueByTime(0,NameTL_D+(i-j+1),Time_M1[barsnum_M1-1],0);
                      if(s>s2)
                      {
                         big_TL=-1-i+j;
                         break;
                      }
                   }
               }
               if(big_TL==-1-i+j)break;
               else
               {
                   big_TL=-1-i;
                   break;
               }
            }
        }
        if(big_TL>=100)//找大通道（第二种方法）
        {
           for(i=0;i<tlines_D;i++)
           {
               if(LineShow_D[i][3]==0)continue;
               if(Time_M1[LineShow_D[i][1]]<Time_H4[ZigZagBuffer_pos_H4[2]-1])
               {
                  big_TL=-1-i;
                  break;
               }
           }
        }
        if(big_TL>0)//找大通道（第三种方法）
        {
           if(tlines_D>0)big_TL=(-1)*tlines_D;
        }
        //大通道找完
        if(big_TL<0)
        {
           middle_TL=100;
           int temp_big=(-1)*big_TL-1;
           for(i=temp_big-1;i>=0;i--)//向下的中通道
           {
               if(LineShow_D[i][3]==0)continue;
               if(LineShow_D[i][1]<barsnum_M1-30)
               {
                  middle_TL=-1-i;
                  break;
               }
           }
           for(i=0;i<tlines_U;i++)//向上的中通道
           {
               if(LineShow_U[i][3]==0)continue;
               if(middle_TL<100)
               {
                  int temp_middle=(-1)*middle_TL-1;
                  if((LineShow_U[i][1]<LineShow_D[temp_middle][1])&&(LineShow_U[i][1]>LineShow_D[temp_big][1]))
                  {
                     middle_TL=i+1;
                     break;
                  }
               }
               else 
               {
                   if((LineShow_U[i][1]<barsnum_M1-30)&&(LineShow_U[i][1]>LineShow_D[temp_big][1]))
                   {
                      middle_TL=i+1;
                      break;
                   }
               }
           }
           //画通道
           if(tlines_D>1)ObjectSetInteger(0,NameTL_D+2,OBJPROP_WIDTH,2);
           if(tlines_D>2)ObjectSetInteger(0,NameTL_D+3,OBJPROP_WIDTH,3);
           ObjectSetInteger(0,NameTL_D+((-1)*big_TL),OBJPROP_WIDTH,5);
           j=(-1)*big_TL-1;
           if(tlines_U>1)
           {
              if(LineShow_U[1][1]>LineShow_D[j][1])
              {
                 ObjectSetInteger(0,NameTL_U+2,OBJPROP_WIDTH,2);
              }
           }
           if(tlines_U>2)
           {
              if(LineShow_U[2][1]>LineShow_D[j][1])
              {
                 ObjectSetInteger(0,NameTL_U+3,OBJPROP_WIDTH,3);
              }
           }
           for(i=tlines_U-1;i>=0;i--)
           {
               if(LineShow_U[i][1]>LineShow_D[j][1])break;
           }
           if(i>=0)
           {
              if(LineShow_U[i][1]>LineShow_D[j][1])
              {
                 ObjectSetInteger(0,NameTL_U+(i+1),OBJPROP_WIDTH,4);
              }
           }
           if(middle_TL<100)
           {
              if(middle_TL>0)
              {
                 ObjectSetInteger(0,NameTL_U+(middle_TL),OBJPROP_WIDTH,2);
                 ObjectSetInteger(0,NameTL_U+(middle_TL),OBJPROP_COLOR,clrLightYellow);
              }
              else
              {
                  ObjectSetInteger(0,NameTL_D+((-1)*middle_TL),OBJPROP_WIDTH,2);
                  ObjectSetInteger(0,NameTL_D+((-1)*middle_TL),OBJPROP_COLOR,clrLightYellow);
              }
           }
        }
        else return;
     }
     //以下是Z字线向上
     else
     {
         big_TL=100;
         for(i=tlines_U-1;i>=0;i--)//找大通道(第一种方法)
         {
             double temp=ZigZagBuffer_H4[ZigZagBuffer_pos_H4[1]]-ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]];
             if((Low_M1[LineShow_U[i][1]]<ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]]+temp/6)&&(Time_M1[LineShow_U[i][1]]>Time_H4[ZigZagBuffer_pos_H4[2]-1]))
             {
                for(j=1;j<=2;j++)//判断更接近的大通道
                {
                   if(i-j<0)break;
                   if((Low_M1[LineShow_U[i-j][1]]<ZigZagBuffer_H4[ZigZagBuffer_pos_H4[2]]+temp/6)&&(Time_M1[LineShow_U[i-j][1]]>Time_H4[ZigZagBuffer_pos_H4[2]-1]))
                   {
                      double s,s2;
                      s=ObjectGetValueByTime(0,NameTL_U+(i+1),Time_M1[barsnum_M1-1],0);
                      s2=ObjectGetValueByTime(0,NameTL_U+(i-j+1),Time_M1[barsnum_M1-1],0);
                      if(s<s2)
                      {
                         big_TL=i+1-j;
                         break;
                      }
                   }
                }
                if(big_TL==i+1-j)break;
                else
                {
                   big_TL=i+1;
                   break;
                }
             }
         }
         if(big_TL>=100)//找大通道(第二种方法)
         {
            for(i=0;i<tlines_U;i++)
            {
                if(LineShow_U[i][3]==0)continue;
                
                if(Time_M1[LineShow_U[i][1]]<Time_H4[ZigZagBuffer_pos_H4[2]-1])
                {
                   big_TL=i+1;
                   break;
                }
            }
         }
         if(big_TL>=100)//找大通道(第三种方法)
         {
            if(tlines_U>0)big_TL=tlines_U;
         }
         if(big_TL<100)
         {
            middle_TL=100;
            int temp_big=big_TL-1;
            for(i=temp_big-1;i>=0;i--)//找向上的中通道
            {
                //if(LineShow_U[i][3]==0)continue;
                if(LineShow_U[i][1]<barsnum_M1-30)
                {
                   middle_TL=i+1;
                   break;
                }
            }
            for(i=0;i<tlines_D;i++)//找向下的中通道
            {
                //if(LineShow_D[i][3]==0)continue;
                if(middle_TL<100)
                {
                   int temp_middle=middle_TL-1;
                   if((LineShow_D[i][1]<LineShow_U[temp_middle][1])&&(LineShow_D[i][1]>LineShow_U[temp_big][1]))
                   {
                      middle_TL=-1-i;
                      break;
                   }
                }
                else 
                {
                    if((LineShow_D[i][1]<barsnum_M1-30)&&(LineShow_D[i][1]>LineShow_U[temp_big][1]))
                    {
                       middle_TL=-1-i;
                       break;
                    }
                }
            }
            //画通道
            if(tlines_U>1)ObjectSetInteger(0,NameTL_U+2,OBJPROP_WIDTH,2);
            if(tlines_U>2)ObjectSetInteger(0,NameTL_U+3,OBJPROP_WIDTH,3);
            ObjectSetInteger(0,NameTL_U+big_TL,OBJPROP_WIDTH,5);
            j=big_TL-1;
            if(tlines_D>1)
            {
               if(LineShow_D[1][1]>LineShow_U[j][1])
               {
                  ObjectSetInteger(0,NameTL_D+2,OBJPROP_WIDTH,2);
               }
            }
            if(tlines_D>2)
            {
               if(LineShow_D[2][1]>LineShow_U[j][1])
               {
                  ObjectSetInteger(0,NameTL_D+3,OBJPROP_WIDTH,3);
               }
            }
            for(i=tlines_D-1;i>=0;i--)
            {
                if(LineShow_D[i][1]>LineShow_U[j][1])break;
            }
            if(i>=0)
            {
               if(LineShow_D[i][1]>LineShow_U[j][1])
               {
                  ObjectSetInteger(0,NameTL_D+(i+1),OBJPROP_WIDTH,4);
               }
            }
            if(middle_TL<100)
            {
               if(middle_TL>0)
               {
                  ObjectSetInteger(0,NameTL_U+(middle_TL),OBJPROP_WIDTH,2);
                  ObjectSetInteger(0,NameTL_U+(middle_TL),OBJPROP_COLOR,clrLightYellow);
               }
               else
               {
                   ObjectSetInteger(0,NameTL_D+((-1)*middle_TL),OBJPROP_WIDTH,2);
                   ObjectSetInteger(0,NameTL_D+((-1)*middle_TL),OBJPROP_COLOR,clrLightYellow);
               }
            }
         }
     }
}

void createtag()
{
     //1点的值 double
     if(ObjectFind(0,"point1")<0)
     {
        ObjectCreate(0,"point1",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point1",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"point1_pos")<0)
     {
        ObjectCreate(0,"point1_pos",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point1_pos",OBJPROP_TEXT,"0");
     }
     //2点的值 double
     if(ObjectFind(0,"point2")<0)
     {
        ObjectCreate(0,"point2",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point2",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"point2_pos")<0)
     {
        ObjectCreate(0,"point2_pos",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point2_pos",OBJPROP_TEXT,"0");
     }
     //3点的值 double
     if(ObjectFind(0,"point3")<0)
     {
        ObjectCreate(0,"point3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point3",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"point3_pos")<0)
     {
        ObjectCreate(0,"point3_pos",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point3_pos",OBJPROP_TEXT,"0");
     }
     //4点的值 double
     if(ObjectFind(0,"point4")<0)
     {
        ObjectCreate(0,"point4",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point4",OBJPROP_TEXT,"0");
     }
     //S点的值 double
     if(ObjectFind(0,"pointS")<0)
     {
        ObjectCreate(0,"pointS",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"pointS",OBJPROP_TEXT,"0");
     }
     //是否破S点 A or B
     if(ObjectFind(0,"before_S")<0)
     {
        ObjectCreate(0,"before_S",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"before_S",OBJPROP_TEXT,"0");
     }
     //是否破S点 1 or 2
     if(ObjectFind(0,"before_S1")<0)
     {
        ObjectCreate(0,"before_S1",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"before_S1",OBJPROP_TEXT,"0");
     }
     //破S点的时间 datetime
     if(ObjectFind(0,"time_po")<0)
     {
        ObjectCreate(0,"time_po",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"time_po",OBJPROP_TEXT,"0");
     }
     //时间级别 12345
     if(ObjectFind(0,"trade_period")<0)
     {
        ObjectCreate(0,"trade_period",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"trade_period",OBJPROP_TEXT,"0");
     }
     //开单时间 datetime
     if(ObjectFind(0,"deal_time")<0)
     {
        ObjectCreate(0,"deal_time",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"deal_time",OBJPROP_TEXT,"0");
     }
     //倒着的
     if(ObjectFind(0,"escape")<0)
     {
        ObjectCreate(0,"escape",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"escapeS")<0)
     {
        ObjectCreate(0,"escapeS",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escapeS",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"escape1")<0)
     {
        ObjectCreate(0,"escape1",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape1",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"escape2")<0)
     {
        ObjectCreate(0,"escape2",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape2",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"escape3")<0)
     {
        ObjectCreate(0,"escape3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape3",OBJPROP_TEXT,"0");
     }
     if(ObjectFind(0,"estime_po")<0)
     {
        ObjectCreate(0,"estime_po",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"estime_po",OBJPROP_TEXT,"0");
     }
     
     if(ObjectFind(0,"resell")<0)
     {
        ObjectCreate(0,"resell",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"resell",OBJPROP_TEXT,"0");
     }
     //打破1点的时间 datetime
     if(ObjectFind(0,"point1_po")<0)
     {
        ObjectCreate(0,"point1_po",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point1_po",OBJPROP_TEXT,"0");
     }
     //接单的2点
     if(ObjectFind(0,"point_ag_time")<0)
     {
        ObjectCreate(0,"point_ag_time",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point_ag_time",OBJPROP_TEXT,"0");
     }
     //记录多单B1开的信息
     if(ObjectFind(0,"B1buy")<0)
     {
        ObjectCreate(0,"B1buy",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"B1buy",OBJPROP_TEXT,"0");
     }
     //
     if(ObjectFind(0,"B1buyvol")<0)
     {
        ObjectCreate(0,"B1buyvol",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"B1buyvol",OBJPROP_TEXT,"0");
     }
     //
     if(ObjectFind(0,"B1buysl")<0)
     {
        ObjectCreate(0,"B1buysl",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"B1buysl",OBJPROP_TEXT,"0");
     }
     //
     if(ObjectFind(0,"B1buypoint")<0)
     {
        ObjectCreate(0,"B1buypoint",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"B1buypoint",OBJPROP_TEXT,"0");
     }
     //B1破S时大通道的宽度
     if(ObjectFind(0,"B1Skuan")<0)
     {
        ObjectCreate(0,"B1Skuan",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"B1Skuan",OBJPROP_TEXT,"0");
     }
     //2次123进场的破S
     if(ObjectFind(0,"beforeS_2to3")<0)
     {
        ObjectCreate(0,"beforeS_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"beforeS_2to3",OBJPROP_TEXT,"0");
     }
     //2次123进场的1点
     if(ObjectFind(0,"point1_2to3")<0)
     {
        ObjectCreate(0,"point1_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point1_2to3",OBJPROP_TEXT,"0");
     }
     //2次123进场的2点
     if(ObjectFind(0,"point2_2to3")<0)
     {
        ObjectCreate(0,"point2_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"point2_2to3",OBJPROP_TEXT,"0");
     }
     //2次123出场的破S
     if(ObjectFind(0,"escapeS_2to3")<0)
     {
        ObjectCreate(0,"escapeS_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escapeS_2to3",OBJPROP_TEXT,"0");
     }
     //2次123出场的1点
     if(ObjectFind(0,"escape1_2to3")<0)
     {
        ObjectCreate(0,"escape1_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape1_2to3",OBJPROP_TEXT,"0");
     }
     //2次123出场的2点
     if(ObjectFind(0,"escape2_2to3")<0)
     {
        ObjectCreate(0,"escape2_2to3",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape2_2to3",OBJPROP_TEXT,"0");
     }
     //出场开关
     if(ObjectFind(0,"escape_mode")<0)
     {
        ObjectCreate(0,"escape_mode",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape_mode",OBJPROP_TEXT,"0");
     }
     //是否接单，接单时间
     if(ObjectFind(0,"escape_ag")<0)
     {
        ObjectCreate(0,"escape_ag",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape_ag",OBJPROP_TEXT,"0");
     }
     //接单价格
     if(ObjectFind(0,"price_ag")<0)
     {
        ObjectCreate(0,"price_ag",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"price_ag",OBJPROP_TEXT,"0");
     }
     //进场的价格
     if(ObjectFind(0,"deal_price")<0)
     {
        ObjectCreate(0,"deal_price",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"deal_price",OBJPROP_TEXT,"0");
     }
     //出场的第二个S点
     if(ObjectFind(0,"beforeS_2")<0)
     {
        ObjectCreate(0,"beforeS_2",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"beforeS_2",OBJPROP_TEXT,"0");
     }
     //出场的第二个1点
     if(ObjectFind(0,"escape1_2")<0)
     {
        ObjectCreate(0,"escape1_2",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape1_2",OBJPROP_TEXT,"0");
     }
     //出场的第二个2点
     if(ObjectFind(0,"escape2_2")<0)
     {
        ObjectCreate(0,"escape2_2",OBJ_LABEL,0,0,0);
        ObjectSetString(0,"escape2_2",OBJPROP_TEXT,"0");
     }
}





void draw_zig(int x)
{
     int i;
     if(x==Bars(_Symbol,PERIOD_H4))
     {
        for(i=1;i<=ZigZagBuffer_num_H4-1;i++)
        {
            ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
            ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrRed);
            ObjectMove(0,zig+i,0,Time_H4[ZigZagBuffer_pos_H4[i]],ZigZagBuffer_H4[ZigZagBuffer_pos_H4[i]]);
            ObjectMove(0,zig+i,1,Time_H4[ZigZagBuffer_pos_H4[i+1]],ZigZagBuffer_H4[ZigZagBuffer_pos_H4[i+1]]);
        }
     }
     if(x==Bars(_Symbol,PERIOD_H1))
     {
        for(i=1;i<=ZigZagBuffer_num_H1-1;i++)
        {
            ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
            ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrRed);
            ObjectMove(0,zig+i,0,Time_H1[ZigZagBuffer_pos_H1[i]],ZigZagBuffer_H1[ZigZagBuffer_pos_H1[i]]);
            ObjectMove(0,zig+i,1,Time_H1[ZigZagBuffer_pos_H1[i+1]],ZigZagBuffer_H1[ZigZagBuffer_pos_H1[i+1]]);
        }
     }
     if(x==Bars(_Symbol,PERIOD_M30))
     {
        for(i=1;i<=ZigZagBuffer_num_M30-1;i++)
        {
            ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
            ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrRed);
            ObjectMove(0,zig+i,0,Time_M30[ZigZagBuffer_pos_M30[i]],ZigZagBuffer_M30[ZigZagBuffer_pos_M30[i]]);
            ObjectMove(0,zig+i,1,Time_M30[ZigZagBuffer_pos_M30[i+1]],ZigZagBuffer_M30[ZigZagBuffer_pos_M30[i+1]]);
        }
     }
     if(x==Bars(_Symbol,PERIOD_M15))
     {
        for(i=1;i<=ZigZagBuffer_num_M15-1;i++)
        {
            ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
            ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrRed);
            ObjectMove(0,zig+i,0,Time_M15[ZigZagBuffer_pos_M15[i]],ZigZagBuffer_M15[ZigZagBuffer_pos_M15[i]]);
            ObjectMove(0,zig+i,1,Time_M15[ZigZagBuffer_pos_M15[i+1]],ZigZagBuffer_M15[ZigZagBuffer_pos_M15[i+1]]);
        }
     }
     if(x==Bars(_Symbol,PERIOD_M5))
     {
        for(i=1;i<=ZigZagBuffer_num_M5-1;i++)
        {
            ObjectCreate(0,zig+i,OBJ_TREND,0,0,0,0,0);
            ObjectSetInteger(0,zig+i,OBJPROP_COLOR,clrRed);
            ObjectMove(0,zig+i,0,Time_M5[ZigZagBuffer_pos_M5[i]],ZigZagBuffer_M5[ZigZagBuffer_pos_M5[i]]);
            ObjectMove(0,zig+i,1,Time_M5[ZigZagBuffer_pos_M5[i+1]],ZigZagBuffer_M5[ZigZagBuffer_pos_M5[i+1]]);
        }
     }
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,0,-1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
void OnTimer()
{



}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     int flag=1;
     datetime time_now=TimeCurrent();
     string symbol_now=_Symbol;
     long id_now=AccountInfoInteger(ACCOUNT_LOGIN);
 
     if( iVolume(_Symbol,PERIOD_M1,0) <= 1  || init == 0) copy();
     if(flag==1)
     {
        if( iVolume(_Symbol,PERIOD_M5,0) <= 1  || init == 0) advance(High_M5,Low_M5,barsnum_M5);
        if( iVolume(_Symbol,PERIOD_M5,0) <= 1  || init == 0) trend(High_M5,Low_M5,Time_M5,LineHP_M5_1,LineHP_M5_2,LineLP_M5_1,LineLP_M5_2,Hnum_M5,Lnum_M5);
        
        if( iVolume(_Symbol,PERIOD_M1,0) <= 1  || init == 0) Draw_TL();
        if( iVolume(_Symbol,PERIOD_M1,0) <= 1  || init == 0) caculate_zig(1000,ZigZagBuffer_num_M1,ZigZagBuffer_M1,High_M1,Low_M1,Time_M1,HighMapBuffer_M1,LowMapBuffer_M1,ZigZagBuffer_pos_M1,barsnum_M1);
        if( iVolume(_Symbol,PERIOD_M5,0) <= 1  || init == 0) caculate_zig(1000,ZigZagBuffer_num_M5,ZigZagBuffer_M5,High_M5,Low_M5,Time_M5,HighMapBuffer_M5,LowMapBuffer_M5,ZigZagBuffer_pos_M5,barsnum_M5);
        if( iVolume(_Symbol,PERIOD_M15,0) <= 1  || init == 0) caculate_zig(1000,ZigZagBuffer_num_M15,ZigZagBuffer_M15,High_M15,Low_M15,Time_M15,HighMapBuffer_M15,LowMapBuffer_M15,ZigZagBuffer_pos_M15,barsnum_M15);
        if( iVolume(_Symbol,PERIOD_M30,0) <= 1  || init == 0) caculate_zig(1000,ZigZagBuffer_num_M30,ZigZagBuffer_M30,High_M30,Low_M30,Time_M30,HighMapBuffer_M30,LowMapBuffer_M30,ZigZagBuffer_pos_M30,barsnum_M30);
        if( iVolume(_Symbol,PERIOD_H1,0) <= 1  || init == 0) caculate_zig(1000,ZigZagBuffer_num_H1,ZigZagBuffer_H1,High_H1,Low_H1,Time_H1,HighMapBuffer_H1,LowMapBuffer_H1,ZigZagBuffer_pos_H1,barsnum_H1);
        if( iVolume(_Symbol,PERIOD_H4,0) <= 1 || init == 0) caculate_zig(200,ZigZagBuffer_num_H4,ZigZagBuffer_H4,High_H4,Low_H4,Time_H4,HighMapBuffer_H4,LowMapBuffer_H4,ZigZagBuffer_pos_H4,barsnum_H4);
        
        if( iVolume(_Symbol,PERIOD_M5,0) <= 1 || init == 0) FRA(6,FRAH_M5,FRAL_M5,High_M5,Low_M5,FRAH_M5_pos,FRAL_M5_pos);
        
        int i;
        string s="zz";
        if( iVolume(_Symbol,PERIOD_M5,0) <= 1 || init == 0)
        {
           for(i=1;i<=Hnum_M5;i++)
           {
               ObjectCreate(0,s+i,OBJ_TREND,0,0,0,0,0);
               ObjectSetInteger(0,s+i,OBJPROP_RAY_RIGHT,true);
               ObjectSetInteger(0,s+i,OBJPROP_COLOR,clrAqua);
               ObjectMove(0,s+i,0,Time_M5[LineHP_M5_1[i]],High_M5[LineHP_M5_1[i]]);
               ObjectMove(0,s+i,1,Time_M5[LineHP_M5_2[i]],High_M5[LineHP_M5_2[i]]);
           }
           for(i=1;i<=Lnum_M5;i++)
           {
               ObjectCreate(0,s+(i+50),OBJ_TREND,0,0,0,0,0);
               ObjectSetInteger(0,s+(i+50),OBJPROP_RAY_RIGHT,true);
               ObjectSetInteger(0,s+(i+50),OBJPROP_COLOR,clrMagenta);
               ObjectMove(0,s+(i+50),0,Time_M5[LineLP_M5_1[i]],Low_M5[LineLP_M5_1[i]]);
               ObjectMove(0,s+(i+50),1,Time_M5[LineLP_M5_2[i]],Low_M5[LineLP_M5_2[i]]);
           }
        }
        int temp=Bars(_Symbol,PERIOD_CURRENT);
        draw_zig(temp);
        
        createtag();
        //int Flag_trade=PositionSelect(_Symbol);
        double vol=PositionGetDouble(POSITION_VOLUME);
        findtrend();
     }
     //Sleep(1000);
     init = 1;
  }
