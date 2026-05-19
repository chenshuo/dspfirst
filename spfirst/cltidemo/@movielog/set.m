function ml = set(ml,varargin)
% @MOVIELOG/SET Set movie log properties to the specified values
% and return the updated object.  The following are valid properties:
% lineNo, time0, data.
%
% See also @MOVIETOOL/ ... GET

% Author(s): Greg Krudysz

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
    case 'lineNo'
        ml.lineNo = val;
    case 'time0'
        ml.time0  = val;
    case 'data'
        ml.data   = val; 
    otherwise
        error('movielog properties: lineNo, time0, data')
    end
end