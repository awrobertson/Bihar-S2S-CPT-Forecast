
* landscape version: 6 plots: BN/AN; Week1, 2, 3-4; Jul 2018
* file body - omitting the 'open' lines at top, and title/gxprint lines at bottom [commented out]

*'open PRCP_Spearman_Jun_wk1.ctl'
*'open PRCP_Spearman_Jun_wk2.ctl'
*'open PRCP_Spearman_Jun_wk34.ctl'

* -----------------------------------------

* set longitude range:
*'set lat -60 70'
*'set lon -180 180'
 
'set gxout grfill'
'set display white' 

*'set vpage 0 3.5 4 8'
'set vpage 0.25 4.25 5 8.5'
'set grads off'
*'set clevs   -.6 -.5 -.4 -.3 -.2 -.1 .1 .2 .3 .4 .5 .6'
*'set ccols  9   14  4  11  13  3   0   10  7 12 8   2 6'
'set clevs 0.001 0.1 0.25 0.35 0.5 0.65 0.75 0.85'
'set ccols 0 9   4   5     3  7    12    8 2'

'd a.1'
'draw title (a) Week 1'
'run cbar'

*'set vpage 3.5 7 4 8'
'set vpage 4.25 8.25 5 8.5'
'set grads off'
'set clevs 0.001 0.1 0.25 0.35 0.5 0.65 0.75 0.85'
'set ccols 0 9   4   5     3  7    12    8 2'
'd a.2'
'draw title (a) Week 2'
'run cbar'

*'set vpage 7 10.5 4 8'
'set vpage 0.25 4.25 1 5'
'set grads off'
'set clevs 0.001 0.1 0.25 0.35 0.5 0.65 0.75 0.85'
'set ccols 0 9   4   5     3  7    12    8 2'
'd a.3'
'draw title (a) Week 3-4'
'run cbar'

'set vpage off'

* -----------------------------------------

*'draw string 3 9 CFSv2 Bihar Precip Fcst Probabilities, June 27 IC  (06/30/18 v7PY)'
*'gxprint PRCP_CCAFCST_PROB_Jun27.pdf'

