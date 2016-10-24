function [ bin, warn] = manchester2bin( man_str )
%   MANCHESTER2Bin(inputData) decodes manchester data to its corresponding 
%    binary sequence.
%
%   Example: 
%       >>bin = bin2manchester('01011010')
%       
%       bin =
%       1100
%
%   Other m-files required: none
%   Subfunctions: none
%   MAT-files required: none
%
%   Author: James Robert Marriott
%   email: jamesrobertmarriott@gmail.com 
%   July 2014; Last revision: 10-July-2014

    [~, bitlenth ] = size(man_str);
    
    
    ref = 0;
    
    
    
    for jj = 1:(bitlenth/2)
        
        if mod(bitlenth,2) == 0
            
            oldref = ref+1;
            ref = (2*jj);
            bitman = man_str(oldref:ref)  ;  

            if  bitman == '01';
                bitbin{jj} = '0';
            elseif bitman == '10';
                    bitbin{jj} = '1'    ;        
            else
                warning('invalid Manchester Code');
                warn = 1;
                bitbin{jj} = '?';
            end
            
        else 
            error('invalid Manchester Code')
        end
  
    end

    a = strcat(bitbin{1:bitlenth/2});
    bin = a;
    bin(a=='1')='0';
    bin(a=='0')='1';
end

