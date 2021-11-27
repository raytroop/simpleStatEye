% load('PulseResponseReflective100ps.mat');
% M = 2;
% DC = false;
% [pdaeye,th] = pulse2pda(pulse,SamplesPerSymbol,M,DC);
% figure
% t = th*SymbolTime*1e12;
% plot(t,pdaeye)
% legend('Upper PDA eye','Lower PDA eye')
% xlabel('ps')
% ylabel('V')
% title('Peak Distortion Analysis Eye')
% grid on

load('PulseResponseReflective100ps.mat');
modulation = 2;
[stateye,vh,th] = pulse2stateye(pulse,SamplesPerSymbol,modulation);
%stateye(1:200, 1:200) = 10000;
cmap = serdes.utilities.SignalIntegrityColorMap;
figure(1);
imagesc(th*SymbolTime*1e12,vh,stateye)
colormap(cmap)
colorbar
axis('xy')
xlabel('ps')
ylabel('V')
title('Statistical Eye PDF')

[ysize, xsize] = size(stateye);
ymid = floor((ysize+1)/2);
upperEyePDF = stateye(ymid:end,:); 
lowerEyePDF = stateye(ymid:-1:1,:); % upside down

upperEyeCDF = cumsum(upperEyePDF, 1);
lowerEyeCDF = cumsum(lowerEyePDF, 1);


berlist = [1e-12, 1e-6, 0.01];
lenBer = length(berlist);
upperBERIdx = zeros(lenBer, xsize);
lowerBERIdx = zeros(lenBer, xsize);

for i = 1:lenBer
    for j = 1:xsize
        upperBERIdx(i, j) = find(upperEyeCDF(:, j) >= berlist(i), 1);
        lowerBERIdx(i, j) = find(lowerEyeCDF(:, j) >= berlist(i), 1);
    end
end

% shift idx to algin original stateye
upperBERIdx = ymid - 1 + upperBERIdx;
lowerBERIdx = ymid + 1 - lowerBERIdx;

upperBERVal = vh(upperBERIdx);
lowerBERVal = vh(lowerBERIdx);

tticks = th*SymbolTime*1e12;
figure(2);
lgd = cell(lenBer*2,1) ;
hold on;
for i = 1:lenBer
    plot(tticks, upperBERVal(i, :), 'Color', cmap(i*15, :));
    lgd{i*2-1} = strcat('BER=',num2str(berlist(i)));
    plot(tticks, lowerBERVal(i, :), 'Color', cmap(i*15, :));
    lgd{i*2} = "";
end
hold off;
legend(lgd)
axis('xy')
xlabel('ps')
ylabel('V')
title('Statistical Eye BER')