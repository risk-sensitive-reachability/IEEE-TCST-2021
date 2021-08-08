%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: A custom method for distributing work in a parallel pool. 
% This maximizes the size of the job sets to minimize overhead 
% on the assumption that tasks are all of near equal size. 
%
% INPUT: 
    % n : number of tasks
    % nw : number of workers
% OUTPUT:   
    % jobArray : An array containing the number of tasks to assign to each worker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function jobArray = distribute_work(n, nw)

    jobArray = ones(1, nw); 

    for i = 1:nw
       
        jobArray(i) = floor(n/nw); 
        
    end
    
    utilized = sum(jobArray); 
    
    unassigned = n - utilized; 
    
    for i = 1:unassigned
       
        jobArray(i) = jobArray(i) + 1; 
        
    end
    
end