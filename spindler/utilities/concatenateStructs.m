function [result, unused] = concatenateStructs(s1, s2)


unused = struct();
result = s1;
s2Names = fieldnames(s2);
for k = 1:length(s2Names)
    if ~isfield(result, s2Names{k})
        result.(s2Names{k}) = s2.(s2Names{k});
    else
        unused.(s2Names{k}) = s2.(s2Names{k});
    end
end
