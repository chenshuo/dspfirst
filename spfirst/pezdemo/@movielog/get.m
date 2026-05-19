function val = get(ml,prop_name)
% @MOVIELOG/GET Get movie log properties from the movielog object
% and return the value.  The following are valid properties: lineNo, time0,
% and Data
%
% See also @MOVIELOG/ ... SET

% Author(s): Greg Krudysz

switch prop_name
    case 'lineNo'
        val = ml.lineNo;
    case 'time0'
        val = ml.time0;
    case 'Data'
        if isempty(ml.data)
            data_status = 'empty';  else
            data_status = 'full';
        end
        val = data_status;       
    otherwise
        error([prop_name,' Is not a valid MOVIELOG property'])
end