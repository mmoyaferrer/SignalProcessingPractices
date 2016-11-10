%% Practica 1 - SAC %%

%  Autores -> Manuel Moya Ferrer
%             Jose Manuel Garcia Gimenez
%             Juan Manuel Lopez Torralba


%% Receptor %%

% En este script se lleva a cabo la implementacion de un receptor,
% encargado de recibir y procesar la se?al recibida, de manera que se
% obtenga el archivo de audio enviado en el emisor.

% Para ello, se implementan las caracteristicas basicas de un emisor:
% 
% - 1? Recepcion de la se?al
% - 2? Conversion de la se?al recibida a 0s y 1s
% - 3? Deteccion de preambulo y postambulo
% - 4? Decodificacion Manchester
% - 5? Decuantizacion de la se?al
% - 6? Test de la se?al recibida

%% Definicion de variables

BitsCuatizacion=8; %2^B -1 niveles cuantizacion

preambulo = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];
postambulo = [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1];


%% Recepcion de la se?al

% Para la recepcion de la se?al empleamos la funcion audiorecorder, en la
% cual especificamos Fs y el numero de bit por muestra, asi como el numero
% de canales. Posteriormente indicamos que la grabacion tiene que darse
% durante 40 segundos, y finalmente pasamos la se?al recibida a un valor
% fisico mediante la funcion getaudiodata.

senalDetectadaCanal = audiorecorder(48000, 8, 1);    
recordblocking(senalDetectadaCanal,40); 
y = getaudiodata(senalDetectadaCanal);



%% Conversion de la se?al recibida a 0s y 1s

senalAnalogicaRX = y;

% Restauramos la se?al recibida para volver a -1s y 1s.

senalAnalogicaRX(find(senalAnalogicaRX < 0)) = -1 ;
senalAnalogicaRX(find(senalAnalogicaRX >= 0)) = 1 ;


senalDigitalRX = reshape(senalAnalogicaRX,4,[]); % Transformamos a una matrix 4 x n
senalDigitalRX = (senalDigitalRX(1,:) + 1)./2; % Nos quedamos con la primera fila, sumamos 1 a todos los elementos y dividimos por 2 para 
                                        % pasar de -1s y 1s a 0s y 1s.


%% Deteccion de preambulo y postambulo                                        
                                      
% buscamos el preambulo
for i=1:length(senalDigitalRX)-length(preambulo)-1
    if(preambulo == senalDigitalRX(length(senalDigitalRX)-i-length(preambulo):length(senalDigitalRX)-i-1))
        indice = length(senalDigitalRX)-i-1;
    end
end

%%%% buscamos el postambulo 

for i=1:length(senalDigitalRX)-length(preambulo)
    if(postambulo == senalDigitalRX(i+1:i+length(postambulo)))
        indice_post = i;
    end
end

senalDigitalRX = senalDigitalRX(indice+1:indice_post);


%% Decodificaci?n Manchester
 
senalDigitalRXTransformada=reshape(senalDigitalRX,2*BitsCuatizacion,[]); %  Hacemos reshape de digital_RX, pasamos ??sta a una matriz de 2*B filas y las columnas correspondientes, de manera que cada columna ser?? una palabra manchester
senalDigitalRXTransformadaString=num2str(senalDigitalRXTransformada,'%1d')';          %  Pasamos aINT a str para poder decodificarla con la funci??n manchester2bin, ya que es necesario que esta sea char, ponemos como argumento %1d para que no se metan espacios.

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

% Obtenemos SNR entre La se?al cuantizada recibida y la se?al cuantizada en
% el emisor
%errorEntreXcuantizadaRXyTX=sum(xCuantizadaRX-xCuantizada);
%SNRentreSenalesCuantizadas=10*log10((xCuantizadaRX'*xCuantizadaRX)/(errorEntreXcuantizadaRXyTX'*errorEntreXcuantizadaRXyTX));

%% Test de la se?al recibida

soundsc(xCuantizadaRX');
