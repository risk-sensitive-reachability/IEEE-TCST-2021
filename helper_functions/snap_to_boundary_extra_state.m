%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION: Snaps state transitions to the boundary of the augmented
%       state-space
% INPUTs: 
%	extra_kPLUS1: the next state in the augmented state space
%	ambient struct 
% OUTPUTS: 
%	extra_kPLUS1: the next state snapped to the boundary of the augmented
%       state-space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function extra_kPLUS1 = snap_to_boundary_extra_state( extra_kPLUS1, amb )

    all_values_extra_state = unique(amb.xcoord(:,end));

    max_extra_state = max(all_values_extra_state);

    min_extra_state = min(all_values_extra_state);

    if extra_kPLUS1 > max_extra_state

        extra_kPLUS1 = max_extra_state;

    elseif extra_kPLUS1 < min_extra_state

        extra_kPLUS1 = min_extra_state;

    end

end