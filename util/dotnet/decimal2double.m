function output = decimal2double(input)

    assert(isa(input, 'System.Decimal'), 'Input must be a System.Decimal');

    output = System.Decimal.ToDouble(input);
