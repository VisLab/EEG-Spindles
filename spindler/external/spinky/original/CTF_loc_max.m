function [nbr,pos_spindle]=CTF_loc_max(CTF_s,fs)
a= length (CTF_s(:,1));
b= length (CTF_s(1,:));
 dBS=CTF_s;
 ab=1;
 bc=1;
%  for ii=2:1:a-1
%    for jj=2:1:b-1
%            dBS(ii,jj)= mean(mean(dBS(ii-1:ii+1,jj-1:jj+1)));
%            
%        end
%  end
  seuil=min(min(dBS));
  ord=[];
%  for ii=2:1:a-1
%    for jj=2:1:b-1
%        if((dBS(ii,jj)>dBS(ii-1,jj))&&(dBS(ii,jj)>dBS(ii+1,jj)) &&(dBS(ii,jj)>dBS(ii,jj-1))&&(dBS(ii,jj)>dBS(ii,jj+1))&&(dBS(ii,jj)>dBS(ii+1,jj+1))&&(dBS(ii,jj)>dBS(ii-1,jj-1))&&(dBS(ii,jj)>dBS(ii-1,jj+1))&&(dBS(ii,jj)>dBS(ii+1,jj-1))&&(dBS(ii,jj)>seuil))
%            axe(ab)=jj;
%            ord(bc)=ii;
%            ab=ab+1;
%            bc=bc+1;
%        end
%    end
%  end
 ii=2:1:a-1;
jj=2:1:b-1;
ind = find( (dBS(ii,jj)>dBS(ii-1,jj)) &...  % using & instead of && because it is not a binary and but a logical and.
            (dBS(ii,jj)>dBS(ii+1,jj)) &...
            (dBS(ii,jj)>dBS(ii,jj-1)) &...
            (dBS(ii,jj)>dBS(ii,jj+1)) &...
            (dBS(ii,jj)>dBS(ii+1,jj+1)) &...
            (dBS(ii,jj)>dBS(ii-1,jj-1)) &... 
            (dBS(ii,jj)>dBS(ii-1,jj+1)) &...
            (dBS(ii,jj)>dBS(ii+1,jj-1)) &...
            (dBS(ii,jj)>seuil));        
ord = mod(ind-1, length(ii))+2;    % +2 is because ii and jj start at 2 
axe = floor((ind-1)/length(ii))+2;
if numel(ord)==0
     nbr=0;
     pos_spindle=[];
else
com1=0;
com2=0;
pos1=1;
pos2=1;
n=fs*30;
len=fs*30;
for kk=1:length(ord)
    while ((dBS(ord(kk),axe(kk)-pos1)>seuil)&&((axe(kk)-pos1)>1))
        com1=com1+1;
        pos1=pos1+1;   
    end
    gauche(kk)=com1;
    debut(kk)=(axe(kk)-com1);
    while ((dBS(ord(kk),axe(kk)+pos2)>seuil)&&((axe(kk)+pos2)<n-1))
        com2=com2+1;
        pos2=pos2+1;
     end
    droite(kk)=com2;
    fin(kk)=(axe(kk)+com2);
    tab(kk)=com1+com2;
    pos1=1;
    pos2=1;
    com1=0;
    com2=0;
end


posdebhfo1=debut;
posfinhfo1=fin;
matto=zeros(1,len);
for jj=1:1:length(posdebhfo1)
    matto(posdebhfo1(jj):posfinhfo1(jj))=1;
end  
ttttt=1;
tttt=1;
wew=1;
ewe=length(matto);
    while(matto(wew)~=0)
        wew=wew+1;
    end
    while(matto(ewe)~=0)
        ewe=ewe-1;
    end
for jj=wew:1:ewe-1
    if((matto(jj)==0)&&(matto(jj+1)==1))
      posdepHFO(ttttt)=jj; 
      ttttt=ttttt+1;
    end
    if((matto(jj)==1)&&(matto(jj+1)==0))
      posfinHFO(tttt)=jj;  
      tttt=tttt+1;
    end
end 
pos_spindle=zeros(1,len);
for jj=1:1:length(posfinHFO)
    pos_spindle(posdepHFO(jj):posfinHFO(jj))=1;
end  
%[position,nnn]=findpeaks(pos_spindle,'MINPEAKDISTANCE',fs);
%nbr=length(nnn);

%%%seuillage de durée
% 
pos_spindle(1)=0;
pos_spindle(end)=0;
duree=200;
y=pos_spindle; 
sa=sign(diff([-inf y]));
sb=sign(diff([-inf y(end:-1:1)]));
sb=sb(end:-1:1);
d=find(sb==-1);
f=find(sa==-1);
a=d((f-d)< duree); %position debut des ondes non spindles
b=f((f-d)< duree); %position fin des ondes non spindles
for i=1:length(a)
pos_spindle(a(i):b(i))=0;
end
gg=f-d;
if numel(gg) ==0
    nbr=0;
else
nbr=length(d((f-d)>=duree));
end
end

end


