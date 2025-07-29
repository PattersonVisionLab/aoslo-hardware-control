function loadDLLs(kinesisPath)
% LOADDLLS
%
% Description:
%   Load the necessary Thorlabs Kinesis .NET assemblies for MATLAB.
%   Includes generic CLI and UI assemblies and some device-specific
%   assemblies (KDC101, KST201, TDC001).
%
% Syntax:
%   loadDLLs()
%   loadDLLs(kinesisPath)
%
% TODO: Strip out device-specific DLL; moved to the DeviceTypes class
% --------------------------------------------------------------------------

    arguments
        kinesisPath     (1,1)   string   {isfolder} = "C:\Program Files\Thorlabs\Kinesis"
    end

    kinesisPath = char(kinesisPath);

    % For operating from command line
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.DeviceManagerCLI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.GenericMotorCLI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoCLI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorCLI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.StepperMotorCLI.dll'));
    % For operating from UI
    NET.addAssembly('System.Drawing');
    NET.addAssembly('System.Windows.Forms');
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.Controls.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.DeviceManagerUI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoUI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorUI.dll'));
    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.StepperMotorUI.dll'));
