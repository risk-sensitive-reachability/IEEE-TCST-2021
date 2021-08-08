%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: Intended to be called from calculate_ambient_variables. 
% DESCRIPTION: 
%   Builds a 'zipped' 2-dimensional coordinate matrix of the form:
%   value x1   |   value x2
%        1       |      3         
%        1       |      4
%        1       |      5
%        2       |      3         
%        2       |      4
%        2       |      5
%   ...
%   i.e., each row represents a coordinate; this is useful because it
%   facilitates iterating over the coordinates in parallel with parfor
%   
% INPUTS: 
%  ambient : a partial ambient struct, created with 
%       calculate_ambient_variables which calls this method
% OUTPUT:
%   xcoord : a matrix containing the coordinates of x, with one row per
%       coordinate pair
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xcoord = build_xcoord_2Dim(ambient)

z = 0; 

xcoord = zeros(ambient.nx,2); 

for i = 1:ambient.x1n
    
    for j = 1:ambient.x2n
        
        z = z + 1; 
        
        xcoord(z,1) = ambient.x1s(i); 
        
        xcoord(z,2) = ambient.x2s(j); 
        
    end
    
end

