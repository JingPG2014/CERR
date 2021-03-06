function planC  = joinH5planC(segMask3M,userOptS,planC)
% function planC  = joinH5planC(segMask3M,userOptS,planC)
%

if ~exist('planC','var')
    global planC
end
indexS = planC{end};

resizeMethod = userOptS.resize.method;
cropS = userOptS.crop; %Added

scanNum = 1;
isUniform = 0;

[minr, maxr, minc, maxc, mins, maxs] = getCropLimits(planC,segMask3M,scanNum,cropS);
scanArray3M = planC{indexS.scan}(scanNum).scanArray;
sizV = size(scanArray3M);
maskOut3M = zeros(sizV, 'uint32');

switch resizeMethod
    
    case 'pad2D'
        limitsM = [minr, maxr, minc, maxc];
        resizeMethod = 'unpad2d';
        originImageSizV = [sizV(1:2), maxs-mins+1];
        [~, maskOut3M(:,:,mins:maxs)] = ...
            resizeScanAndMask(segMask3M,segMask3M,originImageSizV,resizeMethod,limitsM);
        
    otherwise
        originImageSizV = [maxr-minr+1, maxc-minc+1, maxs-mins+1];       
        tempMask3M = ...
            resizeScanAndMask(segMask3M,segMask3M,originImageSizV,resizeMethod);
        maskOut3M(minr:maxr, minc:maxc, mins:maxs) = tempMask3M;
end


for i = 1 : length(userOptS.strNameToLabelMap)
    
    labelVal = userOptS.strNameToLabelMap(i).value;
    maskForStr3M = maskOut3M == labelVal;
    planC = maskToCERRStructure(maskForStr3M, isUniform, scanNum, userOptS.strNameToLabelMap(i).structureName, planC);
    
end