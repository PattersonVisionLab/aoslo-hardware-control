classdef ImagingModes < double

    enumeration
        CALIBRATION (0)
        LED_STIMULI (1)
        SPATIAL_STIMULI (2)
        LED_WAVEFORM (3)
        CONFIGURATION (4)
    end

    methods 
        function value = getTabID(obj)
            value = double(obj);
        end
    end

    methods (Static)
        function obj = init(value)
        
            import ur.pattersonlab.aoslo.slo.ImagingModes.*;
            
            if isnumeric(value)
                mustBeMember(value, 0:4);
                ImagingModes(value);
                return
            end

            try
                obj = ImagingModes.(upper(value));
                return
            catch 
                obj = [];
            end
            
            switch value
                case 'led'
                    obj = ImagingModes.LED_STIMULI;
                case {'spatial', 'physiology'}
                    obj = ImagingModes.SPATIAL_STIMULI;
            end

            if isempty(obj)
                error('ImagingModes:UnknownInput', ...
                    'Imaging mode %s not recognized', value);
            end
        end
    end
end