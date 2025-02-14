//+------------------------------------------------------------------+
//|                                                     Position.mqh |
//|                                     Copyright 2025, Geon-Hee Lee |
//|                                https://www.github.com/TF-Polygon |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Geon-Hee Lee"
#property link      "https://www.github.com/TF-Polygon"
#property strict

#define ZERO                  0
#define ZERO_FLOAT            0.0f
#define INDEX_INIT_VAL        -1
#define MAX_TRADING_SIZE      100
#define LOT_UNIT              10000
#define LONG                  1
#define SHORT                 2
#define TEMP_SLIPPAGE         5
#define PIVOTPOINT_RANGE      5

class Position {
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
// Default constructor
   Position() { }
// Parametric constructor
   Position(int op, int ticket_num, double bep, double lot) {
      m_Op     = op;
      m_Ticket = ticket_num;
      m_Bep    = bep;
      m_Lot    = lot;
   }
// Destructor
   ~Position() { }
public:
   void printData(void) {
      Print("Successfully opened the order, Ticket No.", m_Ticket, "  Entry Price: ", m_Bep, "  Lot: ", m_Lot, "  ::  ", m_Op);
   }

public:
   void set_Lot(double lot)      { m_Lot = lot; }
   void set_Bep(double bep)      { m_Bep = bep; }
   void set_TicketNum(int num)   { m_Ticket = num; }
      
   inline int     get_Op(void)         { return m_Op; }
   inline double  get_Lot(void)        { return m_Lot; }
   inline double  get_Bep(void)        { return m_Bep; }
   inline int     get_Ticket(void)     { return m_Ticket; }
};

struct s_Position {
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
      printData();
   }
// Close the order
   void close(void) { 
      double price = m_Op == OP_BUY ? Bid : Ask; 
      int closed_ticket = OrderClose(m_Ticket, m_Lot, price, TEMP_SLIPPAGE, clrOrange);
      if (closed_ticket > 0) {
         init();
         print_CloseData();
      }
   }
   void print_OpenData(void) {
      Print("Successfully opened the order, Ticket No.", m_Ticket, "  Entry Price: ", m_Bep, "  Lot: ", m_Lot, "  ::  ", m_Op);
   }
   void print_CloseData(void) {
      Print("Successfully closed the order, Ticket No.", m_Ticket, "  Entry Price: ", m_Bep, "  Lot: ", m_Lot, "  ::  ", m_Op);
   }

public:      
   inline int     get_Op(void)         { return m_Op; }
   inline double  get_Lot(void)        { return m_Lot; }
   inline double  get_Bep(void)        { return m_Bep; }
   inline int     get_Ticket(void)     { return m_Ticket; }
};
