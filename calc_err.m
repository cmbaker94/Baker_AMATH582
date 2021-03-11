function [errNum,sucRate] = calc_err(result,labels)
% this function counts the number of erros in the results and calculates
% the success rate 

% errors
% disp('Number of mistakes');
errNum = length(find(result ~= labels));

% errNum = sum(abs(ResVec - hiddenlabels))
% disp('Rate of success'); 
TestNum = length(labels);
sucRate = 1-errNum/TestNum;