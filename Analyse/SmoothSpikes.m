function X = SmoothSpikes(X, filtwidth)

[~, nunits] = size(X);

%% define filter to smooth the firing rate
t = linspace(-2*filtwidth,2*filtwidth,4*filtwidth + 1);
h = exp(-t.^2/(2*filtwidth^2));
h = h/sum(h);

%% smooth
for i=1:nunits, X(:,i) = conv(X(:,i),h,'same'); end