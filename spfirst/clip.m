function  y = clip( x, lo, hi )
%CLIP	Clips a signal so laves fall between "lo" and "hi".
%  usage:    y = clip( x, low, high )
%     x = input image
%   low = set everything below here to low
%  high = set everything above here to high
%     y = output image
%
y = (x .* [x<=hi])  +  (hi .* [x>hi]);
y = (y .* [x>=lo])  +  (lo .* [x<lo]);
