% GRABADOR.

%Este c�digo se encarga de la captaci�n de la se�al an�loga del hidr�fono
%y la convierte en se�al digital para su manipulaci�n en el c�digo. Se
%aplica posteriormente el banco de filtros para determinar los umbrales de
%la lancha y ser comparados con la firma ac�stica (documento que es
%previamente cargado). Luego de la comparaci�n se llama a la funci�n
%EstimacionVerde o EstimacionAmarilla seg�n sea el caso.
%


%% Cargo Variables
Frecuencia_Muestreo = 48000;
Dimension_fft = 4096;   % Minima longitud de ventan para optima resolucion.
load Firma_B
load Firma_A
n_bits = 16;      % tama�o de la muestra en bits
seg = 1;          % duracion de la grabacion en segundos
n_canales = 1;    % numero de canal (mono)
%% Grabaci�n
Indicator = 1;

recObj = audiorecorder(Frecuencia_Muestreo, n_bits, n_canales);

while Indicator < 2
    disp('Comienzo Grabaci�n.')
    recordblocking(recObj, seg);
    disp('Fin Grabaci�n.');
    Captacion_Blanco = getaudiodata(recObj);
    %% Firma ac�stica
    N_Frecuencias = length(Firma_B);
    Maximo_Bandas_dB=zeros(1,N_Frecuencias);
    Frec_Corte1 = 300;
    for i=1:N_Frecuencias
        % Dise�o Filtro Pasa-Banda
        Orden_Filtro = 8;
        Frec_Corte2 = Frec_Corte1 + 50;
        Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,...
            Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
        Filtro = design(Parametros_Filtro,'butter');
        Senal_Blanco_Filtrada = filter(Filtro,Captacion_Blanco);
        % PSD
        [pxx,Frecuencias]=pwelch(Senal_Blanco_Filtrada, hamming(Dimension_fft),[], [], Frecuencia_Muestreo);
        pxxdB = 10*log10(pxx);
        % M�ximos
        [Maximo_Bandas_dB(i),posicion] = max(pxxdB);
        Frec_Corte1 = Frec_Corte2;
    end
    % Comparaci�n con promedo.
    Promedio = sum(Maximo_Bandas_dB)/N_Frecuencias;
    Comparacion_Prom = zeros(1,N_Frecuencias);
    Firma_Grabacion = zeros(1,N_Frecuencias);
    
    for i=1:N_Frecuencias
        Comparacion_Prom(i) = Maximo_Bandas_dB(i)/Promedio;
        Firma_Grabacion(i) = 1./(Comparacion_Prom(i))^100;
    end
    
    %% Correlacion
    
    [Correlacion_B,Lag_B] = xcorr(Firma_Grabacion,Firma_B,'coeff');
    [Correlacion_A,Lag_A] = xcorr(Firma_Grabacion,Firma_A,'coeff');
    Maximo_Corr_B = max(Correlacion_B);
    Maximo_Corr_A = max(Correlacion_A);
    [~,pos] = find(Correlacion_B == Maximo_Corr_B);
    Valor_B = Correlacion_B(pos);
    [~,pos] = find(Correlacion_A == Maximo_Corr_A);
    Valor_A = Correlacion_A(pos);
    
    if Valor_B > 0.8
        disp('Posible Detecci�n Lancha Verde.')
        EstimacionVerde(Captacion_Blanco)
    elseif Valor_A >= 0.7
        disp('Posible Detecci�n Lancha Amarilla')
        EstimacionAmarilla(Captacion_Blanco)
    end
    disp('--------------')
    Indicator = 1;
end


