load("C:/Users/emilia/Downloads/dendriticSpines.rda")
dt<-dendriticSpines

#średnia dla wszystkich myszy
mean(dt$length)
#0.735405

levels(dt$mouse)
# ko, tg, wt
summary(dt$mouse)
#3066 16159 18957

KO<-dt[dt$mouse=="KO",]
TG<-dt[dt$mouse=="TG",]
WT<-dt[dt$mouse=="WT",]

mean(KO$length)
#0.375365
mean(TG$length)
#0.8192713
mean(WT$length)
#0.7221481

levels(WT$treatment)
#[1] "-"      "chiron" "dmso"   "gm"     "li"    
summary(WT$treatment)
#   - chiron   dmso     gm     li 
#   1416   2909   7570   5032   2030 



WT_null<-WT[WT$treatment=="-",]
WT_chiron<-WT[WT$treatment=="chiron",]
WT_dmso<-WT[WT$treatment=="dmso",]
WT_gm<-WT[WT$treatment=="gm",]
WT_li<-WT[WT$treatment=="li",]

mean(WT_null$length)
#[1] 0.4819959
mean(WT_chiron$length)
#[1] 0.7531081
mean(WT_dmso$length)
#[1] 0.8016487
mean(WT_gm$length)
#[1] 0.7924484
mean(WT_li$length)
#[1] 0.3745729


summary(KO$treatment)
#     - chiron   dmso     gm     li 
#  1500      0      0      0   1566 
KO_null<-KO[KO$treatment=="-",]
KO_li<-KO[KO$treatment=="li",]

mean(KO_null$length)
#[1] 0.3880219
mean(KO_li$length)
#[1] 0.3632416



summary(TG$treatment)
#     - chiron   dmso     gm     li 
#     0   3249   8148   4762      0 


TG_chiron<-TG[TG$treatment=="chiron",]
TG_dmso<-TG[TG$treatment=="dmso",]
TG_gm<-TG[TG$treatment=="gm",]


mean(TG_chiron$length)
#[1] 0.733856
mean(TG_dmso$length)
#[1] 0.8575032
mean(TG_gm$length)
#[1] 0.8121316
