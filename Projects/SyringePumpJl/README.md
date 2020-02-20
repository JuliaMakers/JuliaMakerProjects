# SyringePumpJl
![topview](https://github.com/JuliaMakers/JuliaMakerProjects/tree/master/Projects/SyringePumpJl/Images/TopView.jpg)
![sideview](https://github.com/JuliaMakers/JuliaMakerProjects/tree/master/Projects/SyringePumpJl/Images/SideView.jpg)
SyringePumpJl is a Julia + Arduino + Hardware project. The project provides a crude launch point for making your own syringe pump! Syringe pumps are tools that dispense volumes of liquid, over a specified period of time. They can be highly accurate devices if calibrated and constructed properly. Some applications are: chemical/biological experiments, aquariums, medicine, etc. The downside is that they can cost 500-2,000 USD$! So making your own can be fun, but potentially also practical!

## How do I install it?
To build the Arduino code you will need to copy my modified AFMotor library to your Arduino/Libraries folder.

For running the WebUI and getting the interactivity the following should suffice,
```Julia
using Pkg
Pkg.API.develop(Pkg.PackageSpec(name="SyringePumpJl", path="/home/caseykneale/Desktop/JuliaMakerProjects/Projects/SyringePumpJl"))
using SyringePumpJl
#Launch the Web-UI
launch_pump_interface("/dev/ACM0")
```

## How does Julia play a role?
Julia provides a serial(USB) interface to the Arduino which drives the stepper motor. It also hosts a graphical user interface via [Blink.jl](https://github.com/JuliaGizmos/Blink.jl), which allows for easy calibration/operation. Julia also offers uncertainties in the measurements and the calibration (via [Measurements.jl](https://github.com/JuliaPhysics/Measurements.jl) and easily handles the units involved in the conversions (via [Unitful.jl](https://github.com/timholy/Unitful.jl)). Some images of the GUI are below(note you can interact with the GUI without having an Arduino).

![calibrate](https://github.com/JuliaMakers/JuliaMakerProjects/tree/master/Projects/SyringePumpJl/Images/CalibrateWindow.png)
![drive](https://github.com/JuliaMakers/JuliaMakerProjects/tree/master/Projects/SyringePumpJl/Images/DriverWindow.png)

## Why did you use Julia for this project?
It was really easy to make a GUI, pass data over serial, and handle the math. So the math is all algebra really, but, it handled all uncertainties and physical units for me so it was really easy to prototype. In total it took roughly 4-5 afternoons to design both the hardware and write the code for this. Is it a work of art? definitely not, but I was just hacking away and look I easily made a real thing with a real use case.

## What do you plan to use your project for?
Well once upon a time... Many years ago I concocted an experiment involving a physical effect which may or may not exist. I'd like to think that I could use this someday to test that. But... In reality, I just made it because it was a fun minimal project others could build off of, or build for themselves! Maybe it would help an underfunded lab? Don't know!

# Bill of Materials

### Off the Shelf Components
 - T8 Leed Screw Rod and Nut
 - Shaft Coupler (for Screw Rod to the steper motor)
 - 8mm OD stainless steel rod
 - Stepper motor
 - Arduino Uno R3
 - Arctic Silver + Small Heat Sink for L293d IC!
 - L293D motor shield
 - 12V 1A power supply/cellphone charger
 - Syringe
 - 2 stubby M5 screws and nuts
 - A binder clip/rubber band

### Custom Components
 - 2x 3-D printed parts (see CAD subdirectory)

### Tools Needed
 - Micrometer
 - Screw driver/hex set
 - Razor blade (for removing 3-D printed supports)
 - 2 drops of cyanoacrylate glue(for fixing nuts to 3-D print)
 - Computer (Julia + Arduino IDE + FreeCAD)!

### Estimated cost
50-70 USD$ depending on what you have available.

## What could be improved?
### Software
 - The code is pretty sloppy and somewhat under documented.
 - The propagated uncertainty values could actually change the results.
 - The calibration could be saved/loaded for ease of use.
 - A clean REPL interface/workflow could also be made.

### Physical/Hardware
 - Mass would be a better way to calibrate the pump. But I don't own a scale.
 - Finer pitch leed screw would give better resolution. Anti-backlash nut would also help with hysteresis.
 - The tolerance of the linear guide rails and the plunger carriage could be tighter.
 - A smaller shaft coupler could have been used to give a longer dynamic range.
 - The guide rails could have been cut with a hacksaw to size for aesthetics!
 - The V-block for holding the plunger and the syringe body could be cut deeper, or offer greater support for the syringe. Instead of using a rubber band to hold the plunger to the carriage, a clip, or fastener could be used.
 - A nice enclosure for the Arduino could add some safety features for compliance in a wet-lab, but this is just for fun.

## Could your project benefit from a new Julia package?
Sure. I could foresee packages for spinning up simple UI's, plots/structures for dynamic instructions (imagine an arbitrary function driving the motor). The project lead to a couple git hub issues (found a bug and a missing feature). I'm glad I worked on this it was a lot of fun, and now I have a cool new syringe pump that I can change in anyway I want too!
