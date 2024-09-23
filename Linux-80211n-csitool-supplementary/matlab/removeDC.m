function [sOut] = removeDC(sInput)
    DC = mean(sInput);
    sOut = sInput - DC;
end
