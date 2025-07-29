function controller = singleKCubeUI(serialNumber)

    arguments
        serialNumber        char
    end

    import System.Windows.Forms.*
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.DeviceManagerUI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.KCube.DCServoCLI.*
    import Thorlabs.MotionControl.KCube.DCServoUI.*
    import Thorlabs.MotionControl.Controls.*

    f = Form;

    DeviceManagerCLI.BuildDeviceList();

    controller = KCubeDCServoControl();
    controller.LargeView = true;
    controller.Dock = DockStyle.Fill;
    controller.SerialNumber = serialNumber;
    controller.CreateDevice();

    f.Controls.Add(controller);
    f.Show();