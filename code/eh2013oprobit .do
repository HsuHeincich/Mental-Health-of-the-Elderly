capture log close
log using eh2013oprobit,replace
version 14.0
set more off
*your commands start
cd D:\CHARLSdata\all
use eh2013,clear
gen newmemory=0 if memory==1
replace newmemory=1 if memory>1
label variable newmemory "记忆水平"
label define newmemory 0 "0 poor" 1 "1 good" 
label values newmemory newmemory
gen newMH= MH+5
replace newMH=1 if newMH==9
replace newMH=2 if newMH==8
replace newMH=3 if newMH==7
replace newMH=4 if newMH==6
label variable newMH "心理健康（1很不好）"
label define newMHz 1 "verybad" 2 "bad" 3 "fair" 4 "good"
label values newMH newMHz
tab1 MH newMH
gen newSRH2= SRH2+6
replace newSRH2=1 if newSRH2==11
replace newSRH2=2 if newSRH2==10
replace newSRH2=3 if newSRH2==9
replace newSRH2=4 if newSRH2==8
replace newSRH2=5 if newSRH2==7
label variable newSRH2 "自评健康（1很不好）"
label define newSRH2 1 "verybad" 2 "bad" 3 "fair" 4 "good" 5 "verygood"
label values newSRH2 newSRH2
tab1 SRH2 newSRH2
gen liincome=ln( iincome )
gen liwealth=ln( iwealth )
label variable liincome "家庭人均收入对数"
label variable liwealth "家庭人均资产对数"
gen newmarriage=marriage==1
label variable newmarriage "是否与配偶一起生活"
label define newmarriage 1 "1 yes" 0 "0 no"
label values newmarriage newmarriage
tabulate newmarriage
gen oldage=1 if age>=70
replace oldage=0 if age>=60&age<70
replace oldage=2 if age<60
tabulate oldage,missing
gen newSRH=0 if newSRH2<=3
replace newSRH=1 if newSRH2>3
label variable newSRH "自评健康两分类"
label define newSRH 0 "bad" 1"good"
label values newSRH newSRH
save eh2013test,replace
/*生成相对剥夺指数*/
use eh2013test,clear
drop if age<60
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou edu newmarriage smok newSRH || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)
*农村
use eh2013test,clear
drop if hukou==0
drop if age<60
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
oprobit newMH stdSC IH gender age hukou edu newmarriage live smok life
estimates store oprobit1_1
esttab oprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory stdSC IH gender age hukou edu newmarriage live smok life
estimates store probit1_1
esttab probit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)

oprobit newMH incD weaD IH gender age hukou edu newmarriage live smok life
estimates store oprobit2_1
esttab oprobit2_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory incD weaD IH gender age hukou edu newmarriage live smok life
estimates store probit2_1
esttab probit2_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)

oprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life
estimates store oprobit3_1
esttab oprobit3_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life
estimates store probit3_1
esttab probit3_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)

meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit2_1
esttab meoprobit2_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit3_1
esttab meoprobit3_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD sincD sweaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit4_1
esttab meoprobit4_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit5_1
esttab meoprobit5_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)

/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)

*农村低龄：
use eh2013test,clear
drop if hukou==0
drop if age<60
keep if oldage==0
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)


*农村高龄：
use eh2013test,clear
drop if hukou==0
drop if age<60
keep if oldage==1
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)



*城镇
use eh2013test,clear
drop if hukou==1
drop if age<60
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
oprobit newMH stdSC IH gender age hukou edu newmarriage live smok life
estimates store oprobit1_0
esttab oprobit1_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory stdSC IH gender age hukou edu newmarriage live smok life
estimates store probit1_0
esttab probit1_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)

oprobit newMH incD weaD IH gender age hukou edu newmarriage live smok life
estimates store oprobit2_0
esttab oprobit2_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory incD weaD IH gender age hukou edu newmarriage live smok life
estimates store probit2_0
esttab probit2_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)


oprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life
estimates store oprobit3_0
esttab oprobit3_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)
probit newmemory stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life
estimates store probit3_0
esttab probit3_0,mtitles se star(* 0.1 ** 0.05 *** 0.01)

meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit2_1
esttab meoprobit2_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit3_1
esttab meoprobit3_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD sincD sweaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit4_1
esttab meoprobit4_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD IH gender age hukou edu newmarriage live smok life || communityID:
estimates store meoprobit5_1
esttab meoprobit5_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)

/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)


*城镇低龄
use eh2013test,clear
drop if hukou==1
drop if age<60
keep if oldage==0
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)


*城镇高龄
use eh2013test,clear
drop if hukou==1
drop if age<60
keep if oldage==1
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*模型*/
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou newSRH edu newmarriage smok || communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou newSRH edu newmarriage smok|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)





/*低龄*/
use eh2013test,clear
keep if oldage==0
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou edu newmarriage smok newSRH || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)
/*高龄*/
use eh2013test,clear
keep if oldage==1
gen iincome_d= iincome
gsort - iincome_d
gen siincome=sum( iincome_d )
sort iincome
egen uiincome=mean( iincome )
gen nuiincome=_N*uiincome[1]
gen miincome=(_N-_n)* iincome[_n]
gen s_miincome=siincome[_n+1]-miincome[_n]
replace s_miincome=0 if s_miincome==.
gen incD= s_miincome/nuiincome
drop iincome_d siincome uiincome nuiincome miincome s_miincome
gen iwealth_d= iwealth
gsort - iwealth_d
gen siwealth=sum( iwealth_d )
sort iwealth
egen uiwealth=mean( iwealth )
gen nuiwealth=_N*uiwealth[1]
gen miwealth=(_N-_n)* iwealth[_n]
gen s_miwealth=siwealth[_n+1]-miwealth[_n]
replace s_miwealth=0 if s_miwealth==.
gen weaD= s_miwealth/nuiwealth
drop iwealth_d siwealth uiwealth nuiwealth miwealth s_miwealth
egen stdSC=std(SC)
egen stdincD=std( incD )
egen stdweaD=std( weaD )
* 生成社区社会资本
bysort communityID:egen SSC=mean( SC )
egen stdSSC=std( SSC )
sum SSC stdSSC
*生成社区相对剥夺指数
bysort communityID:egen sincome=mean( iincome )
bysort communityID:egen swealth=mean( iwealth )
sum sincome swealth
gen sincome_d= sincome
gsort - sincome_d
gen ssincome=sum( sincome_d )
sort sincome
egen usincome=mean( sincome )
gen nusincome=_N*usincome[1]
gen msincome=(_N-_n)* sincome[_n]
gen s_msincome=ssincome[_n+1]-msincome[_n]
replace s_msincome=0 if s_msincome==.
gen sincD_t= s_msincome/nusincome
bysort communityID:egen sincD=mean(sincD_t)
drop sincome_d ssincome usincome nusincome msincome s_msincome sincD_t
gen swealth_d= swealth
gsort - swealth_d
gen sswealth=sum( swealth_d )
sort swealth
egen uswealth=mean( swealth )
gen nuswealth=_N*uswealth[1]
gen mswealth=(_N-_n)* swealth[_n]
gen s_mswealth=sswealth[_n+1]-mswealth[_n]
replace s_mswealth=0 if s_mswealth==.
gen sweaD_t= s_mswealth/nuswealth
bysort communityID:egen sweaD=mean(sweaD_t)
drop swealth_d sswealth uswealth nuswealth mswealth s_mswealth sweaD_t
sum newMH newmemory incD weaD stdSC gender age edu newmarriage live smok life IH
sum stdSSC sincD sweaD
/*版本二*/
tabulate newMH
sum newMH SC incD weaD SSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH  
meoprobit newMH || communityID:
estimates store meoprobit1_1
esttab meoprobit1_1,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD gender oldage hukou edu newmarriage smok newSRH || communityID:
estimates store meoprobit1_2
esttab meoprobit1_2,mtitles se star(* 0.1 ** 0.05 *** 0.01)
meoprobit newMH stdSC incD weaD stdSSC sincD sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_3
esttab meoprobit1_3,mtitles se star(* 0.1 ** 0.05 *** 0.01)
margins,dydx(*) predict(outcome(1))
margins,dydx(*) predict(outcome(2))
margins,dydx(*) predict(outcome(3))
margins,dydx(*) predict(outcome(4))
meoprobit newMH stdSC incD weaD c.stdSC#c.incD c.stdSC#c.weaD stdSSC sincD sweaD c.stdSSC#c.sincD c.stdSSC#c.sweaD gender oldage hukou edu newmarriage smok newSRH|| communityID:
estimates store meoprobit1_4
esttab meoprobit1_4,mtitles se star(* 0.1 ** 0.05 *** 0.01)
/*剔除组内观测小于10
bys communityID:gen freq=_N
drop if freq<10
*/
log close
translate eh2013oprobit.smcl eh2013oprobit.log,replace
