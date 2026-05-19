 function a = set(a,varargin)
% @MOVIETOOL/SET Set movietool properties and return the updated object
%
% To set a.prop = value :
%       a = set(a,'prop1',value1,'prop2',value2,...);
%
% See also @MOVIETOOL/ ... GET

% Author(s): Greg Krudysz

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop      
        case 'play_flag'
            a.play_flag = val;
        case 'rec_flag'
            a.rec_flag = val;
        case 'stop_flag'
            a.stop_flag = val;
        case 'hili_flag'
            a.hili_flag = val;
        case 'playdata'
            a.playdata = val;                    
        otherwise
            error('Error in @MOVIETOOL/SET: property not found!')
    end  
end
setappdata(a.fig,'movietoolData',a);