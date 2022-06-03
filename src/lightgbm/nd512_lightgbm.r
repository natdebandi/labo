# LightGBM  cambiando algunos de los parametros

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

require("data.table")
require("lightgbm")

#Aqui se debe poner la carpeta de la computadora local
#setwd("D:\\gdrive\\ITBA2022A\\")   #Establezco el Working Directory


setwd("C:\\Users\\natal\\Documents\\Mineriadatos\\") 
#setwd("C:\\Users\\Natilux\\Documents\\_Mineriadatos\\") 
#cargo el dataset donde voy a entrenar
dataset  <- fread("./datasets/paquete_premium_202011.csv", stringsAsFactors= TRUE)


#paso la clase a binaria que tome valores {0,1}  enteros
dataset[ , clase01 := ifelse( clase_ternaria=="BAJA+2", 1L, 0L) ]

dataset[ , ctarjeta_visa_trx2 := ctarjeta_visa_trx ]
dataset[ ctarjeta_visa==0 & ctarjeta_visa_trx==0,  ctarjeta_visa_trx2 := NA ]

#los campos que se van a utilizar
campos_buenos  <- setdiff( colnames(dataset), c("clase_ternaria","clase01") )


#dejo los datos en el formato que necesita LightGBM
dtrain  <- lgb.Dataset( data= data.matrix(  dataset[ , campos_buenos, with=FALSE]),
                        label= dataset$clase01 )

#genero el modelo con los parametros por default
modelo  <- lgb.train( data= dtrain,
                      param= list( objective=        "binary",
                                   num_iterations=     87,
                                   max_bin=              31, ##agregue
                                   num_leaves=         645,
                                  feature_fraction=    0.34,
                                   min_data_in_leaf= 960,
                                   lambda_l1=0.0035,
                                   lambda_l2=88.68,
                                   learning_rate=0.049,
                                   seed= 565273 )
                    )
# 
# learning_rate	0.049618226
# feature_fraction	0.34469814
# min_data_in_leaf	960
# num_leaves	645
# lambda_l1	0.003573354
# lambda_l2	88.6802521
# prob_corte	0.01332598
# ganancia	13726000
# iteracion	87




# max_bin=              31,
# learning_rate=         0.0300696989,
# num_iterations=      567,
# num_leaves=         1002,
# min_data_in_leaf=   6263,
# feature_fraction=      0.9100319271,
# seed=             102191


#aplico el modelo a los datos sin clase
dapply  <- fread("./datasets/paquete_premium_202101.csv")

dapply[ , ctarjeta_visa_trx2 := ctarjeta_visa_trx ]
dapply[ ctarjeta_visa==0 & ctarjeta_visa_trx==0,  ctarjeta_visa_trx2 := NA ]


#aplico el modelo a los datos nuevos
prediccion  <- predict( modelo, 
                        data.matrix( dapply[, campos_buenos, with=FALSE ]) )


#Genero la entrega para Kaggle
entrega  <- as.data.table( list( "numero_de_cliente"= dapply[  , numero_de_cliente],
                                 "Predicted"= as.integer(prediccion > 1/60 ) )  ) #genero la salida

dir.create( "./labo/exp/",  showWarnings = FALSE ) 
dir.create( "./labo/exp/KA2512/", showWarnings = FALSE )
archivo_salida  <- "./labo/exp/KA2512/KA_512_exp015i.csv"

#genero el archivo para Kaggle
fwrite( entrega, 
        file= archivo_salida, 
        sep= "," )


#ahora imprimo la importancia de variables
tb_importancia  <-  as.data.table( lgb.importance(modelo) ) 
archivo_importancia  <- "./labo/exp/KA2512/512_importancia_exp015i.txt"

fwrite( tb_importancia, 
        file= archivo_importancia, 
        sep= "\t" )

