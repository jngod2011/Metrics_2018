	clear all
	global root "C:\Users\Sabrina\Desktop\econometrics\olsnew"
	cd "$root"
	use variables_setting_new,clear 
	keep lnhw male age mino marrige edu ew ew2 g_health cparty ra_exp_soc2 emp* rank3_al c_id


	label var c_id "citycode" 
	label var edu  "教育年限"
	label var ew   "工作经验"
	label var ew2  "工作经验平方"
	label var age  "年龄"
	label var rank3_al "家庭成分" 
	label var male     "是否为男性"
	label var mino   "是否为少数民族"
	label var marrige  "是否已婚有配偶"

	label var cparty   "是否为党员" 
	label var g_health "自评健康状况"

	label var emp_sec   "行业"
	label var emp_ship  "所有制"
	label var emp_contr   "合同类型"
	label var emp_occup  "职业"
	label var emp_num   "单位规模"
	label var lnhw      "小时工资对数"

	label var ra_exp_soc2  "人情往来支出"


	label def rank3_v 1 "New-elite" 2 "Old-elite" 3 "Non-elite"  //creates a value label named rank3_v, which is a set of individual numeric values and their corresponding labels. 

	label val rank3_al rank3_v //attaches rank3_v to rank3_al.
	save chip2002_rank,replace
	tab rank3_al,gen(rank)

	foreach i in num sec ship contr occup {

	tab emp_`i',gen(`i')

	}

	tab c_id,gen(cid)

	global cid cid1-cid76
	global dem age male mino marrige
	global hc  edu ew ew2 g_health
	global pc  cparty ra_exp_soc2
	global wc  num1 num2 num3 contr1 contr2 contr3 contr4 sec1 sec2 sec3 sec4 sec5 sec6 sec7 ship1 ship2 ship3 ship4 ship5 occup1 occup2 occup3 occup4



	estpost tabstat lnhw male age mino marrige edu ew g_health cparty ra_exp_soc2 ship1-ship6 sec1-sec8 occup1-occup5 num1-num4 contr1-contr5, by(rank3_al) statistics(mean sd N) col(statistics) 
    
	esttab, main(mean %9.3f) aux(sd %9.3f) replace nogap compress unstack obslast nolabel order (lnhw male age mino marrige edu ew g_health cparty ra_exp_soc2) 
	   
	   

	reg lnhw rank1 rank2 ${dem},robust  

	est store reg_1 


	

	reg lnhw rank1 rank2 ${dem} ${cid},r 

	est store reg_2 


	

	reg lnhw rank1 rank2 ${dem} ${hc} ${cid},r 

	est store reg_3 

	

	reg lnhw rank1 rank2 ${dem} ${hc} ${pc} ${cid},r 

	est store reg_4 


	reg lnhw rank1 rank2 ${dem} ${hc} ${pc} ${wc} ${cid},r 

	est store reg_5 

       
	esttab reg_1 reg_2 reg_3 reg_4 reg_5 


	esttab reg_1 reg_2 reg_3 reg_4 reg_5, b(%6.3f) se(%6.3f) nogaps compress star(* 0.1 ** 0.05 *** 0.01) replace r2(%6.3f) obslast keep(rank1  rank2  ${dem} ${hc} ${pc} ${wc} _cons) order(rank2 rank1  ${dem} ${hc} ${pc} ${wc} _cons)  
