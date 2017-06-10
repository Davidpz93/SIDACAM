%LOCALIZACI�N
%Este c�digo es un prototipo para la comparaci�n de una se�al captada
%por un arreglo de dos micr�fonos. Realizando una correlaci�n entre las dos
%se�ales puede determinar si el objetivo pas� por un lado A o por un lado
%B.


%% Grabaci�n 1
recObj = audiorecorder(48000, 16,1);
disp('Comienzo Grabaci�n.')
recordblocking(recObj, 9);
disp('Fin Grabaci�n.');
M = getaudiodata(recObj);
M = audioread(''); %se�al de prueba.
%% Grabaci�n 2
recObj2 = audiorecorder(48000, 16,1);
disp('Comienzo Grabaci�n.')
recordblocking(recObj2, 9);
disp('Fin Grabaci�n.');
N = getaudiodata(recObj2);
N = audioread(''); %se�al de prueba.

[Correla_MN,Lagg] = xcorr(M,N,'coeff');
[~,pos] = max(Correla_MN);
if Lagg(pos) > 0
    disp('La lancha cruz� por el lado A')
elseif Legg(pos) < 0
    disp('La lancha cruz� por el lado B')
end




