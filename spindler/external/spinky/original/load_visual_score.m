function [train_score] = load_visual_score(visual_score_file,train_data_length)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
z=load(visual_score_file);
sp=z(:,1);
train_score=zeros(1,train_data_length);
[uV,aa] = unique(sp(:,1));
[~,iV] = sort(aa);
nV = histc(sp(:,1),uV);
train_score(uV(iV))=nV(iV);

end

