%% Pr?ctica 1 - SAC %%

%  Autores -> Manuel Moya Ferrer
%             Jose Manuel Garc?a Gim?nez
%             Juan Manuel L?pez Torralba


%% TRANSMISOR %%

% En este script se lleva a cabo la implementaci?n de un transmisor
% encargado de la comunicaci?n de un archivo de audio hacia un terminal
% receptor. 
% Para ello, se implementan las caracter?sticas b?sicas de un emisor:

% - Cuantizaci?n de la se?al.
% - Codificaci?n de la se?al usando un c?digo de linea Manchester.
% - Muestreo de la se?al codificada para conseguir una segunda
% se?al adaptada a una transmisi?n paso baja con una frecuencia superior 
% de corte de 12kHz.
% - Envio de la se?al.



%% Inicializaci?n variables

clear all
yo
load x.txt % Cargamos la se?al de audio a transmitir.
plot (x);
title 'Se?al a transmitir';
BitsCuatizacion=8; % 2^B -1 niveles cuantizacion
Vd = 2;  % Valor de amplitud de la se??al a transmitir
guardar=0;


%% Cuantizaci?n de la se?al
%  En este primer apartado procedemos a cuantizar la se?al de audio
%  procedente del fichero x.txt.

[x,Xmax,Xmin]=normalizar(x); %En primer lugar, normalizamos la se?al.

quantum=(Xmax-Xmin)/(2^BitsCuatizacion-1); %Definimos el quantum para la cuantizaci?n
xCuantizada=round((x+1)/quantum)*quantum-1; %Se?al cuantizada en niveles
stem(xCuantizada)


% Obtenemos el error de cuantizaci?n
errorCuantizacionEnTransmisor=x-xCuantizada;
SNRenTransmisor=10*log10((x'*x)/(errorCuantizacionEnTransmisor'*errorCuantizacionEnTransmisor));


% Asignamos un c?digo de bits a cada nivel de cuantizaci?n, de manera que
% obtenemos la se?al cuantizada en la cual cada muestra corresponde a un
% nivel de cuantizaci?n definido por 8 bits.

% En primer lugar obtenemos los diferentes niveles de la se?al cuantizada
% mediante la funci?n unique, ordenandolos posteriormente con sort.
nivelesCuantizacion=sort(unique(xCuantizada,'stable')); 
% Obtenemos el n?mero total de niveles de cuantizaci?n a partir de los bits
% utilizados
numeroTotalNivelesCuantizacion=(2^BitsCuatizacion)-1;
% Creamos una nueva matriz de 1 fila y tantas columnas como muestras en la
% se?al de audio. En el for, buscamos en la se?al cuantizada los valores de
% ?sta que se corresponden con el nivel de cuantizaci?n m?s alto, asignandoles el nivel
% correspondiente en decimal, y as? sucesivamente hasta llegar al nivel 0.
palabraCodigoTXDecimal=zeros(1,length(xCuantizada));
for i=1:1:length(nivelesCuantizacion)-1
    palabraCodigoTXDecimal(find(xCuantizada(:,1)==nivelesCuantizacion(i,1)))=numeroTotalNivelesCuantizacion;
    numeroTotalNivelesCuantizacion=numeroTotalNivelesCuantizacion-1;
end

% En dicha matriz hemos asignado los niveles en decimal (7,6,...0) por lo
% que ahora pasamos dicha matriz a binario.
palabraCodigoTXBinario=dec2bin(palabraCodigoTXDecimal);
 


%% Aplicaci?n del c?digo de linea a la se?al cuantizada.
%  Una vez que tenemos la se?al cuantizada y en binario, le aplicamos un
%  c?digo de linea Manchester, de manera que no tenemos componente en
%  continua, y a su vez empleamos un algoritmo ?ptimo para una transmisi?n
%  en un canal paso baja.

% Creamos una nueva matriz, en la cual, mediante un for, almacenamos los
% datos de la se?al cuantizada codificados mediante la funci?n
% bin2manchester.
datosCodificadosTX=[];
for fila=1:1:length(palabraCodigoTXBinario)
    datosCodificadosTX = strcat(datosCodificadosTX,bin2manchester(palabraCodigoTXBinario(fila,:)));
end


%% Pre?mbulo y post-?mbulo 
%  Una vez que tenemos la se?al codificada, hemos de a?adirle una secci?n
%  de c?digo caracter?stica que defina donde comienza nuestra se?al y donde
%  acaba, puesto que en el receptor recibir? otros datos/ruido antes y
%  despu?s de nuestra se?al.

% Definimos un pre?mbulo, el cual marca donde comenzar? nuestra se?al.
preambulo = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];

% Definimos un post-?mbulo, el cual marca donde finalizar? nuestra se?al.
postambulo = [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1];

% Pasamos la matriz de string a int.
datosCodificadosTX = str2num(datosCodificadosTX')';
% A?adimos las delimitaciones de la se?al
datosCodificadosTX = [ preambulo datosCodificadosTX postambulo ] ;

%% Adaptaci?n de la se?al para su env?o a BW=12kHz y Fs=48kHz
%  Para ello, sustituimos los valores 1 de la se?al por 1 1 1 1 as? como
%  los valores cero por -1 -1 -1 -1. De esta manera conseguimos transmitir
%  sin componente en continua (con la necesidad del c?digo Manchester)
senalAnalogicaTX = reshape(bsxfun(@minus, 2*datosCodificadosTX, ones(4,1)), 1, []); 


%% Transmisi?n de la se?al por la tarjeta de sonido

disp('Presiona tecla espacio para iniciar la transmisi?n');
pause();
% Usamos la funci?n sound, indicandole que la Fs=48kHz.
sound(senalAnalogicaTX,48000);


