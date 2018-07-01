
* landscape version: 6 plots: BN/AN; Week1, 2, 3-4; Jun 2018
* file body - omitting the 'open' lines at top, and title/gxprint lines at bottom [commented out]

*'open PRCP_CCAFCST_PROB_Jun27_wk1.ctl'
*'open PRCP_CCAFCST_PROB_Jun27_wk2.ctl'
*'open PRCP_CCAFCST_PROB_Jun27_wk34.ctl'

* -----------------------------------------

* set longitude range:
*'set lat -60 70'
*'set lon -180 180'
 
'set gxout grfill'
'set display white' 

* week 1

'set vpage 0.5 5.5 5.5 8'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd a.1*1'
'run cbar'
'draw title (a) Week 1 BN'

'set vpage 5.5 10.5 5.5 8'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd c.1*1'
'run cbar'
'draw title (b) Week 1 AN'

* week 2

'set vpage 0.5 5.5 3 5.5'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd a.2*1'
'run cbar'
'draw title (c) Week 2 BN'
*'set xlint 60'
*'set ylint 30'


'set vpage 5.5 10.5 3 5.5'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd c.2*1'
'run cbar'
'draw title (d) Week 2 AN'

* week 3-4

'set vpage 0.5 5.5 0.5 3'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd a.3*1'
'run cbar'
'draw title (e) Week 3-4 BN'

'set vpage 5.5 10.5 0.5 3'
'set grads off'
'set xlint 1'
'set ylint 1'

'set clevs 20 25 30 35 40 45 50 60'
'set ccols  4 11 5   0   7 12 8 2 6'
'd c.3*1'
'run cbar'
'draw title (f) Week 3-4 AN'
'set vpage off'

* -----------------------------------------

*'draw string 3 8.2 CFSv2 Bihar Precip Fcst Probabilities, June 27 IC  (06/30/18 v7PY)'
*'gxprint PRCP_CCAFCST_PROB_Jun27.pdf'

