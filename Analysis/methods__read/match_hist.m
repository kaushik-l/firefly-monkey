function output_hist = match_hist(ref_data, targ_data)
% histogram matching

% get reference data 
[f_ref,x_ref] = ecdf(ref_data);
% data to be matched
[f_input, x_input] = ecdf(targ_data);

% interp target data x with ref data 
output_hist = interp1(f_ref,x_ref,f_input, 'linear');

end 
 