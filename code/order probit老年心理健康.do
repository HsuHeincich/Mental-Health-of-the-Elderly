capture log close
log using eh,replace
version 14.0
set more off
cd D:\CHARLSdata\all\do文件
*your commands start
/*2011*/
do charls2011
use D:\CHARLSdata\charls2011\CHARLS2011r\exp_income_wealth,clear
/*2011 is consistent with 2013,ID householdID start*/
gen ID_t1=substr(ID,1,10)
gen ID_t2=substr(ID,-2,2)
gen ID_t=ID_t1+ID_t2
gen householdID_t=substr(ID_t,1,10)
drop ID householdID ID_t1 ID_t2
rename ID_t ID
rename householdID_t householdID
order ID,first
order householdID,after(ID)
sort ID    
/*2011 is consistent with 2013,ID householdID ending*/
keep ID householdID communityID INCOME_PC WEALTH_PC
save D:\CHARLSdata\all\2011inc_asset.dta,replace
cd D:\CHARLSdata\all
merge 1:1 ID using final2011,keep(match) nogenerate
rename INCOME_PC iincome
rename WEALTH_PC iwealth
keep ID householdID communityID iincome iwealth SC snum fmembers H0 gender age hukou edu marriage livemode SRH2 smok medicare MH mem memory life newSSC stdnewSSC
drop if hukou>2
drop if iincome<=0
drop if iwealth<=0
winsor2 iincome iwealth if hukou==0,replace cuts(1 99) trim 
winsor2 iincome iwealth if hukou==1,replace cuts(1 99) trim
egen mis=rowmiss( _all )
drop if mis
drop mis
order SC,after( iwealth )
label variable iincome "家庭人均收入"
label variable iwealth "家庭人均资本"
label variable SC "社会活动参与"
label variable snum "是否与配偶同住"
label variable fmembers "家庭人口规模"
label variable H0 "儿童时期自评健康状况"
label variable gender "性别"
label variable age "年龄"
label variable hukou "户口"
label variable edu "受教育年限"
label variable marriage "婚姻状况"
label variable livemode "居住模式"
label variable SRH2 "自评健康2"
label variable smok "是否吸烟"
label variable medicare "是否参加医保"
label variable MH "心理健康"
label variable newSSC "社区社会资本（社区机构设施）"
drop if gender==0
replace gender=0 if gender==2
label define gender 2 "", modify
label define gender 0 "0 female", add
tabulate gender,missing
replace hukou=0 if hukou==2
label define i38 3 "", modify
label define i38 4 "", modify
label define i38 2 "", modify
label define i38 0 "0 Non-Agricultural Hukou", add
tabulate hukou,missing
gen IH= H0<=4 if !missing(H0)
label define IH 0 "0 not health" 1 "1 health"
label values IH IH
label variable IH "初始健康"
tabulate IH,missing
drop if age<45
gen ageclass=1 if age<60
replace ageclass=2 if age>=60 & age<=70
replace ageclass=3 if age>70
label variable ageclass "年龄段"
label data "老年心理健康2011"
save eh2011,replace


/*2013*/
cd D:\CHARLSdata\all\do文件
do charls2013
cd D:\CHARLSdata\all
use D:\CHARLSdata\charls2013\CHARLS2013r\exp_income_wealth,clear
keep ID householdID communityID INCOME_PC WEALTH_PC
save D:\CHARLSdata\all\2013inc_asset.dta,replace
use final2011,clear
keep ID householdID communityID H0
rename H0 H02011
save h02011,replace
use final2013,clear
merge 1:1 ID using h02011,gen(m1)
keep if m1==1 | m1==3
replace H0=H02011 if H0==. & m1==3
drop H02011 m1
merge 1:1 ID using 2013inc_asset,keep(match) nogenerate
rename INCOME_PC iincome
rename WEALTH_PC iwealth
keep ID householdID communityID iincome iwealth SC snum fmembers H0 gender age hukou edu marriage livemode SRH2 smok medicare MH mem memory life sibinc sibexp friinc friexp comexp newSSC stdnewSSC
drop if hukou>2
drop if iincome<=0
drop if iwealth<=0
winsor2 iincome iwealth if hukou==0,replace cuts(1 99) trim 
winsor2 iincome iwealth if hukou==1,replace cuts(1 99) trim
egen mis=rowmiss( _all )
drop if mis
drop mis
order SC,after( iwealth )
gen SRH= SRH2<=3 
label define SRH 0 "not health" 1 "health"
label variable SRH "自评是否健康"
label define SRH 0 "否", modify
label define SRH 0 "no", modify
label define SRH 1 "yes", modify
label values SRH SRH
gen live=(fmembers==1)
label variable live "是否独居"
label define livealone 0 "no" 1 "yes"
label values live livealone
label variable iincome "家庭人均收入"
label variable iwealth "家庭人均资本"
label variable SC "社会活动参与"
label variable snum "是否与配偶同住"
label variable fmembers "家庭人口规模"
label variable H0 "儿童时期自评健康状况"
label variable gender "性别"
label variable age "年龄"
label variable hukou "户口"
label variable edu "受教育年限"
label variable marriage "婚姻状况"
label variable livemode "居住模式"
label variable SRH2 "自评健康2"
label variable smok "是否吸烟"
label variable medicare "是否参加医保"
label variable MH "心理健康"
drop if gender==0
replace gender=0 if gender==2
label define ba000_w2_3 2 "", modify
label define ba000_w2_3 0 "0 femal", add
tabulate gender,missing
replace hukou=0 if hukou==2
label define bc001 2 "", modify
label define bc001 0 "0 Non-agricultural Hukou", add
label define bc001 3 "", modify
label define bc001 4 "", modify
tabulate hukou,missing
gen IH= H0<=4 if !missing(H0)
label define IH 0 "0 not health" 1 "1 health"
label values IH IH
label variable IH "初始健康"
tabulate IH,missing
drop if age<45
gen ageclass=1 if age<60
replace ageclass=2 if age>=60 & age<=70
replace ageclass=3 if age>70
label variable ageclass "年龄段"
label variable sibinc "来自兄弟姐妹的收入"
label variable sibexp "提供兄弟姐妹的支出"
label variable friinc "来自亲朋的收入"
label variable friexp "提供亲朋的支出"
label variable comexp "通讯支出"
label variable newSSC "社区社会资本（社区机构设施）"
label variable mem "记住词汇量"
label data "老年心理健康2013"
save eh2013,replace
use eh2013,clear
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
oprobit MH incD weaD stdSC gender hukou edu i.marriage smok medicare IH

*your commands end
translate eh.smcl eh.log,replace



