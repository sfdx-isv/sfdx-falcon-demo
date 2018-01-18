/**
* Created by jrattanpal on 11/7/16.
*/

public with sharing class DriveWealthJsonInstrument {
        public String instrumentID;    //459ce368-8f88-4fe1-8edb-d71c78af51f1
        public String name;    //Salesforce.com, Inc
        public String category;    //Stock
        public String currencyID;    //USD
        public Integer limitStatus;    //0
        public Integer instrumentTypeID;    //6
        public boolean isLongOnly;
        public String marginCurrencyID;    //USD
        public Integer orderSizeMax;    //10000
        public Double orderSizeMin;    //0.0001
        public Double orderSizeStep;    //0.0001
        public Double rateAsk;    //74.38
        public Double rateBid;    //74.38
        public Double rateHigh;    //75.18
        public Double rateLow;    //73.86
        public Double rateOpen;    //74.14
        public Integer ratePrecision;    //2
        public String symbol;    //CRM
        public String[] tags;    // "crm", "russell1000", "sp500", "technology", "usa"
        public Integer tradeStatus;    //1
        public String tradingHours;    //Mon-Fri: 9:30am - 4:00pm ET
        public Integer tPlus;    //0
        public String uom;    //shares
        public String urlImage;    //http://syscdn.drivewealth.net/images/symbols/crm.png
        public String chaikinPgr;    //{  "Corrected PGR Value":"-1",  "Financial Metrics":"-1",  "Earnings Performance":"-1",  "Price/Volume Activity":"-1",  "Expert Opinions":"-1",  "pgrSummaryText":""}
        public String sector;    //Technology
        public Double priorClose;    //74.14
        public Double close;    //74.37
        public Double lastTrade;    //74.37
        public String nameLower;    //salesforce.com, inc
        public Integer marketState;    //1
        public Integer minTic;    //0
        public Integer pipMultiplier;    //1
        public Integer rebateSpread;    //0
        public Integer regTLongOveride;    //0
        public Integer regTShortOveride;    //0
        public boolean basketPricingEligible;
        public boolean longOnly;
        public Integer code;      //401
        public String message;      //"Invalid x-mysolomeo-session-key HTTP header [ipAddress=1.1.1.1]"

        public static List<DriveWealthJsonInstrument> parse(String json) {
                return (List<DriveWealthJsonInstrument>) System.JSON.deserialize(json, List<DriveWealthJsonInstrument>.class);
        }
}