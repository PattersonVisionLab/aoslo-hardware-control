
NET.addAssembly('C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Thorlabs.TLDC_64.Interop.dll');
import Thorlabs.TLDC_64.Interop.*;

methodsview('Thorlabs.TLDC_64.Interop.TLDC')

handle = System.IntPtr(0);
tlDC = TLDC(handle);

[~,deviceCount] = tlDC.findRsrc();
disp([num2str(deviceCount),' available devices']);
