<#
    .SYNOPSIS

        El Script esta diseñado para poder agregar etiquetas a todos los recursos con azure. El script genera un archivo en el cual estará registrando los datos que se estan actualizando.
        
    .DESCRIPTION
        El Script esta diseñado para poder agregar etiquetas a todos los recursos con azure. El script genera un archivo en el cual estará registrando los datos que se estan actualizando.
        Requirments:
        Powershell Core
        Module Azure Az

        El archivo cvs que tienes que generar debera tener las siguientes columnas 

        Columna 1 : Nombre de la Servicio
        Columna 2 : Nombre del Tipo de Recursos
        Columna 3 : Grupo de Recurso
        Columna 6 : Nombre del TAG (Encabezado)
        Columna 6 : Valor del TAG ( Renglones )

    .EXAMPLE
        .\RecursoEtiquetas.ps1
   
    .NOTES
        Author:     Edgar Sabanero
        Created:    04/08/2021
#>


#Connect-AzureAD  #Si no estas conectado a Azure descomentar la linea para que puedas iniciar sesion.

Clear-Host

#Se crea archivo para almacenar los logs.
$GDate = Get-Date -format "yyyy-MM-dd"
$FileResources = "${GDate}-Tags-Resources-CBC.csv"
Write-Host "Creating file: ${FileResources}"

$FILE = Get-Content "CBC2021.csv";
$cont = 0;  #Si tiene encabezado el archivo dejar en 0
$Total_Tag_Agregar = 3;

####################################################################
##  Función que realiza la busqueda de los TAG que se van agregar ##
####################################################################
function compara #([String[]]$arreglo_va)
{
       #(  $cadena  ,   $N_NTAG  , $Nuevos_VTAG )
   
    param(
         [String[]]$arreglo_va, 
         [String[]]$arreglo_vn, 
         [String[]]$valor_nuevo )
   
   $i = 0
   $ndato = ""
  
   #Write-Host "Valor Comparar en Funcion:"$arreglo_va
  
   $ndatoC = $arreglo_va.Count
   #Write-Host "Total de Arreglo:"$ndatoC
   
   $finder = 0

   $sarreglo_va = $arreglo_va.Split(";")
   $sarreglo_vaC = $sarreglo_va.Count

   #Write-Host "Total de Arreglo sarreglo_vaC:"$sarreglo_vaC

       foreach ( $arreglito_va in $sarreglo_va )
              {
               $ssarreglo_va = $arreglito_va.Split("=") 
               #Write-Host "Total de Valores:"$ssarreglo_va.Count
               #Write-Host "Nombre Comparar:" $arreglo_vn " Nombre Buscar:"$ssarreglo_va[0]
               #Write-Host "Valor a agregar:" $valor_nuevo
               
               if ( $arreglo_vn -eq $ssarreglo_va[0] )
                  {
                   #Write-Host $ssarreglo_va[0] "=" $valor_nuevo -ForegroundColor Green
                   if ( $ndato -eq "" )
                      {
                       $ndato = $ssarreglo_va[0]+"="+$valor_nuevo
                      }
                   else
                      {
                       $ndato += ";"+$ssarreglo_va[0]+"="+$valor_nuevo
                      }
                    $finder = 1      
                  }
               else
                  {
                   #Write-Host $ssarreglo_va[0] "=" $ssarreglo_va[1] -ForegroundColor Magenta  
                   if ( $ndato -eq "" )
                      {
                       $ndato = $ssarreglo_va[0]+"="+$ssarreglo_va[1]
                      } 
                   else
                      {
                       $ndato += ";"+$ssarreglo_va[0]+"="+$ssarreglo_va[1]
                      }
                  }   
               
              } #Fin For Each

             if ( $finder -eq 0 )
                {
                 if ( $ndato -eq "" )
                     {
                     $ndato = $arreglo_vn+"="+$valor_nuevo
                     } 
                 else
                     {
                     $ndato += ";"+$arreglo_vn+"="+$valor_nuevo
                     }
                }      

   return $ndato
}

#######################################################
## Recorre todo el archivo de texto                  ## 
#######################################################
foreach ($LINE in $FILE) 
{

$LINES = $LINE.Split(",") 
 
    if ( $cont -eq 0 )
       {
        $NTAG_Nuevos = ""
        #Toma el valor para el TAG
        $NTAG = $LINES[6] #Nombre del TAG1
        $NTAG2 = $LINES[7] #Nombre del TAG2
        $NTAG3 = $LINES[8] #Nombre del TAG3
        for ($x = 0; $x -lt $Total_Tag_Agregar; $x++) #Recorre los TAG's creados
           {
            if ( $NTAG_Nuevos -eq "" )
               {
                $NTAG_Nuevos = $LINES[$x+6]
               }
            else
               {
                $NTAG_Nuevos += ","+$LINES[$x+6]
               }
           } 
        $cadena = "" 
        $Nuevos_NTAG = $NTAG_Nuevos.Split(",")
        $Nuevos_NTAG_0 = $NTAG_Nuevos.Split(",")        
       } #IF Principal
    else
       {
           #$RID = $LINES[5]
        
           $VTAG_Nuevos = ""
           $RID = $LINES[5]
           $VTAG = $LINES[6] #Valor del TAG1
           $VTAG2 = $LINES[7] #Valor del TAG2
           $VTAG3 = $LINES[8] #Valor del TAG3 

           for ($x = 0; $x -lt $Total_Tag_Agregar; $x++) #Recorre los TAG's creados
               {
                if ( $VTAG_Nuevos -eq "" -and $x -eq 0 )
                   {
                    $VTAG_Nuevos = $LINES[$x+6]
                   }
                else
                   {
                    $VTAG_Nuevos += ","+$LINES[$x+6]
                   }
                 #Write-Host "TAGS Valores Nuevos 1:"$VTAG_Nuevos
               }
           #$VTAG_G = $LINES[6]+","+$LINES[7]+","+$LINES[8]
           $Nuevos_VTAG = $VTAG_Nuevos.Split(",")
       
           $Data = $RID.Split("/")
           $Suscrip = $Data[2]  #ID de Suscripcion
           $NM = $Data[$Data.Count-1] #Nombre del Recurso
           $RG = $Data[4]  #Nombre del Grupo de Recurso

           <#
           $RT = $Data[6]+"/"+$Data[7] #Tipo de Recurso
           $NM = $Data[$Data.Count-1] #Nombre del Recurso
           #>

           Write-Host "TAGS Nombre Nuevos:"$NTAG_Nuevos -ForegroundColor Magenta
           Write-Host "TAGS Valores Nuevos:"$VTAG_Nuevos -ForegroundColor Magenta
           Write-Host "TAGS N-V Nuevos Total:"$Nuevos_VTAG.Count
           Write-Host "Suscripcion:"$Suscrip
           Write-Host "Grupo de Recurso:"$RG
           
           #######################################################
           # Selecciona la suscripcion a la que se va a conectar #
           #######################################################
           $null = Select-AzSubscription $Suscrip -Force | Out-Null

           #######################################################
           #      Obtiene la información del Recurso             #
           #######################################################
           $resource = Get-AzResource -Name $NM -ResourceGroup $RG
           
           #Get-AzResource -Name AzureBackup_dc201cac-fd61-421f-a6c7-4632f8adcdf8_2021-07-22T22-01-26.8658906 -ResourceGroup snaps

           #Obtiene el Tipo de Recurso
           $RT = $resource.ResourceType
 
           #Obtiene el Tipo de Recurso
           $RN = $resource.Name
           
           #Obtiene listado de nombres de los TAGS del Recurso
           $key = $resource.Tags.Keys
       
           #Obtiene listado de valores de los TAGS del Recurso
           $value = $resource.Tags.Values

           Write-Host "Tipo de Recurso:"$RT
           Write-Host "Nombre de Maquina:"$NM
           Write-Host "Nombre del Recurso:"$RN

           $enc = 0
           $z = 0
           $cadena = ""
           $cadenaT = ""
           $tag1 = ""
           $cadenai = "@{"
           $cadenaf = "}"
           $ATaggeosN = ""
           $indice = 0
           $indice1 = 0
           $cadena_gral = ""
           $cadena_gral_1 = ""
           $New_TAG = ""


           Write-Host "TAG Nombre Actuales:"$key -ForegroundColor Yellow
           Write-Host "TAG Valores Actuales:"$value -ForegroundColor Yellow
           Write-Host "Total de Tags Actuales Registrados:"$key.Count -ForegroundColor Green
           
           #Si los TAG's es mayor a 0
           if ( $key.Count -gt 0 )
              {
              if ( $key.Count -eq 1 )
                 {
                  $sKey = $key
                  $sValue = $value    
                 }
             else
                 {
                  $sKey = $key.Split(" ") #Separa arreglo de Nombres
                  $sValue = $value.Split(" ") #Separa arreglo de Valores
                 }
             }    

           ###########################################
           #   Se arma la primer arreglo en cadena   #
           ###########################################
           foreach ($allkey in $key) 
                   {
                    #Write-Host $allkey -ForegroundColor Green
                    if ( $cadena -eq "" )
                       {
                        $cadena = $allkey+'='+$sValue[$indice]
                        $cadenaT = $allkey
                       }
                    else
                       {
                        $cadena += ';'+$allkey+'='+$sValue[$indice]
                        $cadenaT += ';'+$allkey 
                       }
                    $indice++
                   }

            #Write-Host "Cadena:"$cadena -ForegroundColor Red
            #Write-Host "CadenaT:"$cadenaT -ForegroundColor Cyan
            
            #$cadenaT = $cadenaT.Split(";")
            
            $cadena_gral_1 = $cadena.Split(";")
            $cadena_gral_1_Indice = $cadena_gral_1.Count 


            #$Cadena son los TAGS Originales
            if ( $cadenaT -ne "" )
               {
                $a = compara($cadenaT, "", "")
                #Write-Host "Cadena Original:"$a -ForegroundColor Yellow -BackgroundColor Blue
               } 
 
            ######################################################################
            # Se recorre los TAG Nuevos para validar que no existan en          ##
            # los TAG Originales, si no existen agregarlo, si existen editar    ##
            ######################################################################

            $indice = 0
            foreach ( $N_NTAG in $Nuevos_NTAG ) 
                   {
                    #Write-Host "Comparar:"$N_NTAG -ForegroundColor Yellow
                    #Write-Host "Comparar Valor:"$Nuevos_VTAG[$indice] -ForegroundColor Yellow

                    if ( $Nuevos_VTAG[$indice] -ne "" )
                       {
                        $cadena = compara $cadena $N_NTAG $Nuevos_VTAG[$indice]
                    
                        $New_TAG = $cadenai+$cadena+$cadenaf
                       } 
                  
                    $indice++
                   }

            #Write-Host "TAGs a Agregar:"$New_TAG -ForegroundColor Yellow -BackgroundColor Blue
            #Write-Host "Nueva Cadena:"$cadena -ForegroundColor Yellow -BackgroundColor Blue        
            
            ######################################################################
            # Se recorre la nueva cadena a agregar para preparar arreglo        ##
            ######################################################################
   
            $New_TAG_S = $cadena.Split(";")

            $cadena = ""

            foreach ( $New_TAG_Add in $New_TAG_S )
                    {
                      $TempNT = $New_TAG_Add.Split("=")
                     if ( $TempNT[0] -ne "" )
                        { 
                         if ( $cadena -eq "" )
                            {
                             $cadena = '"'+$TempNT[0]+'"="'+$TempNT[1]+'"'
                            }    
                         else
                            {
                             $cadena += ';"'+$TempNT[0]+'"="'+$TempNT[1]+'"'
                            }
                        }       
                    }

             $cadena = $cadenai+$cadena+$cadenaf

             #Write-Host "Cadena a Agregar:"$cadena -ForegroundColor Yellow       

             #Crear un scriptblock usando la cadena de TAGS
             $scriptBlock = [scriptblock]::Create($cadena)

             #Crear el objeto HashTable para insertar los TAGS
             $tags = (& $scriptBlock)

             Write-Host 'Set-AzResource -ResourceGroupName '$RG '-Name'$RN '-ResourceType'$RT '-Tag'$cadena '-Force'

             #Agrega los TAGS que se encuentran en el archivo.
             $null = Set-AzResource -ResourceGroupName $RG -Name $RN -ResourceType $RT -Tag $tags -Force | Out-Null

             #Set-AzResource -ResourceGroupName $RG -Name $RN -ResourceType $RT -Tag $tags -Force

             Write-Host "*********************************************"


             if ( $cont -ne 0 )
                {
                  $comando = ""
                  $comando = "Set-AzResource -ResourceGroupName "+$RG+" -Name "+$RN+" -ResourceType "+$RT+" -Tag "+$cadena+" -Force"

                  Write-Output "Fecha:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $GDate | Out-File $FileResources -Append
             
                  Write-Output "TAGS Nombre Nuevos:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $NTAG_Nuevos | Out-File $FileResources -Append
             
                  Write-Output "TAGS Valores Nuevos:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $VTAG_Nuevos | Out-File $FileResources -Append

                  Write-Output "TAGS Nombre Actuales:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $key | Out-File $FileResources -Append
             
                  Write-Output "TAGS Valores Actuales:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $value | Out-File $FileResources -Append

                  Write-Output "TAGS N-V Nuevos Total:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $Nuevos_VTAG.Count | Out-File $FileResources -Append

                  Write-Output "Suscripcion:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $Suscrip | Out-File $FileResources -Append

                  Write-Output "Grupo de Recurso:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $RG | Out-File $FileResources -Append

                  Write-Output "Tipo de Recurso:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $RT | Out-File $FileResources -Append

                  Write-Output "Nombre de Maquina:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $NM | Out-File $FileResources -Append

                  Write-Output "Comando:" | Out-File $FileResources -Append -NoNewline
                  Write-Output $comando | Out-File $FileResources -Append
                  Write-Output "*******************************************************" | Out-File $FileResources -Append
              
                }  


       }#ELSE Principal

  $cont++
}