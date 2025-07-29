function output = dict2dict(input)
% DICT2DICT
%
% Note: Assumes String keys

    % Nevermind...
    output = input.dictionary();
    return

    count = input.Count;
    keys = strings(1, count);
    values = [];

    enumerator = input.GetEnumerator();

    i = 1;
    while enumerator.MoveNext()
        currentItem = enumerator.Current;
        keys(i) = string(currentItem.Key);
        values = cat(1, values, currentItem.Value);
        i = i + 1;
    end

    % Quick hack to get correct type
    if endsWith(class(input), '*Boolean>')
        values = logical(values);
    end

    output = dictionary(keys, values);