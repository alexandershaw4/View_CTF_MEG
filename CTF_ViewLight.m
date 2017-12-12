function [Data,times,Markers,D,info] = CTF_ViewLight(Dname)


D       = readCTFds(Dname);
Data    = getCTFdata(D);
EEGid   = strmatch('EEG', D.res4.chanNames);
MEGid   = cat(1,D.res4.senres.sensorTypeIndex);
MEGid   = find(MEGid==5);
Data    = permute(Data,[2,1,3]);
Markers = readmarkerfile(Dname);
Labels  = D.res4.chanNames;

T{1} = [' regexp(D.hist, ''StartTime: *'', ''match'') '];
T{2} = [' regexp(D.hist, ''EndTime: *'', ''match'') '];

[o1,o2] = eval(T{1});
onset   = str2num(D.hist(o2+11:o2+16));
[o1,o2] = eval(T{2});
offset  = str2num(D.hist(o2+9:o2+13));
times   = onset:(1/D.res4.sample_rate):offset;

if isempty(times);
    NS = D.res4.no_samples;
    SR = D.res4.sample_rate;
    NT = D.res4.no_trials;
    onset  = 0;
    offset = NS/SR;
    t = linspace(onset,offset,NS);
    times = t;
end

info.Labels = Labels;
info.EEGid  = EEGid;
info.MEGid  = MEGid;

