function X = SmoothSpikes(X, filtwidth)

[~, nunits, nsamples] = size(X);

%% define filter to smooth the firing rate
t = linspace(-2*filtwidth,2*filtwidth,4*filtwidth + 1);
h = exp(-t.^2/(2*filtwidth^2));
h = h/sum(h);

%% smooth
if nsamples==1
    for i=1:nunits, X(:,i) = conv(X(:,i),h,'same'); end
else
    for j=1:nsamples
        for i=1:nunits, X(:,i,j) = conv(X(:,i,j),h,'same'); end
    end
end