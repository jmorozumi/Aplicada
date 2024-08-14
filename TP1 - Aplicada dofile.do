*PROBLEM SET 1

clear
global main "/Users/juanimorozumi/Downloads/PS1"
global input "$main/input"
global output "$main/output"

use "$input/data_russia.dta", clear
*Para limpiar la base de datos vamos a ver que tipode formato tiene las variables
describe

preserve

gen sex_limpia =.
replace sex_limpia = 1 if sex=="female"
replace sex_limpia = 0 if sex=="male"
drop sex

gen obese_limpia =.
replace obese_limpia = 1 if obese=="This person is obese"
replace obese_limpia = 0 if obese=="This person is not obese"
drop obese

gen smokes_limpia =.
replace smokes_limpia = 1 if smokes=="Smokes"
replace smokes_limpia = 0 if smokes=="0"
drop smokes

split hipsiz, parse("circumference ")
drop hipsiz1
drop hipsiz
replace hipsiz2 = "" if hipsiz2 == ","
replace hipsiz2 = subinstr(hipsiz2, ",", ".", .)

split totexpr, parse("expenditures ")
drop totexpr1
drop totexpr
replace totexpr2 = "" if totexpr2 == ","
replace totexpr2 = subinstr(totexpr2, ",", ".", .)

replace tincm_r = "" if tincm_r == ","
replace tincm_r = subinstr(tincm_r, ",", ".", .)


foreach var of varlist econrk powrnk resprk satlif geo wtchng evalhl operat {
tab `var'
}

*
foreach var of varlist econrk powrnk resprk satlif geo {
replace `var' = "." if `var' == ".b"
replace `var' = "." if `var' == ".d"
replace `var' = "." if `var' == ".c"
replace `var' = "1" if `var' == "one"
replace `var' = "2" if `var' == "two"
replace `var' = "3" if `var' == "three"
replace `var' = "4" if `var' == "four"
replace `var' = "5" if `var' == "five"
}

foreach var of varlist wtchng evalhl operat {
replace `var' = "." if `var' == ".b"
replace `var' = "." if `var' == ".d"
replace `var' = "." if `var' == ".c"
replace `var' = "1" if `var' == "one"
replace `var' = "2" if `var' == "two"
replace `var' = "3" if `var' == "three"
replace `var' = "4" if `var' == "four"
replace `var' = "5" if `var' == "five"
}

foreach var of varlist hattac htself {
replace `var' = "." if `var' == ".b"
replace `var' = "." if `var' == ".d"
replace `var' = "." if `var' == ".c"
replace `var' = "1" if `var' == "one"
replace `var' = "2" if `var' == "two"
replace `var' = "3" if `var' == "three"
replace `var' = "4" if `var' == "four"
replace `var' = "5" if `var' == "five"
}


destring, replace

*lista de las variables
ds
* Calcula el porcentaje de valores faltantes para cada variable
* Verifica si el porcentaje de valores faltantes es mayor al 5%
foreach var of varlist * {
    count if missing(`var')
    local missing = r(N)
    local total = _N
    local percent_missing = 100 * `missing' / `total'
	
    if `percent_missing' > 5 {
        display "`var' tiene más del 5% de valores faltantes: " `percent_missing' "%"
    }
}

*Este código hace lo siguiente:

*ds: lista todas las variables en el dataset.
*foreach var of varlist *: recorre cada variable en la lista de variables.
*count if missing(\var')`: cuenta cuántos valores faltantes tiene la variable actual.
*local missing = r(N): guarda el número de valores faltantes en una macro local.
*local total = _N: guarda el número total de observaciones en otra macro local.
*local percent_missing = 100 * \missing' / ⁠ total' ⁠: calcula el porcentaje de valores faltantes.
*if \percent_missing' > 5`: verifica si el porcentaje es mayor al 5%.
*display "var' tiene más del 5% de valores faltantes: " ⁠ percent_missing' "%" ⁠: muestra un mensaje si la variable tiene más del 5% de valores faltantes.*


*Sacamoslos income negativos
replace tincm_r = . if tincm_r<0
replace totexpr2 = . if totexpr2<0

replace totexpr2 = . if totexpr2 > tincm_r


*4) 
 gsort totexpr2
 
order id site sex_limpia

*5) Creamos una variable edad y le pedimos a Stata que tome los valores de "monage" y los divida por 12

gen age=.
replace age = monage/12

estpost summarize sex_limpia age satlif waistc hipsiz2 totexpr2 , listwise

             |  e(count)   e(sum_w)    e(mean) 
-------------+---------------------------------
  sex_limpia |      1003       1003   .5643071 
         age |      1003       1003   48.23703 
      satlif |      1003       1003   2.443669 
      waistc |      1003       1003   85.74686 
     hipsiz2 |      1003       1003   100.9367 
    totexpr2 |      1003       1003   5263.737 

             |    e(Var)      e(sd)     e(min) 
-------------+---------------------------------
  sex_limpia |    .24611   .4960947          0 
         age |  329.0045   18.13848   18.23333 
      satlif |  1.259049   1.122074          1 
      waistc |  188.8681   13.74293         37 
     hipsiz2 |  138.6673   11.77571         40 
    totexpr2 |  1.86e+07   4313.406     147.83 

             |    e(max)     e(sum) 
-------------+----------------------
  sex_limpia |         1        566 
         age |  100.5833   48381.74 
      satlif |         5       2451 
      waistc |       168    86004.1 
     hipsiz2 |       180   101239.5 
    totexpr2 |   37727.6    5279528

*Cambiamos las etiquetas de las variables
label var sex_limpia "Sexo"
label var age "Edad (en años)"
label var satlif "Satisfacción con la vida"
label var waistc "Circunferencia de la cintura"
label var hipsiz2 "Circunferencia de la cadera"
label var totexpr2 "Gasto real"


* Exportamos la tabla
esttab using "$output/tables/Table 1.tex", cells("Obs. Mean Var Sd Min Max Sum")

*6)
*Definimos el estilo para el gráfico
 ssc install grstyle
  grstyle clear

. grstyle init 
. grstyle set horizontal
. grstyle color background white 
. grstyle color heading black // Title in black
. grstyle clear


*Comparamos las distribuciones de la circunferencia de las caderas de hombres y mujeres.
twoway (kdensity hipsiz if sex_limpia==1) (kdensity hipsiz if sex_limpia==0), legend(order(1 "Women" 2 "Men")) title("Distribución de la circunferencia de las caderas") ytitle("Densidad") xtitle("Circunferencia de las caderas")

graph save "Graph" "C:\Users\Usuario\Desktop\Eco Aplicada\PS1\output\grapichs\Gráfico punto 6.gph"

*6.b) ttest hipsiz, by(sex_limpia)

Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
       0 |   1,160    97.67957     .294948    10.04557    97.10088    98.25826
       1 |   1,637    102.9928    .3139317    12.70163     102.377    103.6085
---------+--------------------------------------------------------------------
combined |   2,797    100.7892    .2261775    11.96177    100.3457    101.2327
---------+--------------------------------------------------------------------
    diff |           -5.313223    .4480286               -6.191723   -4.434722
------------------------------------------------------------------------------
    diff = mean(0) - mean(1)                                      t = -11.8591
Ho: diff = 0                                     degrees of freedom =     2795

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.0000         Pr(|T| > |t|) = 0.0000          Pr(T > t) = 1.0000


*AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= MIRAR COMO EXPORTAR LA TABLA

