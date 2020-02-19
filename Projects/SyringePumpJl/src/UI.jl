struct InputField
    label::String
    μ::Widget
    units::Union{Unitful.FreeUnits, Nothing}
    field::Node
    dumby::Bool
end

"""
    InputField( label::String, μ::Float64, units::Union{ Unitful.FreeUnits,Nothing })

Creates a labelled textbox input field in Blink.

"""
function InputField( label::String, μ::Float64, units::Union{ Unitful.FreeUnits,Nothing })
    mu = Widgets.textbox(; value = string( μ ) )
    if !isa(units, Nothing)
        units_str = string(units)
        field = Interact.hbox( label * " ($(units_str)): ", mu )
    else
        field = Interact.hbox( label * ":", mu )
    end
    return InputField( label, mu, units, field, true )
end

"""
    value(uif::InputField)

Retrieves a numeric value from a labelled textbox InputField.

"""
function value(uif::InputField)
    if isa(uif.units, Nothing)
        return parse(Float64, uif.μ[] )
    else
        type = string( typeof( uif.units ).parameters[1][1] )
        return uparse(uif.μ[] * type )
    end
end

struct UncertainInputField
    label::String
    μ::Widget
    σ::Widget
    units::Unitful.FreeUnits
    field::Node
end

"""
    UncertainInputField( label::String, μ::Float64, σ::Float64, units::Unitful.FreeUnits)

Creates a labelled textbox input field with an uncertainty textbox in Blink.

"""
function UncertainInputField( label::String, μ::Float64, σ::Float64, units::Unitful.FreeUnits)
    ( σ > μ ) && @warn("Uncertainty greater then value. Are you sure you understand the parameters?")
    mu = Widgets.textbox(; value = string( μ ) )
    sigma = Widgets.textbox(; value = string( σ ) )
    units_str = string(units)
    field = Interact.hbox( label * " ($(units_str)): ", mu, " ± ", sigma  )
    return UncertainInputField( label, mu, sigma, units, field )
end

(uif::UncertainInputField)() = uif.field

"""
    value(uif::UncertainInputField)

Retrieves a numeric value with uncertainty from a labelled textbox UncertainInputField.

"""
function value(uif::UncertainInputField)
    type = string( typeof( uif.units ).parameters[1][1] )
    return uparse(uif.μ[] * type ) ± uparse(uif.σ[] * type )
end

mutable struct CalibrationData
    steps::Vector{Float64}
    displacement::Vector{Float64}
    disp_uncertainty::Vector{Float64}
    beta::Float64
    beta_uncertainty::Float64
end

function (cd::CalibrationData)(step, disp, disp_u)
    push!(cd.steps, step)
    push!(cd.displacement, disp)
    push!(cd.disp_uncertainty, disp_u)
    if length(cd.steps) > 1
        disp        = cd.displacement .± cd.disp_uncertainty
        steps       = cumsum( cd.steps )
        b           = inv(disp'*disp)*disp'*steps
        cd.beta = b.val
        cd.beta_uncertainty = b.err
    end
    return cd
end

struct Calibration
    steps_and_disps::Observable
    widget::Node
end

function Calibration( units::String )
    units_str = units

    steps = Widgets.textbox()
    addbtn = Widgets.button("Add")
    stepsentry = hbox( "Steps(#): ", steps )

    disp = Widgets.textbox()
    unc_disp = Widgets.textbox()
    dispentry = hbox( "Displacement($units_str): ", disp, " ± ", unc_disp )

    calib_data = Observable( CalibrationData(Vector{Float64}(undef,0), Vector{Float64}(undef,0),
                                             Vector{Float64}(undef,0), 0.0, 0.0) )

    map!( x -> calib_data[]( parse(Float64, steps[]), parse(Float64, disp[]),
                             parse(Float64, unc_disp[]) ),
                             calib_data, addbtn )

    return Calibration( calib_data, Interact.vbox( stepsentry, dispentry, addbtn ) )
end

cumdiff( a ) = [ 0; -cumsum( reverse( diff( reverse( a ) ) ) ) ]

function makeplot(calib_data)
    disp        = calib_data.displacement .± calib_data.disp_uncertainty
    steps       = cumsum( calib_data.steps )
    retplot     = scatter(  steps, map(x -> x.val, disp), legend = :topleft,
                            yerr = map(x -> x.err, disp), label  = "Calibration",
                            xlabel = "Steps (#)", ylabel = "Displacement (mm)")
    retplot     = Plots.abline!(retplot, 1.0/calib_data.beta, 0.0,
                                line=:dash, color = :red, label = "Trendline")
    return retplot
end

"""
    launch_pump_interface(com_port::String; baud_rate::Int64 = 9600)

Launches a Blink/Electron WebUI for calibrating and driving the pump.

"""
function launch_pump_interface(com_port::String; baud_rate::Int64 = 9600)
    mcu = nothing
    try
        mcu = open( "/dev/ttyACM0", baud_rate )
    catch
        @error("Failed to establish COM connection at: $com_port.")
    end

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
    return w
end
