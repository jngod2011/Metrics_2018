clear all
global root "C:\Users\Sabrina\Desktop\econometrics"
cd "$root"

/******************************************************/
/******************************************************/
/*            heteroskedasticity(异方差)              */
/******************************************************/
/******************************************************/

use nerlove.dta

/******************************************************/
/*                   1.residual plot                  */
/******************************************************/
reg lntc lnq lnpl lnpk lnpf
rvfplot // 观察残差与拟合值的散点图
rvpplot lnq //观察残差与解释变量的散点图，扰动项的方差随观测值而变

/******************************************************/
/*                    2.White Test                    */
/******************************************************/
estat imtest,white // estat是指post-estimation statistics(估计后统计量）,imtest指的是 information matrix test
// ssc install whitetst
// whitetst// 也可以直接下载非官方命令whitetst，然后用whitetst看怀特检验的结果
// p值为0.0000，拒绝同方差的原假设，证明存在异方差

/******************************************************/
/*                     3.BP检验                       */
/******************************************************/
estat hettest //默认设置为使用拟合值ŷ
estat hettest,rhs // 使用方程右边的解释变量，而不是ŷ
estat hettest [varlist] //指定使用某些解释变量
//最初的BP检验假设扰动项ε服从正态分布，具有一定的局限性，后减弱为ε满足独立同分布即可，iid
estat hettest, iid
estat hettest,rhs iid
estat hettest lnq, iid

/******************************************************/
/*                 WLS 加权最小二乘法                 */
/******************************************************/
quietly reg lntc lnq lnpl lnpk lnpf
predict e11,res
g e22=e11^2
g lne22=log(e22)
reg lne22 lnq,noc //R^2=0.75说明lnq可以解释 lne^2 75%的变动，残差平方变动和lnq高度相关
predict lne22f //获得辅助回归的拟合值
g e22f = exp(lne22f) // 去掉对数，获得WLS所要使用的权重的倒数
reg lntc lnq lnpl lnpk lnpf [aw=1/e22f]

reg lntc lnq lnpl lnpk lnpf,r //两者结果存在一点差异，出现这种情况可能是1、因为权重[aw=1/e2f]确定的问题；2、该样本量不够大。Wls方法对应着有多种权重确定的方法，不同的方法对应的结果可能都不一样。当样本容量较大的时候建议使用robust，因为这个方法相对保守，更稳健。如果非要用wls，建议对模型异方差形式具体形式进行诊断一下


/******************************************************/
/******************************************************/
/*             logit model & probit model             */
/******************************************************/
/******************************************************/
use "$root\11.6\womenwk.dta",clear
reg work age married children education,r
logit work age married children education,nolog // nolog是不显示迭代过程
logit work age married children education, r nolog // 加上r就是解决异方差的问题，发现两者区别不大，基本可以认为不存在异方差
logit work age married children education, or nolog // age married children education 最小的变化量至少为1单位，为了方便理解回归结果，可以汇报几率比（在logit模型中汇报几率比是非常常见的作法）
margins,dydx(*) //显示平均边际效应，和ols的回归系数做对比
margins,dydx(*) atmeans //计算在样本均值处的边际效应
margins,dydx(*) at(age==30) //变量age在age=30处的边际效应
margins,dydx(age) // 解释变量age的平均边际效应
margins,eyex(*) //计算平均弹性，其中两个'e'指的是弹性
margins,eydx(*) //计算平均半弹性，x变化一个单位，y变化百分之多少
margins,dyex(*(=) //计算平均半弹性，x变化1%，y变化几个单位
logit work age married children education , nolog vce(cluster age) //假定年龄相同的个体存在组内相关，使用age为聚类变量来计算聚类稳健的标准误

//probit
probit work age married children education ,nolog
margins,dydx(*)
