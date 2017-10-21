function tspk = SimulateSpikes(vars,prs,var)

velkrnlwidth = prs.velkrnlwidth;
distkrnlwidth = prs.distkrnlwidth;
eyekrnlwidth = prs.eyekrnlwidth;
sackrnlwidth = prs.sackrnlwidth;
targetkrnlwidth = prs.targetkrnlwidth;

binSize = double(median(diff(vars.ts)));
expt = buildGLM.initExperiment('s', binSize, 'firefly-monkey', prs);
ts = vars.ts;
lambda = ones(length(ts),1);


if any(strcmp(var,'linvel'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, expt.binfun);
    weights.linvel = bs.B*[0.01 -0.01 0 0 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.linvel,weights.linvel));
    lambda = lambda.*lambda2(1:length(ts));
end

if any(strcmp(var,'angvel'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, expt.binfun);
    weights.angvel = bs.B*[0 0 -0.015 0.015 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.angvel,weights.angvel));
    lambda = lambda.*lambda2(1:length(ts));
end

if any(strcmp(var,'firefly'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, expt.binfun);
    weights.firefly = bs.B*[0.5 -0.5 0 0 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.firefly,weights.firefly));
    lambda = lambda.*lambda2(1:length(ts));
end

if any(strcmp(var,'saccade'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', eyekrnlwidth, 10, expt.binfun);
    weights.saccade = bs.B*[0.5 0 0 0 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.saccade,weights.saccade));
    lambda = lambda.*lambda2(1:length(ts));
end

if any(strcmp(var,'dist2fly'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, expt.binfun);
    weights.dist2fly = bs.B*[0.0005 0 0 0 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.dist2fly,weights.dist2fly));
    lambda = lambda.*lambda2(1:length(ts));
end

if any(strcmp(var,'dist2stop'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, expt.binfun);
    weights.dist2stop = bs.B*[0.0005 0 0 0 0 0 0 0 0 0]';
    lambda2 = exp(conv(vars.dist2stop,weights.dist2stop));
    lambda = lambda.*lambda2(1:length(ts));
end

ts = vars.ts;
endprocess = 0; tspk = [];
while ~endprocess
    if isempty(tspk), tspk(end+1) = exprnd(1/max(lambda)) + ts(1);
    else, tspk(end+1) = exprnd(1/max(lambda)) + tspk(end); end
    if tspk(end) > ts(end)
        tspk(end) = [];
        endprocess = 1;
    end
end
% thinning
tspk2 = [];
for i=1:length(tspk)
    [~,indx] = min(abs(ts - tspk(i)));
    if lambda(indx)/max(lambda) > rand
        tspk2 = [tspk2 tspk(i)];
    end
end
tspk = tspk2;