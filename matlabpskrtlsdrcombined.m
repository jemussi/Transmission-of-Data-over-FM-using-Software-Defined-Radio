% Request user input from the command-line for application parameters
close all
clear all
clc
L=20; %set for 20 bit transmission
userInput = helperFMUserInput;

% Calculate FM system parameters based on the user input
[fmRxParams,sigSrc] = helperFMConfig(userInput);

% Create FM broadcast receiver object and configure based on user input
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
    'SampleRate', fmRxParams.FrontEndSampleRate, ...
    'FrequencyDeviation', fmRxParams.FrequencyDeviation, ...
    'FilterTimeConstant', fmRxParams.FilterTimeConstant, ...
    'AudioSampleRate', fmRxParams.AudioSampleRate, ...
    'Stereo', false);

% Create audio player
player = audioDeviceWriter('SampleRate',fmRxParams.AudioSampleRate);

% Initialize radio time
radioTime = 0;

% Main loop
BPSK=zeros(640,1);
while radioTime < userInput.Duration
  % Receive baseband samples (Signal Source)
  if fmRxParams.isSourceRadio
      %if% fmRxParams.isSourcePlutoSDR
         % rcv = sigSrc();
          %lost = 0;
          %late = 1;
     % else
          [rcv,~,lost,late] = sigSrc();
      %end
  else
    rcv = sigSrc();
    lost = 0;
    late = 1;
  end

  % Demodulate FM broadcast signals and play the decoded audio
  audioSig = fmBroadcastDemod(rcv);
  player(audioSig);

  % Update radio time. If there were lost samples, add those too.
  radioTime = radioTime + fmRxParams.FrontEndFrameTime + ...
    double(lost)/fmRxParams.FrontEndSampleRate;
    BPSK = vertcat(BPSK,audioSig);%audiorecorder (fmRxParams.AudioSampleRate,8,1,0);
    %recordblocking(recFM,userInput.Duration);
    %FM=getaudiodata(recFM);
end

% Release the audio and the signal source
release(sigSrc)
release(fmBroadcastDemod)
release(player)

%%
BPSK=BPSK.';
[xr,locr]=findpeaks(BPSK);
meanp = mean(xr);
[row,colmn]=find(xr>(meanp));
BPSK=BPSK(locr(colmn(1)):end);
plot(BPSK)
B=fir1(822,1.83*120/(762787/2),'high');
Aa=BPSK.*BPSK;
hpout=filter(B,1,Aa);
[x loc] = findpeaks(hpout);
ls=loc(1);
hpout2=hpout(ls:end);
hpout2=double(hpout2);
fdout=interp(hpout2,2);
carrier=fdout(1:length(fdout)/2);
demod=BPSK(1:length(carrier)).*carrier;
 
 %decoding
 tp=0:(length(demod))/L;
 k=1;
 RCV=[];
 for (ii=1:L)
     SM=0;
     for(j=1:length(tp)-1)
    SM=SM+demod(k);
         k=k+1;
     
 end
     if (SM>0)
         RCV=[RCV 1];
     else
         RCV=[RCV 0];
     end
 end
RCV
%% error counting sub routine where A = original transmitted sequence
err=RCV-A;
count=0
for (jj=1:length(err))
    if(err(jj)==0)
    count=count;
    else
    count=count+1;
    end
end
count