#!/bin/bash

Error(){
    echo "[-] Ha ocurrido un error"
    exit 2
}

Test_Domain(){
    echo "[-] Comprobando la existencia del dominio"
    code_error=$(curl -sI $REPLY > /dev/null || echo $?)
    if [[ "$code_error" -ne 0 ]]; then
            Error      
    fi  
    status=$(curl -sI $REPLY | head -n 1 | awk '{print $2}')
    for i in $(seq 400 600); do
        if [ "$status" -eq "$i" ]; then
            Error      
        fi  
    done
    echo "[+] El dominio existe y no arroja errores. "
    sleep 1
}

IP_number(){
    IP=$(ping -c 1 $REPLY | head -n 1 | awk '{gsub( /\(|\)/,"");print $3}')
    
}

Gen_Info(){
    echo "[-] Generando documentación..."
    touch "$info_doc_name" 
        # se puede introducir ruta 
    echo -e "[+] La IP de $REPLY es: $IP\n" > $info_doc_name
    whois $IP >> $info_doc_name
    sleep 1
}

Gen_Sum(){
    touch "$sum_doc_name"
        # se puede introducir ruta 
    echo -e "[+] La IP de $REPLY es: $IP\n" > $sum_doc_name
    for i in $key_word_IP
    do
        cat $info_doc_name | sort | uniq | grep $i >> $sum_doc_name
    done
    
}

Gen_Domain_info(){
    touch "Domain_info_$domain_name.txt"
        # se puede introducir ruta 
    whois $REPLY > "Domain_info_$domain_name.txt"
    
}

Exec_URL(){
    Test_Domain
    IP_number
    Gen_Info
    Gen_Sum
    Gen_Domain_info
}

Exec_IP(){
    Test_Domain
    IP=$REPLY
    Gen_Info
    Gen_Sum
}


echo "Seleccione una opción"
echo "[1]: URL"
echo -e "[2]: IP \n"

read n

case $n in
    1) 
        read -p "[-] Inserte el nombre del dominio: "

        key_word_IP=("OrgName Address City State PostalCode country Phone Email mail")
        domain_name=$(echo $REPLY | awk '{print $1}' FS=".")
        info_doc_name="IP_Info_$domain_name.txt"
        sum_doc_name="IP_Sum_$domain_name.txt"
        Exec_URL
        echo "[+] Documentación generada con exito"
    ;;
    2) 
        read -p "[-] Inserte la dirección IP: "

        key_word_IP=("OrgName Address City State PostalCode country Phone Email mail")
        domain_name=$(echo $REPLY)
        info_doc_name="IP_Info_$domain_name.txt"
        sum_doc_name="IP_Sum_$domain_name.txt"
        Exec_IP
        echo "[+] Documentación generada con exito"
    ;;
    *) 
        Error
    ;;
esac

