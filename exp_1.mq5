//+------------------------------------------------------------------+
//|                                                        exp_1.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
/*
説明
   とりあえず実験的に作成するEA
   OnTimer（）を用いて作成し、バックテストでこの関数が動作するかどうかも検証する
ストラテジー
   30日に1回エントリー
   エントリーのタイミングで、ポジションを持っていれば決済
*/
//+------------------------------------------------------------------+
//| 変数宣言                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade         m_trade;
bool R;
input ulong slip     = 10;//許容誤差 point指定
input ulong o_magic  = 999999;//マジックナンバー
input double initial_volume = 1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderClose(int Ticket)
  {

   MqlTradeRequest CRequest;
   MqlTradeResult CResult;

   ZeroMemory(CRequest);
   ZeroMemory(CResult);

//ヘッジタイプの場合(MT4ライクな場合)-------------------------------------------------------------------------
   m_trade.PositionClose(Ticket, 10);

  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(2592000);

//--
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {


//------------------------変数初期化------------------------------------

//--- リクエストと結果の宣言と初期化
   MqlTradeRequest request= {0};
   MqlTradeResult  result= {0};

//input string symbol = "JP225cash";//日系225
//input double initial_volume = 0.01;//ロット数

   /*request構造体の中身一覧
     ENUM_TRADE_REQUEST_ACTIONS   action;           // 取引の種類
     ulong                         magic;           // エキスパートアドバイザー ID（マジックナンバー）
     ulong                         order;           // 注文チケット
     string                       symbol;           // 取引シンボル
     double                       volume;           // 約定のための要求されたボリューム（ロット単位）
     double                       price;           // 価格
     double                       stoplimit;       // 注文のストップリミットレベル
     double                       sl;               // 注文の決済逆指値レベル
     double                       tp;               // 注文の決済指値レベル
     ulong                         deviation;       // リクエストされた価格からの可能な最大偏差
     ENUM_ORDER_TYPE               type;             // 注文の種類
     ENUM_ORDER_TYPE_FILLING       type_filling;     // 注文実行の種類
     ENUM_ORDER_TYPE_TIME       type_time;       // 注文期限切れの種類
     datetime                     expiration;       // 注文期限切れの時刻 （ORDER_TIME_SPECIFIED 型の注文）
     string                       comment;         // 注文コメント
     ulong                         position;         // Position ticket
     ulong                         position_by;     // The ticket of an opposite position
   */
//-------------------------決済------------------------------------------------------

   int OrdersTotal_ = PositionsTotal();
   for(int i=0; i<OrdersTotal_; i++)
     {
      if(PositionGetTicket(i)>0)//戻り値はチケット　失敗で０
        {
         if(PositionGetInteger(POSITION_MAGIC) == o_magic &&
            PositionGetString(POSITION_SYMBOL) == "JP225Cash")
           {
            OrderClose(PositionGetTicket(i));
           }
        }
     }

//-------------------------発注-----------------------------------------------------

//--- リクエストのパラメータ
   request.type         = ORDER_TYPE_BUY;                         // 注文タイプ
   request.price        = SymbolInfoDouble(Symbol(),SYMBOL_ASK);  // 発注価格
   request.volume       = initial_volume;
   request.action       = TRADE_ACTION_DEAL;                      // 取引操作タイプ
   request.symbol       = "JP225Cash";                            // シンボル
   request.tp           = 0;
   request.sl           = 0;
   request.magic        = o_magic;                                // 注文のMagicNumber
   request.comment      ="";
   request.deviation    = 5;                                      // 価格からの許容偏差
   request.type_filling = ORDER_FILLING_IOC;
//--- リクエストの送信 OrderSend()関数によって注文を発注する
   R = OrderSend(request, result);
   if(!R)
     {
      Print("OrderClose error");
      Print("retcode : "+result.retcode);
      Print("deal : "+result.deal);
      Print("order : "+result.order);
      Print("-----↓Logging↓-----");
      Print("type : "+request.type);
      Print("price : "+request.price);
      Print("volume : "+request.volume);
      Print("action : "+request.action);
      Print("symbol : "+request.symbol);
      Print("deviation : "+request.deviation);
      Print("sl : "+request.sl);
      Print("tp : "+request.tp);
      Print("magic : "+request.magic);
      Print("comment : "+request.comment);
      Print("-----↑Logging↑-----");
     }
//--- 操作についての情報
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//順調に右上に推移しているかの計算
//(純利益/最大ドローダウン)-利益率
//(総利益＋総損失/最大ドローダウン)-(総利益/総損失)
//左の()の中がリカバリーファクター。右の()の中がプロフィットファクター
   return(TesterStatistics(STAT_PROFIT)/TesterStatistics(STAT_BALANCE_DD)-TesterStatistics(STAT_PROFIT_FACTOR));
  }
//+------------------------------------------------------------------+
