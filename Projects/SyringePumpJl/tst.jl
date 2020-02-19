using Pkg
Pkg.API.develop(Pkg.PackageSpec(name="SyringePumpJl", path="/home/caseykneale/Desktop/SyringePumpJl"))
using SyringePumpJl
using Blink, Interact, Measurements, Unitful, LibSerialPort

# mcu = nothing
# try
#     mcu = open( "/dev/ttyACM0", 9600 )
# catch
#
# end
mcu = open( "/dev/ttyACM0", 9600 )

driver          = InputField( "Move N Steps", 100.0,  nothing);
driver_btn      = Widgets.button("Drive Pump");
c               = Calibration("mm");
calibration_plt = Observable{Any}(nothing);
drive_status    = Observable{Any}(nothing);
map!( x ->  drive_pump( mcu, convert( Int64, value(driver) ),
            convert( Int64, 10000) ), drive_status, driver_btn)

map!( x -> makeplot( x ), calibration_plt, c.steps_and_disps)

calibrate_txt = "Drive the stepper motor N steps, and measure the displacement of the plunger with a caliper." *
                "Add the experimental values to the calibration model." *
                "After numerous runs, you will be given a calibration + uncertainty for dispensing fluids based on a linear model."

calibrationbox = vbox( "Calibrate:", calibrate_txt, hbox(driver.field, driver_btn),
                        calibration_plt, c.widget
                );

units       = UncertainInputField( "Dispense Rate", 50.0, 0.02, u"mm / mL");
volume      = InputField( "Volume", 5.0, u"mL");
duration    = InputField( "Duration", 3.0, u"s");
driver_btn2 = Widgets.button("Drive Pump");
stop_btn    = Widgets.button("Stop Pump");

map!( x -> drive_physical( mcu, c.steps_and_disps[], units, volume, duration ), drive_status, driver_btn2)

driverbox   = vbox( units.field, volume.field, duration.field,
                    hbox(driver_btn2, stop_btn) );
tabbed      = Widgets.tabulator(Observable( Dict( "Calibrate" => calibrationbox, "Driver" => driverbox ) ));

w = Window(); body!(w, tabbed)

println("fin")
