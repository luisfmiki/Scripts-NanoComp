#!/bin/bash

read -p "Diretorio do nmlsim: " nmlpwd

read -p "Diretorio de projetos: " projpwd

read -p "Diretorio para armazenar os resultados: " plotpwd

echo $nmlpwd $projpwd $plotpwd > stpinfo.txt

cp chartToFile.py $nmlpwd/chartToFile.py

echo -0.99-0.99 -0.9900.99 00.99-0.99 00.9900.99 >> stpinfo.txt
echo -0.99-0.99-0.99 -0.99-0.9900.99 -0.9900.99-0.99 -0.9900.9900.99 00.99-0.99-0.99 00.99-0.991 00.9900.99-0.99 0.990.990.99 >> stpinfo.txt

chmod a-w stpinfo.txt