%% Practica 1 - SAC %%   LOCAL VERSION

%  Autores -> Manuel Moya Ferrer
%             Jose Manuel Garcia Gimenez
%             Juan Manuel Lopez Torralba


%% TRANSMISOR y RECEPTOR %% 

% Sistema implementado EN LOCAL (SIN transmisión por medio físico)

% En este script se lleva a cabo la implementacion de un transmisor
% encargado de la comunicacion de un archivo de audio hacia un terminal
% receptor, encargado de recibir y procesar la se?al recibida, de manera que se
% obtenga el archivo de audio enviado en el emisor. 

% Para ello, se implementan las caracteristicas basicas de un sistema de
% comunicaciones:

% Transmisor %

% - 1? Cuantizacion de la se?al.
% - 2? Codificacion de la se?al usando un codigo de linea Manchester.
% - 3? Muestreo de la se?al codificada para conseguir una segunda
%      se?al adaptada a una transmision paso baja con una frecuencia superior 
%      de corte de 12kHz.
% - 4? Preambulo y postambulo. (SINCRONIZACIÓN)
% - 5? Envio de la se?al.

% Receptor %

% - 6? Recepcion de la se?al
% - 7? Conversion de la se?al recibida a 0s y 1s
% - 8? Deteccion de preambulo y postambulo
% - 9? Decodificacion Manchester
% - 10? Decuantizacion de la se?al
% - 11? Test de la se?al recibida

clear all
close all 
clc

%% InicializaciÃ³n variables

load x.txt    % Cargamos la se?al de audio a transmitir.

figure
plot (x);
title 'Se?al a transmitir';

BitsCuatizacion=8;  % 2^B -1 niveles cuantizacion
Vd = 2;             % Valor de amplitud de la seÃ±al a transmitir
guardar=0;

%% Cuantizacion de la se?al

%  En este primer apartado procedemos a cuantizar la se?al de audio
%  procedente del fichero x.txt.

[x,Xmax,Xmin]=normalizar(x); %En primer lugar, normalizamos la se?al.

quantum=(Xmax-Xmin)/(2^BitsCuatizacion-1); %Definimos el quantum para la cuantizaci?n
xCuantizada=round((x+1)/quantum)*quantum-1; %Se?al cuantizada en niveles
stem(xCuantizada)


% Obtenemos el error de cuantizacion
errorCuantizacionEnTransmisor=x-xCuantizada;
SNRenTransmisor=10*log10((x'*x)/(errorCuantizacionEnTransmisor'*errorCuantizacionEnTransmisor));


% Asignamos un codigo de bits a cada nivel de cuantizacion, de manera que
% obtenemos la se?al cuantizada en la cual cada muestra corresponde a un
% nivel de cuantizacion definido por 8 bits.

% En primer lugar obtenemos los diferentes niveles de la se?al cuantizada
% mediante la funcion unique, ordenandolos posteriormente con sort.
nivelesCuantizacion=sort(unique(xCuantizada,'stable')); 

% Obtenemos el numero total de niveles de cuantizacion a partir de los bits
% utilizados
numeroTotalNivelesCuantizacion=(2^BitsCuatizacion)-1;

% Creamos una nueva matriz de 1 fila y tantas columnas como muestras en la
% se?al de audio. En el for, buscamos en la se?al cuantizada los valores de
% esta que se corresponden con el nivel de cuantizacion mas alto, asignandoles el nivel
% correspondiente en decimal, y asi sucesivamente hasta llegar al nivel 0.

palabraCodigoTXDecimal=zeros(1,length(xCuantizada));
for i=1:1:length(nivelesCuantizacion)-1
    palabraCodigoTXDecimal(find(xCuantizada(:,1)==nivelesCuantizacion(i,1)))=numeroTotalNivelesCuantizacion;
    numeroTotalNivelesCuantizacion=numeroTotalNivelesCuantizacion-1;
end

% En dicha matriz hemos asignado los niveles en decimal (7,6,...0) por lo
% que ahora pasamos dicha matriz a binario.
palabraCodigoTXBinario=dec2bin(palabraCodigoTXDecimal);
 


%% Aplicacion del codigo de linea a la se?al cuantizada.

%  Una vez que tenemos la se?al cuantizada y en binario, le aplicamos un
%  codigo de linea Manchester, de manera que no tenemos componente en
%  continua, y a su vez empleamos un algoritmo optimo para una transmision
%  en un canal paso baja.

% Añadir que el código Manchester nos proporciona ya un mecanismo de
% detección de errores, al detectar códigos no válidos.

% Creamos una nueva matriz, en la cual, mediante un for, almacenamos los
% datos de la se?al cuantizada codificados mediante la funcion
% bin2manchester.
datosCodificadosTX=[];
for fila=1:1:length(palabraCodigoTXBinario)
    datosCodificadosTX = strcat(datosCodificadosTX,bin2manchester(palabraCodigoTXBinario(fila,:)));
end


%% Preambulo y post-ambulo 

%  Una vez que tenemos la se?al codificada, hemos de a?adirle una seccion
%  de codigo caracteristica que defina donde comienza nuestra se?al y donde
%  acaba, puesto que en el receptor recibira otros datos/ruido antes y
%  despues de nuestra se?al.

% Definimos un preambulo, el cual marca donde comenzara nuestra se?al.
preambulo = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];

% Definimos un post-ambulo, el cual marca donde finalizara nuestra se?al.
postambulo = [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1];

% Pasamos la matriz de string a int.
datosCodificadosTX = str2num(datosCodificadosTX')';
% A?adimos las delimitaciones de la se?al
datosCodificadosTX = [ preambulo datosCodificadosTX postambulo ] ;

%% Adaptacion de la se?al para su envio a BW=12kHz y Fs=48kHz
%  Para ello, sustituimos los valores 1 de la se?al por 1 1 1 1 asi como
%  los valores cero por -1 -1 -1 -1. De esta manera conseguimos transmitir
%  sin componente en continua (conjuntamente con el codigo Manchester)

senalAnalogicaTX = reshape(bsxfun(@minus, 2*datosCodificadosTX, ones(4,1)), 1, []); 

%% CANAL


% Simulación de un canal ruidoso
% Añadimos ruidos a la señal simulando un canal 

senalAnalogicaTX = [zeros(1,randi(1000,1)*4) senalAnalogicaTX zeros(1,randi(1000,1)*4)];

senalAnalogicaTX = senalAnalogicaTX + rand(1,length(senalAnalogicaTX))-0.5;
 



%% Conversion de la se?al recibida a 0s y 1s


senalAnalogicaRX = senalAnalogicaTX;


% Restauramos la señal recibida para volver a -1s y 1s.

senalAnalogicaRX(find(senalAnalogicaRX < 0)) = -1 ;
senalAnalogicaRX(find(senalAnalogicaRX >= 0)) = 1 ;


senalDigitalRX = reshape(senalAnalogicaRX,4,[]); % Transformamos a una matrix 4 x n
senalDigitalRX = (senalDigitalRX(1,:) + 1)./2;   % Nos quedamos con la primera fila, sumamos 1 a todos los elementos y dividimos por 2 para 
                                                 % pasar de -1s y 1s a 0s y 1s.


%% Deteccion de preambulo y postambulo           

%%% buscamos el preambulo y lo eliminamos

for i=1:length(senalDigitalRX)-length(preambulo)-1
    if(preambulo == senalDigitalRX(length(senalDigitalRX)-i-length(preambulo):length(senalDigitalRX)-i-1))
        indice = length(senalDigitalRX)-i-1;
    end
end

senalDigitalRX = senalDigitalRX(indice+1:end);

%%%% buscamos el postambulo y lo eliminamos

for i=1:length(senalDigitalRX)-length(preambulo)
    if(postambulo == senalDigitalRX(i+1:i+length(postambulo)))
        indice_post = i;
    end
end

senalDigitalRX = senalDigitalRX(1:indice_post);


%% Decodificaci?n Manchester

%  Hacemos reshape para pasar a una matriz de 2*B filas y las columnas correspondientes, de manera que cada columna será una palabra manchester
senalDigitalRXTransformada=reshape(senalDigitalRX,2*BitsCuatizacion,[]); 

%  Pasamos senalDigitalRXTransformada a STRING para poder decodificarla con la función 'manchester2bin', ya que es necesario que esta sea char, ponemos como argumento %1d para que no se metan espacios.
senalDigitalRXTransformadaString=num2str(senalDigitalRXTransformada,'%1d')';       

datosRecibidosDecodificados=[];

 for fila=1:1:length(senalDigitalRXTransformadaString)
     datosRecibidosDecodificados = [datosRecibidosDecodificados ; manchester2bin(senalDigitalRXTransformadaString(fila,:))];   
 end

% Obtenemos el error de transmisi??n
%errorTransmision=sum(palabraCodigoTXBinario-datosRecibidosDecodificados);

%% Decuantizacion de la se?al 

palabraCodigoRXDecimal=bin2dec(datosRecibidosDecodificados)';

errorEntrePalabraCodigoTXyRX=sum(palabraCodigoRXDecimal-palabraCodigoTXDecimal);

numeroTotalNivelesCuantizacion=(2^BitsCuatizacion)-1;

xCuantizadaRX=zeros(1,length(palabraCodigoRXDecimal));
for i=1:1:length(nivelesCuantizacion)
    xCuantizadaRX(find(palabraCodigoRXDecimal(1,:)==numeroTotalNivelesCuantizacion))=nivelesCuantizacion(i);
    numeroTotalNivelesCuantizacion=numeroTotalNivelesCuantizacion-1;
end

xCuantizadaRX=xCuantizadaRX';

%% Obtenemos SNR entre seÃ±al cuantizada emitida y seÃ±al cuantizada recibida, es inf. ya que el error entre ambas es 0.
errorEntreXcuantizadaRXyTX=sum(xCuantizadaRX-xCuantizada);
SNRentreSenalesCuantizadas=10*log10((xCuantizadaRX'*xCuantizadaRX)/(errorEntreXcuantizadaRXyTX'*errorEntreXcuantizadaRXyTX));

%% Escuchamos la seÃ±al cuantizada recibida

soundsc(xCuantizadaRX');




