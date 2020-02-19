module SyringePumpJl
    using Measurements, Unitful,  Blink, Interact, LibSerialPort, Plots

    include("UI.jl")
    export InputField, UncertainInputField, value, Calibration,
            makeplot, launch_pump_interface

    include("RXTX.jl")
    export drive_pump, stop_pump, drive_physical
end # module
