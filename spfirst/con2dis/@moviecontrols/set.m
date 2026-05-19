function mc = set(mc,varargin)
% @MOVIECONTROLS/SET Set moviecontrols properties to the specified values
% and return the updated object.  The following are valid properties:
% moviename, moviepath, frameNo, time, playdata, barpatch, barpatcha, bars,
% and mdisplay.
%
% See also @MOVIETOOL/ ... GET

% Author(s): Greg Krudysz

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        case 'moviename'
            mc.moviename = val;
        case 'moviepath'
            mc.moviepath = val;
        case 'frameNo'
            mc.frameNo   = val;
        case 'time'
            mc.time      = val;
        case 'playdata'
            mc.playdata  = val;
        case 'barpatch'
            set(mc.barpatch,'xdata',[0 val val 0]);
        case 'barpatcha'
            set(mc.barpatcha,'xdata',[0 val val 0]);
        case 'bars'
            set([mc.bara,mc.barpatcha],'visible',val);
        case 'mdisplay'
            set(mc.mtool,'checked',val);
        otherwise
            error({'moviecontrols properties: moviename, moviepath, frameNo'}, ...
            {'time, playdata, barpatch, barpatcha, bars'});
    end
end