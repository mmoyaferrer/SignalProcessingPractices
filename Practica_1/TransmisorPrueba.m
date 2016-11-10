%% Practica 1 - SAC %%

%  Autores -> Manuel Moya Ferrer
%             Jose Manuel Garcia Gimenez
%             Juan Manuel Lopez Torralba


%% TRANSMISOR %%

% En este script se lleva a cabo la implementacion de un transmisor
% encargado de la comunicacion de un archivo de audio hacia un terminal
% receptor. 
% Para ello, se implementan las caracteristicas basicas de un emisor:

% - 1? Cuantizacion de la se?al.
% - 2? Codificacion de la se?al usando un codigo de linea Manchester.
% - 3? Muestreo de la se?al codificada para conseguir una segunda
% se?al adaptada a una transmision paso baja con una frecuencia superior 
% de corte de 12kHz.
% - 4? Preambulo y postambulo.
% - 5? Envio de la se?al.



%% Inicializaci?n variables

clear all
yo
load x.txt % Cargamos la se?al de audio a transmitir.
plot (x);
title 'Se?al a transmitir';
BitsCuatizacion=8; % 2^B -1 niveles cuantizacion
Vd = 2;  % Valor de amplitud de la se?al a transmitir
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


%% Transmision de la se?al por la tarjeta de sonido

disp('Presiona tecla espacio para iniciar la transmision');
pause();
% Usamos la funcion sound, indicandole que la Fs=48kHz.
sound(senalAnalogicaTX,48000);


