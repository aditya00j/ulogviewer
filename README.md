# Simple Matlab GUI to View PX4 ULog Files

![Encode Image](Assets/preview.png)

This GUI was created using GUIDE in Matlab 2017a. It is fairly simple, it can only plot the time histories of message fields. To process the ULog file, [pyulog](https://github.com/PX4/pyulog) is used. In order for the GUI to work correctly, change the following line in `ulogviewver.m`:

```
handles.ulog2csv = '/opt/anaconda3/bin/ulog2csv';
```

The above path should correctly point to the `ulog2csv` binary installed by `pyulog`.