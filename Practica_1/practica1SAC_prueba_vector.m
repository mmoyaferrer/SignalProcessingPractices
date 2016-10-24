
%%% TRANSMISOR %%%


clear all

%% Inicializaci�n variables

load x.txt
plot (x)
B=3; %�2^B -1 niveles cuantizacion
Vd = 2;  % Valor de amplitud de la se�al a transmitir
guardar=0;

%% Normalizamos x

[x,Xmax,Xmin]=normalizar(x);


%% Cuantizamos x

q=(Xmax-Xmin)/(2^B-1);
xq=round((x+1)/q)*q-1; %Se�al cuantizada en niveles, falta asignar un codigo de bits a cada nivel
%xq=normalizar(xq);
stem(xq)

%% Escuchamos se�al y SNR

    soundsc(x);
    %pause(5);
    soundsc(xq);


err=x-xq; %Error de cuantizacion
SNR=10*log10((x'*x)/(err'*err));
if(guardar==1)
    cd D:\MASTER\SAC
    wavwrite(xq,'x_unifor'); % guardo se�al cuantizada en wav
end

%% Compruebo codeword

y=sort(unique(xq,'stable')); % niveles de cuantizaci�n | unique saca los diferentes niveles de la se�al cuantizada
num=(2^B)-1;
codeword=zeros(1,length(xq));

for i=1:1:length(y)-1
    codeword(find(xq(:,1)==y(i,1)))=num;
    num=num-1;
end



% Lo paso a binario

codeBIN=dec2bin(codeword);


%% Aplico un c�digo de l�nea

encodedData=[];

for fila=1:1:length(codeBIN)
    encodedData = strcat(encodedData,bin2manchester(codeBIN(fila,:)));
end

encodedData=str2num(encodedData')'
manANALog=reshape(bsxfun(@minus, 2*encodedData, ones(4,1)), 1, []); %Sustituye 1 con 1 1 1 1 y cero con -1 -1 -1 -1


%% TRANSMISOR Y RECEPTOR FALTAN 




%% Quito el codigo de l�nea
manDIGITAL_RX=zeros(size(manANALog));


       % convertimos los bit 1 y 0 a se�ales 0.5 V y -0.5 V para transmisi�n anal�gica y eliminar la componente DC
%manDIGITAL_RX(find(manANALog=='-0.5'))='0';
%manDIGITAL_RX(find(manANALog=='0.5'))='1';

manDIGITAL_RX=regexprep(manANALog, '2222', '1');
manDIGITAL_RX=regexprep(manDIGITAL_RX , '-2-2-2-2', '0');


receivedData=[];

for fila=1:1:length(manDIGITAL_RX)
    receivedData = [receivedData ; manchester2bin(manDIGITAL_RX(fila,:))];
end

%obtengo error de transmisi�n
err=sum(codeBIN-receivedData);

%% dequantizaci�n

codewordReceived=bin2dec(receivedData)';

err2=sum(codewordReceived-codeword);

num=(2^B)-1;

xqReceived=zeros(1,length(codewordReceived));
for i=1:1:length(y)-1
    xqReceived(find(codewordReceived(1,:)==num))=y(i);
    num=num-1;
end

xqReceived=xqReceived';

% obtengo la SNR

err3=xqReceived-xq;

SNRfinal=10*log10((xqReceived'*xqReceived)/(err3'*err3));

% lo escuchamos

soundsc(xqReceived');


