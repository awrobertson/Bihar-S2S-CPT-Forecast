#! /bin/bash
#Script to produce CCA forecast and assess associated skill,
# using NCEP subseasonal rainfall  (4 inits per month), vs IMD data. 
#Author: Á.G. Muñoz (agmunoz@iri.columbia.edu), Andrew W. Robertson and Remi Cousin
#This version: 28 Jun 2018, Modified by AWR
#First version: 12 Dec 2017
#
#Output:
# + Several skill maps for assessment of deterministic forecast, in the output folder.
# + CPT scripts used to assess skill, in the scripts folder.
# + Downloaded input files, in the input folder.
#Notes:
#0. Old data in the input folder is deleted at the beginning of the process!
#1. *Weekly* initializations available per month are used, concatenated.
#2. The T coordinate has been faked, so CPT can deal with all the initializations.
#3. Spatial subsetting is now possible in this version of the script.
#4. Rainfall observations are IMD data (India) at 0.25 deg. (Land only)
#5. Requires pre-computed lead-dependent climo
#5. IMD Lead week DEFINITIONS: week 1 3-9; week 2 10-16; week 3+4 17-30:
#8. This version produces forecasts and skill metric using CCA. 
#9. FORECAST VERSION: Trains model on the calendar month containing the forecast start day (not optimal!)
#10. Grads output version 
#11. v3: climos are calculated on the fly
#12. v4: climo is just mean of 3 perturbed runs, for speed
#13. v5: REAL TIME FORECAST USES the 4 6-hourly forecasts from 'fday' as well as 24Z;  fday will be the previous day from today! Also fixed to include CONTROL member on training
#14. v7: (a) # a) Includes ctrl member in the climo, and (b) Uses only the 4 6-hr starts on the forecast day, typically Wed (does NOT include 00Z of the next day, ie Thurs)

####START OF USER-MODIFIABLE SECTION######

# Forecast date
declare -a mon=('Jun') 
fyr=2018 # Forecast year
fday=27 # Forecast day  (Yesterday in real time)


# Forecast lead interval
wk=1 # week lead label
day1=3 # First daily lead selected. For NCEP model, L1=1 is accum tp after 1 day
day2=9 # Last daily lead selected.
nda=7 # Length of target period (days)

let day1m=$day1-1 
let fdayp=$fday+1
#nda=$day2-$day1

#Spatial domain for predictor
nla1=32 # Northernmost latitude
sla1=12 # Southernmost latitude
wlo1=74 # Westernmost longitude
elo1=92 # Easternmost longitude
#Spatial domain for predictand
nla2=27 # Northernmost latitude
sla2=22 # Southernmost latitude
wlo2=80 # Westernmost longitude
elo2=89 # Easternmost longitude

#PATH to CPT root directory
#cptdir='/Users/agmunoz/Documents/Angel/CPT/CPT/15.7.3/'
cptdir='/Users/andy/Dropbox/pgm/stats/CPT/CPT15/15.7.3/'

#S2S Database key
#Angel key='017a28e8531cac13efd89be8a7612c4c0754a83606f8f90270d14d84f62c28d7ff7fe8fbfb04c0495ddf938392d0bf3d9617e8b7'
# AWR key
key='f7a5c7a57103d4ed1be1224f814b01b77951a6c20a4cbe85dd6b1942af7e479b11e3443a819d6bd601ac35070c7e5667e84e23f5'

####END OF USER-MODIFIABLE SECTION######
####DO NOT CHANGE ANYTHING BELOW THIS LINE####

clear
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Script to assess raw Week23 skill of NCEP subseasonal rainfall forecasts - all inits per month, against IMD data. 
echo Authors: Á.G. Muñoz, Andrew W. Robertson and Remi Cousin @ IRI - Earth Institute - Columbia U.
echo Email: agmunoz@iri.columbia.edu 
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo
echo
#Prepare folders
echo Creating working folders, if not already there...
mkdir -p input
mkdir -p output
mkdir -p scripts
rm -Rf input/model_*.tsv input/obs_*.tsv  #comment if deletion of old input files is not desired.
rm -Rf scripts/*
day1f=$(($day1+1))

cd input
#Set up some parameters
export CPT_BIN_DIR=${cptdir}

#Start month loop
for mo in "${mon[@]}"
do

  echo ---------------------------------------------------
  echo Downloading hindcasts and observations for ${mo} ...
  
# Download hindcasts (NCEP)

url='http://iridl.ldeo.columbia.edu/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.perturbed/.sfc_precip/.tp/%5BM%5Daverage/3./mul/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.control/.sfc_precip/.tp/add/4./div/X/'${wlo1}'/'${elo1}'/RANGE/Y/'${sla1}'/'${nla1}'/RANGE/L1/'${day1m}'/'${day2}'/VALUES/%5BL1%5Ddifferences/S/('${mo}')/VALUES/S/7/STEP/dup/S/npts//I/exch/NewIntegerGRID/replaceGRID/dup/I/5/splitstreamgrid/%5BI2%5Daverage/sub/I/3/-1/roll/.S/replaceGRID/L1/S/add/0/RECHUNK//name//T/def/2/%7Bexch%5BL1/S%5D//I/nchunk/NewIntegerGRID/replaceGRIDstream%7Drepeat/use_as_grid/c://name//water_density/def/998/%28kg/m3%29/:c/div//mm/unitconvert//name/(tp)/def/grid://name/%28T%29/def//units/%28months%20since%201960-01-01%29/def//standard_name/%28time%29/def//pointwidth/1/def/16/Jan/1901/ensotime/12./16/Jan/1960/ensotime/:grid/use_as_grid/-999/setmissing_value/%5BX/Y%5D%5BT%5Dcptv10.tsv'

  echo $url
  curl -g -k -b '__dlauth_id='$key'' ''$url'' > model_precip_${mo}.tsv
  
# Download IMD observations

url='http://iridl.ldeo.columbia.edu/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.control/.sfc_precip/.tp/S/(0000%201%20Jan%201999)/(0000%2031%20Dec%202010)/RANGEEDGES/L1/'${day1m}'/'${day2}'/VALUES/%5BL1%5Ddifferences/S/('${mo}')/VALUES/S/7/STEP/L1/S/add/0/RECHUNK//name//T/def/2/%7Bexch%5BL1/S%5D//I/nchunk/NewIntegerGRID/replaceGRIDstream%7Drepeat/use_as_grid/SOURCES/.IMD/.NCC1-2005/.v4p0/.rf/T/(days%20since%201960-01-01)/streamgridunitconvert/T/(1%20Jan%201999)/(31%20Dec%202011)/RANGEEDGES/T/'${nda}'/runningAverage/'${nda}'/mul/T/2/index/.T/SAMPLE/nip/dup/T/npts//I/exch/NewIntegerGRID/replaceGRID/dup/I/5/splitstreamgrid/%5BI2%5Daverage/sub/I/3/-1/roll/.T/replaceGRID/-999/setmissing_value/grid%3A//name/(T)/def//units/(months%20since%201960-01-01)/def//standard_name/(time)/def//pointwidth/1/def/16/Jan/1901/ensotime/12./16/Jan/1960/ensotime/%3Agrid/use_as_grid/%5BX/Y%5D%5BT%5Dcptv10.tsv'

  echo $url
  curl -g -k -b '__dlauth_id='$key'' ''$url'' > obs_precip_${mo}.tsv

# Download forecast file

#v6
#url='http://iridl.ldeo.columbia.edu/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.perturbed/.sfc_precip/.tp/%5BM%5Daverage/X/70/100/RANGE/Y/0/40/RANGE/L1/'${day1m}'/'${day2}'/VALUES/%5BL1%5Ddifferences/L1/removeGRID/S/(0000%20'${fday}'%20'${mon}')/VALUES/%5BS%5Daverage/c%3A//name//water_density/def/998/(kg/m3)/%3Ac/div//mm/unitconvert/SOURCES/.NOAA/.NCEP/.EMC/.CFSv2/.6_hourly_rotating/.FLXF/.surface/.PRATE/S/(0000%20'${fday}'%20'${mon}'%20'${fyr}')/(0000%20'${fdayp}'%20'${mon}'%20'${fyr}')/RANGE/%5BM%5Daverage/%5BL%5D1/0.0/boxAverage/%5BX/Y%5DregridAverage/L/'${day1}'/'${day2}'/RANGEEDGES/%5BL%5Daverage/%5BS%5Daverage/c%3A//name//water_density/def/998/(kg/m3)/%3Ac/div/(mm/day)/unitconvert/'${nda}'/mul//units/(mm)/def/exch/sub/X/'${wlo1}'/'${elo1}'/RANGE/Y/'${sla1}'/'${nla1}'/RANGE/grid%3A//name/(T)/def//units/(months%20since%201960-01-01)/def//standard_name/(time)/def//pointwidth/1/def/1/Jan/2001/ensotime/12.0/1/Jan/2001/ensotime/%3Agrid/addGRID/T//pointwidth/0/def/pop//name/(tp)/def//units/(mm)/def//long_name/(precipitation_amount)/def/-999/setmissing_value/%5BX/Y%5D%5BT%5Dcptv10.tsv'

#v7:
# a) Includes ctrl member in the climo
# b) Uses only the 4 6-hr starts on the forecast day, typically Wed (does NOT include 00Z of the next day, ie Thurs)
url='http://iridl.ldeo.columbia.edu/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.perturbed/.sfc_precip/.tp/%5BM%5Daverage/3./mul/SOURCES/.ECMWF/.S2S/.NCEP/.reforecast/.control/.sfc_precip/.tp/add/4./div/X/70/100/RANGE/Y/0/40/RANGE/L1/'${day1m}'/'${day2}'/VALUES/%5BL1%5Ddifferences/L1/removeGRID/S/(0000%20'${fday}'%20'${mon}')/VALUES/%5BS%5Daverage/c%3A//name//water_density/def/998/(kg/m3)/%3Ac/div//mm/unitconvert/SOURCES/.NOAA/.NCEP/.EMC/.CFSv2/.6_hourly_rotating/.FLXF/.surface/.PRATE/S/(0000%20'${fday}'%20'${mon}'%20'${fyr}')/(1800%20'${fday}'%20'${mon}'%20'${fyr}')/RANGE/%5BM%5Daverage/%5BL%5D1/0.0/boxAverage/%5BX/Y%5DregridAverage/L/'${day1}'/'${day2}'/RANGEEDGES/%5BL%5Daverage/%5BS%5Daverage/c%3A//name//water_density/def/998/(kg/m3)/%3Ac/div/(mm/day)/unitconvert/'${nda}'/mul//units/(mm)/def/exch/sub/X/'${wlo1}'/'${elo1}'/RANGE/Y/'${sla1}'/'${nla1}'/RANGE/grid%3A//name/(T)/def//units/(months%20since%201960-01-01)/def//standard_name/(time)/def//pointwidth/1/def/1/Jan/2001/ensotime/12.0/1/Jan/2001/ensotime/%3Agrid/addGRID/T//pointwidth/0/def/pop//name/(tp)/def//units/(mm)/def//long_name/(precipitation_amount)/def/-999/setmissing_value/%5BX/Y%5D%5BT%5Dcptv10.tsv'

  echo $url
  curl -g -k -b '__dlauth_id='$key'' ''$url'' > modelfcst_precip_fday${fday}.tsv


#Create CPT script
  cd ../scripts
  echo ---------------------------------------------------
  echo Producing CPT scripts for ${mo} ...

cat  <<< '#!/bin/bash 
'${cptdir}'CPT.x <<- END
611 # Opens CCA
1 # Opens X input file
../input/model_precip_'${mo}'.tsv
'${nla1}' # Nothernmost latitude
'${sla1}' # Southernmost latitude
'${wlo1}' # Westernmost longitude
'${elo1}' # Easternmost longitude

1    # Minimum number of modes
10 # Maximum number of modes

3 # Opens forecast (X) file
../input/modelfcst_precip_fday'${fday}'.tsv

2 # Opens Y input file
../input/obs_precip_'${mo}'.tsv
'${nla2}' # Nothernmost latitude
'${sla2}' # Southernmost latitude
'${wlo2}' # Westernmost longitude
'${elo2}' # Easternmost longitude

1    # Minimum number of modes
10 # Maximum number of modes

1    # Minimum number of CCA modes
5    # Maximum number of CCAmodes

4 # X training period
1901 # First year of X training period
5 # Y training period
1901 # First year of Y training period


531 # Goodness index
3 # Kendalls tau

7 # Option: Lenght of training period
55 # Lenght of training period 
8 # Option: Length of cross-validation window
3 # Enter length

541 # Turn ON Transform predictand data
# 542 # Turn ON zero bound for Y data
545 # Turn ON synchronous predictors
#561 # Turn ON p-values for skill maps

544 # Missing value options
-999 # Missing value X flag:
10 # Maximum % of missing values
10 # Maximum % of missing gridpoints
1 # Number of near-neighbours
4 # Missing value replacement : best-near-neighbours
-999 # Y missing value flag
10 # Maximum % of missing values
10 # Maximum % of missing stations
1 # Number of near-neighours
4 # Best near neighbour

#554 # Transformation seetings
#1   #Empirical distribution


# Cross-validation
112 # save goodness index
../output/PRCP_Kendallstau_CCA_'${mo}'_wk'${wk}'

#######BUILD MODEL AND VALIDATE IT  !!!!!
311 # Cross-validation

131 # select output format
3 # GrADS format

413 # cross-validated skill maps
2 # save Spearmans Correlation
../output/PRCP_Spearman_CCA_'${mo}'_wk'${wk}'

413 # cross-validated skill maps
3 # save 2AFC score
../output/PRCP_2AFC_CCA_'${mo}'_wk'${wk}'

413 # cross-validated skill maps
10 # save 2AFC score
../output/PRCP_RocBelow_CCA_'${mo}'_wk'${wk}'

413 # cross-validated skill maps
11 # save 2AFC score
../output/PRCP_RocAbove_CCA_'${mo}'_wk'${wk}'

#######FORECAST(S)  !!!!!
455 # Probabilistic (3 categories) maps
111 # Output results
501 # Forecast probabilities
../output/PRCP_CCAFCST_PROB_'${fday}'_wk'${wk}'
#502 # Forecast odds
0 #Exit submenu

#0 # Stop saving  (not needed in newest version of CPT)

0 # Exit
END
' > CCA_SkillandForecast_${mo}.cpt 

#Execute CPT and produce skill maps
  echo ---------------------------------------------------
  echo Executing CPT and producing skill maps for ${mo} ...
  chmod 755 CCA_SkillandForecast_${mo}.cpt 
  ./CCA_SkillandForecast_${mo}.cpt #| grep Error

  cd ../input

  echo Done with ${mo} !! Check output folder for results.
  echo
  echo
done
