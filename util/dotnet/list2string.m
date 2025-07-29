function [str, N] = netList2string(netList)
% NETLIST2STRING
%
% Description:
%   Converts a .NET List<string> to MATLAB string array
%
% Syntax:
%   [str, N] = netList2string(netList)
%
% Inputs:
%   netList         .NET List<string>
%
% Outputs:
%   str             string array
%       List contents
%   N               double
%       Number of elements in list
%
% History:
%   20250720    SSP
% -------------------------------------------------------------------------

    N = netList.Count;
    if N > 0
        str = strings(N, 1);
        for i = 1:N
            % .NET uses 0-based indexing
            str(i) = string(netList.Item(i-1));
        end
    else
        str = string.empty();
    end