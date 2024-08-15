/******************************************************************************
                            PROBLEM SET 1
******************************************************************************/

/* 
1) Set up environment
==============================================================================
*/
clear // Limpia la memoria para comenzar con un entorno limpio

* Define las rutas principales para facilitar la carga y guardado de archivos
global main "/Users/juanimorozumi/Documents/GitHub/Aplicada/Trabajo práctico 1/PS1"
global input "$main/input"
global output "$main/output"

* Carga la base de datos "data_russia.dta" desde la ruta definida
use "$input/data_russia.dta", clear 

* Explora la estructura y tipo de variables presentes en la base de datos
describe

preserve // Guarda una copia temporal de la base para posibles restauraciones

/* 
2) Data cleaning
==============================================================================
*/
* Creación de nuevas variables limpias para mayor claridad
gen sex_limpia = .
replace sex_limpia = 1 if sex == "female"
replace sex_limpia = 0 if sex == "male"
drop sex // Se elimina la variable original para evitar duplicados

gen obese_limpia = .
replace obese_limpia = 1 if obese == "This person is obese"
replace obese_limpia = 0 if obese == "This person is not obese"
drop obese

gen smokes_limpia = .
replace smokes_limpia = 1 if smokes == "Smokes"
replace smokes_limpia = 0 if smokes == "0"
drop smokes

* Limpieza y conversión de variables numéricas
split hipsiz, parse("circumference ") // Divide "hipsiz" en múltiples variables
drop hipsiz1 hipsiz
replace hipsiz2 = "" if hipsiz2 == ","
replace hipsiz2 = subinstr(hipsiz2, ",", ".", .)

split totexpr, parse("expenditures ")
drop totexpr1 totexpr
replace totexpr2 = "" if totexpr2 == ","
replace totexpr2 = subinstr(totexpr2, ",", ".", .)

replace tincm_r = "" if tincm_r == ","
replace tincm_r = subinstr(tincm_r, ",", ".", .)

* Tabulación y conversión de valores para variables categóricas
foreach var of varlist econrk powrnk resprk satlif geo wtchng evalhl operat {
    tab `var'
}

* Conversión de valores categóricos de texto a numérico
foreach var of varlist econrk powrnk resprk satlif geo {
    replace `var' = "." if inlist(`var', ".b", ".d", ".c")
    replace `var' = "1" if `var' == "one"
    replace `var' = "2" if `var' == "two"
    replace `var' = "3" if `var' == "three"
    replace `var' = "4" if `var' == "four"
    replace `var' = "5" if `var' == "five"
}

foreach var of varlist wtchng evalhl operat {
    replace `var' = "." if inlist(`var', ".b", ".d", ".c")
    replace `var' = "1" if `var' == "one"
    replace `var' = "2" if `var' == "two"
    replace `var' = "3" if `var' == "three"
    replace `var' = "4" if `var' == "four"
    replace `var' = "5" if `var' == "five"
}

foreach var of varlist hattac htself {
    replace `var' = "." if inlist(`var', ".b", ".d", ".c")
    replace `var' = "1" if `var' == "one"
    replace `var' = "2" if `var' == "two"
    replace `var' = "3" if `var' == "three"
    replace `var' = "4" if `var' == "four"
    replace `var' = "5" if `var' == "five"
}

destring, replace // Convierte variables de string a numérico

* Identificación de variables con valores faltantes
ds
foreach var of varlist * {
    count if missing(`var')
    local missing = r(N)
    local total = _N
    local percent_missing = 100 * `missing' / `total'
    if `percent_missing' > 5 {
        display "`var' tiene más del 5% de valores faltantes: `percent_missing'%"
    }
}

destring econrk powrnk resprk satlif satecc highsc belief monage cmedin hprblm hosl3m, replace 
destring wtchng evalhl operat hattac alclmo waistc hhpres tincm_r geo work1 work2 ortho marsta1 marsta2 marsta3 marsta4 hipsiz2 totexpr2, replace
3) Additional Data Cleaning
==============================================================================
*/
* Eliminar valores negativos y realizar ajustes adicionales
replace tincm_r = . if tincm_r < 0
replace totexpr2 = . if totexpr2 < 0
replace totexpr2 = . if totexpr2 > tincm_r

* Ordenar y ajustar el dataset para análisis posterior
gsort totexpr2
order id site sex_limpia

/* 
4) Creating new variables
==============================================================================
*/
* Crear una nueva variable de edad en años a partir de "monage"
gen age = .
replace age = monage / 12

* Resumir las principales variables de interés
estpost summarize sex_limpia age satlif waistc hipsiz2 totexpr2, listwise

* Etiquetar variables para mayor claridad
label var sex_limpia "Sexo"
label var age "Edad (en años)"
label var satlif "Satisfacción con la vida"
label var waistc "Circunferencia de la cintura"
label var hipsiz2 "Circunferencia de la cadera"
label var totexpr2 "Gasto real"

/* 
5) Exportar resultados
==============================================================================
*/
* Exportar la tabla resumen en formato LaTeX
esttab using "$output/tables/Table 1.tex", cells("Obs Mean Var Sd Min Max Sum")

/* 
6) Generar gráficos y pruebas
==============================================================================
*/
* Estilo del gráfico
ssc install grstyle // Instalar paquete de estilos gráficos
grstyle clear
grstyle init 
grstyle set horizontal
grstyle color background white 
grstyle color heading black

* Comparar distribuciones de circunferencia de cadera entre hombres y mujeres
twoway (kdensity hipsiz if sex_limpia == 1) (kdensity hipsiz if sex_limpia == 0), ///
    legend(order(1 "Women" 2 "Men")) title("Distribución de la circunferencia de las caderas") ///
    ytitle("Densidad") xtitle("Circunferencia de las caderas")

* Guardar gráfico
graph save "Graph" "/Users/juanimorozumi/Documents/GitHub/Aplicada/Trabajo práctico 1/PS1\output\grapichs\Gráfico punto 6.gph"

* Prueba t para comparar medias de circunferencia de cadera
ttest hipsiz, by(sex_limpia)



*AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= MIRAR COMO EXPORTAR LA TABLA



