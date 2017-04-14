function [EEG, srateNew] = resampleToTarget(EEG, srateTarget)
%% Determines an appropriate resampling strategy based on srateTarget
%
%  Parameters:
%     EEG            EEGLAB EEG structure
%     srateTarget    target sampling rate
%
%  If srateTarget < EEG.srate, don't resample otherwise resample at the
%  best event divisor for the srateTarget.
%
%
%% Determine the right sampling rate
   srateNew = getTargetSrate(EEG.srate, srateTarget);
   if isempty(srateNew)
      return;
   end
   EEG =  pop_resample(EEG, srateNew);
end

function srateNew = getTargetSrate(srate, srateTarget)
    srateNew = [];
    if isempty(srateTarget) || srate <= srateTarget
        return;
    end
    srateRem = rem(srate, srateTarget);
    if srateRem == 0
        srateNew = srateTarget;
        return;
    end
    targetDivisor = floor(srate/srateTarget);
    if targetDivisor == 1
        return;
    end
    srateNew = srateTarget;
end
