function [CTF_s] = seuillage_CTF(CTF,seuil)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[m n]=size(CTF);

CTF_s = CTF;
CTF_s(CTF<seuil) = 0;
% for i=1:m
%     for j=1:n
%         if CTF(i,j)>=seuil
%             CTF_s(i,j)=CTF(i,j);
%         else
%             CTF_s(i,j)=0;
%         end
%     end
% end
% ab=1;bc=1;
% for ii=2:1:m-1
%     for jj=2:1:n-1
%         if((CTF_s(ii,jj)>CTF_s(ii-1,jj))&&(CTF_s(ii,jj)>CTF_s(ii+1,jj)) &&(CTF_s(ii,jj)>CTF_s(ii,jj-1))...
%                 &&(CTF_s(ii,jj)>CTF_s(ii,jj+1))&&(CTF_s(ii,jj)>CTF_s(ii+1,jj+1))&&(CTF_s(ii,jj)>CTF_s(ii-1,jj-1))...
%                 &&(CTF_s(ii,jj)>CTF_s(ii-1,jj+1))&&(CTF_s(ii,jj)>CTF_s(ii+1,jj-1))&&(CTF_s(ii,jj)>seuil))
%             abss(ab)=jj;
%             ord(bc)=ii;
%             ab=ab+1;
%             bc=bc+1;
%         end
%     end
% end
end

