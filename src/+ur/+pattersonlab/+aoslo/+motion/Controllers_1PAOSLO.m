classdef Controllers_1PAOSLO < double
% Serial numbers for 1P AOSLO controllers

    enumeration 
        MUSTANG     (83850011) % MTS25
        TOPTICA     (83849957) % MTS25
        REFLECTANCE (27006819) % MTS50
        
        REF_X       (83857268) % Z912B
        REF_Y       (83855258) % Z912B
        REF_Z       (26250117)

        VIS_X       (83848285) % Z912B
        VIS_Y       (83848287) % Z912B
        VIS_Z       (83848308) % Z912B

        FIBER_X     (26005133) % Z912B
        FIBER_Y     (26004981) % Z912B
        FIBER_Z     (26005106) % Z912B

        STAGE_X     (27007514) % Z925B
        STAGE_PITCH (27007530) % PY004Z8 Pitch
        STAGE_YAW   (27007586) % PY004Z8 Yaw

        CERNA_X      (2837365) % PLS
        CERNA_Y      (2837365) % PLS
        CERNA_Z      (283328)  % MPM
    end

    methods
        function value = getCustomStageName(obj)
            import ur.pattersonlab.aoslo.motion.Controllers_1PAOSLO

            switch obj
                case Controllers_1PAOSLO.STAGE_X
                    value = 'Z925B';
                case Controllers_1PAOSLO.STAGE_PITCH
                    value = 'PY004Z8 Pitch';
                case Controllers_1PAOSLO.STAGE_YAW
                    value = 'PY004Z8 Yaw';
                otherwise
                    value = [];
            end
        end
    end
end

