function [w,rN] = dpca(r,Ndims)
%% function to compute first Ndims principal directions of three-dimensional 
%% activity matrix r (Trials x Time x Neurons) separately for each
%% time-step; w is also three-dimensional (Components x Time x Neurons)
%% rN (Trials x Time x Ndims) is the activity projected onto those dimensions

Ntrls = size(r,1);
Nt = size(r,2);
Nunits = size(r,3);

%% compute pca
for i=1:Nt
    fprintf(['Time point ' num2str(i) '\n']);
    r_temp = [];
    r_temp = squeeze(r(:,i,:));
    coeff = pca(r_temp);
    for k=1:Ndims
        w(k,i,:) = coeff(:,k);
        w(k,i,:) = coeff(:,k);
        w(k,i,:) = coeff(:,k);
    end
end

%% project
rN = nan(Ntrls,Nt,Ndims);
for k=1:Ndims
    rN(:,:,k) = (squeeze(w(k,:,:))*r_temp')';
end