//COnverted to apex close from JSON response from DriveWealth
public class DriveWealthJsonSession {
    public Integer appTypeID;    //2000
    public Integer code;      //401
    public Double commissionRate;    //2.99
    public Integer loginState;    //1
    public String message;  //Invalid x-mysolomeo-session-key HTTP header....
    public String referralCode;    //VL7FN4
    public String sessionKey;    //02e57c7d-d071-4c63-b491-1194a9939ea5.2016-01-20T20:50:48.680Z
    public String userID;    //02e57c7d-d071-4c63-b491-1194a9939ea5
    public String wlpID;    //DW
    public cls_accounts[] accounts;
    public cls_instruments[] instruments;
    public boolean guest;
    class cls_accounts {
        public String accountID;    //02e57c7d-d071-4c63-b491-1194a9939ea5.1452548320228
        public String accountNo;    //DPAJ000003
        public String userID;    //02e57c7d-d071-4c63-b491-1194a9939ea5
        public Integer accountType;    //1
        public Double cash;    //9950.04
        public String currencyID;    //USD
        public String defaultGoalID;    //64924fd9-8ef6-48ac-ade2-c628cbfbd6b9
        public Integer freeTradeBalance;    //0
        public Integer goodFaithViolations;    //0
        public String ibID;    //80f9b672-120d-4b73-9cc9-42fb3262c4b9
        public boolean interestFree;
        public Integer margin;    //1
        public String nickname;    //Bob's Practice Account
        public String openedWhen;    //2016-01-11T21:38:40Z
        public cls_goals[] goals;
        public cls_orders[] orders;
        public Integer patternDayTrades;    //0
        public cls_positions[] positions;
        public Integer status;    //2
        public String tradingType;    //C
        public String updatedWhen;    //2016-01-20T08:17:46.770Z
        public String createdWhen;    //2016-01-11T21:38:40.228Z
        public Double bodMoneyMarket;    //9950.04
        public Double bodEquityValue;    //43.56
        public Double bodCashAvailForWith;    //9950.04
        public Double bodCashAvailForTrading;    //9950.04
        public Double rtCashAvailForTrading;    //9950.04
        public Double rtCashAvailForWith;    //9950.04
        public Integer accountMgmtType;    //0
        public boolean longOnly;
    }
    class cls_goals {
    }
    class cls_orders {
    }
    class cls_positions {
    }
    class cls_instruments {
    }
    public static DriveWealthJsonSession parse(String json) {
        return (DriveWealthJsonSession) System.JSON.deserialize(json, DriveWealthJsonSession.class);
    }


}