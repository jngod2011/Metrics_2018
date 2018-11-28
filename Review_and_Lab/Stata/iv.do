	use C:\Users\Sabrina\Desktop\econometrics\iv\grilic.dta,clear
	sum
	pwcorr iq s,sig
	reg lw s expr tenure rns smsa,r
	reg lw s iq expr tenure rns smsa,r
	ivregress 2sls lw s expr tenure rns smsa (iq=med kww mrt age),r

//检验有效工具变量的第一个条件
	estat overid 
//ssc install ivreg2
//ssc install ranktest
	ivreg2 lw s expr tenure rns smsa (iq = med kww mrt age),r orthog(mrt age) //orthog(mrt age)表示检验mrt和age的外生性
	ivregress 2sls lw s expr tenure rns smsa (iq = med kww) ,r first
	estat overid  //检验是否过度识别，接受原假设，认为（med kww)外生
	


//检验有效工具变量的第二个条件，工具变量是否和内生变量相关

	estat firststage,all forcenonrobust //看f检验的统计值

//检查是否存在弱工具变量

//为了稳健起见，用对弱工具变量更不敏感的有限信息最大似然之liml
	ivregress liml lw s expr tenure rns smsa (iq = med kww),r // 结果非常接近，也说明了不存在弱工具变量

	ivreg2 lw s expr tenure rns smsa (iq = med kww), r redundant(kww) //冗余检验（检验弱工具变量问题）

	
	//豪斯曼检验，采用工具变量的前提是存在内生解释变量
	qui reg lw iq s expr tenure rns smsa
	est store ols
	qui ivregress 2sls lw s expr tenure rns smsa (iq = med kww)
	est store iv
	hausman iv ols, constant sigmamore 
//豪斯曼检验在异方差的情形下不成立，可以用异方差稳健的DWH检验
	qui reg lw iq s expr tenure rns smsa,r
	qui ivregress 2sls lw s expr tenure rns smsa (iq = med kww),r
	estat endogenous

//使用ivreg2来进行稳健的内生性检验
	ivreg2 lw s expr tenure rns smsa (iq=med kww),r endog(iq)

//在存在异方差的情况下，gmm比2sls更有效
	ivregress gmm lw s expr tenure rns smsa (iq=med kww)
	estat overid 
//所有工具变量均为外生，可以采用迭代GMM检验
	ivregress gmm lw s expr tenure rns smsa (iq = med kww),igmm


	qui reg lw s expr tenure rns smsa,r
	est store ols_no_iq
	qui reg lw iq s expr tenure rns smsa,r
	est store ols_with_iq
	qui ivregress 2sls lw s expr tenure rns smsa (iq= med kww),r
	est store tsls
	qui ivregress liml lw s expr tenure rns smsa (iq= med kww),r
	est store liml
	qui ivregress gmm lw s expr tenure rns smsa (iq= med kww)
	est store gmm
	qui ivregress gmm lw s expr tenure rns smsa (iq= med kww),igmm
	est store igmm

	esttab ols_no_iq ols_with_iq tsls liml gmm igmm,se r2 mtitle  

esttab ols_no_iq ols_with_iq tsls liml gmm igmm using iv.rtf,se r2 mtitle  

